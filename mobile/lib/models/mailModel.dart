class MailModel {
  final String id;
  final String subject;
  final String from;
  final String to;
  final String date;
  final String snippet;
  final String body;

  MailModel({
    required this.id,
    required this.subject,
    required this.from,
    required this.to,
    required this.date,
    required this.snippet,
    required this.body,
  });

  factory MailModel.fromJson(Map<String, dynamic> json) {
    return MailModel(
      id: json["ID"] ?? '',
      subject: json["Subject"] ?? '',
      from: json["From"] ?? '',
      to: json["To"] ?? '',
      date: json["Date"] ?? '',
      snippet: json["Snippet"] ?? '',
      body: json["Body"] ?? '',
    );
  }
}
