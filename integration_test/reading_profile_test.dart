import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';
import '../test/features/threads/thread_detail_page_test_support.dart';
import 'reading_profile_fixture.dart';

void main() {
  final binding = _ReadingProfileBinding();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  testWidgets('离线千层连续阅读、折返和慢响应', (tester) async {
    expect(kProfileMode, isTrue, reason: '仅允许真机 Profile 性能测量');
    final previousHttp = HttpOverrides.current;
    HttpOverrides.global = ReadingLoopbackOnly();
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawColor(Colors.blue, BlendMode.src);
    final picture = recorder.endRecording();
    final image = await picture.toImage(2560, 1920);
    final bytes = (await image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    image.dispose();
    picture.dispose();
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var imageRequests = 0;
    final connections = server.listen((request) async {
      imageRequests++;
      await Future<void>.delayed(const Duration(milliseconds: 800));
      request.response.headers.contentType = ContentType('image', 'png');
      request.response.add(bytes);
      await request.response.close();
    });
    final repository = ReadingProfileRepository(
      'http://127.0.0.1:${server.port}',
    );
    final root = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          ThreadDetailPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          ThreadDetailPageTestFakeSessionRemote(),
        ),
      ],
    );
    final samples = <Map<String, Object>>[];
    final navigation = <Map<String, Object>>[];
    final frames = _Frames();
    binding.addTimingsCallback(frames.add);
    final wall = Stopwatch()..start();
    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: root,
          child: threadDetailPageTestDetailApp(repository),
        ),
      );
      await _waitForReading(tester, repository);
      debugPrint('READING_PROFILE ready; begin measured interactions');
      const seconds = int.fromEnvironment(
        'READING_SECONDS',
        defaultValue: 1200,
      );
      var cycle = 0;
      var sampledAt = -30;
      final reading = tester
          .widget<ReadingProgressViewport>(find.byType(ReadingProgressViewport))
          .controller;
      while (wall.elapsed.inSeconds < seconds) {
        repository.slow = cycle % 8 >= 5;
        final viewport = find.byType(ReadingProgressViewport);
        await tester.fling(
          viewport,
          Offset(0, cycle % 4 == 3 ? 500 : -650),
          1100,
        );
        // 真机保留自然帧调度，不以全局停止请求帧作为阅读操作完成条件。
        await tester.pump(const Duration(milliseconds: 1200));
        if (cycle % 6 == 0) {
          final target =
              (cycle * 137 + 45) % ReadingProfileRepository.count + 1;
          final started = Stopwatch()..start();
          final priorRequests = repository.requests.length;
          final before = await _jump(
            tester,
            target,
            beforeSubmit: reading.captureBookmark,
          );
          await _waitForReading(tester, repository, targetId: '$target');
          expect(find.byKey(Key('thread-floor-card-$target')), findsOneWidget);
          navigation.add({
            'target': target,
            'ms': started.elapsedMilliseconds,
            'targetReads': repository.requests
                .skip(priorRequests)
                .where((r) => r['target'] == true)
                .length,
          });
          expect(navigation.last['targetReads'], 1);
          final back = find.text('回到刚才');
          if (before != null && back.evaluate().isNotEmpty) {
            await tester.tap(back);
            await _waitForReading(tester, repository, targetId: before.id);
            final returned = reading.captureBookmark();
            navigation.last.addAll({
              'beforeId': before.id,
              'returnedId': returned?.id ?? 'missing',
              'beforeOffset': before.offset,
              'returnedOffset': returned?.offset ?? -1,
            });
            expect(returned?.id, before.id);
          }
        }
        // 在已有阅读窗口上模拟断网，失败之后只通过下一次显式导航恢复。
        if (cycle % 17 == 8) {
          repository.offline = true;
          final countBefore = repository.requests.length;
          await _jump(tester, 1001);
          await tester.pump(const Duration(seconds: 2));
          expect(repository.requests.length - countBefore, 1);
          repository.offline = false;
          Navigator.of(
            tester.element(find.byKey(const Key('discussion-number-input'))),
          ).pop();
          await tester.pump(const Duration(milliseconds: 300));
        }
        if (wall.elapsed.inSeconds - sampledAt >= 30) {
          sampledAt = wall.elapsed.inSeconds;
          final container = ProviderScope.containerOf(
            tester.element(find.byType(ThreadDetailPage)),
          );
          final cache = PaintingBinding.instance.imageCache;
          samples.add({
            'seconds': sampledAt,
            'rssBytes': ProcessInfo.currentRss,
            'anchorsMounted': find
                .byType(ReadingPositionAnchor, skipOffstage: false)
                .evaluate()
                .length,
            'providersWithListeners': container
                .getAllProviderElements()
                .where((e) => e.hasListeners)
                .length,
            'imageBytes': cache.currentSizeBytes,
            'liveImages': cache.liveImageCount,
            'pendingImages': cache.pendingImageCount,
            'windowReads': repository.requests.length,
            'frameScheduled': binding.hasScheduledFrame,
            'scrolling':
                reading.scrollController.position.isScrollingNotifier.value,
            ...frames.take(),
          });
          debugPrint(
            'READING_PROFILE sample=$sampledAt reads=${repository.requests.length} rss=${ProcessInfo.currentRss}',
          );
        }
        cycle++;
        await tester.pump(const Duration(milliseconds: 300));
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.byType(ReadingPositionAnchor, skipOffstage: false),
        findsNothing,
      );
      expect(PaintingBinding.instance.imageCache.liveImageCount, 0);
      binding.reportData ??= {};
      binding.reportData!['reading_profile'] = {
        'elapsedSeconds': wall.elapsed.inSeconds,
        'cycles': cycle,
        'syntheticFloors': ReadingProfileRepository.count,
        'samples': samples,
        'navigation': navigation,
        'requests': repository.requests,
        'maximumConcurrentWindowReads': repository.maximumActive,
        'imageRequests': imageRequests,
        'afterUnmountLiveImages':
            PaintingBinding.instance.imageCache.liveImageCount,
        'listenerMetric': '有监听器的 Riverpod provider 数，非全进程订阅数',
      };
    } finally {
      binding.reportData ??= {};
      binding.reportData!['reading_profile_partial'] = {
        'elapsedSeconds': wall.elapsed.inSeconds,
        'samples': samples,
        'navigation': navigation,
        'requests': repository.requests,
        'imageRequests': imageRequests,
      };
      binding.removeTimingsCallback(frames.add);
      await tester.pumpWidget(const SizedBox.shrink());
      root.dispose();
      await connections.cancel();
      await server.close(force: true);
      HttpOverrides.global = previousHttp;
    }
  }, timeout: const Timeout(Duration(minutes: 30)));
}

