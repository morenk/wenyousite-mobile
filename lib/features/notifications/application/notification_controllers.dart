import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/request_epoch.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/models/paging.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_repository_ports.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_states.dart';

export 'package:wenyousite_mobile/features/notifications/application/notification_states.dart';

class NotificationUnreadController
    extends StateNotifier<NotificationUnreadState> {
  NotificationUnreadController(this._repository, {bool autoStart = true})
    : super(const NotificationUnreadState()) {
    if (autoStart) unawaited(refresh());
  }

  final NotificationRepository _repository;
  final _requestEpoch = RequestEpoch();

  Future<void> refresh({bool force = false}) async {
    if (!mounted || (state.isLoading && !force)) return;
    final epoch = _requestEpoch.begin();
    state = NotificationUnreadState(count: state.count, isLoading: true);
    try {
      final count = await _repository.fetchUnreadCount();
      if (!mounted || !_requestEpoch.isCurrent(epoch)) return;
      state = NotificationUnreadState(count: count < 0 ? 0 : count);
    } on Object catch (error) {
      if (!mounted || !_requestEpoch.isCurrent(epoch)) return;
      state = NotificationUnreadState(
        count: state.count,
        failure: mapApplicationFailure(error, '未读通知数同步失败。'),
      );
    }
  }

  void decrement() {
    if (!mounted) return;
    _setCount(state.count - 1);
  }

  void clear() => _setCount(0);

  void _setCount(int value) {
    if (!mounted) return;
    _requestEpoch.invalidate();
    state = NotificationUnreadState(count: value < 0 ? 0 : value);
  }

  @override
  void dispose() {
    _requestEpoch.invalidate();
    super.dispose();
  }
}

final notificationUnreadControllerProvider =
    StateNotifierProvider<
      NotificationUnreadController,
      NotificationUnreadState
    >((ref) {
      ref.watch(viewerScopeProvider);
      final authenticated = ref.watch(
        sessionControllerProvider.select((session) => session.isAuthenticated),
      );
      return NotificationUnreadController(
        ref.watch(notificationRepositoryProvider),
        autoStart: authenticated,
      );
    }, dependencies: [viewerScopeProvider, notificationRepositoryProvider]);

class NotificationListController extends StateNotifier<NotificationListState> {
  NotificationListController(this._repository, this._unread)
    : super(const NotificationListState.loading()) {
    load();
  }

  final NotificationRepository _repository;
  final NotificationUnreadController _unread;
  final _requestEpoch = RequestEpoch();

  Future<void> selectFilter(NotificationFilter filter) async {
    if (!mounted || filter == state.filter) return;
    await load(filter: filter);
  }

  Future<void> load({NotificationFilter? filter}) async {
    if (!mounted) return;
    final nextFilter = filter ?? state.filter;
    final epoch = _requestEpoch.begin();
    state = NotificationListState.loading(filter: nextFilter);
    try {
      final page = await _repository.fetchPage(filter: nextFilter);
      if (!mounted || !_requestEpoch.isCurrent(epoch)) return;
      state = NotificationListState(
        phase: NotificationListPhase.ready,
        filter: nextFilter,
        items: page.items,
        cursor: page.cursor,
        hasMore: page.hasMore,
      );
    } on Object catch (error) {
      if (!mounted || !_requestEpoch.isCurrent(epoch)) return;
      state = NotificationListState(
        phase: NotificationListPhase.failed,
        filter: nextFilter,
        failure: mapApplicationFailure(error, '通知列表加载失败，请稍后重试。'),
      );
    }
  }

  Future<void> loadMore() async {
    if (!mounted ||
        state.phase != NotificationListPhase.ready ||
        state.isBusy ||
        !state.hasMore) {
      return;
    }
    final epoch = _requestEpoch.current;
    final before = state;
    state = _readyFrom(before, isLoadingMore: true, clearFailures: true);
    try {
      final page = await _repository.fetchPage(
        filter: before.filter,
        cursor: before.cursor,
      );
      if (!mounted || !_requestEpoch.isCurrent(epoch)) return;
      state = NotificationListState(
        phase: NotificationListPhase.ready,
        filter: before.filter,
        items: mergeUniqueBy(
          before.items,
          page.items,
          keyOf: (item) => item.id,
        ),
        cursor: page.cursor,
        hasMore: page.hasMore,
      );
    } on Object catch (error) {
      if (!mounted || !_requestEpoch.isCurrent(epoch)) return;
      final failure = mapApplicationFailure(error, '更多通知加载失败，请稍后重试。');
      if (failure.isInvalidCursor) {
        await load(filter: before.filter);
        return;
      }
      state = _readyFrom(before, loadMoreFailure: failure, clearFailures: true);
    }
  }

