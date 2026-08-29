import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/core/platform/android_background_notification_gateway.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      const InitializationSettings(
        android: AndroidInitializationSettings('fallback'),
      ),
    );
    registerFallbackValue(
      const AndroidNotificationChannel('fallback', 'fallback'),
    );
    registerFallbackValue(const NotificationDetails());
  });

  late _NotificationPlugin plugin;
  late _AndroidNotificationPlugin android;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    plugin = _NotificationPlugin();
    android = _AndroidNotificationPlugin();
    when(
      () => plugin.initialize(
        settings: any(named: 'settings'),
        onDidReceiveNotificationResponse: any(
          named: 'onDidReceiveNotificationResponse',
        ),
      ),
    ).thenAnswer((_) async => true);
    when(
      () => plugin.getNotificationAppLaunchDetails(),
    ).thenAnswer((_) async => null);
    when(
      () => android.createNotificationChannel(any()),
    ).thenAnswer((_) async {});
    when(() => android.areNotificationsEnabled()).thenAnswer((_) async => true);
    when(() => android.getNotificationChannels()).thenAnswer(
      (_) async => const [
        AndroidNotificationChannel(
          'wenyou_messages_v1',
          '新消息提醒',
          importance: Importance.high,
        ),
      ],
    );
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('初始化显式创建高重要性消息频道并校验频道可用', () async {
    final gateway = AndroidBackgroundNotificationGateway(
      plugin: plugin,
      androidPlugin: android,
    );

    expect(await gateway.canNotify(), isTrue);

    final channel =
        verify(
              () => android.createNotificationChannel(captureAny()),
            ).captured.single
            as AndroidNotificationChannel;
    expect(channel.id, 'wenyou_messages_v1');
    expect(channel.importance, Importance.high);
    verify(
      () => plugin.initialize(
        settings: any(named: 'settings'),
        onDidReceiveNotificationResponse: any(
          named: 'onDidReceiveNotificationResponse',
        ),
      ),
    ).called(1);
  });

  test('全局通知或消息频道关闭时均报告不可展示', () async {
    when(
      () => android.areNotificationsEnabled(),
    ).thenAnswer((_) async => false);
    final globallyBlocked = AndroidBackgroundNotificationGateway(
      plugin: plugin,
      androidPlugin: android,
    );
    expect(await globallyBlocked.canNotify(), isFalse);

    plugin = _NotificationPlugin();
    android = _AndroidNotificationPlugin();
    when(
      () => plugin.initialize(
        settings: any(named: 'settings'),
        onDidReceiveNotificationResponse: any(
          named: 'onDidReceiveNotificationResponse',
        ),
      ),
    ).thenAnswer((_) async => true);
    when(
      () => plugin.getNotificationAppLaunchDetails(),
    ).thenAnswer((_) async => null);
    when(
      () => android.createNotificationChannel(any()),
    ).thenAnswer((_) async {});
    when(() => android.areNotificationsEnabled()).thenAnswer((_) async => true);
    when(() => android.getNotificationChannels()).thenAnswer(
      (_) async => const [
        AndroidNotificationChannel(
          'wenyou_messages_v1',
          '新消息提醒',
          importance: Importance.none,
        ),
      ],
    );
    final channelBlocked = AndroidBackgroundNotificationGateway(
      plugin: plugin,
      androidPlugin: android,
    );
    expect(await channelBlocked.canNotify(), isFalse);
  });

  test('系统卡片使用稳定频道、高优先级和锁屏隐私配置', () async {
    when(
      () => plugin.show(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        notificationDetails: any(named: 'notificationDetails'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    final gateway = AndroidBackgroundNotificationGateway(
      plugin: plugin,
      androidPlugin: android,
    );

    await gateway.showAlerts(const [
      BackgroundLocalAlert(
        id: 7,
        title: '小温',
        body: '发来一条新私聊',
        payload: '{"v":1,"type":"directMessage","value":"c1"}',
      ),
    ]);

    final details =
        verify(
              () => plugin.show(
                id: 7,
                title: '小温',
                body: '发来一条新私聊',
                notificationDetails: captureAny(named: 'notificationDetails'),
                payload: any(named: 'payload'),
              ),
            ).captured.single
            as NotificationDetails;
    final androidDetails = details.android!;
    expect(androidDetails.channelId, 'wenyou_messages_v1');
    expect(androidDetails.importance, Importance.high);
    expect(androidDetails.priority, Priority.high);
    expect(androidDetails.visibility, NotificationVisibility.private);
    expect(androidDetails.category, AndroidNotificationCategory.message);
    expect(androidDetails.icon, 'ic_stat_wenyou');
  });
}

class _NotificationPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class _AndroidNotificationPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}
