import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_access.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_preference.dart';
import 'package:wenyousite_mobile/features/settings/presentation/editor_toolbar_settings_page.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/editor_toolbar_store.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('偏好入口可打开，分组移动和排序跨页面恢复并可恢复默认', (tester) async {
    final store = TestEditorToolbarStore();
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const MePage()),
        GoRoute(
          path: AppRouteLocations.editorToolbar,
          name: AppRouteNames.editorToolbar,
          builder: (_, _) => const EditorToolbarSettingsPage(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          editorToolbarPreferenceStoreProvider.overrideWithValue(store),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    final entry = find.byKey(const Key('open-editor-toolbar-settings'));
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();
    expect(
      AppRouteAccessPolicy.forLocation(AppRouteLocations.editorToolbar),
      AppRouteAccess.public,
    );
    await _menu(tester, EditorTool.heading, '下移');
    expect(store.saved.primary.take(2), [EditorTool.bold, EditorTool.heading]);
    await _menu(tester, EditorTool.image, '移到展开栏');
    expect(store.saved.primary, isNot(contains(EditorTool.image)));
    expect(store.saved.expanded.last, EditorTool.image);
    router.pop();
    await tester.pumpAndSettle();
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();
    final group = tester.widget<ReorderableListView>(
      find.byKey(const ValueKey('toolbar-layout-primary')),
    );
    expect(group.itemCount, store.saved.primary.length);
    await tester.ensureVisible(
      find.byKey(const Key('editor-toolbar-layout-reset')),
    );
    await tester.tap(find.byKey(const Key('editor-toolbar-layout-reset')));
    await tester.pumpAndSettle();
    expect(store.saved.isDefault, isTrue);
    expect(find.text('无序列表'), findsNothing);
    expect(find.text('有序列表'), findsNothing);
    expect(find.text('音频'), findsNothing);
  });

  testWidgets('拖动手柄重排，同组菜单提供读屏上移与下移', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final semantics = tester.ensureSemantics();
    try {
      final store = TestEditorToolbarStore();
      await tester.pumpWidget(_app(store));
      await tester.pumpAndSettle();
      final handle = find.descendant(
        of: find.byKey(const ValueKey('toolbar-layout-heading')),
        matching: find.byType(ReorderableDragStartListener),
      );
      await tester.drag(handle, const Offset(0, 105));
      await tester.pumpAndSettle();
      expect(store.saved.isDefault, isFalse);
      expect(store.saved.primary.first, isNot(EditorTool.heading));
      final menu = tester.getSemantics(
        find.descendant(
          of: find.byKey(const ValueKey('toolbar-layout-menu-heading')),
          matching: find.byType(IconButton),
        ),
      );
      expect(menu.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      menu.owner!.performAction(menu.id, SemanticsAction.tap);
      await tester.pumpAndSettle();
      expect(find.text('上移'), findsOneWidget);
      await tester.tap(find.text('上移'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('保存中禁用，失败恢复原布局并重试', (tester) async {
    final store = TestEditorToolbarStore()
      ..failWrite = true
      ..pendingWrite = Completer<void>();
    await tester.pumpWidget(_app(store));
    await tester.tap(find.byKey(const ValueKey('toolbar-layout-menu-heading')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('下移'));
    await tester.pump();
    expect(
      tester
          .widget<PopupMenuButton<String>>(
            find.byKey(const ValueKey('toolbar-layout-menu-heading')),
          )
          .enabled,
      isFalse,
    );
    store.pendingWrite!.complete();
    await tester.pumpAndSettle();
    expect(find.text('工具栏设置保存失败，请重试。'), findsOneWidget);
    expect(store.saved.isDefault, isTrue);
    store.failWrite = false;
    await tester.tap(find.byKey(const Key('editor-toolbar-layout-retry')));
    await tester.pumpAndSettle();
    expect(store.saved.primary.first, EditorTool.bold);
  });

  for (final dark in [false, true]) {
    for (final width in [320, 360]) {
      testWidgets('${width}dp ${dark ? 'dark' : 'light'} 偏好设置实际画面', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width.toDouble(), 1100);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await tester.pumpWidget(
          _app(
            TestEditorToolbarStore()..saved = customEditorToolbarTestLayout(),
            dark: dark,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            'goldens/editor_toolbar_settings_${width}_${dark ? 'dark' : 'light'}.png',
          ),
        );
      });
    }
    testWidgets('320dp ${dark ? 'dark' : 'light'} 两倍字号可滚动并移动到主栏', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final store = TestEditorToolbarStore();
      await tester.pumpWidget(_app(store, dark: dark, scale: 2));
      await _menu(tester, EditorTool.dice, '移到主栏');
      expect(store.saved.primary.last, EditorTool.dice);
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _menu(WidgetTester tester, EditorTool tool, String choice) async {
  final menu = find.byKey(ValueKey('toolbar-layout-menu-${tool.id}'));
  await tester.ensureVisible(menu);
  await tester.tap(menu);
  await tester.pumpAndSettle();
  await tester.tap(find.text(choice));
  await tester.pumpAndSettle();
}

Widget _app(
  TestEditorToolbarStore store, {
  bool dark = false,
  double scale = 1,
}) => ProviderScope(
  overrides: [
    editorToolbarPreferenceStoreProvider.overrideWithValue(store),
    initialEditorToolbarPreferenceProvider.overrideWithValue(
      EditorToolbarPreferenceState(layout: store.saved),
    ),
  ],
  child: MaterialApp(
    theme: dark ? AppTheme.dark : AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: const EditorToolbarSettingsPage(),
  ),
);
