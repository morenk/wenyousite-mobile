import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/core/storage/app_database.dart';

abstract interface class EditorSnapshotStore {
  Future<LocalEditorSnapshot?> findThreadSnapshot(String ownerId);

  Future<void> saveThreadSnapshot(LocalEditorSnapshot snapshot);

  Future<void> deleteThreadSnapshot(String ownerId);

  Future<PendingCreateOperation?> findPendingCreate(String clientRequestId);

  Future<void> savePendingCreate(PendingCreateOperation operation);

  Future<void> deletePendingCreate(String clientRequestId);
}

class DatabaseEditorSnapshotStore implements EditorSnapshotStore {
  DatabaseEditorSnapshotStore(this._database);

  static String threadSnapshotId(String ownerId) => 'thread:new:$ownerId';

  final AppDatabase _database;

  @override
  Future<LocalEditorSnapshot?> findThreadSnapshot(String ownerId) {
    return _database.findEditorSnapshot(threadSnapshotId(ownerId));
  }

  @override
  Future<void> saveThreadSnapshot(LocalEditorSnapshot snapshot) {
    return _database.saveEditorSnapshot(snapshot);
  }

  @override
  Future<void> deleteThreadSnapshot(String ownerId) async {
    await _database.deleteEditorSnapshot(threadSnapshotId(ownerId));
  }

  @override
  Future<PendingCreateOperation?> findPendingCreate(String clientRequestId) {
    return _database.findPendingCreateOperation(clientRequestId);
  }

  @override
  Future<void> savePendingCreate(PendingCreateOperation operation) {
    return _database.savePendingCreateOperation(operation);
  }

  @override
  Future<void> deletePendingCreate(String clientRequestId) async {
    await _database.deletePendingCreateOperation(clientRequestId);
  }
}

final editorSnapshotStoreProvider = Provider<EditorSnapshotStore>((ref) {
  return DatabaseEditorSnapshotStore(ref.watch(appDatabaseProvider));
});
