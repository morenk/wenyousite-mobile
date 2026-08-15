import 'package:flutter/foundation.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';

@immutable
class NotificationFilter {
  const NotificationFilter({
    required this.id,
    required this.label,
    required this.eventTypes,
  });

  final String id;
  final String label;
  final List<String> eventTypes;

  String? get wireValue => eventTypes.isEmpty ? null : eventTypes.join(',');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationFilter &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

abstract final class NotificationFilters {
  static const all = NotificationFilter(
    id: 'all',
    label: WenyouNotificationContract.allLabel,
    eventTypes: <String>[],
  );

  static final List<NotificationFilter> values = List.unmodifiable([
    all,
    for (final id in WenyouNotificationContract.groupOrder)
      NotificationFilter(
        id: id,
        label: WenyouNotificationContract.labels[id] ?? id,
        eventTypes: List.unmodifiable(
          WenyouNotificationContract.eventTypes[id] ?? const <String>[],
        ),
      ),
  ]);

  static NotificationFilter byId(String id) =>
      values.firstWhere((filter) => filter.id == id, orElse: () => all);
}
