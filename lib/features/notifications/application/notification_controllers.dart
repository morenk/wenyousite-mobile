import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_repository_ports.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_states.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';

export 'package:wenyousite_mobile/features/notifications/application/notification_states.dart';

class NotificationUnreadController
    extends StateNotifier<NotificationUnreadState> {
  NotificationUnreadController(
    this._repository, {
    bool autoStart = true,
    Duration refreshInterval = const Duration(seconds: 30),
  }) : super(const NotificationUnreadState()) {
    if (autoStart) {
      refresh();
      _timer = Timer.periodic(refreshInterval, (_) => refresh());
    }
  }

  final NotificationRepository _repository;
  Timer? _timer;

  Future<void> refresh() async {
    if (state.isLoading) return;
    state = NotificationUnreadState(count: state.count, isLoading: true);
    try {
      final count = await _repository.fetchUnreadCount();
      if (!mounted) return;
      state = NotificationUnreadState(count: count < 0 ? 0 : count);
    } on Object catch (error) {
      if (!mounted) return;
      state = NotificationUnreadState(
        count: state.count,
        failure: _asFailure(error, '未读通知数没有同步完成。'),
      );
    }
  }

  void decrement() => _setCount(state.count - 1);

  void clear() => _setCount(0);

  void _setCount(int value) {
    state = NotificationUnreadState(count: value < 0 ? 0 : value);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final notificationUnreadControllerProvider =
    StateNotifierProvider<
      NotificationUnreadController,
      NotificationUnreadState
    >((ref) {
      final authenticated = ref.watch(
        sessionControllerProvider.select((session) => session.isAuthenticated),
      );
      return NotificationUnreadController(
        ref.watch(notificationRepositoryProvider),
        autoStart: authenticated,
      );
    }, dependencies: [notificationRepositoryProvider]);

class NotificationListController extends StateNotifier<NotificationListState> {
  NotificationListController(this._repository, this._unread)
    : super(const NotificationListState.loading()) {
    load();
  }

  final NotificationRepository _repository;
  final NotificationUnreadController _unread;
  var _loadEpoch = 0;

  Future<void> selectFilter(NotificationFilter filter) async {
    if (filter == state.filter) return;
    await load(filter: filter);
  }

  Future<void> load({NotificationFilter? filter}) async {
    final nextFilter = filter ?? state.filter;
    final epoch = ++_loadEpoch;
    state = NotificationListState.loading(filter: nextFilter);
    try {
      final page = await _repository.fetchPage(filter: nextFilter);
      if (!mounted || epoch != _loadEpoch) return;
      state = NotificationListState(
        phase: NotificationListPhase.ready,
        filter: nextFilter,
        items: page.items,
        cursor: page.cursor,
        hasMore: page.hasMore,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _loadEpoch) return;
      state = NotificationListState(
        phase: NotificationListPhase.failed,
        filter: nextFilter,
        failure: _asFailure(error, '通知列表没有加载完成，请稍后重试。'),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.phase != NotificationListPhase.ready ||
        state.isBusy ||
        !state.hasMore) {
      return;
    }
    final epoch = _loadEpoch;
    final before = state;
    state = _readyFrom(before, isLoadingMore: true, clearFailures: true);
    try {
      final page = await _repository.fetchPage(
        filter: before.filter,
        cursor: before.cursor,
      );
      if (!mounted || epoch != _loadEpoch) return;
      state = NotificationListState(
        phase: NotificationListPhase.ready,
        filter: before.filter,
        items: List.unmodifiable([...before.items, ...page.items]),
        cursor: page.cursor,
        hasMore: page.hasMore,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _loadEpoch) return;
      state = _readyFrom(
        before,
        loadMoreFailure: _asFailure(error, '更多通知没有加载完成，请稍后重试。'),
        clearFailures: true,
      );
    }
  }

  Future<bool> markRead(String id) async {
    if (state.phase != NotificationListPhase.ready || state.isMutating) {
      return false;
    }
    final index = state.items.indexWhere((item) => item.id == id);
    if (index < 0 || state.items[index].isRead) return true;
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
      state = _readyFrom(state);
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = _readyFrom(
        before,
        actionFailure: _asFailure(error, '通知没有标记为已读，请稍后重试。'),
      );
      unawaited(_unread.refresh());
      return false;
    }
  }

  Future<bool> remove(String id) async {
    if (state.phase != NotificationListPhase.ready || state.isMutating) {
      return false;
    }
    final item = state.items
        .where((candidate) => candidate.id == id)
        .firstOrNull;
    if (item == null) return false;
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
      final updated = before.items
          .where((candidate) => candidate.id != id)
          .toList(growable: false);
      final nextCursor = before.cursor == id
          ? (updated.isEmpty ? null : updated.last.id)
          : before.cursor;
      state = NotificationListState(
        phase: NotificationListPhase.ready,
        filter: before.filter,
        items: updated,
        cursor: nextCursor,
        hasMore: before.hasMore,
        loadMoreFailure: before.loadMoreFailure,
      );
      if (!item.isRead) _unread.decrement();
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = _readyFrom(
        before,
        actionFailure: _asFailure(error, '通知没有删除，请稍后重试。'),
      );
      return false;
    }
  }

  Future<bool> markAllRead() async {
    if (state.phase != NotificationListPhase.ready ||
        state.isMutating ||
        !state.hasUnread) {
      return false;
    }
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
      state = _readyFrom(state);
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = _readyFrom(
        before,
        actionFailure: _asFailure(error, '全部已读没有完成，请稍后重试。'),
      );
      unawaited(_unread.refresh());
      return false;
    }
  }

  void clearActionFailure() {
    if (state.actionFailure == null) return;
    state = _readyFrom(state);
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
        return NotificationListController(
          ref.watch(notificationRepositoryProvider),
          ref.watch(notificationUnreadControllerProvider.notifier),
        );
      },
      dependencies: [
        notificationRepositoryProvider,
        notificationUnreadControllerProvider,
      ],
    );

ApiFailure _asFailure(Object error, String fallback) {
  return error is ApiFailure
      ? error
      : ApiFailure(userMessage: fallback, cause: error);
}
