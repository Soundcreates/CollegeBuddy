import 'package:mobile/models/mailModel.dart';

class MailEntity {
  final String id;
  final String threadId;
  final String subject;
  final String from;
  final String to;
  final String date;
  final String snippet;
  final String body;
  final List<AttachmentModel> attachments;
  final DateTime serverCreatedAt;
  final DateTime cachedAt;

  const MailEntity({
    required this.id,
    this.threadId = '',
    required this.subject,
    required this.from,
    required this.to,
    required this.date,
    required this.snippet,
    required this.body,
    this.attachments = const [],
    required this.serverCreatedAt,
    required this.cachedAt,
  });
}
