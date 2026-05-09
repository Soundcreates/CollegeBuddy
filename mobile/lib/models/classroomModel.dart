/// Models for Google Classroom data — courses, assignments, and materials.

class CourseModel {
  final String id;
  final String name;
  final String section;
  final String description;
  final String room;
  final String enrollCode;
  final String state;

  CourseModel({
    required this.id,
    required this.name,
    this.section = '',
    this.description = '',
    this.room = '',
    this.enrollCode = '',
    this.state = '',
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      section: (json['section'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      room: (json['room'] ?? '').toString(),
      enrollCode: (json['enroll_code'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
    );
  }
}

class MaterialModel {
  final String title;
  final String url;
  final String type; // driveFile, link, youtubeVideo, form
  final String thumbnailUrl;

  MaterialModel({
    required this.title,
    required this.url,
    required this.type,
    this.thumbnailUrl = '',
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      title: (json['title'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      thumbnailUrl: (json['thumbnail_url'] ?? '').toString(),
    );
  }

  bool get isDriveFile => type == 'driveFile';
  bool get isLink => type == 'link';
  bool get isYoutubeVideo => type == 'youtubeVideo';
  bool get isForm => type == 'form';
}

class AssignmentModel {
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
  final List<MaterialModel> materials;

  // These are set when fetching all assignments globally
  String courseName;
  String courseId;

  AssignmentModel({
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
    this.materials = const [],
    this.courseName = '',
    this.courseId = '',
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    final materialsRaw = json['materials'] as List? ?? [];
    return AssignmentModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      dueDate: (json['due_date'] ?? '').toString(),
      creationTime: (json['creation_time'] ?? '').toString(),
      updateTime: (json['update_time'] ?? '').toString(),
      maxPoints: (json['max_points'] ?? 0).toDouble(),
      workType: (json['work_type'] ?? '').toString(),
      alternateLink: (json['alternate_link'] ?? '').toString(),
      materials: materialsRaw
          .map((m) => MaterialModel.fromJson(Map<String, dynamic>.from(m as Map)))
          .toList(),
    );
  }

  /// Parse from the global assignments endpoint which wraps assignment inside course context
  factory AssignmentModel.fromGlobalJson(Map<String, dynamic> json) {
    final assignmentData = json['assignment'] as Map<String, dynamic>? ?? {};
    final model = AssignmentModel.fromJson(assignmentData);
    model.courseName = (json['course_name'] ?? '').toString();
    model.courseId = (json['course_id'] ?? '').toString();
    return model;
  }

  bool get hasDueDate => dueDate.isNotEmpty;

  /// Check if this assignment has any PDF-like materials
  bool get hasPdfMaterial =>
      materials.any((m) => m.isDriveFile);

  /// Get the first Drive file material URL (usually the assignment template)
  String? get firstDriveFileUrl {
    final mat = materials.where((m) => m.isDriveFile).firstOrNull;
    return mat?.url;
  }
}

/// AI help response model
class AIHelpSection {
  final String header;
  final List<String> points;

  AIHelpSection({required this.header, required this.points});

  factory AIHelpSection.fromJson(Map<String, dynamic> json) {
    return AIHelpSection(
      header: (json['header'] ?? '').toString(),
      points: (json['points'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class AIHelpResponse {
  final bool success;
  final String rawMarkdown;
  final List<AIHelpSection> sections;
  final String error;

  AIHelpResponse({
    required this.success,
    this.rawMarkdown = '',
    this.sections = const [],
    this.error = '',
  });

  factory AIHelpResponse.fromJson(Map<String, dynamic> json) {
    final sectionsRaw = json['sections'] as List? ?? [];
    return AIHelpResponse(
      success: json['success'] ?? false,
      rawMarkdown: (json['raw_markdown'] ?? '').toString(),
      sections: sectionsRaw
          .map((s) => AIHelpSection.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList(),
      error: (json['error'] ?? '').toString(),
    );
  }
}
