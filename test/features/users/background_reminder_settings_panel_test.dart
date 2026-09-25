import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/background_execution.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/core/application/background_reminder_preference.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/features/users/presentation/background_reminder_settings_panel.dart';

void main() {
  testWidgets('320dp 两倍字号分组内的提醒和系统入口保持可用', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 960);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer(
      overrides: [
        backgroundExecutionGatewayProvider.overrideWithValue(_Execution()),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const Scaffold(
            body: WenyouSettingsBody(
              children: [
                WenyouSettingsGroup(
                  children: [BackgroundReminderSettingsPanel(embedded: true)],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('background-reminder-toggle')), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('后台消息提醒')).style?.fontWeight,
      FontWeight.w400,
    );
    expect(find.byTooltip('后台消息提醒说明'), findsNothing);
    await tester.ensureVisible(
      find.byKey(const Key('background-reminder-system-settings')),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('拒绝授权后账号设置提供手动重试，成功移除权限提示', (tester) async {
    final gateway = _Gateway();
    final container = ProviderContainer(
      overrides: [
        backgroundExecutionGatewayProvider.overrideWithValue(_Execution()),
        backgroundNotificationGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: BackgroundReminderSettingsPanel(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(gateway.requests, 0);
    expect(find.text('消息通知未开启。'), findsOneWidget);
    expect(find.text('也可在系统设置中开启。'), findsNothing);
    await tester.ensureVisible(find.text('申请权限'));
    await tester.tap(find.text('申请权限'));
    await tester.pumpAndSettle();
    expect(gateway.requests, 1);
    expect(find.text('申请权限'), findsOneWidget);
    gateway.grant = true;
    await tester.tap(find.text('申请权限'));
    await tester.pumpAndSettle();
    expect(gateway.requests, 2);
    expect(find.text('申请权限'), findsNothing);
  });
  for (final scale in [1.0, 2.0]) {
    testWidgets('360dp $scale 字号开关和系统频道入口可用', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 1000);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final execution = _Execution();
      final container = ProviderContainer(
        overrides: [
          backgroundExecutionGatewayProvider.overrideWithValue(execution),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: const Scaffold(
                body: SingleChildScrollView(
                  child: BackgroundReminderSettingsPanel(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('管理消息弹窗'), findsNothing);
      final semantics = tester.ensureSemantics();
      expect(find.byTooltip('后台消息提醒说明'), findsNothing);
      expect(
        tester
            .getSemantics(find.byTooltip('后台常驻提醒，可能增加耗电；划掉应用后停止。'))
            .getSemanticsData()
            .tooltip,
        '后台常驻提醒，可能增加耗电；划掉应用后停止。',
      );
      semantics.dispose();
      expect(find.text('后台常驻提醒，可能增加耗电；划掉应用后停止。'), findsNothing);
      await tester.longPress(find.text('后台消息提醒'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('后台常驻提醒，可能增加耗电；划掉应用后停止。'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).subtitle,
        isNull,
      );
      expect(find.textContaining('系统默认提示音'), findsNothing);
      expect(find.textContaining('30 秒'), findsNothing);
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue,
      );
      await tester.tap(find.byKey(const Key('background-reminder-toggle')));
      await tester.pumpAndSettle();
      expect(
        container.read(backgroundReminderPreferenceProvider).enabled,
        isFalse,
      );
      await tester.ensureVisible(
        find.byKey(const Key('background-reminder-system-settings')),
      );
      await tester.tap(
        find.byKey(const Key('background-reminder-system-settings')),
      );
      await tester.pumpAndSettle();
      expect(execution.settingsOpened, 1);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('非 Android 不显示开关或频道入口', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: BackgroundReminderSettingsPanel()),
        ),
      ),
    );
    expect(find.byType(SwitchListTile), findsNothing);
    expect(find.text('系统消息通知设置'), findsNothing);
  });
}

class _Execution extends UnsupportedBackgroundExecutionGateway {
  int settingsOpened = 0;
  @override
  bool get isSupported => true;
  @override
  Future<void> openNotificationSettings() async {
    settingsOpened++;
  }
}

class _Gateway implements BackgroundNotificationGateway {
  bool grant = false;
  bool enabled = false;
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
  Future<String?> takeLaunchPayload() async => null;
  @override
  Future<void> showAlerts(List<BackgroundLocalAlert> alerts) async {}
}
