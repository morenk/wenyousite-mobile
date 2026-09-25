import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/appearance_preference.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selection_menu.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/settings/presentation/appearance_settings_page.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('外观页可直接开启与关闭省流量', (tester) async {
    await tester.pumpWidget(
      _testApp(
        store: _FakeAppearanceStore(),
        preference: AppearancePreference.system,
      ),
    );
    final toggle = find.byKey(const Key('cover-data-saver'));
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
    expect(tester.widget<SwitchListTile>(toggle).subtitle, isNull);
    await tester.tap(find.byTooltip('省流量说明'));
    await tester.pumpAndSettle();
    expect(find.text('开启后，帖子列表封面保持静态。'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
  });

  testWidgets('展示 Foundation 三种偏好并持久化黑夜选择', (tester) async {
    final store = _FakeAppearanceStore();
    await tester.pumpWidget(
      _testApp(store: store, preference: AppearancePreference.system),
    );

    expect(find.text('跟随系统'), findsOneWidget);
    expect(find.text('亮色'), findsOneWidget);
    expect(find.text('黑夜'), findsOneWidget);
    expect(find.text('随设备外观自动切换'), findsNothing);
    expect(
      tester
          .widgetList<ListTile>(find.byType(ListTile))
          .every((tile) => tile.subtitle == null),
      isTrue,
    );
    expect(find.byType(WenyouSettingsTypography), findsOneWidget);
    final panels = find.byType(WenyouPanel);
    expect(panels, findsNWidgets(2));
    expect(
      tester.getTopLeft(panels.at(1)).dy -
          tester.getBottomLeft(panels.at(0)).dy,
      8,
    );

    await tester.tap(find.byKey(const Key('appearance-option-dark')));
    await tester.pump();

    expect(store.writes, [AppearancePreference.dark]);
    expect(
      Theme.of(
        tester.element(find.byKey(const Key('appearance-option-dark'))),
      ).brightness,
      Brightness.dark,
    );
    expect(
      tester
          .element(find.byKey(const Key('appearance-option-dark')))
          .wenyouTokens,
      WenyouThemeTokens.dark,
    );
    expect(_rootAnimatedTheme, findsNothing);
  });

  testWidgets('保存失败回滚原选择并允许重试目标选择', (tester) async {
    final store = _FakeAppearanceStore(failWrite: true);
    await tester.pumpWidget(
      _testApp(store: store, preference: AppearancePreference.light),
    );

    await tester.tap(find.byKey(const Key('appearance-option-dark')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('appearance-failure')), findsOneWidget);
    expect(find.text('外观设置保存失败，请重试。'), findsOneWidget);
    expect(
      Theme.of(
        tester.element(find.byKey(const Key('appearance-option-light'))),
      ).brightness,
      Brightness.light,
    );

    store.failWrite = false;
    await tester.tap(find.byKey(const Key('appearance-retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('appearance-failure')), findsNothing);
    expect(store.writes, [
      AppearancePreference.dark,
      AppearancePreference.dark,
    ]);
    expect(
      Theme.of(
        tester.element(find.byKey(const Key('appearance-option-dark'))),
      ).brightness,
      Brightness.dark,
    );
  });

  testWidgets('重复选择不写入，保存期间整行选择禁用且不重复提交', (tester) async {
    final pending = Completer<void>();
    final store = _FakeAppearanceStore()..pendingWrite = pending;
    await tester.pumpWidget(
      _testApp(store: store, preference: AppearancePreference.system),
    );
    await tester.tap(find.byKey(const Key('appearance-option-system')));
    await tester.pump();
    expect(store.writes, isEmpty);
    await tester.tap(find.byKey(const Key('appearance-option-dark')));
    await tester.pump();
    expect(
      tester
          .widgetList<WenyouSelectionTile>(find.byType(WenyouSelectionTile))
          .every((tile) => tile.onTap == null),
      isTrue,
    );
    await tester.tap(find.byKey(const Key('appearance-option-light')));
    expect(store.writes, [AppearancePreference.dark]);
    pending.complete();
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<WenyouSelectionTile>(
            find.byKey(const Key('appearance-option-dark')),
          )
          .selected,
      isTrue,
    );
  });

  testWidgets('跟随系统会响应设备黑夜外观', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(
      _testApp(
        store: _FakeAppearanceStore(),
        preference: AppearancePreference.system,
      ),
    );

    expect(
      Theme.of(
        tester.element(find.byKey(const Key('appearance-option-system'))),
      ).brightness,
      Brightness.dark,
    );
  });

  testWidgets('黑夜外观设置页视觉回归', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 720);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _testApp(
        store: _FakeAppearanceStore(),
        preference: AppearancePreference.dark,
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('appearance-page-golden')),
      matchesGoldenFile('goldens/appearance_settings_dark_360.png'),
    );
  });
}

final _rootAnimatedTheme = find.byWidgetPredicate(
  (widget) => widget is AnimatedTheme && widget.child is ScaffoldMessenger,
  description: 'MaterialApp root AnimatedTheme',
);

Widget _testApp({
  required _FakeAppearanceStore store,
  required AppearancePreference preference,
}) {
  return ProviderScope(
    overrides: [
      appearancePreferenceStoreProvider.overrideWithValue(store),
      initialAppearancePreferenceStateProvider.overrideWithValue(
        AppearancePreferenceState(preference: preference),
      ),
    ],
    child: const _AppearanceTestApp(),
  );
}

class _AppearanceTestApp extends ConsumerWidget {
  const _AppearanceTestApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(
      appearancePreferenceControllerProvider.select(
        (state) => state.preference,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: preference.themeMode,
      themeAnimationStyle: AnimationStyle.noAnimation,
      home: const RepaintBoundary(
        key: Key('appearance-page-golden'),
        child: AppearanceSettingsPage(),
      ),
    );
  }
}

class _FakeAppearanceStore implements AppearancePreferenceStore {
  _FakeAppearanceStore({this.failWrite = false});

  bool failWrite;
  Completer<void>? pendingWrite;
  AppearancePreference value = AppearancePreference.system;
  final List<AppearancePreference> writes = [];

  @override
  Future<AppearancePreference> read() async => value;

  @override
  Future<void> write(AppearancePreference preference) async {
    writes.add(preference);
    await pendingWrite?.future;
    if (failWrite) throw StateError('write failed');
    value = preference;
  }
}
