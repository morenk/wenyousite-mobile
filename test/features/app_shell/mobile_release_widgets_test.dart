import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_feedback_visibility.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_notice_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_release.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update_notice.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/mobile_update_notice_dialog.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/mobile_update_notice_host.dart';

import '../../app_shell_fixtures.dart';
import '../../support/deterministic_test_fonts.dart';
import 'mobile_release_test_support.dart';
import 'mobile_update_notice_test_support.dart';

const _android = MobileClientPlatform.android;
const _installed = (platform: _android, build: 97, version: '0.8.0');
final _update = MobileUpdateInfo(
  kind: MobileUpdateKind.recommended,
  platform: _android,
  currentVersion: '0.8.0',
  currentBuild: 97,
  targetBuild: 100,
  targetVersion: '0.9.0',
  updateUri: Uri.parse(appShellTestAndroidUpdateUrl),
);
final _forced = MobileUpdateInfo(
  kind: MobileUpdateKind.required,
  platform: _android,
  currentVersion: '0.8.0',
  currentBuild: 97,
  targetBuild: 100,
  targetVersion: '0.9.0',
  updateUri: Uri.parse(appShellTestAndroidUpdateUrl),
);

class _Service extends AppShellTestFakeMobileUpdateService {
  _Service() : super(build: 97);
  InstalledAppInfo installed = const InstalledAppInfo(
    platform: _android,
    version: '0.8.0',
    build: 97,
  );
  @override
  Future<InstalledAppInfo> readInstalledApp() async => installed;
}

class _Repository implements MobileReleaseRepository {
  final targets = <MobileReleaseTarget>[];
  Future<MobileRelease?> Function(MobileReleaseTarget)? fetcher;
  @override
  Future<MobileRelease?> fetch(MobileReleaseTarget target) async {
    targets.add(target);
    return fetcher != null ? fetcher!(target) : releaseFixture(target: target);
  }
}

typedef _State = ({bool enabled, bool checking, MobileUpdateInfo? update});

class _Harness {
  final store = MemoryNoticeStore();
  final repository = _Repository();
  final service = _Service();
  final dismiss = AppShellTestMemoryRecommendedUpdateDismissStore();
  final navigator = GlobalKey<NavigatorState>();
  final visibility = WenyouFeedbackVisibility();
  final state = ValueNotifier<_State>((
    enabled: true,
    checking: false,
    update: _update,
  ));
  late final observer = visibility.createObserver();

  Widget build({bool dark = false, double textScale = 1}) => ProviderScope(
    overrides: [
      mobileReleaseRepositoryProvider.overrideWithValue(repository),
      mobileUpdateServiceProvider.overrideWithValue(service),
      mobileUpdateNoticeStoreProvider.overrideWithValue(store),
      recommendedUpdateDismissStoreProvider.overrideWithValue(dismiss),
      availableMobileReleaseUpdateProvider.overrideWith(
        (ref) async => state.value.update,
      ),
    ],
    child: ValueListenableBuilder<_State>(
      valueListenable: state,
      builder: (context, config, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigator,
        navigatorObservers: [observer],
        theme: dark ? AppTheme.dark : AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: MobileUpdateNoticeHost(
            enabled: config.enabled,
            policyChecking: config.checking,
            navigatorKey: navigator,
            visibility: visibility,
            update: config.update,
            child: config.enabled
                ? child!
                : Scaffold(
                    body: MobileUpdateNoticeDialog(
                      title: '需要更新后继续',
                      update: _forced,
                      target: releaseTarget,
                    ),
                  ),
          ),
        ),
        home: Scaffold(body: Center(child: Text('原来的任务'))),
      ),
    ),
  );

  void pending() => store.records[_android] = const MobileUpdateNoticeRecord(
    lastInstalledBuild: 90,
  );
  void dispose() {
    state.dispose();
    visibility.dispose();
  }
}

Future<void> _resume(WidgetTester tester) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  await tester.pump();
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pumpAndSettle();
}

