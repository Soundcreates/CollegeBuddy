class WidgetMailModel {
  final String id;
  final String subject;
  final String from;
  final String date;
  final bool isCompleted;

  WidgetMailModel({
    required this.id,
    required this.subject,
    required this.from,
    required this.date,
    this.isCompleted = false,
  });

  factory WidgetMailModel.fromJson(Map<String, dynamic> json) {
    return WidgetMailModel(
      id: json["id"] ?? '',
      subject: json["subject"] ?? '',
      from: json["from"] ?? '',
      date: json["date"] ?? '',
      isCompleted: json["isCompleted"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "subject": subject,
      "from": from,
      "date": date,
      "isCompleted": isCompleted,
    };
  }

  WidgetMailModel copyWith({
    String? id,
    String? subject,
    String? from,
    String? date,
    bool? isCompleted,
  }) {
    return WidgetMailModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      from: from ?? this.from,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
