import 'package:CollegeBuddy/data/database/app_database.dart';
import 'package:CollegeBuddy/domain/repositories/i_sync_repository.dart';

class SyncRepository implements ISyncRepository {
  static const _kLastSyncKey = 'last_sync_time';

  final AppDatabase _db;

  SyncRepository(this._db);

  @override
  Future<DateTime?> getLastSyncTime() async {
    final raw = await _db.getState(_kLastSyncKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<void> setLastSyncTime(DateTime time) async {
    await _db.setState(_kLastSyncKey, time.toUtc().toIso8601String());
  }

  @override
  Future<void> clearLastSyncTime() async {
    await _db.deleteState(_kLastSyncKey);
  }
}
