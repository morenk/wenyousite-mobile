import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/drafts/application/content_draft_repository_ports.dart';
import 'package:wenyousite_mobile/features/drafts/application/content_drafts_state.dart';
import 'package:wenyousite_mobile/features/drafts/domain/content_draft_models.dart';

export 'package:wenyousite_mobile/features/drafts/application/content_drafts_state.dart';

class ContentDraftsController extends StateNotifier<ContentDraftsState> {
  ContentDraftsController(
    this._repository, {
    bool autoStart = true,
    this._autoSaveDebounce = const Duration(milliseconds: 800),
    String Function()? requestIdFactory,
  }) : _requestIdFactory = requestIdFactory ?? const Uuid().v4,
       super(const ContentDraftsState()) {
    if (autoStart) unawaited(load());
  }

  final ContentDraftRepository _repository;
  final Duration _autoSaveDebounce;
  final String Function() _requestIdFactory;
  var _loadEpoch = 0;
  var _autoSaveRevision = 0;
  Timer? _autoSaveTimer;
  String _latestContent = '';
  ContentDraft? _autoSaveDraft;
  String? _pendingAutoCreateId;
  String? _pendingAutoCreateContent;
  String? _pendingManualCreateId;
  String? _pendingManualCreateContent;
  int? _pendingManualCreateSlot;

  ContentDraft? draftAt(int slot) => state.draftAt(slot);

  Future<void> load() async {
    if (state.isBusy) return;
    final epoch = ++_loadEpoch;
    final autoSaveEnabled = state.autoSaveEnabled;
    final autoSaveStatus = state.autoSaveStatus;
    final autoSaveFailure = state.autoSaveFailure;
    final expectedAutoSaveDraft = _autoSaveDraft;
    state = ContentDraftsState(
      autoSaveEnabled: autoSaveEnabled,
      autoSaveStatus: autoSaveStatus,
      autoSaveFailure: autoSaveFailure,
    );
    try {
      final collection = await _repository.fetchCollection();
      if (!mounted || epoch != _loadEpoch) return;
      state = ContentDraftsState(
        phase: ContentDraftsPhase.ready,
        drafts: _sorted(collection.drafts),
        usage: collection.usage,
        autoSaveEnabled: autoSaveEnabled,
        autoSaveStatus: autoSaveStatus,
        autoSaveFailure: autoSaveFailure,
      );
      if (autoSaveEnabled) {
        _reconcileAutoSaveDraft(expectedAutoSaveDraft);
      }
    } on Object catch (error) {
      if (!mounted || epoch != _loadEpoch) return;
      final loadFailure = _asFailure(
        error,
        autoSaveEnabled ? '草稿位 1 刷新失败，自动保存已关闭，请重新开启。' : '正文草稿加载失败，请稍后重试。',
      );
      state = ContentDraftsState(
        phase: ContentDraftsPhase.failed,
        failure: loadFailure,
        autoSaveEnabled: false,
        autoSaveStatus: autoSaveEnabled
            ? ContentDraftAutoSaveStatus.error
            : autoSaveStatus,
        autoSaveFailure: autoSaveEnabled ? loadFailure : autoSaveFailure,
      );
      if (autoSaveEnabled) {
        _autoSaveTimer?.cancel();
        _autoSaveRevision += 1;
        _autoSaveDraft = null;
      }
    }
  }

  Future<bool> saveToNextSlot(String content) async {
    if (!_canWrite(content) || state.usage.isFull) {
      if (state.usage.isFull) {
        _setActionFailure('五个草稿位都已有内容，请选择一个位置保存并确认替换。');
      }
      return false;
    }
    return _create(content, slot: null);
  }

  Future<bool> createAtSlot(String content, int slot) async {
    if (!_canWrite(content) || slot < 1 || slot > state.usage.maxSlots) {
      return false;
    }
    if (state.draftAt(slot) != null) {
      _setActionFailure('草稿位 $slot 已有内容，请刷新后再选择。');
      return false;
    }
    if (slot == 1 && state.autoSaveEnabled) _autoSaveTimer?.cancel();
    final succeeded = await _create(content, slot: slot);
    if (!succeeded && slot == 1 && state.autoSaveEnabled) {
      _scheduleAutoSave();
    }
    return succeeded;
  }