  Future<bool> markRead(String id) async {
    if (!mounted ||
        state.phase != NotificationListPhase.ready ||
        state.isBusy) {
      return false;
    }
    final index = state.items.indexWhere((item) => item.id == id);
    if (index < 0 || state.items[index].isRead) return true;
    final epoch = _requestEpoch.current;
    final before = state;
    final optimistic = [...before.items];
    optimistic[index] = optimistic[index].copyWith(isRead: true);
    state = NotificationListState(
      phase: NotificationListPhase.ready,
      filter: before.filter,
      items: optimistic,
      cursor: before.cursor,
      hasMore: before.hasMore,
      loadMoreFailure: before.loadMoreFailure,
      pendingId: id,
      pendingAction: NotificationPendingAction.markRead,
    );
    _unread.decrement();
    try {
      await _repository.setReadStatus(id, isRead: true);
      if (!mounted) return false;
      unawaited(_unread.refresh(force: true));
      if (!_requestEpoch.isCurrent(epoch)) return false;
      state = _readyFrom(state);
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      unawaited(_unread.refresh(force: true));
      if (!_requestEpoch.isCurrent(epoch)) return false;
      state = _readyFrom(
        before,
        actionFailure: mapApplicationFailure(error, '通知没有标记为已读，请稍后重试。'),
      );
      return false;
    }
  }

  Future<bool> remove(String id) async {
    if (!mounted ||
        state.phase != NotificationListPhase.ready ||
        state.isBusy) {
      return false;
    }
    final item = state.items
        .where((candidate) => candidate.id == id)
        .firstOrNull;
    if (item == null) return false;
    final epoch = _requestEpoch.current;
    final before = state;
    state = _readyFrom(
      before,
      pendingId: id,
      pendingAction: NotificationPendingAction.remove,
      clearFailures: true,
    );
    try {
      await _repository.remove(id);
      if (!mounted) return false;
      if (!item.isRead) _unread.decrement();
      unawaited(_unread.refresh(force: true));
      if (!_requestEpoch.isCurrent(epoch)) return false;
      final updated = before.items
          .where((candidate) => candidate.id != id)
          .toList(growable: false);
      state = NotificationListState(
        phase: NotificationListPhase.ready,
        filter: before.filter,
        items: updated,
        // Cursor is opaque even when its bytes happen to equal a removed ID.
        cursor: before.cursor,
        hasMore: before.hasMore,
        loadMoreFailure: before.loadMoreFailure,
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      unawaited(_unread.refresh(force: true));
      if (!_requestEpoch.isCurrent(epoch)) return false;
      state = _readyFrom(
        before,
        actionFailure: mapApplicationFailure(error, '通知没有删除，请稍后重试。'),
      );
      return false;
    }
  }

  Future<bool> markAllRead() async {
    if (!mounted ||
        state.phase != NotificationListPhase.ready ||
        state.isBusy) {
      return false;
    }
    final epoch = _requestEpoch.current;
    final before = state;
    state = NotificationListState(
      phase: NotificationListPhase.ready,
      filter: before.filter,
      items: before.items
          .map((item) => item.copyWith(isRead: true))
          .toList(growable: false),
      cursor: before.cursor,
      hasMore: before.hasMore,
      loadMoreFailure: before.loadMoreFailure,
      pendingAction: NotificationPendingAction.markAllRead,
    );
    _unread.clear();
    try {
      await _repository.markAllRead();
      if (!mounted) return false;
      unawaited(_unread.refresh(force: true));
      if (!_requestEpoch.isCurrent(epoch)) return false;
      state = _readyFrom(state);
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      unawaited(_unread.refresh(force: true));
      if (!_requestEpoch.isCurrent(epoch)) return false;
      state = _readyFrom(
        before,
        actionFailure: mapApplicationFailure(error, '全部标为已读失败，请稍后重试。'),
      );
      return false;
    }
  }

  void clearActionFailure() {
    if (!mounted || state.actionFailure == null) return;
    state = _readyFrom(state);
  }

  @override
  void dispose() {
    _requestEpoch.invalidate();
    super.dispose();
  }

  NotificationListState _readyFrom(
    NotificationListState source, {
    bool isLoadingMore = false,
    ApiFailure? loadMoreFailure,
    String? pendingId,
    NotificationPendingAction? pendingAction,
    ApiFailure? actionFailure,
    bool clearFailures = false,
  }) {
    return NotificationListState(
      phase: NotificationListPhase.ready,
      filter: source.filter,
      items: source.items,
      cursor: source.cursor,
      hasMore: source.hasMore,
      isLoadingMore: isLoadingMore,
      loadMoreFailure: clearFailures
          ? loadMoreFailure
          : loadMoreFailure ?? source.loadMoreFailure,
      pendingId: pendingId,
      pendingAction: pendingAction,
      actionFailure: actionFailure,
    );
  }
}

final notificationListControllerProvider =
    StateNotifierProvider.autoDispose<
      NotificationListController,
      NotificationListState
    >(
      (ref) {
        ref.watch(viewerScopeProvider);
        return NotificationListController(
          ref.watch(notificationRepositoryProvider),
          ref.watch(notificationUnreadControllerProvider.notifier),
        );
      },
      dependencies: [
        viewerScopeProvider,
        notificationRepositoryProvider,
        notificationUnreadControllerProvider,
      ],
    );
