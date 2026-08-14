import 'dart:async';
import 'package:logging/logging.dart';
import 'package:CollegeBuddy/data/datasources/sync_api_client.dart';
import 'package:CollegeBuddy/domain/repositories/i_assignment_repository.dart';
import 'package:CollegeBuddy/domain/repositories/i_course_repository.dart';
import 'package:CollegeBuddy/domain/repositories/i_mail_repository.dart';
import 'package:CollegeBuddy/domain/repositories/i_sync_repository.dart';

enum SyncStatus { idle, syncing, success, failure }

/// Orchestrates stale-while-revalidate syncing:
///
///  1. UI always reads from SQLite (instant).
///  2. On launch, we check if cache is stale.
///  3. If stale, fire a background fetch without blocking the UI.
///  4. When fresh data arrives, upsert into SQLite — reactive streams
///     in the repositories push the new data to the UI automatically.
class SyncService {
  static const Duration _staleThreshold = Duration(hours: 3);
  static const int _maxRetries = 3;
  static final _log = Logger('SyncService');

  final SyncApiClient _api;
  final ISyncRepository _syncRepo;
  final IAssignmentRepository _assignmentRepo;
  final ICourseRepository _courseRepo;
  final IMailRepository _mailRepo;

  // Mutex: prevents concurrent syncs from overlapping.
  bool _isSyncing = false;

  // Exposes sync status to the UI layer.
  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;

  SyncService({
    required SyncApiClient api,
    required ISyncRepository syncRepo,
    required IAssignmentRepository assignmentRepo,
    required ICourseRepository courseRepo,
    required IMailRepository mailRepo,
  })  : _api = api,
        _syncRepo = syncRepo,
        _assignmentRepo = assignmentRepo,
        _courseRepo = courseRepo,
        _mailRepo = mailRepo;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Call on app launch. Returns immediately — sync runs in background if stale.
  Future<void> syncIfStale() async {
    final lastSync = await _syncRepo.getLastSyncTime();
    final isStale =
        lastSync == null || DateTime.now().difference(lastSync) > _staleThreshold;

    if (!isStale) {
      _log.info('Cache is fresh (last sync: $lastSync). Skipping background sync.');
      return;
    }

    _log.info('Cache is stale. Triggering background sync.');
    // unawaited: intentionally non-blocking — the UI shows cached data while
    // this runs in the background. Errors are caught inside _runSync.
    unawaited(_runSync(since: lastSync));
  }

  /// Force a full sync — called on pull-to-refresh.
  Future<void> forceSync() => _runSync(since: null);

  // ── Internal sync logic ───────────────────────────────────────────────────

  Future<void> _runSync({DateTime? since}) async {
    if (_isSyncing) {
      _log.info('Sync already in progress, skipping duplicate request.');
      return;
    }

    _isSyncing = true;
    _statusController.add(SyncStatus.syncing);
    _log.info('Sync started (since: ${since?.toIso8601String() ?? 'full'})');

    try {
      final response = await _fetchWithRetry(since: since);
      await _persist(response);
      await _syncRepo.setLastSyncTime(response.serverTime);
      _statusController.add(SyncStatus.success);
      _log.info(
        'Sync complete — ${response.deadlines.length} deadlines, '
        '${response.announcements.length} announcements, '
        '${response.courses.length} courses.',
      );
    } catch (e, stack) {
      _statusController.add(SyncStatus.failure);
      _log.severe('Sync failed', e, stack);
    } finally {
      _isSyncing = false;
    }
  }

  Future<SyncResponse> _fetchWithRetry({DateTime? since}) async {
    Exception? lastError;

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        return await _api.fetchDelta(since: since);
      } on SyncException catch (e) {
        // 401 / 403 are not retryable — bad token, stop immediately.
        if (e.statusCode == 401 || e.statusCode == 403) rethrow;
        lastError = e;
        _log.warning('Sync attempt $attempt/$_maxRetries failed: $e');
      } catch (e) {
        lastError = Exception(e.toString());
        _log.warning('Sync attempt $attempt/$_maxRetries failed: $e');
      }

      if (attempt < _maxRetries) {
        // Exponential backoff: 2s, 4s, …
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    }

    throw lastError!;
  }

  Future<void> _persist(SyncResponse response) async {
    // Upsert all three collections in parallel; they are independent tables.
    await Future.wait([
      if (response.deadlines.isNotEmpty)
        _assignmentRepo.upsert(response.deadlines),
      if (response.courses.isNotEmpty)
        _courseRepo.upsert(response.courses),
      if (response.announcements.isNotEmpty)
        _mailRepo.upsert(response.announcements),
    ]);
  }

  void dispose() {
    _statusController.close();
  }
}
