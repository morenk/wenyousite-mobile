import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';

enum NotificationListPhase { loading, ready, failed }

enum NotificationPendingAction { markRead, remove, markAllRead }

class NotificationListState {
  const NotificationListState({
    required this.phase,
    this.filter = NotificationFilter.all,
    this.items = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.failure,
    this.loadMoreFailure,
    this.pendingId,
    this.pendingAction,
    this.actionFailure,
  });

  const NotificationListState.loading({this.filter = NotificationFilter.all})
    : phase = NotificationListPhase.loading,
      items = const [],
      cursor = null,
      hasMore = false,
      isLoadingMore = false,
      failure = null,
      loadMoreFailure = null,
      pendingId = null,
      pendingAction = null,
      actionFailure = null;

  final NotificationListPhase phase;
  final NotificationFilter filter;
  final List<NotificationListItem> items;
  final String? cursor;
  final bool hasMore;
  final bool isLoadingMore;
  final ApiFailure? failure;
  final ApiFailure? loadMoreFailure;
  final String? pendingId;
  final NotificationPendingAction? pendingAction;
  final ApiFailure? actionFailure;

  bool get isMutating => pendingAction != null;
  bool get isBusy => isLoadingMore || isMutating;
  bool get hasUnread => items.any((item) => !item.isRead);
}

class NotificationUnreadState {
  const NotificationUnreadState({
    this.count = 0,
    this.isLoading = false,
    this.failure,
  });

  final int count;
  final bool isLoading;
  final ApiFailure? failure;
}
