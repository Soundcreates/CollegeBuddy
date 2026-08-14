import 'package:CollegeBuddy/domain/entities/course_entity.dart';

abstract interface class ICourseRepository {
  Stream<List<CourseEntity>> watchAll();
  Future<List<CourseEntity>> getAll();
  Future<void> upsert(List<CourseEntity> courses);
}
