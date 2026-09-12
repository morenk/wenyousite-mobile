import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/background_execution.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/core/application/background_reminder_preference.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/app_shell/application/background_online_poller.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/app_scaffold.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_repository_ports.dart';
import '../users/me_page_session_fixtures.dart';

void main() {
  testWidgets('真实应用壳按生命周期运行，后台无帧退出也立即取消', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final execution = _Execution();
    final poller = _Poller();
    final repository = _Notifications();
    var hasBaseline = false;
    when(() => poller.hasBaseline).thenAnswer((_) => hasBaseline);
    when(() => poller.invalidate()).thenAnswer((_) => hasBaseline = false);
    when(() => poller.ensureBaseline(includeDirectMessages: false)).thenAnswer((
      _,
    ) async {
      hasBaseline = true;
      return true;
    });
    when(() => poller.poll(includeDirectMessages: false)).thenAnswer(
      (_) async => BackgroundOnlinePollBatch(
        alerts: const [],
        commitCallback: () => true,
      ),
    );
    when(() => repository.fetchUnreadCount()).thenAnswer((_) async => 0);
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(MePageTestMemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(MePageTestFakeSessionRemote()),
        backgroundExecutionGatewayProvider.overrideWithValue(execution),
        backgroundNotificationGatewayProvider.overrideWithValue(_Gateway()),
        backgroundOnlinePollerProvider.overrideWithValue(poller),
        notificationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    final session = container.read(sessionControllerProvider.notifier);
    await session.authenticate(mePageTestTokens);
    final router = GoRouter(
      initialLocation: '/test',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) =>
              AppScaffold(navigationShell: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/test', builder: (_, _) => const SizedBox()),
              ],
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(execution.enabled, isTrue);
    expect(execution.starts, 0);
    verifyNever(() => poller.ensureBaseline(includeDirectMessages: false));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    await tester.pump();
    verify(() => poller.ensureBaseline(includeDirectMessages: false)).called(1);
    clearInteractions(repository);
    await tester.pump(const Duration(seconds: 30));
    await tester.pump();
    verify(() => poller.poll(includeDirectMessages: false)).called(1);
    verifyNever(() => repository.fetchUnreadCount());

    // 不发新帧，验证认证作用域监听立即撤销后台资格。
    await session.logoutLocally();
    await Future<void>.value();
    expect(execution.enabled, isFalse);
    await tester.pump(const Duration(seconds: 30));
    verifyNever(() => poller.poll(includeDirectMessages: false));
    expect(
      container.read(backgroundReminderPreferenceProvider).enabled,
      isTrue,
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    await session.authenticate(mePageTestTokens);
    await tester.pumpAndSettle();
    expect(execution.enabled, isTrue);
    await container
        .read(backgroundReminderPreferenceProvider.notifier)
        .select(false);
    expect(execution.enabled, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 30));
    verifyNever(() => poller.poll(includeDirectMessages: false));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    router.dispose();
    container.dispose();
    expect(tester.takeException(), isNull);
  });
}

class _Poller extends Mock implements BackgroundOnlinePoller {}

class _Notifications extends Mock implements NotificationRepository {}

class _Execution extends UnsupportedBackgroundExecutionGateway {
  bool enabled = false;
  int starts = 0;
  @override
  bool get isSupported => true;
  @override
  Future<void> setEnabled(bool value) async => enabled = value;
  @override
  Future<BackgroundExecutionStatus> start() async {
    starts++;
    return BackgroundExecutionStatus.running;
  }

  @override
  Future<BackgroundExecutionStatus> getStatus() async =>
      BackgroundExecutionStatus.running;
}

class _Gateway implements BackgroundNotificationGateway {
  @override
  bool get isSupported => true;
  @override
  Stream<String> get notificationTaps => const Stream.empty();
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> canNotify() async => true;
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<String?> takeLaunchPayload() async => null;
  @override
  Future<void> showAlerts(List<BackgroundLocalAlert> alerts) async {}
}
