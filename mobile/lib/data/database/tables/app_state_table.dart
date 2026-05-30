import 'package:drift/drift.dart';

/// Key-value store for persistent app state (e.g. last_sync_time).
class AppStateTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  String get tableName => 'app_state';

  @override
  Set<Column> get primaryKey => {key};
}
