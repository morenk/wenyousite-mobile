import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_page_transitions.dart';

void main() {
  testWidgets('Android 普通路由只使用 180ms 横向位移', (tester) async {
    final observer = _RecordingNavigatorObserver();
    var destinationBuilds = 0;
    late BuildContext launcherContext;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light.copyWith(platform: TargetPlatform.android),
        navigatorObservers: [observer],
        home: Builder(
          builder: (context) {
            launcherContext = context;
            return GestureDetector(
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) {
                    destinationBuilds += 1;
                    return const Scaffold(body: Text('目标页'));
                  },
                ),
              ),
              child: const Text('打开'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pump();

    final route = observer.lastPushed! as PageRoute<void>;
    expect(route.transitionDuration, WenyouFoundationMotion.standard);
    expect(route.reverseTransitionDuration, WenyouFoundationMotion.standard);
    final transition = Theme.of(launcherContext)
        .pageTransitionsTheme
        .builders[TargetPlatform.android]!
        .buildTransitions<void>(
          route,
          launcherContext,
          const AlwaysStoppedAnimation<double>(0.5),
          const AlwaysStoppedAnimation<double>(0),
          const SizedBox(),
        );
    expect(transition, isA<SlideTransition>());
    expect((transition as SlideTransition).child, isA<SizedBox>());

    await tester.pump(const Duration(milliseconds: 90));
    expect(_movingSlides(tester), hasLength(1));
    expect(find.byType(FadeTransition), findsNothing);
    expect(destinationBuilds, 1);

    Navigator.of(tester.element(find.text('目标页'))).pop();
    await tester.pump(const Duration(milliseconds: 90));
    expect(_movingSlides(tester), hasLength(1));
    expect(find.byType(FadeTransition), findsNothing);
    expect(destinationBuilds, 1);
    await tester.pumpAndSettle();
  });

  testWidgets('全屏媒体只使用 120ms 淡化', (tester) async {
    final observer = _RecordingNavigatorObserver();
    late BuildContext launcherContext;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light.copyWith(platform: TargetPlatform.android),
        navigatorObservers: [observer],
        home: Builder(
          builder: (context) {
            launcherContext = context;
            return GestureDetector(
              onTap: () => pushWenyouFullscreenPage<void>(
                context: context,
                builder: (_) => const Scaffold(body: Text('原图')),
              ),
              child: const Text('查看'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('查看'));
    await tester.pump();

    final route = observer.lastPushed! as PageRoute<void>;
    expect(route.fullscreenDialog, isTrue);
    expect(route.transitionDuration, WenyouFoundationMotion.fast);
    expect(route.reverseTransitionDuration, WenyouFoundationMotion.fast);
    final transition = route.buildTransitions(
      launcherContext,
      const AlwaysStoppedAnimation<double>(0.5),
      const AlwaysStoppedAnimation<double>(0),
      const SizedBox(),
    );
    expect(transition, isA<FadeTransition>());
    expect((transition as FadeTransition).child, isA<SizedBox>());

    await tester.pump(const Duration(milliseconds: 60));
    expect(find.byType(FadeTransition), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('关闭动画时页面路由降为零时长', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final observer = _RecordingNavigatorObserver();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light.copyWith(platform: TargetPlatform.android),
        navigatorObservers: [observer],
        home: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: Text('目标页')),
              ),
            ),
            child: const Text('打开'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pump();

    final route = observer.lastPushed! as PageRoute<void>;
    expect(route.transitionDuration, Duration.zero);
    expect(route.reverseTransitionDuration, Duration.zero);
    expect(find.text('目标页'), findsOneWidget);
    expect(find.byType(SlideTransition), findsNothing);
    expect(find.byType(FadeTransition), findsNothing);
  });

  testWidgets('直达兜底页保持瞬时切换', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (currentContext) {
            context = currentContext;
            return const SizedBox();
          },
        ),
      ),
    );

    final page = wenyouInstantPage<void>(
      key: const ValueKey('instant'),
      child: const SizedBox(),
    );
    final route = page.createRoute(context) as PageRoute<void>;

    expect(route.transitionDuration, Duration.zero);
    expect(route.reverseTransitionDuration, Duration.zero);
  });
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  Route<dynamic>? lastPushed;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (previousRoute != null) lastPushed = route;
  }
}

List<SlideTransition> _movingSlides(WidgetTester tester) {
  return tester
      .widgetList<SlideTransition>(find.byType(SlideTransition))
      .where((transition) => transition.position.value.dx.abs() > 0.001)
      .toList();
}
