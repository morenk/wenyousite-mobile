import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/toolbox_page.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';

import '../../support/deterministic_test_fonts.dart';
import '../users/me_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final state in ['ready', 'loading', 'failed', 'without-stickers']) {
    testWidgets('登录用户资料 $state 时可从页面工具入口进入目录', (tester) async {
      final repository = MePageTestFakeMeProfileRepository(
        failFetchOnce: state == 'failed',
      );
      if (state == 'loading') {
        repository.deferNextFetch(Completer<MeProfileModel>());
      }
      final container = await mePageTestAuthenticatedContainer(
        repository,
        stickersEnabled: state != 'without-stickers',
      );
      addTearDown(container.dispose);
      final router = GoRouter(
        initialLocation: '/me',
        routes: [
          GoRoute(path: '/me', builder: (_, _) => const MePage()),
          GoRoute(
            path: '/tools',
            name: AppRouteNames.toolbox,
            builder: (_, _) => const ToolboxPage(),
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      final entry = find.byKey(const Key('me-open-toolbox'));
      expect(entry, findsOneWidget);
      expect(
        find.descendant(of: find.byType(AppBar), matching: entry),
        findsNothing,
      );
      await tester.ensureVisible(entry);
      await tester.tap(entry);
      await tester.pumpAndSettle();
      expect(find.text('文字处理'), findsOneWidget);
      expect(find.byKey(const Key('toolbox-names')), findsOneWidget);
      expect(repository.updateCalls, 0);
      expect(tester.takeException(), isNull);
    });
  }

  for (final visual in const [
    (width: 400.0, height: 860.0, scale: 1.0, dark: false, name: '400_light'),
    (width: 400.0, height: 860.0, scale: 1.0, dark: true, name: '400_dark'),
    (
      width: 320.0,
      height: 800.0,
      scale: 2.0,
      dark: false,
      name: '320_2x_light',
    ),
    (width: 320.0, height: 800.0, scale: 2.0, dark: true, name: '320_2x_dark'),
  ]) {
    testWidgets('游客工具箱入口视觉 ${visual.name}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(visual.width, visual.height);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final container = ProviderContainer();
      addTearDown(container.dispose);
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
            home: const RepaintBoundary(
              key: Key('guest-visual'),
              child: MePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('me-open-toolbox')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('guest-visual')),
        matchesGoldenFile('goldens/toolbox_guest_${visual.name}.png'),
      );
    });
  }
}
