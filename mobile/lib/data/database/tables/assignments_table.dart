import 'package:drift/drift.dart';

/// Caches Google Classroom assignments locally.
/// [materialsJson] stores the materials list as a JSON string to avoid
/// a separate join table for a small, read-only nested collection.
class AssignmentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get state => text().withDefault(const Constant(''))();
  TextColumn get dueDate => text().withDefault(const Constant(''))();
  TextColumn get creationTime => text().withDefault(const Constant(''))();
  // updateTime comes from Google Classroom — used as change-detection key for delta sync.
  TextColumn get updateTime => text().withDefault(const Constant(''))();
  RealColumn get maxPoints => real().withDefault(const Constant(0))();
  TextColumn get workType => text().withDefault(const Constant(''))();
  TextColumn get alternateLink => text().withDefault(const Constant(''))();
  TextColumn get courseId => text().withDefault(const Constant(''))();
  TextColumn get courseName => text().withDefault(const Constant(''))();
  TextColumn get materialsJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  String get tableName => 'assignments';

  @override
  Set<Column> get primaryKey => {id};
}
