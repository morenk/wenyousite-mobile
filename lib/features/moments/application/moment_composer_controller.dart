import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

typedef MomentComposerRequestIdFactory = String Function();

enum MomentComposerPhase { loading, editing, submitting, succeeded, failed }

class MomentComposerState {
  const MomentComposerState({
    this.phase = MomentComposerPhase.loading,
    this.initialDetail,
    this.savedDetail,
    this.failure,
    this.localDraft,
    this.pendingCreate,
  });

  final MomentComposerPhase phase;
  final MomentDetail? initialDetail;
  final MomentDetail? savedDetail;
  final ApiFailure? failure;
  final MomentLocalDraft? localDraft;
  final PendingCreateOperation? pendingCreate;

  bool get isSubmitting => phase == MomentComposerPhase.submitting;
  bool get awaitingConfirmation => pendingCreate != null;
  bool get canEditContent =>
      phase == MomentComposerPhase.editing && !awaitingConfirmation;
}

class MomentComposerController extends StateNotifier<MomentComposerState> {
  MomentComposerController(
    this._repository, {
    required this.draftStore,
    required this.resolveOwner,
    this.momentId,
    bool autoStart = true,
    MomentComposerRequestIdFactory? requestIdFactory,
  }) : _requestIdFactory = requestIdFactory ?? const Uuid().v4,
       _createRequestId = (requestIdFactory ?? const Uuid().v4)(),
       super(const MomentComposerState()) {
    if (autoStart) unawaited(load());
  }

  final MomentRepository _repository;
  final MomentDraftStore draftStore;
  final MomentComposerOwnerResolver resolveOwner;
  final String? momentId;
  final MomentComposerRequestIdFactory _requestIdFactory;
  String _createRequestId;
  String? _ownerId;
  PendingCreateOperation? _pendingCreate;
  MomentLocalDraft? _submissionDraft;
  MomentDetail? _confirmedResult;
  Future<void> _saveQueue = Future.value();
  int _loadEpoch = 0;

  Future<void> load() async {
    if (!mounted || state.isSubmitting) return;
    final epoch = ++_loadEpoch;
    state = const MomentComposerState();
    try {
      final ownerId = await resolveOwner();
      if (!mounted || epoch != _loadEpoch) return;
      if (ownerId.trim().isEmpty) {
        throw const FormatException('Missing moment owner.');
      }
      _ownerId = ownerId;
      final draft = await draftStore.read(ownerId, momentId);
      if (!mounted || epoch != _loadEpoch) return;
      final detail = momentId == null
          ? null
          : await _repository.fetchDetail(momentId!);
      if (!mounted || epoch != _loadEpoch) return;
      if (detail != null && !detail.canEdit) {
        state = const MomentComposerState(
          phase: MomentComposerPhase.failed,
          failure: ApiFailure(userMessage: '当前账号不能编辑这条动态。'),
        );
        return;
      }
      _createRequestId = draft?.clientRequestId ?? _createRequestId;
      _pendingCreate = draft?.pendingCreate;
      _submissionDraft = draft?.pendingCreate == null ? null : draft;
      if (_pendingCreate != null) _pendingInput();
      state = MomentComposerState(
        phase: MomentComposerPhase.editing,
        initialDetail: detail,
        localDraft: draft,
        pendingCreate: _pendingCreate,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _loadEpoch) return;
      state = MomentComposerState(
        phase: MomentComposerPhase.failed,
        failure: _asFailure(error, '动态加载失败，请稍后重试。'),
      );
    }
  }

