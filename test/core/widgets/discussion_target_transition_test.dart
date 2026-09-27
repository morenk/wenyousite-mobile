import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_target_cover.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_target_loading.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('目标稳定后按 Foundation 淡出，结束前隔离操作和读屏且不移动正文', (tester) async {
    final semantics = tester.ensureSemantics();
    final key = GlobalKey<_HarnessState>();
    await tester.pumpWidget(_app(key));
    expect(_opacity(tester), 1);
    expect(find.bySemanticsLabel('目标操作'), findsNothing);
    await _untilFading(tester);
    final targetTop = tester.getTopLeft(
      find.byKey(key.currentState!.targetKey),
    );
    expect(_opacity(tester), inExclusiveRange(0, 1));
    expect(find.text('目标操作').hitTestable(), findsNothing);
    expect(find.bySemanticsLabel('目标操作'), findsNothing);
    expect(key.currentState!.reveals, 0);
    await tester.pump(WenyouFoundationMotion.standard);
    await tester.pump();
    expect(find.byKey(const Key('discussion-target-cover')), findsNothing);
    expect(find.bySemanticsLabel('目标操作'), findsOneWidget);
    expect(key.currentState!.reveals, 1);
    expect(
      tester.getTopLeft(find.byKey(key.currentState!.targetKey)),
      targetTop,
    );
    await tester.tap(find.text('目标操作'));
    expect(key.currentState!.taps, 1);
    semantics.dispose();
  });

  testWidgets('淡出途中切换坐标立即盖回，旧动画不能揭开新目标', (tester) async {
    final key = GlobalKey<_HarnessState>();
    await tester.pumpWidget(_app(key));
    await _untilFading(tester);
    key.currentState!.update(target: 'second', ready: false);
    await tester.pump();
    expect(_opacity(tester), 1);
    await tester.pump(const Duration(seconds: 1));
    expect(_opacity(tester), 1);
    expect(key.currentState!.reveals, 0);
    key.currentState!.update(ready: true);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('discussion-target-cover')), findsNothing);
    expect(key.currentState!.reveals, 1);
    expect(find.text('second'), findsOneWidget);
  });

  testWidgets('淡出途中失败保留错误与返回，重试从不透明等待重新开始', (tester) async {
    final key = GlobalKey<_HarnessState>();
    await tester.pumpWidget(_app(key));
    await _untilFading(tester);
    key.currentState!.update(issue: true);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(_opacity(tester), 1);
    expect(key.currentState!.reveals, 0);
    expect(find.text('加载失败').hitTestable(), findsOneWidget);
    await tester.tap(find.byKey(const Key('discussion-target-return')));
    expect(key.currentState!.backs, 1);
    key.currentState!.update(target: 'retry', issue: false, ready: false);
    await tester.pump();
    expect(find.byType(DiscussionTargetLoading), findsOneWidget);
    expect(_opacity(tester), 1);
    key.currentState!.update(ready: true);
    await tester.pumpAndSettle();
    expect(key.currentState!.reveals, 1);
  });

  testWidgets('等待中开启减少动画立即静止，目标稳定后直接显现', (tester) async {
    final key = GlobalKey<_HarnessState>();
    await tester.pumpWidget(_app(key, ready: false));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    await tester.pumpWidget(_app(key, reduceMotion: true, ready: false));
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
    key.currentState!.update(ready: true);
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      if (find.byKey(const Key('discussion-target-cover')).evaluate().isEmpty) {
        break;
      }
      expect(_opacity(tester), 1);
    }
    expect(find.byKey(const Key('discussion-target-cover')), findsNothing);
    expect(key.currentState!.reveals, 1);
  });

  testWidgets('淡出中开启减少动画直接完成且只回调一次', (tester) async {
    final key = GlobalKey<_HarnessState>();
    await tester.pumpWidget(_app(key));
    await _untilFading(tester);
    await tester.pumpWidget(_app(key, reduceMotion: true));
    await tester.pump();
    expect(find.byKey(const Key('discussion-target-cover')), findsNothing);
    expect(key.currentState!.reveals, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(key.currentState!.reveals, 1);
  });

  testWidgets('动画中返回销毁不产生延迟回调或异常', (tester) async {
    final key = GlobalKey<_HarnessState>();
    await tester.pumpWidget(_app(key));
    await _untilFading(tester);
    final state = key.currentState!;
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 6));
    expect(state.reveals, 0);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('定位等待视觉 ${dark ? 'dark' : 'light'} ${scale}x', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(scale == 2 ? 320 : 360, 640);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await tester.pumpWidget(
          _app(
            GlobalKey<_HarnessState>(),
            ready: false,
            dark: dark,
            scale: scale,
            reduceMotion: true,
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('正在定位目标楼层'), findsOneWidget);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            'goldens/target_loading_${dark ? 'dark' : 'light'}_${scale}x.png',
          ),
        );
        await tester.pump(const Duration(seconds: 5));
        expect(
          find.byKey(const Key('discussion-target-return')).hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}

double _opacity(WidgetTester tester) => tester
    .widget<FadeTransition>(
      find.byKey(const Key('discussion-target-transition')),
    )
    .opacity
    .value;

Future<void> _untilFading(WidgetTester tester) async {
  for (var frame = 0; frame < 60; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
    if (_opacity(tester) < 1) return;
  }
  fail('真实目标布局稳定后应开始淡出');
}

Widget _app(
  GlobalKey<_HarnessState> key, {
  bool ready = true,
  bool reduceMotion = false,
  bool dark = false,
  double scale = 1,
}) => MaterialApp(
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      disableAnimations: reduceMotion,
      textScaler: TextScaler.linear(scale),
    ),
    child: child!,
  ),
  home: _Harness(key: key, ready: ready),
);

class _Harness extends StatefulWidget {
  const _Harness({super.key, this.ready = true});
  final bool ready;
  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  final targetKey = GlobalKey();
  final listKey = GlobalKey();
  final controller = ScrollController();
  late bool ready = widget.ready;
  bool issue = false;
  String target = 'first';
  int reveals = 0, taps = 0, backs = 0;

  void update({String? target, bool? ready, bool? issue}) => setState(() {
    this.target = target ?? this.target;
    this.ready = ready ?? this.ready;
    this.issue = issue ?? this.issue;
  });

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('主题讨论')),
    body: DiscussionTargetCover(
      scope: target,
      targetId: target,
      loadingLabel: '正在定位目标楼层',
      revealedLabel: '已定位到目标楼层',
      targetKey: targetKey,
      itemListKey: listKey,
      scrollController: controller,
      targetIndex: 1,
      itemCount: 3,
      canLocate: ready,
      isLoadingPage: false,
      hasMore: false,
      onLoadMore: () {},
      onRetry: () {},
      onBack: () => backs++,
      onRevealed: () => reveals++,
      issue: issue ? const Text('加载失败') : null,
      child: CustomScrollView(
        controller: controller,
        slivers: [
          SliverList.list(
            key: listKey,
            children: [
              const SizedBox(height: 900),
              SizedBox(
                key: targetKey,
                height: 300,
                child: Column(
                  children: [
                    Text(target),
                    TextButton(
                      onPressed: () => taps++,
                      child: const Text('目标操作'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 1000),
            ],
          ),
        ],
      ),
    ),
  );
}
