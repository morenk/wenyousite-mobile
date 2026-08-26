import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackgroundLocalAlert {
  const BackgroundLocalAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

abstract interface class BackgroundNotificationGateway {
  bool get isSupported;

  Stream<String> get notificationTaps;

  Future<void> initialize();

  Future<bool> canNotify();

  Future<bool> requestPermission();

  Future<void> showAlerts(List<BackgroundLocalAlert> alerts);

  Future<String?> takeLaunchPayload();
}

final backgroundNotificationGatewayProvider =
    Provider<BackgroundNotificationGateway>(
      (ref) => const _UnsupportedBackgroundNotificationGateway(),
    );

class _UnsupportedBackgroundNotificationGateway
    implements BackgroundNotificationGateway {
  const _UnsupportedBackgroundNotificationGateway();

  @override
  bool get isSupported => false;

  @override
  Stream<String> get notificationTaps => const Stream.empty();

  @override
  Future<bool> canNotify() async => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> showAlerts(List<BackgroundLocalAlert> alerts) async {}

  @override
  Future<String?> takeLaunchPayload() async => null;
}

class BackgroundOnlineState {
  const BackgroundOnlineState({
    required this.supported,
    this.isLoading = true,
    this.permissionDenied = false,
    this.failureMessage,
  });

  final bool supported;
  final bool isLoading;
  final bool permissionDenied;
  final String? failureMessage;

  bool get canRun => supported && !isLoading && !permissionDenied;
}

class BackgroundOnlineController extends StateNotifier<BackgroundOnlineState> {
  BackgroundOnlineController(this._gateway)
    : super(BackgroundOnlineState(supported: _gateway.isSupported)) {
    _load();
  }

  final BackgroundNotificationGateway _gateway;
  int _operationEpoch = 0;

  /// Requests notification access when an authenticated foreground session is
  /// ready. The best-effort polling policy itself is always enabled.
  Future<void> activateForAuthenticatedSession() async {
    if (!state.supported) return;
    final epoch = ++_operationEpoch;
    state = const BackgroundOnlineState(supported: true);
    try {
      await _gateway.initialize();
      final alreadyGranted = await _gateway.canNotify();
      final granted = alreadyGranted || await _gateway.requestPermission();
      if (!mounted || epoch != _operationEpoch) return;
      state = BackgroundOnlineState(
        supported: true,
        isLoading: false,
        permissionDenied: !granted,
      );
    } on Object {
      if (!mounted || epoch != _operationEpoch) return;
      state = const BackgroundOnlineState(
        supported: true,
        isLoading: false,
        permissionDenied: true,
        failureMessage: '后台在线提醒准备失败，请稍后重试。',
      );
    }
  }

  Future<void> refreshPermission() async {
    if (!state.supported) return;
    final epoch = ++_operationEpoch;
    try {
      final granted = await _gateway.canNotify();
      if (!mounted || epoch != _operationEpoch) return;
      state = BackgroundOnlineState(
        supported: true,
        isLoading: false,
        permissionDenied: !granted,
      );
    } on Object {
      if (!mounted || epoch != _operationEpoch) return;
      state = BackgroundOnlineState(
        supported: true,
        isLoading: false,
        permissionDenied: state.permissionDenied,
        failureMessage: '系统通知状态读取失败，请重试。',
      );
    }
  }

  Future<void> markPermissionDenied() async {
    if (!mounted || !state.supported) return;
    state = BackgroundOnlineState(
      supported: state.supported,
      isLoading: false,
      permissionDenied: true,
    );
  }

  Future<void> _load() async {
    if (!_gateway.isSupported) {
      state = const BackgroundOnlineState(supported: false, isLoading: false);
      return;
    }
    final epoch = _operationEpoch;
    try {
      await _gateway.initialize();
      final granted = await _gateway.canNotify();
      if (!mounted || epoch != _operationEpoch) return;
      state = BackgroundOnlineState(
        supported: true,
        isLoading: false,
        permissionDenied: !granted,
      );
    } on Object {
      if (!mounted || epoch != _operationEpoch) return;
      state = const BackgroundOnlineState(
        supported: true,
        isLoading: false,
        permissionDenied: true,
        failureMessage: '系统通知状态读取失败，请稍后重试。',
      );
    }
  }
}

final backgroundOnlineControllerProvider =
    StateNotifierProvider<BackgroundOnlineController, BackgroundOnlineState>((
      ref,
    ) {
      return BackgroundOnlineController(
        ref.watch(backgroundNotificationGatewayProvider),
      );
    });

enum BackgroundNotificationDestination {
  notification,
  directMessage,
  messageCenter,
}

class BackgroundNotificationPayload {
  const BackgroundNotificationPayload._(this.destination, {this.value});

  factory BackgroundNotificationPayload.notification(String? location) {
    final safeLocation = _safeNotificationLocation(location);
    return BackgroundNotificationPayload._(
      BackgroundNotificationDestination.notification,
      value: safeLocation,
    );
  }

  const BackgroundNotificationPayload.directMessage(String conversationId)
    : this._(
        BackgroundNotificationDestination.directMessage,
        value: conversationId,
      );

  const BackgroundNotificationPayload.messageCenter()
    : this._(BackgroundNotificationDestination.messageCenter);

  final BackgroundNotificationDestination destination;
  final String? value;

  String encode() => jsonEncode({
    'v': 1,
    'type': destination.name,
    if (value != null) 'value': value,
  });

  String get location => switch (destination) {
    BackgroundNotificationDestination.notification => value ?? '/notifications',
    BackgroundNotificationDestination.directMessage => Uri(
      pathSegments: ['', 'messages', value!],
    ).toString(),
    BackgroundNotificationDestination.messageCenter => '/notifications',
  };

  static BackgroundNotificationPayload? tryParse(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> || decoded['v'] != 1) return null;
      final type = decoded['type'];
      final value = decoded['value'];
      if (type == BackgroundNotificationDestination.notification.name) {
        if (value != null && value is! String) return null;
        return BackgroundNotificationPayload.notification(value as String?);
      }
      if (type == BackgroundNotificationDestination.directMessage.name &&
          value is String &&
          value.trim().isNotEmpty) {
        return BackgroundNotificationPayload.directMessage(value.trim());
      }
      if (type == BackgroundNotificationDestination.messageCenter.name &&
          value == null) {
        return const BackgroundNotificationPayload.messageCenter();
      }
    } on Object {
      return null;
    }
    return null;
  }
}

String? _safeNotificationLocation(String? location) {
  final value = location?.trim();
  if (value == null || value.isEmpty || !value.startsWith('/')) return null;
  if (value.startsWith('//') || value.startsWith('/auth/')) return null;
  const allowedPrefixes = [
    '/notifications',
    '/threads/',
    '/moments/',
    '/users/',
  ];
  return allowedPrefixes.any(value.startsWith) ? value : null;
}