  Future<T> _enqueueSave<T>(Future<T> Function() action) {
    final operation = _saveQueue.then((_) => action());
    // Report errors to the caller but allow a later explicit retry.
    _saveQueue = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<bool> saveDraft(MomentLocalDraft draft) {
    final ownerId = _ownerId;
    if (ownerId == null || !mounted || !state.canEditContent) {
      return Future.value(false);
    }
    final snapshot = draft.withPersistence(_createRequestId);
    return _enqueueSave(() async {
      if (!mounted || !state.canEditContent) return false;
      await draftStore.write(ownerId, momentId, snapshot);
      return true;
    });
  }

  Future<bool> deleteDraft() {
    final ownerId = _ownerId;
    if (ownerId == null ||
        !mounted ||
        state.awaitingConfirmation ||
        state.isSubmitting) {
      return Future.value(false);
    }
    return _enqueueSave(() async {
      if (!mounted || state.awaitingConfirmation || state.isSubmitting) {
        return false;
      }
      await draftStore.delete(ownerId, momentId);
      return true;
    });
  }

  Future<MomentDetail?> submit(
    MomentDraftInput input, {
    MomentLocalDraft? draft,
  }) async {
    final ownerId = _ownerId;
    if (ownerId == null || state.phase != MomentComposerPhase.editing) {
      return null;
    }
    final initial = state.initialDetail;
    state = MomentComposerState(
      phase: MomentComposerPhase.submitting,
      initialDetail: initial,
      pendingCreate: _pendingCreate,
    );
    var sent = false;
    try {
      MomentDetail saved;
      if (momentId == null) {
        if (_pendingCreate == null) {
          final normalized = input.normalized();
          final operation = PendingCreateOperation(
            clientRequestId: _createRequestId,
            operationType: 'moment.create',
            normalizedPayload: jsonEncode({
              'ownerId': ownerId,
              'input': {
                'title': normalized.title,
                'content': normalized.content,
                'mediaIds': normalized.mediaIds,
                'coverMediaId': normalized.coverMediaId,
              },
            }),
            state: PendingOperationState.sending,
            updatedAt: DateTime.now(),
          );
          final snapshot =
              (draft ??
                      MomentLocalDraft(
                        title: normalized.title,
                        content: normalized.content,
                        images: const [],
                        updatedAt: DateTime.now(),
                      ))
                  .withPersistence(operation.clientRequestId);
          await _enqueueSave(
            () => draftStore.beginCreate(ownerId, snapshot, operation),
          );
          if (!mounted) return null;
          _pendingCreate = operation;
          _submissionDraft = snapshot;
        }
        sent = true;
        saved =
            _confirmedResult ??
            await _repository.create(
              _pendingInput(),
              clientRequestId: _pendingCreate!.clientRequestId,
            );
        if (!mounted) return null;
        _confirmedResult = saved;
        await _enqueueSave(
          () => draftStore.finishCreate(
            ownerId,
            _pendingCreate!.clientRequestId,
            discardDraft: true,
          ),
        );
        if (!mounted) return null;
        _pendingCreate = null;
        _submissionDraft = null;
        _confirmedResult = null;
        _createRequestId = _requestIdFactory();
      } else {
        saved = await _repository.update(
          momentId!,
          input,
          version: initial!.version,
        );
      }
      if (!mounted) return null;
      state = MomentComposerState(
        phase: MomentComposerPhase.succeeded,
        initialDetail: saved,
        savedDetail: saved,
      );
      return saved;
    } on Object catch (error) {
      if (!mounted) return null;
      var failure = _asFailure(
        error,
        momentId == null ? '发布失败，请重试。' : '保存失败，请重试。',
      );
      if (sent && _pendingCreate != null) {
        try {
          if (_confirmedResult == null && _definitelyRejected(failure)) {
            await _enqueueSave(
              () => draftStore.finishCreate(
                ownerId,
                _pendingCreate!.clientRequestId,
                discardDraft: false,
              ),
            );
            _pendingCreate = null;
            _submissionDraft = null;
            _createRequestId = _requestIdFactory();
          } else {
            final pending = _pendingCreate!;
            _pendingCreate = PendingCreateOperation(
              clientRequestId: pending.clientRequestId,
              operationType: pending.operationType,
              normalizedPayload: pending.normalizedPayload,
              state: PendingOperationState.awaitingConfirmation,
              updatedAt: DateTime.now(),
            );
            await _enqueueSave(
              () => draftStore.beginCreate(
                ownerId,
                _submissionDraft!,
                _pendingCreate!,
              ),
            );
          }
        } on Object catch (storageError) {
          failure = _asFailure(storageError, '草稿保存失败，请重试。');
        }
      }
      if (!mounted) return null;
      state = MomentComposerState(
        phase: MomentComposerPhase.editing,
        initialDetail: initial,
        failure: failure,
        pendingCreate: _pendingCreate,
      );
      return null;
    }
  }

  bool _definitelyRejected(ApiFailure failure) {
    final code = failure.businessCode;
    if (code == 40912 || failure.hasUnknownWriteOutcome) return false;
    return code != null && code >= 40000 && code < 50000;
  }

  MomentDraftInput _pendingInput() {
    final envelope =
        jsonDecode(_pendingCreate!.normalizedPayload) as Map<String, dynamic>;
    if (envelope['ownerId'] != _ownerId) {
      throw const FormatException('Invalid moment operation owner.');
    }
    final value = envelope['input'] as Map<String, dynamic>;
    return MomentDraftInput(
      title: value['title'] as String,
      content: value['content'] as String,
      mediaIds: (value['mediaIds'] as List).cast<String>(),
      coverMediaId: value['coverMediaId'] as String?,
    ).normalized();
  }

  Future<MomentDetail?> resubmitAfterConflict(MomentDraftInput input) async {
    final id = momentId;
    if (id == null || state.isSubmitting) return null;
    final initial = state.initialDetail;
    state = MomentComposerState(
      phase: MomentComposerPhase.submitting,
      initialDetail: initial,
    );
    try {
      final latest = await _repository.fetchDetail(id);
      if (!mounted) return null;
      if (!latest.canEdit) {
        state = MomentComposerState(
          phase: MomentComposerPhase.editing,
          initialDetail: initial,
          failure: const ApiFailure(userMessage: '当前账号不能编辑这条动态。'),
        );
        return null;
      }
      final saved = await _repository.update(
        id,
        input,
        version: latest.version,
      );
      if (!mounted) return null;
      state = MomentComposerState(
        phase: MomentComposerPhase.succeeded,
        initialDetail: saved,
        savedDetail: saved,
      );
      return saved;
    } on Object catch (error) {
      if (!mounted) return null;
      state = MomentComposerState(
        phase: MomentComposerPhase.editing,
        initialDetail: initial,
        failure: _asFailure(error, '保存失败，请重试。'),
      );
      return null;
    }
  }

  Future<bool> remove() async {
    final id = momentId;
    if (id == null || state.isSubmitting) return false;
    final initial = state.initialDetail;
    state = MomentComposerState(
      phase: MomentComposerPhase.submitting,
      initialDetail: initial,
    );
    try {
      await _repository.remove(id);
      if (!mounted) return false;
      state = MomentComposerState(
        phase: MomentComposerPhase.succeeded,
        initialDetail: initial,
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = MomentComposerState(
        phase: MomentComposerPhase.editing,
        initialDetail: initial,
        failure: _asFailure(error, '删除失败，请重试。'),
      );
      return false;
    }
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

final momentComposerControllerProvider = StateNotifierProvider.autoDispose
    .family<MomentComposerController, MomentComposerState, String?>(
      (ref, momentId) {
        final scope = ref.watch(sessionScopeProvider);
        final resolver = ref.watch(momentComposerOwnerResolverProvider);
        return MomentComposerController(
          ref.watch(momentRepositoryProvider),
          momentId: momentId,
          draftStore: ref.watch(momentDraftStoreProvider),
          resolveOwner: () => scope.accountId == null
              ? resolver()
              : Future.value(scope.accountId!),
        );
      },
      dependencies: [
        momentRepositoryProvider,
        momentDraftStoreProvider,
        momentComposerOwnerResolverProvider,
        sessionScopeProvider,
      ],
    );
