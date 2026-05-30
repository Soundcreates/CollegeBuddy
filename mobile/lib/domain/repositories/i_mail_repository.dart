import 'package:mobile/domain/entities/mail_entity.dart';

abstract interface class IMailRepository {
  Stream<List<MailEntity>> watchAll();
  Future<List<MailEntity>> getAll();
  Future<void> upsert(List<MailEntity> mails);
}
