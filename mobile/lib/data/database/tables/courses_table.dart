import 'package:drift/drift.dart';

class CoursesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get section => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get room => text().withDefault(const Constant(''))();
  TextColumn get enrollCode => text().withDefault(const Constant(''))();
  TextColumn get state => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  String get tableName => 'courses';

  @override
  Set<Column> get primaryKey => {id};
}
