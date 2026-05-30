class CourseEntity {
  final String id;
  final String name;
  final String section;
  final String description;
  final String room;
  final String enrollCode;
  final String state;
  final DateTime updatedAt;

  const CourseEntity({
    required this.id,
    required this.name,
    this.section = '',
    this.description = '',
    this.room = '',
    this.enrollCode = '',
    this.state = '',
    required this.updatedAt,
  });
}
