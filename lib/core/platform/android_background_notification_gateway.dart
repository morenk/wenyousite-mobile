import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';

final androidBackgroundNotificationGatewayProvider =
    Provider<BackgroundNotificationGateway>(
      (ref) => AndroidBackgroundNotificationGateway(),
    );

class AndroidBackgroundNotificationGateway
    implements BackgroundNotificationGateway {
  AndroidBackgroundNotificationGateway({
    FlutterLocalNotificationsPlugin? plugin,
    this.androidPlugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       super();

  static const _messageChannelId = 'wenyou_messages_v1';
  static const _groupKey = 'site.wenyou.app.messages';
  static const _messageChannel = AndroidNotificationChannel(
    _messageChannelId,
    '新消息提醒',
    description: '温油站通知和私聊的新消息提醒',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _plugin;
  final AndroidFlutterLocalNotificationsPlugin? androidPlugin;
  final _tapController = StreamController<String>.broadcast();
  Future<void>? _initialization;
  String? _launchPayload;
  bool _launchPayloadTaken = false;

  @override
  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Stream<String> get notificationTaps => _tapController.stream;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      androidPlugin ??
      _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  @override
  Future<void> initialize() {
    if (!isSupported) return Future.value();
    return _initialization ??= _initializeOnce();
  }

  Future<void> _initializeOnce() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_wenyou'),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload?.trim();
        if (payload != null && payload.isNotEmpty) {
          _tapController.add(payload);
        }
      },
    );
    await _android?.createNotificationChannel(_messageChannel);
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      _launchPayload = details?.notificationResponse?.payload?.trim();
    }
  }

  @override
  Future<bool> canNotify() async {
    if (!isSupported) return false;
    await initialize();
    final android = _android;
    if (android == null) return false;
    final notificationsEnabled = await android.areNotificationsEnabled();
    if (notificationsEnabled != true) return false;
    final channels = await android.getNotificationChannels();
    if (channels == null) return false;
    for (final channel in channels) {
      if (channel.id == _messageChannelId) {
        return channel.importance != Importance.none;
      }
    }
    return false;
  }

  @override
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await initialize();
    final granted = await _android?.requestNotificationsPermission() ?? false;
    return granted && await canNotify();
  }

  @override
  Future<void> showAlerts(List<BackgroundLocalAlert> alerts) async {
    if (!isSupported || alerts.isEmpty) return;
    await initialize();
    for (final alert in alerts) {
      await _plugin.show(
        id: alert.id,
        title: alert.title,
        body: alert.body,
        payload: alert.payload,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _messageChannelId,
            _messageChannel.name,
            channelDescription: _messageChannel.description,
            icon: 'ic_stat_wenyou',
            importance: Importance.high,
            priority: Priority.high,
            groupKey: _groupKey,
            visibility: NotificationVisibility.private,
            category: AndroidNotificationCategory.message,
            styleInformation: BigTextStyleInformation(alert.body),
          ),
        ),
      );
    }
  }

  @override
  Future<String?> takeLaunchPayload() async {
    await initialize();
    if (_launchPayloadTaken) return null;
    _launchPayloadTaken = true;
    final payload = _launchPayload;
    return payload == null || payload.isEmpty ? null : payload;
  }
}