Future<void> _close(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('mobile-update-dismiss')));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadDeterministicTestFonts);
  late _Harness h;
  setUp(() => h = _Harness());
  tearDown(() => h.dispose());

  testWidgets('推荐直接完整说明且每目标一次，关闭恢复任务，无查看入口', (tester) async {
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    expect(find.text('温油站有新版本'), findsOneWidget);
    expect(find.textContaining('**这是纯文本**'), findsOneWidget);
    expect(find.text('下载并安装'), findsOneWidget);
    expect(find.text('查看更新'), findsNothing);
    expect(h.store.records[_android]!.recommendedShown, {100});
    await _close(tester);
    expect(find.text('原来的任务'), findsOneWidget);
    await _resume(tester);
    expect(find.byType(MobileUpdateNoticeDialog), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    expect(find.byType(MobileUpdateNoticeDialog), findsNothing);
  });

  testWidgets('升级后优先实际安装版，关闭不接弹，下一前台推荐目标版', (tester) async {
    h.pending();
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    expect(find.text('已更新'), findsOneWidget);
    expect(find.textContaining('当前安装版本 0.8.0'), findsOneWidget);
    expect(find.text('下载并安装'), findsNothing);
    expect(h.repository.targets, [_installed]);
    await _close(tester);
    expect(find.byType(MobileUpdateNoticeDialog), findsNothing);
    await _resume(tester);
    expect(find.text('温油站有新版本'), findsOneWidget);
    expect(h.repository.targets, [_installed, releaseTarget]);
    expect(find.byType(MobileUpdateNoticeDialog), findsOneWidget);
  });

  testWidgets('首次迁移仅说已安装当前版本，同build重装后不重弹', (tester) async {
    h.state.value = (enabled: true, checking: false, update: null);
    h.service.installed = InstalledAppInfo(
      platform: _android,
      version: '0.8.0',
      build: 97,
      firstInstallTime: DateTime.utc(2026),
      lastUpdateTime: DateTime.utc(2026, 2),
    );
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    expect(find.text('已安装当前版本'), findsOneWidget);
    expect(find.text('已更新'), findsNothing);
    await _close(tester);
    await _resume(tester);
    expect(find.byType(MobileUpdateNoticeDialog), findsNothing);
  });

  for (final failure in ['missing', 'offline']) {
    testWidgets('安装说明$failure时冷启动和前后台均不弹空壳，恢复后只展示一次', (tester) async {
      h.state.value = (enabled: true, checking: false, update: null);
      h.service.installed = InstalledAppInfo(
        platform: _android,
        version: '0.8.0',
        build: 97,
        firstInstallTime: DateTime.utc(2026, 9, 13),
        lastUpdateTime: DateTime.utc(2026, 9, 28),
      );
      h.repository.fetcher = (_) async {
        if (failure == 'offline') throw StateError('offline');
        return null;
      };
      await tester.pumpWidget(h.build());
      await tester.pumpAndSettle();
      expect(find.byType(MobileUpdateNoticeDialog), findsNothing);
      expect(find.text('原来的任务'), findsOneWidget);
      expect(h.repository.targets, [_installed]);
      expect(h.store.records[_android]!.pendingInstalledBuild, 97);
      expect(h.store.records[_android]!.installedShown, isEmpty);
      await _resume(tester);
      expect(find.byType(MobileUpdateNoticeDialog), findsNothing);
      expect(h.repository.targets, [_installed, _installed]);

      // 新 ProviderScope 重建 tracker，读取磁盘等价记录而非进程内收据。
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.pumpWidget(h.build());
      await tester.pumpAndSettle();
      expect(find.byType(MobileUpdateNoticeDialog), findsNothing);
      expect(h.repository.targets.length, 3);
      expect(h.store.records[_android]!.installedShown, isEmpty);

      h.repository.fetcher = null;
      await _resume(tester);
      expect(find.text('已安装当前版本'), findsOneWidget);
      expect(find.textContaining('**这是纯文本**'), findsOneWidget);
      expect(find.text('知道了'), findsOneWidget);
      expect(h.store.records[_android]!.installedShown, {97});
      await _close(tester);
      await _resume(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.pumpWidget(h.build());
      await tester.pumpAndSettle();
      expect(find.byType(MobileUpdateNoticeDialog), findsNothing);
      expect(h.repository.targets.length, 4);
    });
  }

  testWidgets('缺失说明点过知道了后冷启动不再弹空壳', (tester) async {
    h.state.value = (enabled: true, checking: false, update: null);
    h.service.installed = InstalledAppInfo(
      platform: _android,
      version: '0.8.0',
      build: 97,
      firstInstallTime: DateTime.utc(2026, 9, 13),
      lastUpdateTime: DateTime.utc(2026, 9, 28),
    );
    h.repository.fetcher = (_) async => null;
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    // 旧实现走负责人原操作：暂无说明 → 知道了 → 冷启动。
    // 候选首次就不应出现空壳，两者都不能在下次启动重弹。
    if (find.byType(MobileUpdateNoticeDialog).evaluate().isNotEmpty) {
      expect(find.text('此版本暂无更新说明'), findsOneWidget);
      await tester.tap(find.text('知道了'));
      await tester.pumpAndSettle();
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    expect(find.byType(MobileUpdateNoticeDialog), findsNothing);
    expect(h.store.records[_android]!.pendingInstalledBuild, 97);
    expect(h.store.records[_android]!.installedShown, isEmpty);
  });

  testWidgets('安装说明失败不弹空壳或阻挡推荐，恢复后仍能展示安装说明', (tester) async {
    h.pending();
    h.repository.fetcher = (target) async {
      if (target.build == 97) throw StateError('offline');
      return releaseFixture(target: target);
    };
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    expect(find.text('更新说明加载失败'), findsNothing);
    expect(find.text('温油站有新版本'), findsOneWidget);
    expect(h.store.records[_android]!.pendingInstalledBuild, 97);
    expect(h.store.records[_android]!.installedShown, isEmpty);
    await _close(tester);
    expect(h.repository.targets, [_installed, releaseTarget]);
    await _resume(tester);
    expect(find.byType(MobileUpdateNoticeDialog), findsNothing);
    h.repository.fetcher = null;
    await _resume(tester);
    expect(find.text('已更新'), findsOneWidget);
    expect(h.store.records[_android]!.installedShown, {97});
  });

  for (final interruption in ['background', 'modal', 'unmount']) {
    testWidgets('安装说明预取期间$interruption阻止迟到弹窗，恢复后重新读取', (tester) async {
      h.pending();
      h.state.value = (enabled: true, checking: false, update: null);
      final response = Completer<MobileRelease?>();
      h.repository.fetcher = (_) => response.future;
      await tester.pumpWidget(h.build());
      for (var i = 0; i < 20 && h.repository.targets.isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(h.repository.targets, [_installed]);
      expect(find.byType(MobileUpdateNoticeDialog), findsNothing);
      if (interruption == 'background') {
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      } else if (interruption == 'modal') {
        unawaited(
          showDialog<void>(
            context: h.navigator.currentContext!,
            builder: (_) => const AlertDialog(title: Text('其他操作')),
          ),
        );
      } else {
        await tester.pumpWidget(const SizedBox());
      }
      await tester.pumpAndSettle();
      response.complete(releaseFixture(target: _installed));
      await tester.pumpAndSettle();
      expect(find.byType(MobileUpdateNoticeDialog), findsNothing);
      expect(h.store.records[_android]!.installedShown, isEmpty);
      expect(h.store.records[_android]!.pendingInstalledBuild, 97);

      h.repository.fetcher = null;
      if (interruption == 'background') {
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
      } else if (interruption == 'modal') {
        h.navigator.currentState!.pop();
      } else {
        await tester.pumpWidget(h.build());
      }
      await tester.pumpAndSettle();
      expect(find.text('已更新'), findsOneWidget);
      expect(h.store.records[_android]!.installedShown, {97});
      expect(h.repository.targets, [_installed, _installed]);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('安装说明目标不匹配不弹出或记账，下次可恢复正确说明', (tester) async {
    h.pending();
    h.state.value = (enabled: true, checking: false, update: null);
    h.repository.fetcher = (_) async => releaseFixture();
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    expect(find.byType(MobileUpdateNoticeDialog), findsNothing);
    expect(h.store.records[_android]!.installedShown, isEmpty);
    expect(h.store.records[_android]!.pendingInstalledBuild, 97);
    h.repository.fetcher = null;
    await _resume(tester);
    expect(find.text('已更新'), findsOneWidget);
    expect(h.store.records[_android]!.installedShown, {97});
  });

  testWidgets('弹窗接收到其他版本预取内容时只读取并展示准确目标', (tester) async {
    var visible = false;
    h.repository.fetcher = (_) async =>
        releaseFixture(target: _installed, summary: '准确版本的内容');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mobileReleaseRepositoryProvider.overrideWithValue(h.repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: MobileUpdateNoticeDialog(
              title: '已更新',
              target: _installed,
              preloadedRelease: releaseFixture(summary: '错误版本的内容'),
              onVisible: () => visible = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('错误版本的内容'), findsNothing);
    expect(find.text('准确版本的内容'), findsOneWidget);
    expect(visible, isTrue);
    expect(h.repository.targets, [_installed]);
  });

  testWidgets('明确无记录可关闭重试，不视为说明已展示', (tester) async {
    h.repository.fetcher = (_) async => null;
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    expect(find.text('此版本暂无更新说明'), findsOneWidget);
    expect(find.text('下载并安装'), findsOneWidget);
    expect(h.store.records[_android]!.recommendedShown, isEmpty);
    h.repository.fetcher = null;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(h.store.records[_android]!.recommendedShown, {100});
  });

  testWidgets('旧忽略抑制推荐；强制不受记录影响并阻断返回', (tester) async {
    h.dismiss.dismissedBuild = 100;
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    expect(find.byType(MobileUpdateNoticeDialog), findsNothing);
    h.state.value = (enabled: false, checking: false, update: _forced);
    await tester.pumpAndSettle();
    expect(find.text('需要更新后继续'), findsOneWidget);
    expect(find.byKey(const Key('mobile-update-dismiss')), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.tapAt(const Offset(2, 2));
    await tester.pumpAndSettle();
    expect(find.text('需要更新后继续'), findsOneWidget);
    expect(find.text('原来的任务'), findsNothing);
  });

  testWidgets('强制说明失败仍可下载和重试，返回不能解除阻断', (tester) async {
    h.state.value = (enabled: false, checking: false, update: _forced);
    h.repository.fetcher = (_) async => throw StateError('offline');
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    expect(find.text('更新说明加载失败'), findsOneWidget);
    expect(find.text('下载并安装'), findsOneWidget);
    expect(find.byKey(const Key('mobile-update-dismiss')), findsNothing);
    await tester.binding.handlePopRoute();
    expect(find.text('原来的任务'), findsNothing);
    h.repository.fetcher = null;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.textContaining('**这是纯文本**'), findsOneWidget);
    expect(find.text('需要更新后继续'), findsOneWidget);
    expect(h.store.records, isEmpty);
  });

  testWidgets('强制抢占加载弹窗和Navigator子树，恢复后未展示的实际版仍提示', (tester) async {
    h.pending();
    final response = Completer<MobileRelease?>();
    h.repository.fetcher = (target) => target.build == 97
        ? response.future
        : Future.value(releaseFixture(target: target));
    await tester.pumpWidget(h.build());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    h.state.value = (enabled: false, checking: false, update: _forced);
    await tester.pumpAndSettle();
    response.complete(releaseFixture(target: _installed));
    await tester.pumpAndSettle();
    expect(find.byType(MobileUpdateNoticeDialog), findsOneWidget);
    expect(find.text('需要更新后继续'), findsOneWidget);
    expect(h.store.records[_android]!.installedShown, isEmpty);
    h.state.value = (enabled: true, checking: false, update: _update);
    await tester.pumpAndSettle();
    expect(find.text('已更新'), findsOneWidget);
    expect(h.store.records[_android]!.installedShown, {97});
    expect(tester.takeException(), isNull);
  });

  testWidgets('推荐旧响应不能标记或覆盖新目标', (tester) async {
    final response = Completer<MobileRelease?>();
    h.repository.fetcher = (target) => target.build == 100
        ? response.future
        : Future.value(releaseFixture(target: target));
    await tester.pumpWidget(h.build());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    h.state.value = (
      enabled: true,
      checking: false,
      update: MobileUpdateInfo(
        kind: MobileUpdateKind.recommended,
        platform: _android,
        currentVersion: '0.8.0',
        currentBuild: 97,
        targetBuild: 101,
        targetVersion: '0.9.1',
        updateUri: Uri.parse(appShellTestAndroidUpdateUrl),
      ),
    );
    await tester.pumpAndSettle();
    response.complete(releaseFixture());
    await tester.pumpAndSettle();
    expect(find.textContaining('更新至 0.9.1'), findsOneWidget);
    expect(h.store.records[_android]!.recommendedShown, {101});
  });

  testWidgets('策略复核和其他模态期间不打开，后台到达内容不算已展示', (tester) async {
    h.state.value = (enabled: true, checking: true, update: _update);
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    expect(h.repository.targets, isEmpty);
    final blocker = showDialog<void>(
      context: h.navigator.currentContext!,
      builder: (_) => const AlertDialog(title: Text('其他操作')),
    );
    h.state.value = (enabled: true, checking: false, update: _update);
    await tester.pumpAndSettle();
    expect(h.repository.targets, isEmpty);
    final response = Completer<MobileRelease?>();
    h.repository.fetcher = (_) => response.future;
    h.navigator.currentState!.pop();
    await blocker;
    await tester.pump(const Duration(seconds: 1));
    for (var i = 0; i < 20 && h.repository.targets.isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(h.repository.targets, [releaseTarget]);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    response.complete(releaseFixture());
    await tester.pumpAndSettle();
    expect(h.store.records[_android]!.recommendedShown, isEmpty);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(h.store.records[_android]!.recommendedShown, {100});
  });

  testWidgets('iOS沿用TestFlight一次提示与动作，不读取Android说明', (tester) async {
    h.service.installed = const InstalledAppInfo(
      platform: MobileClientPlatform.ios,
      version: '0.8.0',
      build: 97,
    );
    h.state.value = (
      enabled: true,
      checking: false,
      update: MobileUpdateInfo(
        kind: MobileUpdateKind.recommended,
        platform: MobileClientPlatform.ios,
        currentVersion: '0.8.0',
        currentBuild: 97,
        targetBuild: 100,
        updateUri: Uri.parse('https://testflight.apple.com/join/example'),
      ),
    );
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    expect(find.text('前往 TestFlight'), findsOneWidget);
    expect(h.repository.targets, isEmpty);
    await _close(tester);
    await _resume(tester);
    expect(find.byType(MobileUpdateNoticeDialog), findsNothing);
  });

  for (final dark in [false, true]) {
    for (final after in [false, true]) {
      testWidgets('一次弹窗360宽${dark ? '暗' : '亮'}色${after ? '升级后' : '更新前'}', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(360, 800);
        addTearDown(tester.view.reset);
        if (after) h.pending();
        h.repository.fetcher = (target) async => releaseFixture(
          target: target,
          summary: '这次更新让阅读和日常使用更顺手。',
          items: const [
            '阅读长主题时，可以拖动右侧滑块快速浏览。',
            '优化图片加载，查看清晰大图更方便。',
            '调整部分页面的文字和按钮，大字号下也能完整显示。',
          ],
        );
        await tester.pumpWidget(h.build(dark: dark));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/mobile_notice_${after ? 'after' : 'before'}_${dark ? 'dark' : 'light'}_360.png',
          ),
        );
      });
    }
  }

  testWidgets('入场动画未完成就被强制打断不记展示', (tester) async {
    h.pending();
    await tester.pumpWidget(h.build());
    for (var i = 0; i < 20 && h.repository.targets.isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
    await tester.pump(const Duration(milliseconds: 1));
    expect(h.repository.targets, [_installed]);
    expect(h.store.records[_android]!.installedShown, isEmpty);
    h.state.value = (enabled: false, checking: false, update: _forced);
    await tester.pumpAndSettle();
    expect(h.store.records[_android]!.installedShown, isEmpty);
    expect(h.store.records[_android]!.pendingInstalledBuild, 97);
  });

  testWidgets('说明返回前实际安装身份变化，只展示当前安装版', (tester) async {
    h.pending();
    final response = Completer<MobileRelease?>();
    h.repository.fetcher = (target) => target.build == 97
        ? response.future
        : Future.value(releaseFixture(target: target));
    await tester.pumpWidget(h.build());
    for (var i = 0; i < 20 && h.repository.targets.isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    h.service.installed = const InstalledAppInfo(
      platform: _android,
      build: 99,
      version: '0.8.2',
    );
    response.complete(releaseFixture(target: _installed));
    await tester.pumpAndSettle();
    expect(find.textContaining('当前安装版本 0.8.2'), findsOneWidget);
    expect(h.store.records[_android]!.installedShown, {99});
  });

  testWidgets('明确更新动作仍复核策略并使用原下载服务', (tester) async {
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mobile-update-start')));
    await tester.pumpAndSettle();
    expect(h.service.launchCalls, 1);
    expect(find.text('系统安装器已打开，请按提示完成更新。'), findsOneWidget);
  });

  testWidgets('两倍字号长内容完整滚动且关闭可达', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.reset);
    h.pending();
    h.repository.fetcher = (target) async => releaseFixture(
      target: target,
      summary: '这次更新让阅读和日常使用更顺手。',
      items: List.generate(12, (i) => '第${i + 1}项：主题阅读、动态与设置的体验调整，长文字应自然换行。'),
    );
    await tester.pumpWidget(h.build(textScale: 2));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.textContaining('第12项'), 500);
    await tester.pumpAndSettle();
    expect(find.textContaining('第12项').hitTestable(), findsOneWidget);
    expect(find.text('知道了').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/mobile_notice_large_text_360.png'),
    );
    await _close(tester);
    expect(find.text('原来的任务'), findsOneWidget);
  });

  for (final kind in ['recommended', 'required', 'after']) {
    testWidgets('$kind 小屏两倍字号说明双向滚动，底部操作固定可达', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.reset);
      if (kind == 'after') h.pending();
      if (kind == 'required') {
        h.state.value = (enabled: false, checking: false, update: _forced);
      }
      h.repository.fetcher = (target) async => releaseFixture(
        target: target,
        summary: '阅读和日常使用更顺手。',
        items: List.generate(
          12,
          (i) => '第${i + 1}条更新：优化长主题阅读与图片浏览，大字号下说明也可以完整查看。',
        ),
      );
      await tester.pumpWidget(h.build(textScale: 2));
      await tester.pumpAndSettle();
      final action = find.byKey(
        Key(kind == 'after' ? 'mobile-update-dismiss' : 'mobile-update-start'),
      );
      final initialAction = tester.getRect(action);
      expect(action.hitTestable(), findsOneWidget);
      final scrollable = find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(Scrollable),
          )
          .first;
      final position = tester.state<ScrollableState>(scrollable).position;
      await tester.drag(scrollable, const Offset(0, -160));
      await tester.pumpAndSettle();
      expect(position.pixels, greaterThan(0));
      await tester.scrollUntilVisible(
        find.textContaining('第12条更新'),
        250,
        scrollable: scrollable,
        maxScrolls: 100,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('第12条更新').hitTestable(), findsOneWidget);
      expect(tester.getRect(action), initialAction);
      expect(action.hitTestable(), findsOneWidget);
      if (kind != 'required') {
        expect(
          find.byKey(const Key('mobile-update-dismiss')).hitTestable(),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/mobile_notice_long_${kind}_320_2x.png'),
      );
      final bottom = position.pixels;
      await tester.drag(scrollable, const Offset(0, 160));
      await tester.pumpAndSettle();
      expect(position.pixels, lessThan(bottom));
      await tester.scrollUntilVisible(
        find.text('阅读和日常使用更顺手。'),
        -250,
        scrollable: scrollable,
        maxScrolls: 100,
      );
      await tester.pumpAndSettle();
      expect(find.text('阅读和日常使用更顺手。').hitTestable(), findsOneWidget);
      expect(tester.getRect(action), initialAction);
      expect(tester.takeException(), isNull);
      if (kind == 'after') {
        await _close(tester);
        expect(find.text('原来的任务'), findsOneWidget);
      } else {
        await tester.tap(action);
        await tester.pumpAndSettle();
        expect(h.service.launchCalls, 1);
        expect(action.hitTestable(), findsOneWidget);
        if (kind == 'required') {
          await tester.binding.handlePopRoute();
          expect(find.byKey(const Key('mobile-update-dismiss')), findsNothing);
          expect(find.text('原来的任务'), findsNothing);
        }
      }
    });
  }
}
