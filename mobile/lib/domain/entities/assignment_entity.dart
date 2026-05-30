import 'package:mobile/models/classroomModel.dart';

class AssignmentEntity {
  final String id;
  final String title;
  final String description;
  final String state;
  final String dueDate;
  final String creationTime;
  final String updateTime;
  final double maxPoints;
  final String workType;
  final String alternateLink;
  final String courseId;
  final String courseName;
  final List<MaterialModel> materials;
  final DateTime cachedAt;

  const AssignmentEntity({
    required this.id,
    required this.title,
    this.description = '',
    this.state = '',
    this.dueDate = '',
    this.creationTime = '',
    this.updateTime = '',
    this.maxPoints = 0,
    this.workType = '',
    this.alternateLink = '',
    this.courseId = '',
    this.courseName = '',
    this.materials = const [],
    required this.cachedAt,
  });

  bool get hasDueDate => dueDate.isNotEmpty;
}
