import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/data/database/app_database.dart';
import 'package:mobile/data/datasources/sync_api_client.dart';
import 'package:mobile/data/repositories/assignment_repository.dart';
import 'package:mobile/data/repositories/course_repository.dart';
import 'package:mobile/data/repositories/mail_repository.dart';
import 'package:mobile/data/repositories/sync_repository.dart';
import 'package:mobile/domain/entities/assignment_entity.dart';
import 'package:mobile/domain/entities/course_entity.dart';
import 'package:mobile/domain/entities/mail_entity.dart';
import 'package:mobile/services/sync_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

/// Single Drift database instance for the app lifetime.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// ── Remote ────────────────────────────────────────────────────────────────────

final syncApiClientProvider = Provider<SyncApiClient>((ref) {
  final baseUrl = dotenv.env['API_URL'] ?? 'https://kisha-volcanologic-motherly.ngrok-free.dev';
  return SyncApiClient(
    baseUrl: baseUrl,
    storage: ref.watch(secureStorageProvider),
  );
});

// ── Repositories ──────────────────────────────────────────────────────────────

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  return AssignmentRepository(ref.watch(appDatabaseProvider));
});

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository(ref.watch(appDatabaseProvider));
});

final mailRepositoryProvider = Provider<MailRepository>((ref) {
  return MailRepository(ref.watch(appDatabaseProvider));
});

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository(ref.watch(appDatabaseProvider));
});

// ── SyncService ───────────────────────────────────────────────────────────────

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    api: ref.watch(syncApiClientProvider),
    syncRepo: ref.watch(syncRepositoryProvider),
    assignmentRepo: ref.watch(assignmentRepositoryProvider),
    courseRepo: ref.watch(courseRepositoryProvider),
    mailRepo: ref.watch(mailRepositoryProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Exposes the live sync status (idle/syncing/success/failure).
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return ref.watch(syncServiceProvider).statusStream;
});

// ── Data streams (UI reads these — never the API) ─────────────────────────────

/// Reactive stream of all assignments from SQLite.
/// Emits a new list every time an upsert happens.
final assignmentsProvider = StreamProvider<List<AssignmentEntity>>((ref) {
  return ref.watch(assignmentRepositoryProvider).watchAll();
});

/// Assignments that have a due date, sorted by due date ascending.
final upcomingDeadlinesProvider = Provider<AsyncValue<List<AssignmentEntity>>>((ref) {
  final all = ref.watch(assignmentsProvider);
  return all.whenData(
    (list) => list
        .where((a) => a.hasDueDate && a.state != 'TURNED_IN')
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate)),
  );
});

final coursesProvider = StreamProvider<List<CourseEntity>>((ref) {
  return ref.watch(courseRepositoryProvider).watchAll();
});

final mailsProvider = StreamProvider<List<MailEntity>>((ref) {
  return ref.watch(mailRepositoryProvider).watchAll();
});
