import 'dart:async';

import 'package:flutter/gestures.dart';
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

  testWidgets('偏好入口可打开，拖放跨页面保留并可恢复默认', (tester) async {
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
    await _drop(tester, EditorTool.image, EditorToolbarGroup.expanded, 0);
    expect(store.saved.expanded.first, EditorTool.image);
    router.pop();
    await tester.pumpAndSettle();
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('toolbar-layout-expanded')),
        matching: find.byKey(const ValueKey('toolbar-layout-image')),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('editor-toolbar-layout-reset')));
    await tester.pumpAndSettle();
    expect(store.saved.isDefault, isTrue);
    expect(find.byType(ReorderableListView), findsNothing);
    expect(find.text('无序列表'), findsNothing);
    expect(find.text('有序列表'), findsNothing);
    expect(find.text('音频'), findsNothing);
  });

  testWidgets('不显示点击调整控件，隐式读屏操作可重排和换栏，固定控件不可拖动', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      final store = TestEditorToolbarStore();
      await tester.pumpWidget(_app(store));
      await tester.tap(_dragTool(EditorTool.heading));
      await tester.pumpAndSettle();
      expect(store.writes, 0);
      _expectNoAdjustmentControls();
      final icon = tester.getSemantics(
        find.byKey(const ValueKey('toolbar-semantics-heading')),
      );
      expect(icon.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      await _semanticAction(tester, EditorTool.heading, '后移');
      expect(store.saved.primary[1], EditorTool.heading);
      await _semanticAction(tester, EditorTool.heading, '前移');
      expect(store.saved.primary.first, EditorTool.heading);
      await _semanticAction(tester, EditorTool.heading, '移到展开栏');
      expect(store.saved.expanded.last, EditorTool.heading);
      _expectNoAdjustmentControls();
      final draggable = find.byWidgetPredicate(
        (widget) => widget is Draggable<EditorTool>,
      );
      expect(draggable, findsNWidgets(14));
      for (final key in [
        'toolbar-layout-fixed-more',
        'toolbar-layout-fixed-submit',
      ]) {
        expect(
          find.ancestor(of: find.byKey(Key(key)), matching: draggable),
          findsNothing,
        );
      }
      expect(find.byTooltip('收起更多（固定按钮）'), findsOneWidget);
      expect(find.byTooltip('发送（固定按钮）'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('鼠标无需长按即开始拖放，触屏横滑不误拖', (tester) async {
    _viewport(tester, const Size(320, 640));
    final store = TestEditorToolbarStore();
    await tester.pumpWidget(_app(store));
    final mouse = await tester.startGesture(
      tester.getCenter(_dragTool(EditorTool.heading)),
      kind: PointerDeviceKind.mouse,
    );
    final target = tester.getCenter(
      find.byKey(const ValueKey('toolbar-drop-expanded-0')),
    );
    await mouse.moveTo(target);
    await tester.pump(const Duration(milliseconds: 16));
    await mouse.moveBy(const Offset(1, 0));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byKey(const Key('toolbar-drop-indicator')), findsOneWidget);
    await mouse.up();
    await tester.pumpAndSettle();
    expect(store.saved.expanded.first, EditorTool.heading);
    final writes = store.writes;
    final scroll = tester
        .widget<SingleChildScrollView>(
          find.byKey(const Key('toolbar-layout-primary')),
        )
        .controller!;
    await tester.drag(_dragTool(EditorTool.italic), const Offset(-100, 0));
    await tester.pumpAndSettle();
    expect(scroll.offset, greaterThan(0));
    expect(store.writes, writes);
    expect(find.byKey(const Key('toolbar-drop-indicator')), findsNothing);
  });

  testWidgets('长按拖放提供插入反馈并保存准确顺序，取消不写入', (tester) async {
    _viewport(tester, const Size(320, 640));
    final store = TestEditorToolbarStore();
    await tester.pumpWidget(_app(store));
    final drag = await _startDrag(tester, EditorTool.heading);
    await drag.moveTo(
      tester.getCenter(find.byKey(const ValueKey('toolbar-drop-primary-2'))),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('toolbar-drop-indicator')), findsOneWidget);
    expect(store.writes, 0);
    await drag.up();
    await tester.pumpAndSettle();
    expect(store.saved.primary.take(3), [
      EditorTool.bold,
      EditorTool.heading,
      EditorTool.italic,
    ]);
    final writes = store.writes;
    final cancel = await _startDrag(tester, EditorTool.bold);
    await cancel.moveTo(const Offset(20, 600));
    await tester.pump();
    await cancel.up();
    await tester.pumpAndSettle();
    expect(store.writes, writes);
    expect(tester.takeException(), isNull);
  });

  testWidgets('空展开栏可接收拖放，主栏横滑及边缘拖动不改写保存归属', (tester) async {
    _viewport(tester, const Size(320, 640));
    final saved = EditorToolbarLayout.custom(
      primary: EditorTool.values,
      expanded: [],
    );
    final store = TestEditorToolbarStore()..saved = saved;
    await tester.pumpWidget(_app(store));
    await tester.drag(
      find.byKey(const Key('toolbar-layout-primary')),
      const Offset(-180, 0),
    );
    await tester.pumpAndSettle();
    expect(store.writes, 0);
    expect(store.saved, saved);
    expect(
      find.byKey(const ValueKey('toolbar-empty-expanded')),
      findsOneWidget,
    );

    final drag = await _startDrag(tester, EditorTool.heading);
    final viewport = tester.getRect(
      find.byKey(const Key('toolbar-layout-primary')),
    );
    final scroll = tester
        .widget<SingleChildScrollView>(
          find.byKey(const Key('toolbar-layout-primary')),
        )
        .controller!;
    await drag.moveTo(Offset(viewport.right - 4, viewport.center.dy));
    await tester.pump(const Duration(milliseconds: 240));
    expect(scroll.offset, greaterThan(0));
    expect(store.writes, 0);
    await drag.moveTo(
      tester.getCenter(find.byKey(const ValueKey('toolbar-empty-expanded'))),
    );
    await tester.pump();
    await drag.up();
    await tester.pumpAndSettle();
    expect(store.saved.expanded, [EditorTool.heading]);
    expect(
      store.saved.primary,
      EditorTool.values.where((tool) => tool != EditorTool.heading),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('空主栏也可直接接收拖放，更多可收起并重新展开', (tester) async {
    final store = TestEditorToolbarStore()
      ..saved = EditorToolbarLayout.custom(
        primary: [],
        expanded: EditorTool.values,
      );
    await tester.pumpWidget(_app(store));
    final drag = await _startDrag(tester, EditorTool.sticker);
    await drag.moveTo(
      tester.getCenter(find.byKey(const ValueKey('toolbar-empty-primary'))),
    );
    await tester.pump();
    await drag.up();
    await tester.pumpAndSettle();
    expect(store.saved.primary, [EditorTool.sticker]);
    await tester.tap(find.byKey(const Key('toolbar-layout-fixed-more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('toolbar-layout-expanded')), findsNothing);
    await tester.tap(find.byKey(const Key('toolbar-layout-fixed-more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('toolbar-layout-expanded')), findsOneWidget);
  });

  testWidgets('保存中禁用，失败恢复原布局并重试', (tester) async {
    final store = TestEditorToolbarStore()
      ..failWrite = true
      ..pendingWrite = Completer<void>();
    await tester.pumpWidget(_app(store));
    final drag = await _startDrag(tester, EditorTool.heading);
    await drag.moveTo(
      tester.getCenter(find.byKey(const ValueKey('toolbar-drop-primary-2'))),
    );
    await tester.pump();
    await drag.up();
    await tester.pump();
    expect(
      tester
          .widget<Draggable<EditorTool>>(_dragTool(EditorTool.heading))
          .maxSimultaneousDrags,
      0,
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
      testWidgets('${width}dp ${dark ? 'dark' : 'light'} 图标摆放实际画面', (
        tester,
      ) async {
        _viewport(tester, Size(width.toDouble(), 640));
        final store = TestEditorToolbarStore()
          ..saved = customEditorToolbarTestLayout();
        await tester.pumpWidget(_app(store, dark: dark));
        await tester.tap(_dragTool(EditorTool.sticker));
        await tester.pumpAndSettle();
        expect(store.writes, 0);
        _expectNoAdjustmentControls();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            'goldens/editor_toolbar_settings_${width}_${dark ? 'dark' : 'light'}.png',
          ),
        );
      });
    }
    testWidgets('320dp ${dark ? 'dark' : 'light'} 两倍字号可拖放换栏', (tester) async {
      _viewport(tester, const Size(320, 640));
      final store = TestEditorToolbarStore();
      await tester.pumpWidget(_app(store, dark: dark, scale: 2));
      await _drop(tester, EditorTool.dice, EditorToolbarGroup.primary, 0);
      expect(store.saved.primary.first, EditorTool.dice);
      expect(_dragTool(EditorTool.dice).hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

void _viewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Finder _dragTool(EditorTool tool) =>
    find.byKey(ValueKey('toolbar-drag-${tool.id}'));

void _expectNoAdjustmentControls() {
  expect(find.byKey(const Key('toolbar-layout-actions')), findsNothing);
  for (final label in ['前移', '后移', '移到主栏', '移到展开栏', '点按调整']) {
    expect(find.text(label), findsNothing);
    expect(find.byTooltip(label), findsNothing);
  }
  expect(find.byKey(const Key('toolbar-layout-previous')), findsNothing);
  expect(find.byKey(const Key('toolbar-layout-next')), findsNothing);
  expect(find.byKey(const Key('toolbar-layout-change-group')), findsNothing);
}

Future<void> _semanticAction(
  WidgetTester tester,
  EditorTool tool,
  String label,
) async {
  final node = tester.getSemantics(
    find.byKey(ValueKey('toolbar-semantics-${tool.id}')),
  );
  final id = node.getSemanticsData().customSemanticsActionIds!.singleWhere(
    (id) => CustomSemanticsAction.getAction(id)!.label == label,
  );
  node.owner!.performAction(node.id, SemanticsAction.customAction, id);
  await tester.pumpAndSettle();
}

Future<void> _drop(
  WidgetTester tester,
  EditorTool tool,
  EditorToolbarGroup group,
  int index,
) async {
  final drag = await _startDrag(tester, tool);
  await drag.moveTo(
    tester.getCenter(find.byKey(ValueKey('toolbar-drop-${group.name}-$index'))),
  );
  await tester.pump();
  await drag.up();
  await tester.pumpAndSettle();
}

Future<TestGesture> _startDrag(WidgetTester tester, EditorTool tool) async {
  await tester.ensureVisible(_dragTool(tool));
  final gesture = await tester.startGesture(tester.getCenter(_dragTool(tool)));
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
  return gesture;
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
