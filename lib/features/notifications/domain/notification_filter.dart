class NotificationFilter {
  const NotificationFilter({required this.id, required this.eventTypes});

  static const all = NotificationFilter(id: 'all', eventTypes: []);

  final String id;
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
