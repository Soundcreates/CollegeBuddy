/// Manages the last_sync_time key in SQLite's app_state table.
abstract interface class ISyncRepository {
  Future<DateTime?> getLastSyncTime();
  Future<void> setLastSyncTime(DateTime time);
  Future<void> clearLastSyncTime();
}
