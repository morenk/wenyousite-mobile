import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/editor/editor_persistence.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_compose_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';

enum ThreadComposePhase { loading, ready, failed, published }

enum ThreadComposeAction { openRemoteDraft, saveDraft, publish }

enum LocalSnapshotStatus { idle, saving, saved, failed }

const _unset = Object();

class ThreadComposeState {
  const ThreadComposeState({
    this.phase = ThreadComposePhase.loading,
    this.ownerId,
    this.categories = const [],
    this.bootstrapLoading = false,
    this.title = '',
    this.categorySlug,
    this.visibility = ThreadComposeVisibility.public,
    this.tags = const [],
    this.body = '',
    this.clientRequestId = '',
    this.remoteDraft,
    this.documentRevision = 0,
    this.restoredFromLocal = false,
    this.localSnapshotStatus = LocalSnapshotStatus.idle,
    this.lastLocalSaveAt,
    this.action,
    this.failure,
    this.bootstrapFailure,
    this.actionFailure,
    this.successMessage,
    this.publishedThreadId,
  });

  final ThreadComposePhase phase;
  final String? ownerId;
  final List<ThreadComposeCategory> categories;
  final bool bootstrapLoading;
  final String title;
  final String? categorySlug;
  final ThreadComposeVisibility visibility;
  final List<String> tags;
  final String body;
  final String clientRequestId;
  final ThreadRemoteDraft? remoteDraft;
  final int documentRevision;
  final bool restoredFromLocal;
  final LocalSnapshotStatus localSnapshotStatus;
  final DateTime? lastLocalSaveAt;
  final ThreadComposeAction? action;
  final ApiFailure? failure;
  final ApiFailure? bootstrapFailure;
  final ApiFailure? actionFailure;
  final String? successMessage;
  final String? publishedThreadId;

  bool get isSubmitting => action != null;
  bool get canPublish =>
      phase == ThreadComposePhase.ready &&
      !isSubmitting &&
      !bootstrapLoading &&
      bootstrapFailure == null;

  ThreadComposeState copyWith({
    ThreadComposePhase? phase,
    Object? ownerId = _unset,
    List<ThreadComposeCategory>? categories,
    bool? bootstrapLoading,
    String? title,
    Object? categorySlug = _unset,
    ThreadComposeVisibility? visibility,
    List<String>? tags,
    String? body,
    String? clientRequestId,
    Object? remoteDraft = _unset,
    int? documentRevision,
    bool? restoredFromLocal,
    LocalSnapshotStatus? localSnapshotStatus,
    Object? lastLocalSaveAt = _unset,
    Object? action = _unset,
    Object? failure = _unset,
    Object? bootstrapFailure = _unset,
    Object? actionFailure = _unset,
    Object? successMessage = _unset,
    Object? publishedThreadId = _unset,
  }) {
    return ThreadComposeState(
      phase: phase ?? this.phase,
      ownerId: identical(ownerId, _unset) ? this.ownerId : ownerId as String?,
      categories: categories ?? this.categories,
      bootstrapLoading: bootstrapLoading ?? this.bootstrapLoading,
      title: title ?? this.title,
      categorySlug: identical(categorySlug, _unset)
          ? this.categorySlug
          : categorySlug as String?,
      visibility: visibility ?? this.visibility,
      tags: tags ?? this.tags,
      body: body ?? this.body,
      clientRequestId: clientRequestId ?? this.clientRequestId,
      remoteDraft: identical(remoteDraft, _unset)
          ? this.remoteDraft
          : remoteDraft as ThreadRemoteDraft?,
      documentRevision: documentRevision ?? this.documentRevision,
      restoredFromLocal: restoredFromLocal ?? this.restoredFromLocal,
      localSnapshotStatus: localSnapshotStatus ?? this.localSnapshotStatus,
      lastLocalSaveAt: identical(lastLocalSaveAt, _unset)
          ? this.lastLocalSaveAt
          : lastLocalSaveAt as DateTime?,
      action: identical(action, _unset)
          ? this.action
          : action as ThreadComposeAction?,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      bootstrapFailure: identical(bootstrapFailure, _unset)
          ? this.bootstrapFailure
          : bootstrapFailure as ApiFailure?,
      actionFailure: identical(actionFailure, _unset)
          ? this.actionFailure
          : actionFailure as ApiFailure?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
      publishedThreadId: identical(publishedThreadId, _unset)
          ? this.publishedThreadId
          : publishedThreadId as String?,
    );
  }
}

