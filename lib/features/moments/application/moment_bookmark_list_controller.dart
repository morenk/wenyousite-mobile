import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/models/paging.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_bookmark_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

enum MomentBookmarkListPhase { loading, ready, failed }

enum MomentBookmarkPendingAction { move, remove }

const _unsetBookmarkValue = Object();

class MomentBookmarkListState {
  const MomentBookmarkListState({
    required this.folderId,
    this.phase = MomentBookmarkListPhase.loading,
    this.items = const [],
    this.cursor,
    this.hasMore = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.pendingMomentId,
    this.pendingAction,
    this.failure,
    this.transientFailure,
  });

  final String folderId;
  final MomentBookmarkListPhase phase;
  final List<MomentCard> items;
  final String? cursor;
  final bool hasMore;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? pendingMomentId;
  final MomentBookmarkPendingAction? pendingAction;
  final ApiFailure? failure;
  final ApiFailure? transientFailure;

  bool get isBusy => isRefreshing || isLoadingMore || pendingMomentId != null;

  MomentBookmarkListState copyWith({
    MomentBookmarkListPhase? phase,
    List<MomentCard>? items,
    Object? cursor = _unsetBookmarkValue,
    bool? hasMore,
    bool? isRefreshing,
    bool? isLoadingMore,
    Object? pendingMomentId = _unsetBookmarkValue,
    Object? pendingAction = _unsetBookmarkValue,
    Object? failure = _unsetBookmarkValue,
    Object? transientFailure = _unsetBookmarkValue,
  }) {
    return MomentBookmarkListState(
      folderId: folderId,
      phase: phase ?? this.phase,
      items: items ?? this.items,
      cursor: identical(cursor, _unsetBookmarkValue)
          ? this.cursor
          : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      pendingMomentId: identical(pendingMomentId, _unsetBookmarkValue)
          ? this.pendingMomentId
          : pendingMomentId as String?,
      pendingAction: identical(pendingAction, _unsetBookmarkValue)
          ? this.pendingAction
          : pendingAction as MomentBookmarkPendingAction?,
      failure: identical(failure, _unsetBookmarkValue)
          ? this.failure
          : failure as ApiFailure?,
      transientFailure: identical(transientFailure, _unsetBookmarkValue)
          ? this.transientFailure
          : transientFailure as ApiFailure?,
    );
  }
}

class MomentBookmarkListController
    extends StateNotifier<MomentBookmarkListState> {
  MomentBookmarkListController(
    this._repository,
    String folderId, {
    bool autoStart = true,
  }) : super(MomentBookmarkListState(folderId: folderId)) {
    if (autoStart) unawaited(load());
  }

  final MomentBookmarkRepository _repository;
  var _epoch = 0;

  Future<void> load() => _loadFirst(refreshing: false);

  Future<void> refresh() => _loadFirst(refreshing: state.items.isNotEmpty);

  Future<void> _loadFirst({required bool refreshing}) async {
    final epoch = ++_epoch;
    state = state.copyWith(
      phase: refreshing
          ? MomentBookmarkListPhase.ready
          : MomentBookmarkListPhase.loading,
      isRefreshing: refreshing,
      isLoadingMore: false,
      failure: null,
      transientFailure: null,
    );
    try {
      final page = await _repository.fetchPage(folderId: state.folderId);
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        phase: MomentBookmarkListPhase.ready,
        items: page.items,
        cursor: page.cursor,
        hasMore: page.hasMore,
        isRefreshing: false,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      final failure = mapApplicationFailure(error, '动态收藏加载失败，请稍后重试。');
      state = state.copyWith(
        phase: refreshing
            ? MomentBookmarkListPhase.ready
            : MomentBookmarkListPhase.failed,
        isRefreshing: false,
        failure: refreshing ? null : failure,
        transientFailure: refreshing ? failure : null,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.phase != MomentBookmarkListPhase.ready ||
        state.isBusy ||
        !state.hasMore) {
      return;
    }
    final epoch = _epoch;
    state = state.copyWith(isLoadingMore: true, transientFailure: null);
    try {
      final page = await _repository.fetchPage(
        folderId: state.folderId,
        cursor: state.cursor,
      );
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        items: mergeUniqueBy(state.items, page.items, keyOf: (item) => item.id),
        cursor: page.cursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } on ApiFailure catch (failure) {
      if (!mounted || epoch != _epoch) return;
      if (failure.isInvalidCursor) {
        await _loadFirst(refreshing: state.items.isNotEmpty);
        return;
      }
      state = state.copyWith(isLoadingMore: false, transientFailure: failure);
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        isLoadingMore: false,
        transientFailure: mapApplicationFailure(error, '加载更多动态收藏失败，请重试。'),
      );
    }
  }

  Future<bool> move(MomentCard card, String folderId) async {
    if (state.isBusy || folderId == state.folderId) return false;
    if (!card.canInteract) {
      state = state.copyWith(
        transientFailure: const ApiFailure(userMessage: '这条动态暂时无法移动。'),
      );
      return false;
    }
    return _runAction(
      card,
      MomentBookmarkPendingAction.move,
      () => _repository.moveBookmark(card.id, folderId),
      fallback: '移动收藏失败，请稍后重试。',
    );
  }

  Future<bool> remove(MomentCard card) {
    if (state.isBusy) return Future.value(false);
    return _runAction(
      card,
      MomentBookmarkPendingAction.remove,
      () => _repository.setBookmark(card.id, active: false),
      fallback: '取消收藏失败，请稍后重试。',
    );
  }

  Future<bool> _runAction(
    MomentCard card,
    MomentBookmarkPendingAction action,
    Future<Object?> Function() write, {
    required String fallback,
  }) async {
    state = state.copyWith(
      pendingMomentId: card.id,
      pendingAction: action,
      transientFailure: null,
    );
    try {
      await write();
      if (!mounted) return false;
      state = state.copyWith(
        items: List.unmodifiable(
          state.items.where((item) => item.id != card.id),
        ),
        pendingMomentId: null,
        pendingAction: null,
      );
      await refresh();
      return mounted;
    } on Object catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        pendingMomentId: null,
        pendingAction: null,
        transientFailure: mapApplicationFailure(error, fallback),
      );
      return false;
    }
  }
}

final momentBookmarkListControllerProvider = StateNotifierProvider.autoDispose
    .family<MomentBookmarkListController, MomentBookmarkListState, String>((
      ref,
      folderId,
    ) {
      return MomentBookmarkListController(
        ref.watch(momentBookmarkRepositoryProvider),
        folderId,
      );
    }, dependencies: [momentBookmarkRepositoryProvider]);