  Future<bool> _create(String content, {required int? slot}) async {
    if (state.phase != ContentDraftsPhase.ready || state.isBusy) return false;
    state = state.copyWith(
      pendingSlot: slot ?? 0,
      actionFailure: null,
      successMessage: null,
      conflict: null,
    );
    try {
      if (_pendingManualCreateContent != content ||
          _pendingManualCreateSlot != slot) {
        _pendingManualCreateContent = content;
        _pendingManualCreateSlot = slot;
        _pendingManualCreateId = _requestIdFactory();
      }
      final saved = await _repository.create(
        content,
        slot: slot,
        clientRequestId: _pendingManualCreateId!,
      );
      if (!mounted) return false;
      _pendingManualCreateId = null;
      _pendingManualCreateContent = null;
      _pendingManualCreateSlot = null;
      _applySaved(saved, message: '正文已保存到草稿位 ${saved.slot}。');
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        actionFailure: _asFailure(error, '正文草稿没有保存成功，请稍后重试。'),
      );
      // 创建请求已携带稳定幂等键；失败后仍校准权威槽位，避免用户把
      // 已经落库但响应丢失的结果误当作新的保存操作。
      await _refreshAfterActionFailure();
      if (mounted) state = state.copyWith(pendingSlot: null);
      return false;
    }
  }

  Future<bool> overwrite(ContentDraft draft, String content) async {
    if (!_canWrite(content) ||
        state.phase != ContentDraftsPhase.ready ||
        state.isBusy) {
      return false;
    }
    if (draft.slot == 1 && state.autoSaveEnabled) _autoSaveTimer?.cancel();
    state = state.copyWith(
      pendingSlot: draft.slot,
      pendingDraftId: draft.id,
      actionFailure: null,
      successMessage: null,
      conflict: null,
    );
    try {
      final saved = await _repository.update(
        id: draft.id,
        content: content,
        version: draft.version,
      );
      if (!mounted) return false;
      _applySaved(saved, message: '草稿位 ${saved.slot} 已更新。');
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      final failure = _asFailure(error, '正文草稿没有更新成功，请稍后重试。');
      if (failure.businessCode == 40002 || failure.httpStatus == 409) {
        await _loadConflict(draft, content, failure);
      } else {
        state = state.copyWith(
          pendingSlot: null,
          pendingDraftId: null,
          actionFailure: failure,
        );
      }
      if (draft.slot == 1 && state.autoSaveEnabled) {
        _stopAutoSave(_asFailure(error, '草稿位 1 没有更新成功，自动保存已关闭，请重新开启。'));
      }
      return false;
    }
  }

  Future<bool> retryConflict() async {
    final conflict = state.conflict;
    if (conflict == null || state.isBusy) return false;
    return overwrite(conflict.latest, conflict.pendingContent);
  }

  Future<ContentDraft?> fetchFreshForRestore(String id) async {
    if (state.phase != ContentDraftsPhase.ready || state.isBusy) return null;
    state = state.copyWith(
      pendingDraftId: id,
      actionFailure: null,
      successMessage: null,
    );
    try {
      final latest = await _repository.fetchById(id);
      if (!mounted) return null;
      state = state.copyWith(
        drafts: _upsert(state.drafts, latest),
        pendingDraftId: null,
      );
      return latest;
    } on Object catch (error) {
      if (!mounted) return null;
      state = state.copyWith(
        pendingDraftId: null,
        actionFailure: _asFailure(error, '正文草稿读取失败，请稍后重试。'),
      );
      return null;
    }
  }

  Future<bool> remove(ContentDraft draft) async {
    if (state.phase != ContentDraftsPhase.ready || state.isBusy) return false;
    state = state.copyWith(
      pendingSlot: draft.slot,
      pendingDraftId: draft.id,
      actionFailure: null,
      successMessage: null,
      conflict: null,
    );
    try {
      await _repository.remove(draft.id, version: draft.version);
      if (!mounted) return false;
      final drafts = state.drafts
          .where((item) => item.id != draft.id)
          .toList(growable: false);
      state = state.copyWith(
        drafts: drafts,
        usage: _usageFor(drafts, state.usage.maxSlots),
        pendingSlot: null,
        pendingDraftId: null,
        successMessage: '草稿位 ${draft.slot} 的正文已删除。',
      );
      if (draft.slot == 1 && state.autoSaveEnabled) {
        disableAutoSave();
      }
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        pendingSlot: null,
        pendingDraftId: null,
        actionFailure: _asFailure(error, '正文草稿没有删除成功，请稍后重试。'),
      );
      return false;
    }
  }

  Future<bool> refreshForAutoSave() async {
    if (state.phase != ContentDraftsPhase.ready || state.isBusy) return false;
    final epoch = ++_loadEpoch;
    final expectedAutoSaveDraft = _autoSaveDraft;
    state = state.copyWith(
      pendingDraftId: 'auto-save-refresh',
      failure: null,
      actionFailure: null,
    );
    try {
      final collection = await _repository.fetchCollection();
      if (!mounted || epoch != _loadEpoch) return false;
      state = state.copyWith(
        drafts: _sorted(collection.drafts),
        usage: collection.usage,
        pendingDraftId: null,
      );
      if (state.autoSaveEnabled) {
        _reconcileAutoSaveDraft(expectedAutoSaveDraft);
      }
      return state.phase == ContentDraftsPhase.ready;
    } on Object catch (error) {
      if (!mounted || epoch != _loadEpoch) return false;
      state = state.copyWith(
        pendingDraftId: null,
        actionFailure: _asFailure(error, '开启自动保存前未能刷新草稿位 1，请重试。'),
      );
      return false;
    }
  }

  bool enableAutoSave(String currentContent) {
    if (state.phase != ContentDraftsPhase.ready || state.isBusy) return false;
    final retryAfterFailure =
        state.autoSaveStatus == ContentDraftAutoSaveStatus.error;
    _latestContent = currentContent;
    _autoSaveDraft = state.draftAt(1);
    if (_autoSaveDraft != null) {
      _pendingAutoCreateId = null;
      _pendingAutoCreateContent = null;
    }
    _autoSaveRevision += 1;
    state = state.copyWith(
      autoSaveEnabled: true,
      autoSaveStatus: ContentDraftAutoSaveStatus.waiting,
      autoSaveFailure: null,
      actionFailure: null,
      successMessage: null,
      conflict: null,
    );
    if (retryAfterFailure) _scheduleAutoSave();
    return true;
  }

  void disableAutoSave({bool preserveFailure = false}) {
    _autoSaveTimer?.cancel();
    _autoSaveRevision += 1;
    _autoSaveDraft = null;
    state = state.copyWith(
      autoSaveEnabled: false,
      autoSaveStatus: preserveFailure
          ? ContentDraftAutoSaveStatus.error
          : ContentDraftAutoSaveStatus.idle,
      autoSaveFailure: preserveFailure ? state.autoSaveFailure : null,
    );
  }

  void updateAutoSaveContent(String content) {
    final changed = content != _latestContent;
    _latestContent = content;
    if (!state.autoSaveEnabled || !changed) return;
    _autoSaveRevision += 1;
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    if (!state.autoSaveEnabled) return;
    final content = _latestContent;
    final writeInFlight =
        state.autoSaveStatus == ContentDraftAutoSaveStatus.saving;
    if (!MarkdownContent.hasVisibleContent(content)) {
      state = state.copyWith(
        autoSaveStatus: writeInFlight
            ? ContentDraftAutoSaveStatus.saving
            : ContentDraftAutoSaveStatus.waiting,
      );
      return;
    }
    if (!writeInFlight && _autoSaveDraft?.content == content) {
      state = state.copyWith(autoSaveStatus: ContentDraftAutoSaveStatus.saved);
      return;
    }
    final revision = _autoSaveRevision;
    state = state.copyWith(
      autoSaveStatus: writeInFlight
          ? ContentDraftAutoSaveStatus.saving
          : ContentDraftAutoSaveStatus.waiting,
    );
    _autoSaveTimer = Timer(
      _autoSaveDebounce,
      () => unawaited(_saveAutomatically(content, revision)),
    );
  }

  Future<void> _saveAutomatically(String content, int revision) async {
    if (!mounted || !state.autoSaveEnabled || revision != _autoSaveRevision) {
      return;
    }
    if (state.phase == ContentDraftsPhase.failed) {
      _stopAutoSave(
        state.failure ??
            const ApiFailure(userMessage: '正文草稿状态不可用，自动保存已关闭，请重新开启。'),
      );
      return;
    }
    if (state.phase != ContentDraftsPhase.ready || state.isBusy) {
      _autoSaveTimer = Timer(
        const Duration(milliseconds: 200),
        () => unawaited(_saveAutomatically(content, revision)),
      );
      return;
    }
    final validationFailure = _contentValidationFailure(content);
    if (validationFailure != null) {
      _stopAutoSave(ApiFailure(userMessage: validationFailure));
      return;
    }
    state = state.copyWith(
      autoSaveStatus: ContentDraftAutoSaveStatus.saving,
      autoSaveFailure: null,
    );
    try {
      final current = _autoSaveDraft;
      final ContentDraft saved;
      if (current == null) {
        if (_pendingAutoCreateContent != content) {
          _pendingAutoCreateContent = content;
          _pendingAutoCreateId = _requestIdFactory();
        }
        saved = await _repository.create(
          content,
          slot: 1,
          clientRequestId: _pendingAutoCreateId!,
        );
      } else {
        saved = await _repository.update(
          id: current.id,
          content: content,
          version: current.version,
        );
      }
      if (!mounted) return;
      _pendingAutoCreateId = null;
      _pendingAutoCreateContent = null;
      _autoSaveDraft = saved;
      final drafts = _upsert(state.drafts, saved);
      state = state.copyWith(
        drafts: drafts,
        usage: _usageFor(drafts, state.usage.maxSlots),
        autoSaveStatus: state.autoSaveEnabled && revision == _autoSaveRevision
            ? ContentDraftAutoSaveStatus.saved
            : ContentDraftAutoSaveStatus.waiting,
        autoSaveFailure: null,
      );
    } on Object catch (error) {
      if (!mounted) return;
      final failure = _asFailure(error, '正文草稿自动保存失败，请重新开启。');
      _stopAutoSave(failure);
      await _refreshAfterActionFailure();
    }
  }

  void _stopAutoSave(ApiFailure failure) {
    _autoSaveTimer?.cancel();
    _autoSaveRevision += 1;
    _autoSaveDraft = null;
    state = state.copyWith(
      autoSaveEnabled: false,
      autoSaveStatus: ContentDraftAutoSaveStatus.error,
      autoSaveFailure: failure,
    );
  }

  void _reconcileAutoSaveDraft(ContentDraft? expected) {
    final latest = state.draftAt(1);
    final unchanged = expected == null
        ? latest == null
        : latest != null &&
              latest.id == expected.id &&
              latest.version == expected.version;
    if (!unchanged) {
      _stopAutoSave(
        const ApiFailure(userMessage: '草稿位 1 已在其他位置发生变化，自动保存已关闭，请重新开启。'),
      );
      return;
    }
    _autoSaveDraft = latest;
  }

  void clearFeedback() {
    state = state.copyWith(
      actionFailure: null,
      successMessage: null,
      conflict: null,
    );
  }

  bool _canWrite(String content) {
    if (state.phase != ContentDraftsPhase.ready || state.isBusy) return false;
    final failure = _contentValidationFailure(content, allowEmpty: false);
    if (failure != null) {
      _setActionFailure(failure);
      return false;
    }
    return true;
  }

  String? _contentValidationFailure(String content, {bool allowEmpty = true}) {
    if (!MarkdownContent.hasVisibleContent(content)) {
      return allowEmpty ? null : '当前正文为空，先写一点内容再保存。';
    }
    if (content.length > 10000) {
      return '正文超过 10000 字符，请精简后再保存。';
    }
    if (MarkdownDiceContract.countMarkdownNodes(content) >
        MarkdownDiceContract.maximumNodesPerPost) {
      return '当前正文最多可插入 20 个骰子，请删除一个后再保存。';
    }
    return null;
  }

  Future<void> _loadConflict(
    ContentDraft stale,
    String content,
    ApiFailure originalFailure,
  ) async {
    try {
      final latest = await _repository.fetchById(stale.id);
      if (!mounted) return;
      state = state.copyWith(
        drafts: _upsert(state.drafts, latest),
        pendingSlot: null,
        pendingDraftId: null,
        actionFailure: originalFailure,
        conflict: ContentDraftConflict(latest: latest, pendingContent: content),
      );
    } on Object catch (refreshError) {
      if (!mounted) return;
      state = state.copyWith(
        pendingSlot: null,
        pendingDraftId: null,
        actionFailure: _asFailure(
          refreshError,
          '云端版本已经变化，且最新版没有读取成功；当前正文仍未丢失。',
        ),
      );
    }
  }

  Future<void> _refreshAfterActionFailure() async {
    try {
      final collection = await _repository.fetchCollection();
      if (!mounted || state.phase != ContentDraftsPhase.ready) return;
      state = state.copyWith(
        drafts: _sorted(collection.drafts),
        usage: collection.usage,
      );
    } on Object {
      // 原始写入失败已经可见；刷新失败不覆盖更有帮助的错误。
    }
  }

  void _applySaved(ContentDraft saved, {required String message}) {
    final drafts = _upsert(state.drafts, saved);
    if (saved.slot == 1 && state.autoSaveEnabled) {
      _autoSaveDraft = saved;
    }
    state = state.copyWith(
      drafts: drafts,
      usage: _usageFor(drafts, state.usage.maxSlots),
      pendingSlot: null,
      pendingDraftId: null,
      actionFailure: null,
      successMessage: message,
      conflict: null,
      autoSaveStatus: saved.slot == 1 && state.autoSaveEnabled
          ? ContentDraftAutoSaveStatus.saved
          : state.autoSaveStatus,
      autoSaveFailure: saved.slot == 1 && state.autoSaveEnabled
          ? null
          : state.autoSaveFailure,
    );
  }

  void _setActionFailure(String message) {
    state = state.copyWith(
      actionFailure: ApiFailure(userMessage: message),
      successMessage: null,
    );
  }

  static List<ContentDraft> _upsert(
    List<ContentDraft> current,
    ContentDraft saved,
  ) {
    return _sorted([
      ...current.where(
        (draft) => draft.id != saved.id && draft.slot != saved.slot,
      ),
      saved,
    ]);
  }

  static List<ContentDraft> _sorted(Iterable<ContentDraft> drafts) {
    final result = drafts.toList(growable: false);
    result.sort((left, right) => left.slot.compareTo(right.slot));
    return List.unmodifiable(result);
  }

  static ContentDraftSlotUsage _usageFor(
    List<ContentDraft> drafts,
    int maxSlots,
  ) {
    return ContentDraftSlotUsage(
      usedSlots: drafts.length,
      maxSlots: maxSlots,
      occupiedSlots: drafts.map((draft) => draft.slot).toSet(),
    );
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}

final contentDraftsControllerProvider = StateNotifierProvider.autoDispose
    .family<ContentDraftsController, ContentDraftsState, Object>((
      ref,
      sessionKey,
    ) {
      ref.watch(sessionScopeProvider);
      return ContentDraftsController(
        ref.watch(contentDraftRepositoryProvider),
        autoStart: false,
      );
    }, dependencies: [sessionScopeProvider, contentDraftRepositoryProvider]);