class ThreadComposeController extends StateNotifier<ThreadComposeState> {
  ThreadComposeController(
    this._repository,
    this._snapshotStore, {
    String? knownOwnerId,
    String Function()? createRequestId,
    DateTime Function()? clock,
    Duration snapshotDebounce = const Duration(milliseconds: 700),
    bool autoStart = true,
  }) : _knownOwnerId = knownOwnerId?.isEmpty == true ? null : knownOwnerId,
       _createRequestId = createRequestId ?? const Uuid().v4,
       _clock = clock ?? DateTime.now,
       _snapshotDebounce = Duration(
         microseconds: snapshotDebounce.inMicroseconds,
       ),
       super(const ThreadComposeState()) {
    if (autoStart) unawaited(load());
  }

  final ThreadComposeRepository _repository;
  final EditorSnapshotStore _snapshotStore;
  final String? _knownOwnerId;
  final String Function() _createRequestId;
  final DateTime Function() _clock;
  final Duration _snapshotDebounce;

  Timer? _snapshotTimer;
  Future<void> _snapshotQueue = Future.value();
  PendingCreateOperation? _pendingCreate;
  int _loadEpoch = 0;
  int _snapshotRevision = 0;

  Future<void> load() async {
    final epoch = ++_loadEpoch;
    _snapshotRevision = 0;
    _snapshotTimer?.cancel();
    state = const ThreadComposeState();
    var ownerId = _knownOwnerId;
    ThreadComposeBootstrap? bootstrap;

    try {
      if (ownerId == null) {
        bootstrap = await _repository.fetchBootstrap();
        ownerId = bootstrap.userId;
      }
      final snapshot = await _snapshotStore.findThreadSnapshot(ownerId);
      if (!_isCurrent(epoch)) return;
      final restored = _restoreSnapshot(ownerId, snapshot);
      state = restored.copyWith(
        phase: ThreadComposePhase.ready,
        ownerId: ownerId,
        bootstrapLoading: false,
        categories: bootstrap?.categories,
      );
      if (snapshot != null) {
        _pendingCreate = await _snapshotStore.findPendingCreate(
          snapshot.clientRequestId,
        );
      }
      if (!_isCurrent(epoch)) return;
      if (bootstrap == null) unawaited(refreshBootstrap());
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return;
      state = ThreadComposeState(
        phase: ThreadComposePhase.failed,
        failure: _asFailure(error, '打开本地创作空间失败，请重试。'),
      );
    }
  }

  Future<void> refreshBootstrap() async {
    if (state.phase != ThreadComposePhase.ready || state.bootstrapLoading) {
      return;
    }
    state = state.copyWith(bootstrapLoading: true, bootstrapFailure: null);
    try {
      final bootstrap = await _repository.fetchBootstrap();
      if (!mounted || state.phase != ThreadComposePhase.ready) return;
      if (state.ownerId != bootstrap.userId) {
        state = state.copyWith(
          bootstrapLoading: false,
          bootstrapFailure: const ApiFailure(
            userMessage: '登录身份已经变化，请退出编辑器后重新进入。',
          ),
        );
        return;
      }
      state = state.copyWith(
        categories: bootstrap.categories,
        bootstrapLoading: false,
        bootstrapFailure: null,
      );
    } on Object catch (error) {
      if (!mounted || state.phase != ThreadComposePhase.ready) return;
      state = state.copyWith(
        bootstrapLoading: false,
        bootstrapFailure: _asFailure(error, '刷新分类与账号状态失败；本地编辑仍会保存。'),
      );
    }
  }

  void updateTitle(String value) => _update(state.copyWith(title: value));

  void updateCategory(String? value) =>
      _update(state.copyWith(categorySlug: value));

  void updateVisibility(ThreadComposeVisibility value) =>
      _update(state.copyWith(visibility: value));

  void updateTags(Iterable<String> value) =>
      _update(state.copyWith(tags: normalizeTagNames(value)));

  void updateBody(String value) => _update(state.copyWith(body: value));

  void restoreContentDraft(String content) {
    if (state.phase != ThreadComposePhase.ready || state.isSubmitting) return;
    final normalized = MarkdownContent.normalize(content);
    state = state.copyWith(
      body: normalized,
      documentRevision: state.documentRevision + 1,
      actionFailure: null,
      successMessage: '已恢复正文草稿；标题、分类和标签保持不变。',
      localSnapshotStatus: LocalSnapshotStatus.idle,
    );
    _snapshotRevision += 1;
    _snapshotTimer?.cancel();
    _snapshotTimer = Timer(_snapshotDebounce, () {
      unawaited(flushLocalSnapshot());
    });
  }

