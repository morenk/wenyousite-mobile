import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/core/storage/app_database.dart';
import 'package:wenyousite_mobile/features/editor/application/editor_snapshot_store_ports.dart';

export 'package:wenyousite_mobile/features/editor/application/editor_snapshot_store_ports.dart'
    show
        EditorSnapshotStore,
        editorSnapshotStoreProvider,
        threadEditorSnapshotId;

class DatabaseEditorSnapshotStore implements EditorSnapshotStore {
  DatabaseEditorSnapshotStore(this._database);

  static String threadSnapshotId(String ownerId) =>
      threadEditorSnapshotId(ownerId);

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

final databaseEditorSnapshotStoreProvider = Provider<EditorSnapshotStore>((
  ref,
) {
  return DatabaseEditorSnapshotStore(ref.watch(appDatabaseProvider));
});
