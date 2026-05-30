import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:mobile/data/database/app_database.dart';
import 'package:mobile/domain/entities/assignment_entity.dart';
import 'package:mobile/domain/repositories/i_assignment_repository.dart';
import 'package:mobile/models/classroomModel.dart';

class AssignmentRepository implements IAssignmentRepository {
  final AppDatabase _db;

  AssignmentRepository(this._db);

  @override
  Stream<List<AssignmentEntity>> watchAll() {
    return _db.watchAssignments().map(
          (rows) => rows.map(_rowToEntity).toList(),
        );
  }

  @override
  Future<List<AssignmentEntity>> getAll() async {
    final rows = await _db.getAssignments();
    return rows.map(_rowToEntity).toList();
  }

  @override
  Future<void> upsert(List<AssignmentEntity> assignments) async {
    final companions = assignments.map(_entityToCompanion).toList();
    await _db.upsertAssignments(companions);
  }

  // ── Mapper: DB row → domain entity ────────────────────────────────────────

  AssignmentEntity _rowToEntity(AssignmentsTableData row) {
    List<MaterialModel> materials = [];
    try {
      final raw = jsonDecode(row.materialsJson) as List;
      materials = raw
          .map((e) => MaterialModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {}

    return AssignmentEntity(
      id: row.id,
      title: row.title,
      description: row.description,
      state: row.state,
      dueDate: row.dueDate,
      creationTime: row.creationTime,
      updateTime: row.updateTime,
      maxPoints: row.maxPoints,
      workType: row.workType,
      alternateLink: row.alternateLink,
      courseId: row.courseId,
      courseName: row.courseName,
      materials: materials,
      cachedAt: row.cachedAt,
    );
  }

  // ── Mapper: domain entity → DB companion ──────────────────────────────────

  AssignmentsTableCompanion _entityToCompanion(AssignmentEntity e) {
    return AssignmentsTableCompanion(
      id: Value(e.id),
      title: Value(e.title),
      description: Value(e.description),
      state: Value(e.state),
      dueDate: Value(e.dueDate),
      creationTime: Value(e.creationTime),
      updateTime: Value(e.updateTime),
      maxPoints: Value(e.maxPoints),
      workType: Value(e.workType),
      alternateLink: Value(e.alternateLink),
      courseId: Value(e.courseId),
      courseName: Value(e.courseName),
      materialsJson: Value(
        jsonEncode(e.materials.map((m) => m.toJson()).toList()),
      ),
      cachedAt: Value(e.cachedAt),
    );
  }
}