  void clearFeedback() {
    if (state.actionFailure == null && state.successMessage == null) return;
    state = state.copyWith(actionFailure: null, successMessage: null);
  }

  Future<void> flushLocalSnapshot() {
    _snapshotTimer?.cancel();
    _snapshotTimer = null;
    if (state.phase != ThreadComposePhase.ready) return Future.value();
    final snapshot = _buildSnapshot(state);
    final revision = _snapshotRevision;
    state = state.copyWith(localSnapshotStatus: LocalSnapshotStatus.saving);
    _snapshotQueue = _snapshotQueue.then((_) async {
      try {
        await _snapshotStore.saveThreadSnapshot(snapshot);
        if (!mounted ||
            state.phase != ThreadComposePhase.ready ||
            revision != _snapshotRevision) {
          return;
        }
        state = state.copyWith(
          localSnapshotStatus: LocalSnapshotStatus.saved,
          lastLocalSaveAt: snapshot.updatedAt,
        );
      } on Object {
        if (!mounted ||
            state.phase != ThreadComposePhase.ready ||
            revision != _snapshotRevision) {
          return;
        }
        state = state.copyWith(localSnapshotStatus: LocalSnapshotStatus.failed);
      }
    });
    return _snapshotQueue;
  }

  Future<String?> saveDraft() => _submit(publish: false);

  Future<String?> publish() => _submit(publish: true);

  Future<bool> openRemoteDraft(String draftId) async {
    final normalizedId = draftId.trim();
    if (state.phase != ThreadComposePhase.ready ||
        state.isSubmitting ||
        normalizedId.isEmpty) {
      return false;
    }
    if (state.remoteDraft?.id == normalizedId) {
      state = state.copyWith(
        actionFailure: null,
        successMessage: '这个云端草稿已经打开。',
      );
      return true;
    }
    if (_pendingCreate != null) {
      state = state.copyWith(
        actionFailure: const ApiFailure(
          userMessage: '当前主题创建结果仍待确认，请先重试保存，不能切换草稿。',
        ),
        successMessage: null,
      );
      return false;
    }
    await flushLocalSnapshot();
    if (!mounted || state.phase != ThreadComposePhase.ready) return false;
    if (state.localSnapshotStatus == LocalSnapshotStatus.failed) {
      state = state.copyWith(
        actionFailure: const ApiFailure(userMessage: '当前内容未能保存到这台设备，暂不切换云端草稿。'),
        successMessage: null,
      );
      return false;
    }
    state = state.copyWith(
      action: ThreadComposeAction.openRemoteDraft,
      actionFailure: null,
      successMessage: null,
    );
    try {
      final remote = await _repository.fetchDraft(
        id: normalizedId,
        ownerId: state.ownerId!,
      );
      if (!mounted || state.phase != ThreadComposePhase.ready) return false;
      state = state.copyWith(
        action: null,
        title: remote.title,
        categorySlug: remote.categorySlug,
        visibility: remote.visibility,
        tags: remote.tags,
        body: remote.body,
        clientRequestId: _createRequestId(),
        remoteDraft: remote,
        documentRevision: state.documentRevision + 1,
        restoredFromLocal: false,
        localSnapshotStatus: LocalSnapshotStatus.idle,
        lastLocalSaveAt: null,
        successMessage: '已打开云端草稿。',
      );
      _snapshotRevision += 1;
      await flushLocalSnapshot();
      return true;
    } on Object catch (error) {
      if (!mounted || state.phase != ThreadComposePhase.ready) return false;
      state = state.copyWith(
        action: null,
        actionFailure: _asFailure(error, '云端草稿没有打开成功，当前内容仍已保留。'),
      );
      return false;
    }
  }

