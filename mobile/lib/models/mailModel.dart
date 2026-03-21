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
    final attachmentsJson = (json["attachments"] ?? json["attatchments"]) as List?;

    return MailModel(
      id: json["id"] ?? '',
      subject: json["subject"] ?? '',
      from: json["from"] ?? '',
      to: json["to"] ?? '',
      date: json["date"] ?? '',
      snippet: json["snippet"] ?? '',
      body: json["body"] ?? '',
      attachments: attachmentsJson
              ?.map((e) => AttachmentModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
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
      filename: json["filename"] ?? json["fileName"] ?? '',
      mimeType: json["mimeType"] ?? json["mimetype"] ?? '',
      attachmentId: json["attachmentId"] ?? json["attatchment_id"] ?? json["attachment_id"] ?? '',
    );
  }
}
