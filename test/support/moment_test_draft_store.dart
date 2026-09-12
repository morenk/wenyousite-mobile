import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';

class MemoryMomentDraftStore implements MomentDraftStore {
  MomentLocalDraft? draft;

  @override
  Future<void> delete(String ownerId, String? momentId) async => draft = null;

  @override
  Future<MomentLocalDraft?> read(String ownerId, String? momentId) async =>
      draft;

  @override
  Future<void> write(
    String ownerId,
    String? momentId,
    MomentLocalDraft value,
  ) async {
    draft = value;
  }

  @override
  Future<void> beginCreate(
    String ownerId,
    MomentLocalDraft value,
    PendingCreateOperation operation,
  ) async {
    draft = value.withPersistence(
      operation.clientRequestId,
      pending: operation,
    );
  }

  @override
  Future<void> finishCreate(
    String ownerId,
    String requestId, {
    required bool discardDraft,
  }) async {
    draft = discardDraft ? null : draft?.withPersistence(requestId);
  }
}
