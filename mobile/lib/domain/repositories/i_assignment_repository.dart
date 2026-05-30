import 'package:mobile/domain/entities/assignment_entity.dart';

abstract interface class IAssignmentRepository {
  /// Reactive stream — emits a new list every time SQLite is updated.
  Stream<List<AssignmentEntity>> watchAll();

  /// One-shot read from SQLite.
  Future<List<AssignmentEntity>> getAll();

  /// Upsert: insert or replace on primary-key conflict.
  Future<void> upsert(List<AssignmentEntity> assignments);
}
