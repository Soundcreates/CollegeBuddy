import 'package:drift/drift.dart';

/// Caches Gmail messages locally.
/// [attachmentsJson] stores the attachments list as a JSON string.
class MailsTable extends Table {
  TextColumn get id => text()();
  TextColumn get threadId => text().withDefault(const Constant(''))();
  TextColumn get subject => text().withDefault(const Constant(''))();
  TextColumn get fromAddr => text().withDefault(const Constant(''))();
  TextColumn get toAddr => text().withDefault(const Constant(''))();
  TextColumn get date => text().withDefault(const Constant(''))();
  TextColumn get snippet => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();
  TextColumn get attachmentsJson => text().withDefault(const Constant('[]'))();
  // serverCreatedAt: the timestamp from the server, used for delta sync ordering.
  DateTimeColumn get serverCreatedAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  String get tableName => 'mails';

  @override
  Set<Column> get primaryKey => {id};
}
