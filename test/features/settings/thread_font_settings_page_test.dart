import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/thread_font_preference.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/settings/presentation/thread_font_settings_page.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/thread_font_store.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('默认 15，七个数字左右等距且点击对应刻度选择准确字号', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final store = TestThreadFontStore();
    await tester.pumpWidget(_app(store));
    final slider = find.byKey(const Key('thread-font-slider'));
    final widget = tester.widget<Slider>(slider);
    expect(widget.min, 0);
    expect(widget.max, 6);
    expect(widget.divisions, 6);
    expect(widget.value, 2);
    final bounds = tester.getRect(slider);
    final centers = [
      for (var size = 13; size <= 19; size++)
        tester.getCenter(find.byKey(ValueKey('thread-font-tick-$size'))).dx,
    ];
    expect(centers[3], closeTo(bounds.center.dx, 0.01));
    final interval = centers[1] - centers[0];
    for (var index = 0; index < centers.length; index++) {
      expect(centers[index], closeTo(centers[0] + interval * index, 0.01));
      await tester.tapAt(Offset(centers[index], bounds.center.dy));
      await tester.pumpAndSettle();
      expect(_preview(tester), 13 + index);
      expect(store.saved.fontSize, 13 + index);
    }
    expect(find.text('超大'), findsNothing);
    expect(find.text('标准'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('拖动实时预览、松手保存，返回再进恢复选择并可恢复默认', (tester) async {
    final store = TestThreadFontStore();
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const MePage()),
        GoRoute(
          path: AppRoutePaths.threadFont,
          name: AppRouteNames.threadFont,
          builder: (_, _) => const ThreadFontSettingsPage(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [threadFontPreferenceStoreProvider.overrideWithValue(store)],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    final entry = find.byKey(const Key('open-thread-font-settings'));
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();
    expect(_preview(tester), 15);
    final slider = find.byKey(const Key('thread-font-slider'));
    await tester.ensureVisible(slider);
    final bounds = tester.getRect(slider);
    final gesture = await tester.startGesture(bounds.center);
    await gesture.moveTo(Offset(bounds.right - 25, bounds.center.dy));
    await tester.pump();
    expect(_preview(tester), 19);
    expect(tester.getRect(slider), bounds);
    expect(store.writes, isEmpty);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(store.writes, [ThreadFontPreference.size19]);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('19'), findsOneWidget);
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();
    expect(_preview(tester), 19);
    await tester.ensureVisible(find.byKey(const Key('thread-font-reset')));
    await tester.tap(find.byKey(const Key('thread-font-reset')));
    await tester.pumpAndSettle();
    expect(_preview(tester), 15);
    expect(store.saved, ThreadFontPreference.standard);
  });

  testWidgets('保存中禁用，失败回滚预览并能重试', (tester) async {
    final store = TestThreadFontStore()
      ..pending = Completer<void>()
      ..failWrite = true;
    await tester.pumpWidget(_app(store));
    final slider = find.byKey(const Key('thread-font-slider'));
    await tester.tapAt(
      tester.getRect(slider).centerRight - const Offset(25, 0),
    );
    await tester.pump();
    expect(tester.widget<Slider>(slider).onChanged, isNull);
    store.pending!.complete();
    await tester.pumpAndSettle();
    expect(_preview(tester), 15);
    expect(find.text('字号设置保存失败，请重试。'), findsOneWidget);
    store.failWrite = false;
    await tester.ensureVisible(find.byKey(const Key('thread-font-retry')));
    await tester.tap(find.byKey(const Key('thread-font-retry')));
    await tester.pumpAndSettle();
    expect(_preview(tester), 19);
  });

  testWidgets('读屏可按档调整且读出当前选择', (tester) async {
    final handle = tester.ensureSemantics();
    final store = TestThreadFontStore();
    await tester.pumpWidget(_app(store));
    await tester.pumpAndSettle();
    final node = tester.getSemantics(find.bySemanticsLabel('15'));
    expect(node.getSemanticsData().value, '15，默认字号');
    node.owner!.performAction(node.id, SemanticsAction.increase);
    await tester.pumpAndSettle();
    expect(_preview(tester), 16);
    expect(store.saved, ThreadFontPreference.size16);
    handle.dispose();
  });

  for (final dark in [false, true]) {
    for (final width in [320.0, 600.0]) {
      testWidgets('$width ${dark ? '黑夜' : '浅色'} 字号预览', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await tester.pumpWidget(_app(TestThreadFontStore(), dark: dark));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            'goldens/thread_font_${width.toInt()}_${dark ? 'dark' : 'light'}.png',
          ),
        );
      });
    }
    testWidgets('320dp 系统两倍字号与最大阅读字号可滚动操作 ${dark ? '黑夜' : '浅色'}', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        _app(
          TestThreadFontStore(),
          dark: dark,
          scale: 2,
          preference: ThreadFontPreference.size19,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final reset = find.byKey(const Key('thread-font-reset'));
      await tester.ensureVisible(reset);
      await tester.tap(reset);
      await tester.pumpAndSettle();
      expect(_preview(tester), 15);
      expect(tester.takeException(), isNull);
    });
  }
}

double _preview(WidgetTester tester) => tester
    .widget<WenyouMarkdown>(find.byKey(const Key('thread-font-preview')))
    .bodyFontSize;

Widget _app(
  TestThreadFontStore store, {
  bool dark = false,
  double scale = 1,
  ThreadFontPreference preference = ThreadFontPreference.standard,
}) => ProviderScope(
  overrides: [
    threadFontPreferenceStoreProvider.overrideWithValue(store),
    initialThreadFontPreferenceProvider.overrideWithValue(
      ThreadFontPreferenceState(preference: preference),
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
    home: const ThreadFontSettingsPage(),
  ),
);