Future<void> _waitForReading(
  WidgetTester tester,
  ReadingProfileRepository repository, {
  String? targetId,
}) async {
  var stable = 0;
  for (var i = 0; i < 120; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (repository.active == 0 &&
        (targetId == null ||
            find
                .byKey(Key('thread-floor-card-$targetId'))
                .evaluate()
                .isNotEmpty) &&
        find.byType(ReadingProgressViewport).evaluate().isNotEmpty &&
        find.byType(ReadingPositionAnchor).evaluate().isNotEmpty &&
        find.byKey(const Key('discussion-number-input')).evaluate().isEmpty &&
        find.byKey(const Key('discussion-target-cover')).evaluate().isEmpty) {
      // 旧窗口仍可见不代表新请求已完成；目标揭开后连续三帧确认。
      if (++stable >= 3) return;
    } else {
      stable = 0;
    }
  }
  fail(
    '合成阅读页面未在 12 秒内完成定位：'
    'input=${find.byKey(const Key('discussion-number-input')).evaluate().length}, '
    'cover=${find.byKey(const Key('discussion-target-cover')).evaluate().length}',
  );
}

Future<ReadingBookmark?> _jump(
  WidgetTester tester,
  int number, {
  ReadingBookmark? Function()? beforeSubmit,
}) async {
  final capsule = find.byKey(const Key('discussion-position-button'));
  final button = capsule.evaluate().isNotEmpty
      ? capsule
      : find.byKey(const Key('thread-floors-count'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.enterText(
    find.byKey(const Key('discussion-number-input')),
    '$number',
  );
  // 输入后的 setState 必须完成，才能点击已启用的按钮。
  await tester.pump(const Duration(milliseconds: 600));
  final submit = find.byKey(const Key('discussion-number-submit'));
  expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);
  await tester.ensureVisible(submit);
  // 与应用保存书签的点击时点一致，不能取惯性滚动中的更早位置。
  final bookmark = beforeSubmit?.call();
  await tester.tap(submit);
  await tester.pump(const Duration(milliseconds: 300));
  return bookmark;
}

/// Profile 不接受测试输入默认的 -1 client ID；登记模拟输入以使用真实 ID。
/// 这里只测阅读与导航，不把模拟键盘当作原生 IME 性能验收。
class _ReadingProfileBinding extends IntegrationTestWidgetsFlutterBinding {
  @override
  bool get registerTestTextInput => true;
}

class _Frames {
  final build = <int>[];
  final raster = <int>[];
  void add(List<ui.FrameTiming> timings) {
    for (final frame in timings) {
      build.add(frame.buildDuration.inMicroseconds);
      raster.add(frame.rasterDuration.inMicroseconds);
    }
  }

  Map<String, Object> take() {
    Map<String, Object> summary(String name, List<int> values) {
      if (values.isEmpty) return {};
      values.sort();
      return {
        '${name}P95Us': values[((values.length - 1) * .95).floor()],
        '${name}MaxUs': values.last,
        '${name}Over16ms': values.where((v) => v > 16667).length,
        '${name}Over8ms': values.where((v) => v > 8333).length,
      };
    }

    final result = {
      'frames': build.length,
      ...summary('build', build),
      ...summary('raster', raster),
    };
    build.clear();
    raster.clear();
    return result;
  }
}
