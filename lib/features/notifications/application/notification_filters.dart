import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_filter.dart';

export 'package:wenyousite_mobile/features/notifications/domain/notification_filter.dart';

abstract final class NotificationFilters {
  static const all = NotificationFilter.all;

  static final List<NotificationFilter> values = List.unmodifiable([
    all,
    for (final id in WenyouNotificationContract.groupOrder)
      NotificationFilter(
        id: id,
        eventTypes: List.unmodifiable(
          WenyouNotificationContract.eventTypes[id] ?? const <String>[],
        ),
      ),
  ]);

  static NotificationFilter byId(String id) =>
      values.firstWhere((filter) => filter.id == id, orElse: () => all);
}

extension NotificationFilterPresentation on NotificationFilter {
  String get label => id == NotificationFilter.all.id
      ? WenyouNotificationContract.allLabel
      : WenyouNotificationContract.labels[id] ?? id;
}
