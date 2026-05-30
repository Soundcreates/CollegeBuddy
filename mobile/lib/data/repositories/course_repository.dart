import 'package:drift/drift.dart';
import 'package:mobile/data/database/app_database.dart';
import 'package:mobile/domain/entities/course_entity.dart';
import 'package:mobile/domain/repositories/i_course_repository.dart';

class CourseRepository implements ICourseRepository {
  final AppDatabase _db;

  CourseRepository(this._db);

  @override
  Stream<List<CourseEntity>> watchAll() {
    return _db.watchCourses().map((rows) => rows.map(_rowToEntity).toList());
  }

  @override
  Future<List<CourseEntity>> getAll() async {
    final rows = await _db.getCourses();
    return rows.map(_rowToEntity).toList();
  }

  @override
  Future<void> upsert(List<CourseEntity> courses) async {
    final companions = courses.map(_entityToCompanion).toList();
    await _db.upsertCourses(companions);
  }

  CourseEntity _rowToEntity(CoursesTableData row) {
    return CourseEntity(
      id: row.id,
      name: row.name,
      section: row.section,
      description: row.description,
      room: row.room,
      enrollCode: row.enrollCode,
      state: row.state,
      updatedAt: row.updatedAt,
    );
  }

  CoursesTableCompanion _entityToCompanion(CourseEntity e) {
    return CoursesTableCompanion(
      id: Value(e.id),
      name: Value(e.name),
      section: Value(e.section),
      description: Value(e.description),
      room: Value(e.room),
      enrollCode: Value(e.enrollCode),
      state: Value(e.state),
      updatedAt: Value(e.updatedAt),
    );
  }
}
