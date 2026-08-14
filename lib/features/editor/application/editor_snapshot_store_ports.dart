import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';

String threadEditorSnapshotId(String ownerId) => 'thread:new:$ownerId';

abstract interface class EditorSnapshotStore {
  Future<LocalEditorSnapshot?> findThreadSnapshot(String ownerId);

  Future<void> saveThreadSnapshot(LocalEditorSnapshot snapshot);

  Future<void> deleteThreadSnapshot(String ownerId);

  Future<PendingCreateOperation?> findPendingCreate(String clientRequestId);

  Future<void> savePendingCreate(PendingCreateOperation operation);

  Future<void> deletePendingCreate(String clientRequestId);
}

final editorSnapshotStoreProvider = Provider<EditorSnapshotStore>((ref) {
  return const _UnboundEditorSnapshotStore();
});

class _UnboundEditorSnapshotStore implements EditorSnapshotStore {
  const _UnboundEditorSnapshotStore();

  @override
  Future<LocalEditorSnapshot?> findThreadSnapshot(String ownerId) {
    return Future.error(_error());
  }

  @override
  Future<void> saveThreadSnapshot(LocalEditorSnapshot snapshot) {
    return Future.error(_error());
  }

  @override
  Future<void> deleteThreadSnapshot(String ownerId) {
    return Future.error(_error());
  }

  @override
  Future<PendingCreateOperation?> findPendingCreate(String clientRequestId) {
    return Future.error(_error());
  }

  @override
  Future<void> savePendingCreate(PendingCreateOperation operation) {
    return Future.error(_error());
  }

  @override
  Future<void> deletePendingCreate(String clientRequestId) {
    return Future.error(_error());
  }
}

StateError _error() => StateError('编辑器本地快照存储尚未在应用组合根绑定。');
