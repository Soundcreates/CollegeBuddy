import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/app_state_table.dart';
import 'tables/assignments_table.dart';
import 'tables/courses_table.dart';
import 'tables/mails_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [AppStateTable, CoursesTable, AssignmentsTable, MailsTable],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ── App State ─────────────────────────────────────────────────────────────

  Future<String?> getState(String key) async {
    final row = await (select(appStateTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setState(String key, String value) async {
    await into(appStateTable).insertOnConflictUpdate(
      AppStateTableCompanion.insert(key: key, value: value),
    );
  }

  Future<void> deleteState(String key) async {
    await (delete(appStateTable)..where((t) => t.key.equals(key))).go();
  }

  // ── Courses ───────────────────────────────────────────────────────────────

  Stream<List<CoursesTableData>> watchCourses() => select(coursesTable).watch();

  Future<List<CoursesTableData>> getCourses() => select(coursesTable).get();

  Future<void> upsertCourses(List<CoursesTableCompanion> rows) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(coursesTable, rows);
    });
  }

  // ── Assignments ───────────────────────────────────────────────────────────

  Stream<List<AssignmentsTableData>> watchAssignments() {
    return (select(assignmentsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.dueDate)]))
        .watch();
  }

  Future<List<AssignmentsTableData>> getAssignments() =>
      select(assignmentsTable).get();

  Future<void> upsertAssignments(List<AssignmentsTableCompanion> rows) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(assignmentsTable, rows);
    });
  }

  // ── Mails ─────────────────────────────────────────────────────────────────

  Stream<List<MailsTableData>> watchMails() {
    return (select(mailsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.serverCreatedAt)]))
        .watch();
  }

  Future<List<MailsTableData>> getMails() => select(mailsTable).get();

  Future<void> upsertMails(List<MailsTableCompanion> rows) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(mailsTable, rows);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'college_buddy.sqlite'));
    // NativeDatabase.createInBackground offloads SQLite I/O to an isolate,
    // preventing any jank on the main thread during large writes.
    return NativeDatabase.createInBackground(file);
  });
}
