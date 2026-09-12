import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/background_notification_navigation.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_controllers.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_filters.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_repository_ports.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';

import '../users/me_page_session_fixtures.dart';

void main() {
  late _Gateway gateway;
  late _Repository repository;
  late ProviderContainer container;
  late GoRouter router;
  String payload({String owner = 'me'}) =>
      BackgroundNotificationPayload.notification(
        '/threads/thread-1',
        notificationId: 'n1',
        recipientId: owner,
      ).encode();

  setUp(() {
    gateway = _Gateway();
    repository = _Repository();
    router = GoRouter(
      initialLocation: '/home',
      routes: [
        for (final path in [
          '/home',
          '/threads/thread-1',
          '/notifications',
          '/messages/c1',
        ])
          GoRoute(
            path: path,
            builder: (_, _) => Scaffold(body: Text(path)),
          ),
      ],
    );
    container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(MePageTestMemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(MePageTestFakeSessionRemote()),
        notificationRepositoryProvider.overrideWithValue(repository),
        backgroundNotificationGatewayProvider.overrideWithValue(gateway),
        appRouterProvider.overrideWithValue(router),
      ],
    );
  });
  tearDown(() {
    container.dispose();
    router.dispose();
    unawaited(gateway.taps.close());
  });
  Future<void> login([String id = 'me']) => container
      .read(sessionControllerProvider.notifier)
      .authenticate(
        SessionTokens(
          accessToken:
              'test.${base64Url.encode(utf8.encode(jsonEncode({'sub': id})))}.test',
          refreshToken: 'test',
        ),
      );
  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
          builder: (_, child) =>
              BackgroundNotificationNavigation(child: child!),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String raw) async {
    gateway.taps.add(raw);
    await tester.pump();
    await tester.pumpAndSettle();
    // 路由解析在通知事件的帧结束回调后完成。
    await tester.pumpAndSettle();
  }

  for (final cold in [false, true]) {
    testWidgets('${cold ? '冷启动' : '热点击'}按通知 ID 已读并刷新已加载通知中心与角标', (
      tester,
    ) async {
      await login();
      final keepList = container.listen(
        notificationListControllerProvider,
        (_, _) {},
      );
      addTearDown(keepList.close);
      if (cold) gateway.launch = payload();
      await mount(tester);
      if (!cold) {
        await container
            .read(notificationListControllerProvider.notifier)
            .selectFilter(NotificationFilters.byId('subscription'));
        expect(
          container
              .read(notificationListControllerProvider)
              .items
              .single
              .isRead,
          isFalse,
        );
        await tap(tester, payload());
      }
      expect(find.text('/threads/thread-1'), findsOneWidget);
      expect(repository.reads, ['n1']);
      expect(
        container.read(notificationListControllerProvider).items.single.isRead,
        isTrue,
      );
      expect(container.read(notificationUnreadControllerProvider).count, 0);
      if (!cold) {
        expect(
          container.read(notificationListControllerProvider).filter,
          NotificationFilters.byId('subscription'),
        );
      }
    });
  }

  testWidgets('未打开通知列表也能已读，网络等待不阻挡跳转；重复点击合并', (tester) async {
    await login();
    repository.pending = Completer<void>();
    await mount(tester);
    await tap(tester, payload());
    await tap(tester, payload());
    expect(find.text('/threads/thread-1'), findsOneWidget);
    expect(repository.reads, ['n1']);
    expect(repository.pages, 0);
    repository.pending!.complete();
    await tester.pumpAndSettle();
    expect(container.read(notificationUnreadControllerProvider).count, 0);
  });

  testWidgets('旧载荷、汇总及私聊不误做通知中心单条或全部已读', (tester) async {
    await login();
    await mount(tester);
    for (final raw in [
      BackgroundNotificationPayload.notification('/threads/thread-1').encode(),
      const BackgroundNotificationPayload.messageCenter().encode(),
      const BackgroundNotificationPayload.directMessage('c1').encode(),
    ]) {
      await tap(tester, raw);
    }
    expect(repository.reads, isEmpty);
    expect(repository.allReads, 0);
    expect(find.text('/messages/c1'), findsOneWidget);
  });

  testWidgets('失败仍跳转但不伪装已读，显式重试成功后校准', (tester) async {
    await login();
    repository.fail = true;
    await mount(tester);
    await tap(tester, payload());
    expect(find.text('/threads/thread-1'), findsOneWidget);
    expect(repository.isRead, isFalse);
    expect(find.text('通知未能标为已读，请重试。'), findsOneWidget);
    repository.fail = false;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(repository.isRead, isTrue);
    expect(repository.reads, ['n1', 'n1']);
  });

  testWidgets('冷启动未登录先保留意图，正确账号登录后才已读', (tester) async {
    gateway.launch = payload();
    await mount(tester);
    expect(repository.reads, isEmpty);
    await login();
    await tester.pumpAndSettle();
    expect(repository.reads, ['n1']);
  });

  testWidgets('其他账号卡片不写入；在途切号不刷新新账号状态', (tester) async {
    await login();
    await mount(tester);
    await tap(tester, payload(owner: 'other'));
    expect(repository.reads, isEmpty);
    expect(find.text('/notifications'), findsOneWidget);
    repository.pending = Completer<void>();
    await tap(tester, payload());
    await login('other');
    final countsBefore = repository.countCalls;
    repository.pending!.complete();
    await tester.pumpAndSettle();
    expect(repository.countCalls, countsBefore);
    expect(find.text('通知未能标为已读，请重试。'), findsNothing);
  });
}

class _Repository implements NotificationRepository {
  final reads = <String>[];
  int allReads = 0;
  int pages = 0;
  int countCalls = 0;
  bool isRead = false;
  bool fail = false;
  Completer<void>? pending;
  @override
  Future<void> setReadStatus(String id, {required bool isRead}) async {
    reads.add(id);
    if (pending != null) await pending!.future;
    if (fail) throw StateError('read failed');
    this.isRead = isRead;
  }

  @override
  Future<CursorPage<NotificationListItem>> fetchPage({
    NotificationFilter filter = NotificationFilter.all,
    String? cursor,
  }) async {
    pages++;
    return CursorPage(
      items: [
        NotificationListItem(
          id: 'n1',
          recipientUserId: 'me',
          kind: NotificationKind.reply,
          content: '新回复',
          target: const NotificationTarget(
            kind: NotificationTargetKind.thread,
            threadId: 'thread-1',
          ),
          isRead: isRead,
          createdAt: DateTime.utc(2026, 9, 13),
        ),
      ],
      hasMore: false,
    );
  }

  @override
  Future<int> fetchUnreadCount() async {
    countCalls++;
    return isRead ? 0 : 1;
  }

  @override
  Future<void> markAllRead() async {
    allReads++;
  }

  @override
  Future<void> remove(String id) async {}
}

class _Gateway implements BackgroundNotificationGateway {
  final taps = StreamController<String>.broadcast(sync: true);
  String? launch;
  @override
  bool get isSupported => true;
  @override
  Stream<String> get notificationTaps => taps.stream;
  @override
  Future<String?> takeLaunchPayload() async => launch;
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> canNotify() async => true;
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> showAlerts(List<BackgroundLocalAlert> alerts) async {}
}
