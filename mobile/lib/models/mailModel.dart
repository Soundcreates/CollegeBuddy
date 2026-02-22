class MailModel {
  final String id;
  final String subject;
  final String from;
  final String to;
  final String date;
  final String snippet;
  final String body;
  final List<AttachmentModel> attachments;

  MailModel({
    required this.id,
    required this.subject,
    required this.from,
    required this.to,
    required this.date,
    required this.snippet,
    required this.body,
    required this.attachments,
  });

  factory MailModel.fromJson(Map<String, dynamic> json) {
    return MailModel(
      id: json["id"] ?? '',
      subject: json["subject"] ?? '',
      from: json["from"] ?? '',
      to: json["to"] ?? '',
      date: json["date"] ?? '',
      snippet: json["snippet"] ?? '',
      body: json["body"] ?? '',
      attachments: (json["attachments"] as List?)?.map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}

class AttachmentModel {
  final String filename;
  final String mimeType;
  final String attachmentId;

  AttachmentModel({
    required this.filename,
    required this.mimeType,
    required this.attachmentId,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      filename: json["filename"] ?? '',
      mimeType: json["mimeType"] ?? '',
      attachmentId: json["attachmentId"] ?? '',
    );
  }
}
