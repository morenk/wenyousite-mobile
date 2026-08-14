import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_repository_ports.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

typedef StickerRequestIdFactory = String Function();

final stickersEnabledProvider = Provider<bool>(
  (ref) => ref.watch(
    appCapabilitiesProvider.select((capabilities) => capabilities.stickers),
  ),
  dependencies: [appCapabilitiesProvider],
);

class StickerCollectionController
    extends StateNotifier<StickerCollectionState> {
  StickerCollectionController(
    this._repository, {
    bool autoStart = true,
    StickerRequestIdFactory? requestIdFactory,
    this._pollInterval = const Duration(seconds: 2),
  }) : _requestIdFactory = requestIdFactory ?? const Uuid().v4,
       super(const StickerCollectionState()) {
    if (autoStart) unawaited(load());
  }

  final StickerRepository _repository;
  final StickerRequestIdFactory _requestIdFactory;
  final Duration _pollInterval;
  final Map<String, String> _requestIds = {};
  Timer? _pollTimer;
  var _polling = false;
  var _epoch = 0;

  Future<void> load() async {
    final epoch = ++_epoch;
    final before = state;
    if (before.collection == null) {
      state = const StickerCollectionState();
    } else {
      state = before.copyWith(transientFailure: null, successMessage: null);
    }
    try {
      final collection = await _repository.fetchCollection();
      if (!mounted || epoch != _epoch) return;
      state = StickerCollectionState(
        phase: StickerCollectionPhase.ready,
        collection: collection,
      );
      _syncPolling();
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      final failure = _asFailure(error, '表情收藏没有加载完成，请稍后重试。');
      if (before.collection == null) {
        state = StickerCollectionState(
          phase: StickerCollectionPhase.failed,
          failure: failure,
        );
      } else {
        state = before.copyWith(transientFailure: failure);
      }
    }
  }

  Future<StickerImport?> importMedia(String mediaId) {
    return importSource(StickerMediaSource(mediaId));
  }

  Future<StickerImport?> importDirectMessage(String messageId) {
    return importSource(StickerDirectMessageSource(messageId));
  }

  Future<StickerImport?> importPostImage({
    required String postId,
    required String imageUrl,
  }) {
    return importSource(
      StickerPostImageSource(postId: postId, imageUrl: imageUrl),
    );
  }

  Future<StickerImport?> importSource(StickerImportSource source) async {
    if (state.isBusy) return null;
    final requestId = _requestIds.putIfAbsent(
      source.requestKey,
      _requestIdFactory,
    );
    state = state.copyWith(
      action: StickerAction.importing,
      actionTarget: source.requestKey,
      transientFailure: null,
      retrySource: null,
      successMessage: null,
    );
    try {
      final result = await _repository.importSource(
        source,
        clientRequestId: requestId,
      );
      if (!mounted) return null;
      if (result.status == StickerImportStatus.failed) {
        final failure = ApiFailure(
          userMessage: _importFailureMessage(result.failureCode),
        );
        state = state.copyWith(
          action: null,
          actionTarget: null,
          transientFailure: failure,
          retrySource: source,
        );
        return null;
      }
      _requestIds.remove(source.requestKey);
      final message = switch (result.status) {
        StickerImportStatus.processing => '图片正在处理，完成后会出现在收藏中。',
        StickerImportStatus.completed when result.alreadySaved => '已经收藏过这个表情。',
        StickerImportStatus.completed => '已添加到表情收藏。',
        StickerImportStatus.failed => throw StateError('handled above'),
      };
      state = state.copyWith(
        action: null,
        actionTarget: null,
        retrySource: null,
        successMessage: message,
      );
      await _refreshAfterConfirmedMutation();
      return result;
    } on Object catch (error) {
      if (!mounted) return null;
      state = state.copyWith(
        action: null,
        actionTarget: null,
        transientFailure: _asFailure(error, '表情没有添加成功，请使用原请求重试。'),
        retrySource: source,
      );
      return null;
    }
  }

  Future<StickerImport?> retryImport() async {
    final source = state.retrySource;
    if (source == null) return null;
    return importSource(source);
  }

  Future<bool> reorder(List<UserSticker> items) async {
    final collection = state.collection;
    if (collection == null || state.isBusy) return false;
    final ids = items.map((item) => item.id).toList(growable: false);
    if (ids.length != collection.items.length ||
        ids.toSet().length != ids.length ||
        !ids.toSet().containsAll(collection.items.map((item) => item.id))) {
      state = state.copyWith(
        transientFailure: const ApiFailure(userMessage: '表情排序与当前收藏夹不一致，请重新加载。'),
      );
      return false;
    }
    state = state.copyWith(
      action: StickerAction.reordering,
      actionTarget: null,
      transientFailure: null,
      successMessage: null,
    );
    try {
      final updated = await _repository.reorder(
        version: collection.version,
        favoriteIds: ids,
      );
      if (!mounted) return false;
      state = StickerCollectionState(
        phase: StickerCollectionPhase.ready,
        collection: updated,
        successMessage: '表情顺序已更新。',
      );
      _syncPolling();
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      final failure = _asFailure(error, '表情排序失败，请重新加载后重试。');
      state = state.copyWith(
        action: null,
        actionTarget: null,
        transientFailure: failure,
      );
      if (failure.businessCode == 40911) unawaited(load());
      return false;
    }
  }

  Future<bool> remove(String favoriteId) async {
    if (state.collection == null || state.isBusy) return false;
    state = state.copyWith(
      action: StickerAction.removing,
      actionTarget: favoriteId,
      transientFailure: null,
      successMessage: null,
    );
    try {
      final updated = await _repository.remove(favoriteId);
      if (!mounted) return false;
      state = StickerCollectionState(
        phase: StickerCollectionPhase.ready,
        collection: updated,
        successMessage: '已从收藏中移除。',
      );
      _syncPolling();
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        action: null,
        actionTarget: null,
        transientFailure: _asFailure(error, '表情没有移除成功，请重试。'),
      );
      return false;
    }
  }

  void clearFeedback() {
    state = state.copyWith(transientFailure: null, successMessage: null);
  }

  Future<void> _refreshAfterConfirmedMutation() async {
    try {
      final collection = await _repository.fetchCollection();
      if (!mounted) return;
      state = state.copyWith(
        phase: StickerCollectionPhase.ready,
        collection: collection,
        failure: null,
      );
      _syncPolling();
    } on Object catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        transientFailure: _asFailure(error, '操作已经提交，但收藏夹没有刷新完成，请手动刷新。'),
      );
    }
  }

  void _syncPolling() {
    final shouldPoll = state.collection?.pendingImports.isNotEmpty ?? false;
    if (!shouldPoll || _pollInterval <= Duration.zero) {
      _pollTimer?.cancel();
      _pollTimer = null;
      return;
    }
    _pollTimer ??= Timer.periodic(
      _pollInterval,
      (_) => unawaited(_pollPending()),
    );
  }

  Future<void> _pollPending() async {
    if (_polling || state.isBusy) return;
    final pending = state.collection?.pendingImports ?? const <StickerImport>[];
    if (pending.isEmpty) {
      _syncPolling();
      return;
    }
    _polling = true;
    try {
      final results = await Future.wait(
        pending.map((item) => _repository.fetchImport(item.id)),
      );
      if (!mounted) return;
      final finished = results.where(
        (item) => item.status != StickerImportStatus.processing,
      );
      if (finished.isEmpty) return;
      final failed = finished.where(
        (item) => item.status == StickerImportStatus.failed,
      );
      final collection = await _repository.fetchCollection();
      if (!mounted) return;
      state = state.copyWith(
        collection: collection,
        transientFailure: failed.isEmpty
            ? null
            : ApiFailure(
                userMessage: _importFailureMessage(failed.first.failureCode),
              ),
        successMessage: failed.isEmpty ? '表情处理完成，已加入收藏。' : null,
      );
      _syncPolling();
    } on Object {
      // 后台轮询失败不覆盖可用收藏；下一轮或手动刷新会继续校准。
    } finally {
      _polling = false;
    }
  }

  String _importFailureMessage(String? failureCode) {
    return switch (failureCode) {
      'INVALID_STICKER' => '所选图片不符合表情规格，请换一张图片。',
      'STICKER_LIMIT_REACHED' => '表情收藏已满，请先移除一些表情。',
      _ => '表情处理失败，请换一张图片后重试。',
    };
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return error is ApiFailure
        ? error
        : ApiFailure(userMessage: fallback, cause: error);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final stickerCollectionControllerProvider =
    StateNotifierProvider<StickerCollectionController, StickerCollectionState>(
      (ref) {
        final authenticated = ref.watch(
          sessionControllerProvider.select(
            (session) => session.isAuthenticated,
          ),
        );
        final enabled = ref.watch(stickersEnabledProvider);
        return StickerCollectionController(
          ref.watch(stickerRepositoryProvider),
          autoStart: authenticated && enabled,
        );
      },
      // The capability is scoped by WenyouApp, so this controller must be
      // recreated inside the same override scope.
      dependencies: [stickersEnabledProvider, stickerRepositoryProvider],
    );
