import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/core/storage/app_database.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';

export 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart'
    show MomentDraftStore, MomentLocalDraft, momentDraftStoreProvider;

class DatabaseMomentDraftStore implements MomentDraftStore {
  DatabaseMomentDraftStore(this._database);
  final AppDatabase _database;

  String _key(String ownerId, String? momentId) {
    if (ownerId.trim().isEmpty) throw ArgumentError.value(ownerId, 'ownerId');
    return 'moment:${jsonEncode([ownerId, momentId])}';
  }

  @override
  Future<MomentLocalDraft?> read(String ownerId, String? momentId) =>
      _database.transaction(() => _read(ownerId, momentId));

  Future<MomentLocalDraft?> _read(String ownerId, String? momentId) async {
    final row = await _database.findEditorSnapshot(_key(ownerId, momentId));
    if (row == null) return null;
    final metadata = jsonDecode(row.metadataJson);
    if (row.contextType != EditorContextType.moment ||
        row.contextId != momentId ||
        metadata is! Map<String, dynamic> ||
        metadata['version'] != 1 ||
        metadata['ownerId'] != ownerId ||
        metadata['draft'] is! Map<String, dynamic>) {
      throw const FormatException('Invalid account-owned moment snapshot.');
    }
    final draft = MomentLocalDraft.fromJson({
      ...metadata['draft'] as Map<String, dynamic>,
      'content': row.body,
    });
    if (draft == null) throw const FormatException('Invalid moment draft.');
    final pending = await _database.findPendingCreateOperation(
      row.clientRequestId,
    );
    if (pending != null) {
      final payload = jsonDecode(pending.normalizedPayload);
      if (momentId != null ||
          pending.operationType != 'moment.create' ||
          payload is! Map<String, dynamic> ||
          payload['ownerId'] != ownerId) {
        throw const FormatException('Invalid moment operation ownership.');
      }
    }
    return draft.withPersistence(row.clientRequestId, pending: pending);
  }

  @override
  Future<void> write(
    String ownerId,
    String? momentId,
    MomentLocalDraft draft,
  ) => _database.transaction(() async {
    final existing = await _read(ownerId, momentId);
    // A delayed ordinary save cannot replace a frozen pending submission.
    if (existing?.pendingCreate != null) return;
    await _saveSnapshot(
      ownerId,
      momentId,
      draft,
      draft.clientRequestId ?? existing?.clientRequestId ?? const Uuid().v4(),
    );
  });

  Future<void> _saveSnapshot(
    String ownerId,
    String? momentId,
    MomentLocalDraft draft,
    String requestId,
  ) {
    final metadata = draft.toJson()..remove('content');
    return _database.saveEditorSnapshot(
      LocalEditorSnapshot(
        id: _key(ownerId, momentId),
        contextType: EditorContextType.moment,
        contextId: momentId,
        body: draft.content,
        metadataJson: jsonEncode({
          'version': 1,
          'ownerId': ownerId,
          'draft': metadata,
        }),
        clientRequestId: requestId,
        updatedAt: draft.updatedAt,
      ),
    );
  }

  @override
  Future<void> delete(String ownerId, String? momentId) =>
      _database.transaction(() async {
        final existing = await _read(ownerId, momentId);
        if (existing?.pendingCreate != null) {
          throw StateError(
            'Pending publication must be reconciled before discard.',
          );
        }
        await _database.deleteEditorSnapshot(_key(ownerId, momentId));
      });

  @override
  Future<void> beginCreate(
    String ownerId,
    MomentLocalDraft draft,
    PendingCreateOperation operation,
  ) => _database.transaction(() async {
    final payload = jsonDecode(operation.normalizedPayload);
    if (operation.operationType != 'moment.create' ||
        payload is! Map<String, dynamic> ||
        payload['ownerId'] != ownerId) {
      throw const FormatException('Invalid moment operation ownership.');
    }
    final existing = await _read(ownerId, null);
    final previous = existing?.pendingCreate;
    if (previous != null &&
        (previous.clientRequestId != operation.clientRequestId ||
            previous.normalizedPayload != operation.normalizedPayload)) {
      throw StateError('Cannot replace an unconfirmed moment operation.');
    }
    await _saveSnapshot(
      ownerId,
      null,
      previous == null ? draft : existing!,
      operation.clientRequestId,
    );
    await _database.savePendingCreateOperation(operation);
  });

  @override
  Future<void> finishCreate(
    String ownerId,
    String requestId, {
    required bool discardDraft,
  }) => _database.transaction(() async {
    final existing = await _read(ownerId, null);
    if (existing == null) return;
    if (existing.clientRequestId != requestId) {
      throw StateError('Cannot clear another moment operation.');
    }
    await _database.deletePendingCreateOperation(requestId);
    if (discardDraft) {
      await _database.deleteEditorSnapshot(_key(ownerId, null));
    } else {
      await _saveSnapshot(ownerId, null, existing, const Uuid().v4());
    }
  });
}

final databaseMomentDraftStoreProvider = Provider<MomentDraftStore>(
  (ref) => DatabaseMomentDraftStore(ref.watch(appDatabaseProvider)),
);
