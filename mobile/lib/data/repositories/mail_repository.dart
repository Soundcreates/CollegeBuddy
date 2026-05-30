import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:mobile/data/database/app_database.dart';
import 'package:mobile/domain/entities/mail_entity.dart';
import 'package:mobile/domain/repositories/i_mail_repository.dart';
import 'package:mobile/models/mailModel.dart';

class MailRepository implements IMailRepository {
  final AppDatabase _db;

  MailRepository(this._db);

  @override
  Stream<List<MailEntity>> watchAll() {
    return _db.watchMails().map((rows) => rows.map(_rowToEntity).toList());
  }

  @override
  Future<List<MailEntity>> getAll() async {
    final rows = await _db.getMails();
    return rows.map(_rowToEntity).toList();
  }

  @override
  Future<void> upsert(List<MailEntity> mails) async {
    final companions = mails.map(_entityToCompanion).toList();
    await _db.upsertMails(companions);
  }

  MailEntity _rowToEntity(MailsTableData row) {
    List<AttachmentModel> attachments = [];
    try {
      final raw = jsonDecode(row.attachmentsJson) as List;
      attachments = raw
          .map((e) => AttachmentModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {}

    return MailEntity(
      id: row.id,
      threadId: row.threadId,
      subject: row.subject,
      from: row.fromAddr,
      to: row.toAddr,
      date: row.date,
      snippet: row.snippet,
      body: row.body,
      attachments: attachments,
      serverCreatedAt: row.serverCreatedAt,
      cachedAt: row.cachedAt,
    );
  }

  MailsTableCompanion _entityToCompanion(MailEntity e) {
    return MailsTableCompanion(
      id: Value(e.id),
      threadId: Value(e.threadId),
      subject: Value(e.subject),
      fromAddr: Value(e.from),
      toAddr: Value(e.to),
      date: Value(e.date),
      snippet: Value(e.snippet),
      body: Value(e.body),
      attachmentsJson: Value(
        jsonEncode(e.attachments.map((a) => a.toJson()).toList()),
      ),
      serverCreatedAt: Value(e.serverCreatedAt),
      cachedAt: Value(e.cachedAt),
    );
  }
}
