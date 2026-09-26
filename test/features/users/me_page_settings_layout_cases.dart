import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';

import '../../support/deterministic_test_fonts.dart';
import 'me_page_test_support.dart';

void registerMePageSettingsLayoutCases() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('离开未保存的资料时可继续编辑或明确放弃', (tester) async {
    final repository = MePageTestFakeMeProfileRepository();
    final container = await mePageTestAuthenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                key: const Key('open-me-edit'),
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(builder: (_) => const MeEditPage()),
                ),
                child: const Text('打开编辑资料'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open-me-edit')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('me-bio-field')), '还没有保存');
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsOneWidget);
    await tester.tap(find.text('继续编辑'));
    await tester.pumpAndSettle();
    expect(find.text('还没有保存'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('me-edit-discard-confirm')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('open-me-edit')), findsOneWidget);
  });

  testWidgets('账号设置不依赖个人资料读取即可使用安全入口', (tester) async {
    final repository = MePageTestFakeMeProfileRepository(failFetchOnce: true);
    final container = await mePageTestAuthenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const MeSettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.fetchCalls, 0);
    expect(find.text('账号设置'), findsOneWidget);
    expect(find.text('偏好与提醒'), findsOneWidget);
    expect(find.text('账号'), findsOneWidget);
    expect(find.byKey(const Key('me-open-edit-profile')), findsOneWidget);
    expect(find.text('账号操作'), findsOneWidget);
    expect(find.text('帮助'), findsOneWidget);
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('账号操作'), findsOneWidget);
    semantics.dispose();
    expect(
      tester
          .widgetList<ListTile>(find.byType(ListTile))
          .every((tile) => tile.subtitle == null),
      isTrue,
    );
    expect(find.text('跟随系统'), findsOneWidget);
    expect(find.text('修改后所有终端需要重新登录'), findsNothing);
    expect(find.text('查看近 30 天决定与申诉进度'), findsNothing);
    expect(find.text('不可恢复；已发布内容会匿名保留'), findsNothing);
    expect(find.byType(WenyouSettingsTypography), findsOneWidget);
    expect(find.text('登录终端'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('登录终端')).style?.fontWeight,
      FontWeight.w400,
    );
    expect(find.text('修改密码'), findsOneWidget);
    expect(find.text('更换邮箱'), findsOneWidget);
    expect(find.byKey(const Key('logout-submit')), findsOneWidget);
    expect(find.text('账号状态加载失败'), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('logout-submit')));
    await tester.tap(find.byKey(const Key('logout-submit')));
    await tester.pumpAndSettle();
    expect(find.text('退出当前账号？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
  });

  for (final fromSettings in [true, false]) {
    testWidgets('${fromSettings ? '设置列表' : '主页小按钮'}复用既有编辑页并可返回', (
      tester,
    ) async {
      final container = await mePageTestAuthenticatedContainer(
        MePageTestFakeMeProfileRepository(),
      );
      addTearDown(container.dispose);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) =>
                fromSettings ? const MeSettingsPage() : const MePage(),
          ),
          GoRoute(
            path: AppRoutePaths.meEdit,
            name: AppRouteNames.meEdit,
            builder: (_, _) => const MeEditPage(),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final editEntry = find.byKey(
        Key(fromSettings ? 'me-open-edit-profile' : 'me-profile-edit'),
      );
      await tester.ensureVisible(editEntry);
      await tester.tap(editEntry);
      await tester.pumpAndSettle();
      expect(
        GoRouterState.of(tester.element(find.byType(MeEditPage))).uri.path,
        AppRoutePaths.meEdit,
      );
      expect(find.byType(MeEditPage), findsOneWidget);
      expect(find.byKey(const Key('me-bio-field')), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        find.byType(fromSettings ? MeSettingsPage : MePage),
        findsOneWidget,
      );
      expect(editEntry, findsOneWidget);
    });
  }

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    for (final dark in [false, true]) {
      testWidgets('$width dp ${dark ? '黑夜' : '浅色'} 两倍字号账号设置可滚动', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 960);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final container = await mePageTestAuthenticatedContainer(
          MePageTestFakeMeProfileRepository(failFetchOnce: true),
        );
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
              home: const MeSettingsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('open-appearance-settings')),
          findsOneWidget,
        );
        await tester.ensureVisible(find.byKey(const Key('logout-submit')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.byKey(const Key('me-open-delete-account')),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (width == 360 && !dark) {
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        }
      });
    }
  }

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('账号设置无副标题，深色 $dark 字号 $scale', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(360, 900);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final container = await mePageTestAuthenticatedContainer(
          MePageTestFakeMeProfileRepository(),
        );
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: const RepaintBoundary(
                key: Key('account-settings-golden'),
                child: MeSettingsPage(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('当前会话'), findsNothing);
        if (scale == 1) {
          await expectLater(
            find.byKey(const Key('account-settings-golden')),
            matchesGoldenFile(
              'goldens/account_settings_${dark ? 'dark' : 'light'}_360.png',
            ),
          );
        }
        await tester.ensureVisible(find.byKey(const Key('logout-submit')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final visual in const [
    (name: 'me_profile_edit_empty_360_light.png', dark: false),
    (name: 'me_profile_edit_empty_360_dark.png', dark: true),
  ]) {
    testWidgets('编辑资料空背景视觉基线 ${visual.name}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final container = await mePageTestAuthenticatedContainer(
        MePageTestFakeMeProfileRepository(),
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: visual.dark ? AppTheme.dark : AppTheme.light,
            home: const RepaintBoundary(
              key: Key('me-profile-edit-golden'),
              child: MeEditPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(const Key('me-profile-edit-golden')),
        matchesGoldenFile('goldens/${visual.name}'),
      );
    });
  }

  for (final visual in const [
    (width: 320.0, scale: 2.0, dark: false, suffix: '320_2x_light'),
    (width: 320.0, scale: 2.0, dark: true, suffix: '320_2x_dark'),
    (width: 400.0, scale: 1.0, dark: false, suffix: '400_light'),
    (width: 400.0, scale: 1.0, dark: true, suffix: '400_dark'),
    (width: 600.0, scale: 1.0, dark: false, suffix: '600_light'),
    (width: 600.0, scale: 1.0, dark: true, suffix: '600_dark'),
  ]) {
    testWidgets('个人区宽度视觉基线 ${visual.suffix}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(visual.width, 960);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final container = await mePageTestAuthenticatedContainer(
        MePageTestFakeMeProfileRepository(),
      );
      addTearDown(container.dispose);

      Future<void> pumpPage(Widget page) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: visual.dark ? AppTheme.dark : AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(visual.scale)),
                child: child!,
              ),
              home: RepaintBoundary(
                key: const Key('personal-visual-golden'),
                child: page,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await pumpPage(const MeSettingsPage());
      await expectLater(
        find.byKey(const Key('personal-visual-golden')),
        matchesGoldenFile('goldens/account_settings_${visual.suffix}.png'),
      );
      await pumpPage(const MeEditPage());
      await expectLater(
        find.byKey(const Key('personal-visual-golden')),
        matchesGoldenFile('goldens/me_profile_edit_${visual.suffix}.png'),
      );
    });
  }

  testWidgets('编辑资料在两倍字号下可滚动且主要入口满足点击规范', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = await mePageTestAuthenticatedContainer(
      MePageTestFakeMeProfileRepository(),
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
          home: const MeEditPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('me-privacy-bookmarks')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 个人中心、资料编辑和账号设置无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = MePageTestFakeMeProfileRepository();
      final container = await mePageTestAuthenticatedContainer(repository);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: AppTheme.light, home: const MePage()),
        ),
      );
      await tester.pumpAndSettle();
      final expectedWidth = width;
      expect(
        tester.getSize(find.byKey(const Key('me-profile-header'))).width,
        expectedWidth,
      );
      await tester.drag(find.byType(NestedScrollView), const Offset(0, -240));
      await tester.pumpAndSettle();
      final createdTab = find.byKey(
        const ValueKey('me-content-MeContentTab.createdThreads'),
      );
      final overviewTab = find.byKey(
        const ValueKey('me-content-MeContentTab.createdThreads'),
      );
      final playedTab = find.byKey(
        const ValueKey('me-content-MeContentTab.replies'),
      );
      await tester.ensureVisible(createdTab);
      await tester.pumpAndSettle();
      final mainTabGroup = Rect.fromLTRB(
        tester.getRect(overviewTab).left,
        tester.getRect(overviewTab).top,
        tester.getRect(playedTab).right,
        tester.getRect(playedTab).bottom,
      );
      expect(mainTabGroup.center.dx, closeTo(width / 2, 0.01));

      await tester.tap(createdTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const Key('me-settings-save')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MeSettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('后台在线提醒（实验性）'), findsNothing);
      expect(
        find.byKey(const Key('background-online-reminders-switch')),
        findsNothing,
      );
      await tester.ensureVisible(find.byKey(const Key('logout-submit')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
