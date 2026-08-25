import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/appearance_preference.dart';
import 'package:wenyousite_mobile/features/settings/presentation/appearance_settings_page.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('展示 Foundation 三种偏好并持久化黑夜选择', (tester) async {
    final store = _FakeAppearanceStore();
    await tester.pumpWidget(
      _testApp(store: store, preference: AppearancePreference.system),
    );

    expect(find.text('跟随系统'), findsOneWidget);
    expect(find.text('亮色'), findsOneWidget);
    expect(find.text('黑夜'), findsOneWidget);
    expect(find.text('随设备外观自动切换'), findsOneWidget);

    await tester.tap(find.byKey(const Key('appearance-option-dark')));
    await tester.pumpAndSettle();

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
  AppearancePreference value = AppearancePreference.system;
  final List<AppearancePreference> writes = [];

  @override
  Future<AppearancePreference> read() async => value;

  @override
  Future<void> write(AppearancePreference preference) async {
    writes.add(preference);
    if (failWrite) throw StateError('write failed');
    value = preference;
  }
}