  Future<String?> _submit({required bool publish}) async {
    if (state.phase != ThreadComposePhase.ready || state.isSubmitting) {
      return null;
    }
    final validationError = publish
        ? _publishValidationError()
        : validateThreadDraft(
            title: state.title,
            body: state.body,
            tags: state.tags,
          );
    if (validationError != null) {
      state = state.copyWith(
        actionFailure: ApiFailure(userMessage: validationError),
        successMessage: null,
      );
      return null;
    }
    await flushLocalSnapshot();
    if (!mounted || state.phase != ThreadComposePhase.ready) return null;
    state = state.copyWith(
      action: publish
          ? ThreadComposeAction.publish
          : ThreadComposeAction.saveDraft,
      actionFailure: null,
      successMessage: null,
    );
    try {
      var remote = await _ensureRemoteDraft();
      if (!mounted || state.phase != ThreadComposePhase.ready) return null;
      remote = await _repository.saveAggregate(
        remoteDraft: remote,
        title: state.title,
        categorySlug: state.categorySlug,
        visibility: state.visibility,
        tags: state.tags,
        body: state.body,
        publish: publish,
      );
      if (!mounted || state.phase != ThreadComposePhase.ready) return null;
      if (publish) {
        final ownerId = state.ownerId!;
        await _snapshotStore.deleteThreadSnapshot(ownerId);
        state = state.copyWith(
          phase: ThreadComposePhase.published,
          action: null,
          remoteDraft: remote,
          publishedThreadId: remote.id,
          successMessage: '主题已发布。',
        );
        return remote.id;
      }
      state = state.copyWith(
        action: null,
        remoteDraft: remote,
        title: remote.title,
        categorySlug: remote.categorySlug,
        visibility: remote.visibility,
        tags: remote.tags,
        body: remote.body,
        documentRevision: state.documentRevision + 1,
        successMessage: '主题草稿已保存到云端。',
      );
      _snapshotRevision += 1;
      await flushLocalSnapshot();
      return remote.id;
    } on Object catch (error) {
      if (!mounted || state.phase != ThreadComposePhase.ready) return null;
      final failure = _asFailure(
        error,
        publish ? '主题没有发布成功，本地草稿仍已保留。' : '云端草稿没有保存成功，本地草稿仍已保留。',
      );
      state = state.copyWith(action: null, actionFailure: failure);
      return null;
    }
  }

  Future<ThreadRemoteDraft> _ensureRemoteDraft() async {
    final existing = state.remoteDraft;
    if (existing != null) return existing;

    var pending = _pendingCreate;
    ThreadCreatePayload payload;
    if (pending != null) {
      final restored = ThreadCreatePayload.fromNormalizedJson(
        pending.normalizedPayload,
      );
      if (restored == null ||
          restored.clientRequestId != state.clientRequestId) {
        throw const ApiFailure(userMessage: '待确认创建记录无法安全恢复，请保留本地草稿并联系维护者。');
      }
      payload = restored;
    } else {
      payload = _currentCreatePayload();
      pending = PendingCreateOperation(
        clientRequestId: payload.clientRequestId,
        operationType: 'thread.create',
        normalizedPayload: payload.toNormalizedJson(),
        state: PendingOperationState.pending,
        updatedAt: _clock(),
      );
    }

    final sending = PendingCreateOperation(
      clientRequestId: pending.clientRequestId,
      operationType: pending.operationType,
      normalizedPayload: pending.normalizedPayload,
      state: PendingOperationState.sending,
      updatedAt: _clock(),
    );
    await _snapshotStore.savePendingCreate(sending);
    _pendingCreate = sending;
    try {
      final remote = await _repository.createDraft(payload);
      await _snapshotStore.deletePendingCreate(payload.clientRequestId);
      _pendingCreate = null;
      state = state.copyWith(remoteDraft: remote);
      _snapshotRevision += 1;
      await flushLocalSnapshot();
      return remote;
    } on Object catch (error) {
      final failure = _asFailure(error, '主题草稿创建失败，请重试。');
      if (_isAmbiguousCreateFailure(failure)) {
        final awaiting = PendingCreateOperation(
          clientRequestId: sending.clientRequestId,
          operationType: sending.operationType,
          normalizedPayload: sending.normalizedPayload,
          state: PendingOperationState.awaitingConfirmation,
          updatedAt: _clock(),
        );
        await _snapshotStore.savePendingCreate(awaiting);
        _pendingCreate = awaiting;
      } else {
        await _snapshotStore.deletePendingCreate(sending.clientRequestId);
        _pendingCreate = null;
        if (failure.businessCode == 40912) {
          state = state.copyWith(clientRequestId: _createRequestId());
          _snapshotRevision += 1;
          await flushLocalSnapshot();
        }
      }
      throw failure;
    }
  }

