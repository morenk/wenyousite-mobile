import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/appearance_preference.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_widgets.dart';
import 'package:wenyousite_mobile/features/settings/presentation/appearance_settings_page.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('采集离线且可重复的关键交互帧时间', (tester) async {
    expect(kDebugMode, isFalse, reason: '性能采样必须使用 Profile 构建');

    await _measureAppearanceSwap(binding, tester);
    await _measureStandardNavigation(binding, tester);
    await _measureMomentFeedScroll(binding, tester);
    await _measureMarkdownTimelineScroll(binding, tester);
  });
}

Future<void> _measureAppearanceSwap(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appearancePreferenceStoreProvider.overrideWithValue(
          _MemoryAppearanceStore(),
        ),
        initialAppearancePreferenceStateProvider.overrideWithValue(
          const AppearancePreferenceState(
            preference: AppearancePreference.light,
          ),
        ),
      ],
      child: const _AppearanceBenchmarkApp(),
    ),
  );
  await tester.pumpAndSettle();
  await _selectAppearance(tester, AppearancePreference.dark);
  await _selectAppearance(tester, AppearancePreference.light);

  await binding.watchPerformance(() async {
    for (var index = 0; index < 12; index++) {
      await _selectAppearance(
        tester,
        index.isEven ? AppearancePreference.dark : AppearancePreference.light,
      );
    }
  }, reportKey: 'appearance_swap');
}

Future<void> _selectAppearance(
  WidgetTester tester,
  AppearancePreference preference,
) async {
  await tester.tap(find.byKey(Key('appearance-option-${preference.name}')));
  await tester.pumpAndSettle();
}

Future<void> _measureStandardNavigation(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
) async {
  await tester.pumpWidget(const _BenchmarkApp(home: _NavigationHome()));
  await tester.pumpAndSettle();
  await _openAndCloseRoute(tester);

  await binding.watchPerformance(() async {
    for (var index = 0; index < 8; index++) {
      await _openAndCloseRoute(tester);
    }
  }, reportKey: 'standard_navigation');
}

Future<void> _openAndCloseRoute(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('open-standard-route')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('close-standard-route')));
  await tester.pumpAndSettle();
}

Future<void> _measureMomentFeedScroll(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
) async {
  await tester.pumpWidget(const _BenchmarkApp(home: _MomentFeedBenchmark()));
  await tester.pumpAndSettle();
  await _flingBothDirections(tester, const Key('moment-feed-scroll'), 1);

  await binding.watchPerformance(() async {
    await _flingBothDirections(tester, const Key('moment-feed-scroll'), 6);
  }, reportKey: 'moment_feed_scroll');
}

Future<void> _measureMarkdownTimelineScroll(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    const _BenchmarkApp(home: _MarkdownTimelineBenchmark()),
  );
  await tester.pumpAndSettle();
  await _flingBothDirections(tester, const Key('markdown-timeline-scroll'), 1);

  await binding.watchPerformance(() async {
    await _flingBothDirections(
      tester,
      const Key('markdown-timeline-scroll'),
      6,
    );
  }, reportKey: 'markdown_timeline_scroll');
}

Future<void> _flingBothDirections(
  WidgetTester tester,
  Key scrollKey,
  int repetitions,
) async {
  final scrollable = find.byKey(scrollKey);
  for (var index = 0; index < repetitions; index++) {
    await tester.fling(scrollable, const Offset(0, -1400), 7000);
    await tester.pumpAndSettle();
  }
  for (var index = 0; index < repetitions; index++) {
    await tester.fling(scrollable, const Offset(0, 1400), 7000);
    await tester.pumpAndSettle();
  }
}

class _AppearanceBenchmarkApp extends ConsumerWidget {
  const _AppearanceBenchmarkApp();

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
      home: const AppearanceSettingsPage(),
    );
  }
}

class _MemoryAppearanceStore implements AppearancePreferenceStore {
  var value = AppearancePreference.light;

  @override
  Future<AppearancePreference> read() async => value;

  @override
  Future<void> write(AppearancePreference preference) async {
    value = preference;
  }
}

class _BenchmarkApp extends StatelessWidget {
  const _BenchmarkApp({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      themeAnimationStyle: AnimationStyle.noAnimation,
      home: home,
    );
  }
}

class _NavigationHome extends StatelessWidget {
  const _NavigationHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导航性能基准')),
      body: Center(
        child: FilledButton(
          key: const Key('open-standard-route'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const _NavigationDestination(),
              ),
            );
          },
          child: const Text('打开内容页'),
        ),
      ),
    );
  }
}

class _NavigationDestination extends StatelessWidget {
  const _NavigationDestination();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('close-standard-route'),
          onPressed: () => Navigator.of(context).pop(),
          icon: const WenyouIcon(WenyouIconIds.navigationBack),
        ),
        title: const Text('内容页'),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(tokens.space16),
        itemCount: 24,
        separatorBuilder: (context, index) => SizedBox(height: tokens.space12),
        itemBuilder: (context, index) =>
            WenyouPanel(child: Text('第 ${index + 1} 段内容，用于覆盖标准页面进出动画。')),
      ),
    );
  }
}

class _MomentFeedBenchmark extends StatelessWidget {
  const _MomentFeedBenchmark();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Scaffold(
      appBar: AppBar(title: const Text('动态流性能基准')),
      body: ListView.separated(
        key: const Key('moment-feed-scroll'),
        padding: EdgeInsets.all(tokens.space16),
        itemCount: 36,
        separatorBuilder: (context, index) => SizedBox(height: tokens.space16),
        itemBuilder: (context, index) =>
            MomentCardTile(moment: _moment(index), onTap: () {}),
      ),
    );
  }
}

MomentCard _moment(int index) {
  final timestamp = DateTime.utc(2026, 8, 26, 8, index % 60);
  return MomentCard(
    id: 'benchmark-$index',
    author: MomentAuthor(
      id: 'author-${index % 8}',
      username: '测试用户 ${index % 8 + 1}',
      level: index % 12 + 1,
    ),
    title: '第 ${index + 1} 条动态：雾港今日见闻',
    contentExcerpt: '这是不访问网络的固定内容，用于复现动态卡片在连续滚动时的布局与绘制负载。',
    coverType: MomentCoverType.text,
    textCoverTheme:
        MomentTextCoverTheme.values[index % MomentTextCoverTheme.values.length],
    imageCount: 0,
    likeCount: index * 17,
    commentCount: index * 3,
    bookmarkCount: index,
    tipTotal: '0',
    viewerLiked: index.isEven,
    viewerBookmarked: index % 3 == 0,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

class _MarkdownTimelineBenchmark extends StatelessWidget {
  const _MarkdownTimelineBenchmark();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Scaffold(
      appBar: AppBar(title: const Text('长内容性能基准')),
      body: ListView.separated(
        key: const Key('markdown-timeline-scroll'),
        padding: EdgeInsets.all(tokens.space16),
        itemCount: 72,
        separatorBuilder: (context, index) => SizedBox(height: tokens.space12),
        itemBuilder: (context, index) {
          final ownMessage = index.isEven;
          return Align(
            alignment: ownMessage
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.88,
              child: WenyouPanel(
                color: ownMessage ? tokens.accentedBackground : tokens.panel,
                padding: EdgeInsets.all(tokens.space12),
                child: WenyouMarkdown(
                  data:
                      '**第 ${index + 1} 条记录**\n\n'
                      '固定 Markdown 正文覆盖强调、段落和列表：\n'
                      '- 保持离线可重复\n'
                      '- 模拟讨论与私信时间线',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
