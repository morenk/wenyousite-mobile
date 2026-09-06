import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';
import '../../support/foundation_test_fonts.dart';
import 'me_page_test_support.dart';

void registerMePageSettingsLayoutCases() {
  setUpAll(loadFoundationTestFonts);
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
    expect(find.byType(WenyouSettingsTypography), findsOneWidget);
    expect(find.text('登录终端'), findsOneWidget);
    expect(find.text('修改密码'), findsOneWidget);
    expect(find.text('更换邮箱'), findsOneWidget);
    expect(find.byKey(const Key('logout-submit')), findsOneWidget);
    expect(find.text('账号状态加载失败'), findsNothing);
  });

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
      final expectedWidth = width <= 400 ? width - 24 : width - 48;
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
        const ValueKey('me-content-MeContentTab.overview'),
      );
      final playedTab = find.byKey(
        const ValueKey('me-content-MeContentTab.playedThreads'),
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