  String? _publishValidationError() {
    final validation = validateThreadPublish(
      title: state.title,
      categorySlug: state.categorySlug,
      body: state.body,
      tags: state.tags,
    );
    if (validation != null) return validation;
    final category = state.categorySlug;
    if (!state.categories.any((item) => item.slug == category)) {
      return '请选择当前可用的主题分类。';
    }
    return null;
  }

  ThreadCreatePayload _currentCreatePayload() {
    return ThreadCreatePayload(
      clientRequestId: state.clientRequestId,
      title: state.title,
      categorySlug: state.categorySlug,
      visibility: state.visibility,
      tags: state.tags,
      body: state.body,
    );
  }

  ThreadComposeState _restoreSnapshot(
    String ownerId,
    LocalEditorSnapshot? snapshot,
  ) {
    if (snapshot == null) {
      return ThreadComposeState(
        phase: ThreadComposePhase.ready,
        ownerId: ownerId,
        clientRequestId: _createRequestId(),
        documentRevision: 1,
      );
    }
    final metadata = ThreadSnapshotMetadata.fromJson(snapshot.metadataJson);
    if (metadata == null || metadata.ownerId != ownerId) {
      throw const ApiFailure(userMessage: '读取本地草稿失败，原草稿已保留。');
    }
    final remote = metadata.remoteDraft;
    return ThreadComposeState(
      phase: ThreadComposePhase.ready,
      ownerId: ownerId,
      title: metadata.title,
      categorySlug: metadata.categorySlug,
      visibility: metadata.visibility,
      tags: metadata.tags,
      body: snapshot.body,
      clientRequestId: snapshot.clientRequestId,
      remoteDraft: remote == null
          ? null
          : ThreadRemoteDraft(
              id: remote.id,
              version: remote.version,
              defaultSubthreadId: remote.defaultSubthreadId,
              defaultSubthreadVersion: remote.defaultSubthreadVersion,
              bodyVersion: remote.bodyVersion,
              title: metadata.title,
              categorySlug: metadata.categorySlug,
              visibility: metadata.visibility,
              tags: metadata.tags,
              body: snapshot.body,
            ),
      documentRevision: 1,
      restoredFromLocal: true,
      localSnapshotStatus: LocalSnapshotStatus.saved,
      lastLocalSaveAt: snapshot.updatedAt,
    );
  }

  LocalEditorSnapshot _buildSnapshot(ThreadComposeState source) {
    final ownerId = source.ownerId!;
    return LocalEditorSnapshot(
      id: threadEditorSnapshotId(ownerId),
      contextType: EditorContextType.thread,
      contextId: source.remoteDraft?.id,
      body: source.body,
      metadataJson: ThreadSnapshotMetadata(
        ownerId: ownerId,
        title: source.title,
        categorySlug: source.categorySlug,
        visibility: source.visibility,
        tags: source.tags,
        remoteDraft: source.remoteDraft,
      ).toJson(),
      clientRequestId: source.clientRequestId,
      updatedAt: _clock(),
    );
  }

  void _update(ThreadComposeState next) {
    if (state.phase != ThreadComposePhase.ready || state.isSubmitting) return;
    state = next.copyWith(
      actionFailure: null,
      successMessage: null,
      localSnapshotStatus: LocalSnapshotStatus.idle,
    );
    _snapshotRevision += 1;
    _snapshotTimer?.cancel();
    _snapshotTimer = Timer(_snapshotDebounce, () {
      unawaited(flushLocalSnapshot());
    });
  }

  bool _isAmbiguousCreateFailure(ApiFailure failure) {
    final status = failure.httpStatus;
    return status == null || status >= 500;
  }

  bool _isCurrent(int epoch) => mounted && epoch == _loadEpoch;

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }

  @override
  void dispose() {
    _snapshotTimer?.cancel();
    super.dispose();
  }
}

final threadComposeControllerProvider =
    StateNotifierProvider.autoDispose<
      ThreadComposeController,
      ThreadComposeState
    >(
      (ref) {
        ref.watch(sessionControllerProvider);
        final ownerId = ref
            .read(sessionControllerProvider.notifier)
            .currentUserId;
        return ThreadComposeController(
          ref.watch(threadComposeRepositoryProvider),
          ref.watch(editorSnapshotStoreProvider),
          knownOwnerId: ownerId,
        );
      },
      dependencies: [
        threadComposeRepositoryProvider,
        editorSnapshotStoreProvider,
      ],
    );
