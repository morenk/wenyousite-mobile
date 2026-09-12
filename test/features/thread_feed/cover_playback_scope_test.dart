import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/data_saver_preference.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_feedback_visibility.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/features/thread_feed/domain/thread_feed_models.dart';
import 'package:wenyousite_mobile/features/thread_feed/presentation/cover_playback_scope.dart';
import 'package:wenyousite_mobile/features/thread_feed/presentation/thread_feed_cover.dart';

Widget _readyPoster(
  BuildContext context,
  String url,
  VoidCallback onReady,
  VoidCallback onError,
) {
  WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
  return const ColoredBox(color: Colors.white);
}

void main() {
  for (final nested in [false, true]) {
    testWidgets('真实路由转场完成后无需滚动激活可见项，嵌套父路由=$nested', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      final tokens = <CancelToken>[];
      Widget coverPage() => Scaffold(
        body: Center(
          child: SizedBox(
            width: 300,
            child: ThreadFeedCover(
              posterUrl: 'https://cdn.example/poster.webp',
              animationUrl: 'https://cdn.example/a.gif',
              posterBuilder: _readyPoster,
              animationLoader: (_, cancel) {
                tokens.add(cancel);
                return Completer<Uint8List>().future;
              },
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            navigatorKey: navigator,
            builder: (_, child) => CoverPlaybackScope(child: child!),
            home: const Scaffold(body: Text('入口')),
          ),
        ),
      );
      unawaited(
        navigator.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => nested
                ? Navigator(
                    onGenerateRoute: (_) =>
                        MaterialPageRoute<void>(builder: (_) => coverPage()),
                  )
                : coverPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(tokens, isEmpty);
      await tester.pumpAndSettle();
      await tester.pump();
      await tester.pump();
      expect(tokens.length, 1);
      unawaited(
        navigator.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('详情')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tokens.single.isCancelled, isTrue);
      navigator.currentState!.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 140));
      expect(tokens.length, 1);
      await tester.pumpAndSettle();
      await tester.pump();
      await tester.pump();
      expect(tokens.length, 2);
      await tester.pumpWidget(const SizedBox());
    });
  }
  for (final ratio in [1.0, 2.0]) {
    testWidgets('真实封面宽度300与DPR=$ratio选择一档，预览失败不补取原图', (tester) async {
      final requests = <String>[];
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(800, 600),
                devicePixelRatio: ratio,
              ),
              child: CoverPlaybackScope(
                child: Scaffold(
                  body: Center(
                    child: SizedBox(
                      width: 300,
                      child: ThreadFeedCover(
                        posterUrl: 'https://cdn.example/poster.webp',
                        animationUrl: 'https://cdn.example/original.gif',
                        previewVariants: const [
                          ThreadFeedCoverPreviewVariant(
                            url: 'https://cdn.example/small.webp',
                            width: 480,
                            height: 270,
                            bytes: 9000,
                          ),
                          ThreadFeedCoverPreviewVariant(
                            url: 'https://cdn.example/large.webp',
                            width: 800,
                            height: 450,
                            bytes: 14000,
                          ),
                        ],
                        posterBuilder: _readyPoster,
                        animationLoader: (url, _) async {
                          requests.add(url);
                          throw StateError('preview unavailable');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 1));
      expect(requests, [
        ratio == 1
            ? 'https://cdn.example/small.webp'
            : 'https://cdn.example/large.webp',
      ]);
      expect(find.byType(RawImage), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
  testWidgets('隐藏Tab和减少动态效果撤销播放，恢复立即重测', (tester) async {
    var active = true;
    late StateSetter updateTab;
    final tokens = <CancelToken>[];
    Future<Uint8List> loader(String _, CancelToken token) {
      tokens.add(token);
      return Completer<Uint8List>().future;
    }

    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (_, child) => CoverPlaybackScope(child: child!),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                updateTab = setState;
                return TickerMode(
                  enabled: active,
                  child: Offstage(
                    offstage: !active,
                    child: Center(
                      child: SizedBox(
                        width: 300,
                        child: ThreadFeedCover(
                          posterUrl: 'https://cdn.example/poster.webp',
                          animationUrl: 'https://cdn.example/a.gif',
                          animationLoader: loader,
                          posterBuilder: _readyPoster,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tokens.length, 1);
    updateTab(() => active = false);
    await tester.pump();
    expect(tokens.single.isCancelled, isTrue);
    await tester.pump(const Duration(seconds: 1));
    expect(tokens.length, 1);
    updateTab(() => active = true);
    await tester.pump();
    await tester.pump();
    expect(tokens.length, 2);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    await tester.pump();
    expect(tokens.last.isCancelled, isTrue);
    await tester.pump(const Duration(seconds: 1));
    expect(tokens.length, 2);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('poster加载或解码失败保持占位且迟到成功不启动动画', (tester) async {
    var calls = 0;
    VoidCallback? ready;
    VoidCallback? failed;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (_, child) => CoverPlaybackScope(child: child!),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: ThreadFeedCover(
                  posterUrl: 'https://cdn.example/missing.webp',
                  animationUrl: 'https://cdn.example/a.gif',
                  animationLoader: (_, _) {
                    calls++;
                    return Completer<Uint8List>().future;
                  },
                  posterBuilder: (_, _, onReady, onError) {
                    ready = onReady;
                    failed = onError;
                    return const ColoredBox(color: Colors.white);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(calls, 0);
    failed!();
    ready!();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(calls, 0);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('半可见的所有封面立即请求，滚动保持，离屏及全局限制才撤销', (tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final requests = <String>[];
    final tokens = <CancelToken>[];
    final container = ProviderContainer();
    final scroll = ScrollController();
    Future<Uint8List> loader(String url, CancelToken cancel) {
      requests.add(url);
      tokens.add(cancel);
      return Completer<Uint8List>().future;
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => CoverPlaybackScope(child: child!),
          home: Scaffold(
            body: ListView(
              controller: scroll,
              children: [
                for (var index = 0; index < 5; index++)
                  ThreadFeedCover(
                    posterUrl: 'https://cdn.example/$index.jpg',
                    animationUrl: 'https://cdn.example/$index.gif',
                    animationLoader: loader,
                    posterBuilder: _readyPoster,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(requests, [
      'https://cdn.example/0.gif',
      'https://cdn.example/1.gif',
      'https://cdn.example/2.gif',
    ]);
    final gesture = await tester.startGesture(const Offset(200, 400));
    await gesture.moveBy(const Offset(0, -70));
    await tester.pump();
    expect(tokens.every((token) => !token.isCancelled), isTrue);
    await gesture.up();
    await tester.pumpAndSettle();
    await tester.pump();
    expect(requests.length, 3);
    scroll.jumpTo(250);
    await tester.pump();
    expect(tokens.first.isCancelled, isTrue);
    expect(tokens[1].isCancelled, isFalse);
    expect(tokens[2].isCancelled, isFalse);
    expect(requests.last, 'https://cdn.example/3.gif');
    scroll.jumpTo(0);
    await tester.pump();
    expect(tokens[3].isCancelled, isTrue);
    expect(tokens[1].isCancelled, isFalse);
    expect(tokens[2].isCancelled, isFalse);
    expect(requests.last, 'https://cdn.example/0.gif');
    expect(requests.length, 5);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(tokens.every((token) => token.isCancelled), isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();
    expect(requests.length, 8);
    await container
        .read(dataSaverPreferenceControllerProvider.notifier)
        .select(true);
    expect(tokens.every((token) => token.isCancelled), isTrue);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(requests.length, 8);
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    scroll.dispose();
  });

  testWidgets('缺失可信poster不请求旧原图，详情遮挡与返回重新激活', (tester) async {
    final visibility = WenyouFeedbackVisibility();
    final navigator = GlobalKey<NavigatorState>();
    var calls = 0;
    CancelToken? token;
    Future<Uint8List> loader(String _, CancelToken cancel) {
      calls++;
      token = cancel;
      return Completer<Uint8List>().future;
    }

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          navigatorKey: navigator,
          navigatorObservers: [visibility.createObserver()],
          builder: (context, child) =>
              CoverPlaybackScope(navigationChanges: visibility, child: child!),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: ThreadFeedCover(
                  animationUrl: 'https://external.example/a.gif',
                  animationLoader: loader,
                  posterBuilder: _readyPoster,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(calls, 0);
    expect(find.byType(WenyouCachedImage), findsNothing);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          navigatorKey: navigator,
          navigatorObservers: [visibility.createObserver()],
          builder: (context, child) =>
              CoverPlaybackScope(navigationChanges: visibility, child: child!),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: ThreadFeedCover(
                  posterUrl: 'https://cdn.example/poster.jpg',
                  animationUrl: 'https://cdn.example/a.gif',
                  animationLoader: loader,
                  posterBuilder: _readyPoster,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(calls, 1);
    unawaited(
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('详情')),
        ),
      ),
    );
    expect(token!.isCancelled, isTrue);
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(calls, 1);
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    await tester.pump();
    expect(calls, 2);
    await tester.pumpWidget(const SizedBox());
    visibility.dispose();
  });
}
