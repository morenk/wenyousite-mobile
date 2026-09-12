import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/background_execution.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/core/application/background_reminder_preference.dart';
import 'package:wenyousite_mobile/core/application/notification_guidance.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/notification_permission_guidance.dart';

import '../users/me_page_session_fixtures.dart';

void main() {
  late _Gateway gateway;
  late _Execution execution;
  late ProviderContainer container;
  late _Store store;

  setUp(() {
    gateway = _Gateway();
    execution = _Execution();
    store = _Store();
    container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(MePageTestMemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(MePageTestFakeSessionRemote()),
        backgroundNotificationGatewayProvider.overrideWithValue(gateway),
        backgroundExecutionGatewayProvider.overrideWithValue(execution),
        notificationGuidanceStoreProvider.overrideWithValue(store),
      ],
    );
  });
  tearDown(() => container.dispose());

  Future<void> mount(WidgetTester tester, {double scale = 1}) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: const Scaffold(
              body: NotificationPermissionGuidance(child: _Page()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> login() => container
      .read(sessionControllerProvider.notifier)
      .authenticate(mePageTestTokens);

  testWidgets('首次登录只引导，点击才授权，成功后再由用户打开消息频道', (tester) async {
    await login();
    await mount(tester);
    expect(find.text('允许通知'), findsOneWidget);
    expect(find.text('原页面可继续使用'), findsOneWidget);
    expect(gateway.requests, 0);
    expect(store.handled, isTrue);
    await tester.tap(find.text('允许通知'));
    await tester.pumpAndSettle();
    expect(gateway.requests, 1);
    expect(execution.opens, 0);
    expect(find.textContaining('悬浮通知'), findsOneWidget);
    expect(find.textContaining('系统默认'), findsNothing);
    await tester.tap(find.text('原页面可继续使用'));
    await tester.pumpAndSettle();
    expect(find.text('页面操作 1'), findsOneWidget);
    await tester.tap(find.text('去设置'));
    await tester.pumpAndSettle();
    expect(execution.opens, 1);
    expect(find.byType(MaterialBanner), findsNothing);
    expect(find.text('页面操作 1'), findsOneWidget);
  });

  testWidgets('拒绝后不自动重试，跳过跨账号和组件重建保留', (tester) async {
    gateway.grant = false;
    await login();
    await mount(tester);
    await tester.tap(find.text('允许通知'));
    await tester.pumpAndSettle();
    expect(find.text('去设置'), findsOneWidget);
    expect(find.text('允许通知'), findsNothing);
    await tester.tap(find.text('暂不设置'));
    await container.read(sessionControllerProvider.notifier).logoutLocally();
    await login();
    await tester.pumpWidget(const SizedBox());
    await mount(tester);
    expect(find.byType(MaterialBanner), findsNothing);
    expect(gateway.requests, 1);
  });

  testWidgets('游客和关闭功能时不消费引导，开启后展示，关闭再开不重复', (tester) async {
    await mount(tester);
    expect(store.handled, isFalse);
    await container
        .read(backgroundReminderPreferenceProvider.notifier)
        .select(false);
    await login();
    await tester.pumpAndSettle();
    expect(store.handled, isFalse);
    await container
        .read(backgroundReminderPreferenceProvider.notifier)
        .select(true);
    await tester.pumpAndSettle();
    expect(find.byType(MaterialBanner), findsOneWidget);
    await container
        .read(backgroundReminderPreferenceProvider.notifier)
        .select(false);
    await container
        .read(backgroundReminderPreferenceProvider.notifier)
        .select(true);
    await tester.pumpAndSettle();
    expect(find.byType(MaterialBanner), findsNothing);
  });

  testWidgets('已授权不再申请；设置失败保留重试，360dp 大字无溢出', (tester) async {
    gateway.enabled = true;
    execution.fail = true;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await login();
    await mount(tester, scale: 2);
    await tester.ensureVisible(find.text('去设置'));
    await tester.tap(find.text('去设置'));
    await tester.pumpAndSettle();
    expect(find.textContaining('打开失败'), findsOneWidget);
    expect(gateway.requests, 0);
    execution.fail = false;
    await tester.ensureVisible(find.text('去设置'));
    await tester.tap(find.text('去设置'));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialBanner), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('后台不消费引导，恢复后展示，退出立即隐藏', (tester) async {
    await mount(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await login();
    await tester.pump();
    expect(store.handled, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(MaterialBanner), findsOneWidget);
    await container.read(sessionControllerProvider.notifier).logoutLocally();
    await tester.pumpAndSettle();
    expect(find.byType(MaterialBanner), findsNothing);
  });
}

class _Page extends StatefulWidget {
  const _Page();
  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> {
  int taps = 0;
  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: () => setState(() => taps++),
      child: Text(taps == 0 ? '原页面可继续使用' : '页面操作 $taps'),
    ),
  );
}

class _Store implements NotificationGuidanceStore {
  bool handled = false;
  @override
  Future<bool> readHandled() async => handled;
  @override
  Future<void> writeHandled() async => handled = true;
}

class _Gateway implements BackgroundNotificationGateway {
  bool enabled = false;
  bool grant = true;
  int requests = 0;
  @override
  bool get isSupported => true;
  @override
  Stream<String> get notificationTaps => const Stream.empty();
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> canNotify() async => enabled;
  @override
  Future<bool> requestPermission() async {
    requests++;
    return enabled = grant;
  }

  @override
  Future<void> showAlerts(List<BackgroundLocalAlert> alerts) async {}
  @override
  Future<String?> takeLaunchPayload() async => null;
}

class _Execution extends UnsupportedBackgroundExecutionGateway {
  int opens = 0;
  bool fail = false;
  @override
  bool get isSupported => true;
  @override
  Future<void> openNotificationSettings() async {
    opens++;
    if (fail) throw StateError('settings unavailable');
  }
}
