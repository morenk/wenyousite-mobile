import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/drafts/application/content_draft_repository_ports.dart';
import 'package:wenyousite_mobile/features/drafts/domain/content_draft_models.dart';

class ContentDraftsController extends StateNotifier<ContentDraftsState> {
  ContentDraftsController(this._repository, {bool autoStart = true})
    : super(const ContentDraftsState()) {
    if (autoStart) unawaited(load());
  }

  final ContentDraftRepository _repository;
  var _loadEpoch = 0;

  Future<void> load() async {
    final epoch = ++_loadEpoch;
    state = const ContentDraftsState();
    try {
      final collection = await _repository.fetchCollection();
      if (!mounted || epoch != _loadEpoch) return;
      state = ContentDraftsState(
        phase: ContentDraftsPhase.ready,
        drafts: _sorted(collection.drafts),
        usage: collection.usage,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _loadEpoch) return;
      state = ContentDraftsState(
        phase: ContentDraftsPhase.failed,
        failure: _asFailure(error, '正文草稿没有加载完成，请稍后重试。'),
      );
    }
  }

  Future<bool> saveToNextSlot(String content) async {
    if (!_canWrite(content) || state.usage.isFull) {
      if (state.usage.isFull) {
        _setActionFailure('5 个正文草稿槽位都已占用，请先删除或覆盖旧草稿。');
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
      _setActionFailure('槽位 $slot 已被占用，请刷新后再选择。');
      return false;
    }
    return _create(content, slot: slot);
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
      final saved = await _repository.create(content, slot: slot);
      if (!mounted) return false;
      _applySaved(saved, message: '正文已保存到槽位 ${saved.slot}。');
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        actionFailure: _asFailure(error, '正文草稿没有保存成功，请稍后重试。'),
      );
      // POST 没有幂等键；失败后先串行校准服务端槽位，避免结果不确定时
      // 用户立刻重试而占用第二个空槽。
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
      _applySaved(saved, message: '槽位 ${saved.slot} 已更新。');
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
        actionFailure: _asFailure(error, '正文草稿没有读取完成，请稍后重试。'),
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
      await _repository.remove(draft.id);
      if (!mounted) return false;
      final drafts = state.drafts
          .where((item) => item.id != draft.id)
          .toList(growable: false);
      state = state.copyWith(
        drafts: drafts,
        usage: _usageFor(drafts, state.usage.maxSlots),
        pendingSlot: null,
        pendingDraftId: null,
        successMessage: '槽位 ${draft.slot} 的正文草稿已删除。',
      );
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

  void clearFeedback() {
    state = state.copyWith(
      actionFailure: null,
      successMessage: null,
      conflict: null,
    );
  }

  bool _canWrite(String content) {
    if (state.phase != ContentDraftsPhase.ready || state.isBusy) return false;
    if (!MarkdownContent.hasVisibleContent(content)) {
      _setActionFailure('当前正文为空，先写一点内容再保存。');
      return false;
    }
    if (content.length > 10000) {
      _setActionFailure('正文超过 10000 字符，请精简后再保存。');
      return false;
    }
    return true;
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
    state = state.copyWith(
      drafts: drafts,
      usage: _usageFor(drafts, state.usage.maxSlots),
      pendingSlot: null,
      pendingDraftId: null,
      actionFailure: null,
      successMessage: message,
      conflict: null,
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
    return error is ApiFailure
        ? error
        : ApiFailure(userMessage: fallback, cause: error);
  }
}

final contentDraftsControllerProvider =
    StateNotifierProvider.autoDispose<
      ContentDraftsController,
      ContentDraftsState
    >((ref) {
      ref.watch(sessionControllerProvider);
      return ContentDraftsController(ref.watch(contentDraftRepositoryProvider));
    }, dependencies: [contentDraftRepositoryProvider]);
