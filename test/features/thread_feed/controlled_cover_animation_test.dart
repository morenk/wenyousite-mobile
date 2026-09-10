import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:wenyousite_mobile/features/thread_feed/application/cover_animation_source_ports.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_playback_coordinator.dart';
import 'package:wenyousite_mobile/features/thread_feed/presentation/controlled_cover_animation.dart';

Uint8List _gif() {
  final encoder = image.GifEncoder(
    repeat: 1,
    numColors: 2,
    quantizerType: image.QuantizerType.octree,
  );
  encoder.addFrame(
    image.Image(width: 16, height: 16)..clear(image.ColorRgb8(255, 0, 0)),
    duration: 10,
  );
  encoder.addFrame(
    image.Image(width: 16, height: 16)..clear(image.ColorRgb8(0, 0, 255)),
    duration: 20,
  );
  return encoder.finish()!;
}

Widget _app({
  required bool playing,
  required CoverAnimationLoader loader,
  ValueNotifier<bool>? lease,
  ValueNotifier<CoverPlaybackPhase>? phase,
  CoverAnimationCodecFactory codecFactory = decodeCoverAnimation,
  String url = 'https://cdn.example/cover.gif',
}) => MaterialApp(
  home: SizedBox(
    width: 100,
    height: 100,
    child: ControlledCoverAnimation(
      url: url,
      playing: playing,
      lease: lease,
      phase: phase,
      codecFactory: codecFactory,
      loader: loader,
      poster: const ColoredBox(key: Key('poster'), color: Colors.white),
    ),
  ),
);

void main() {
  testWidgets('后续帧解码未完成时无关重建不能并发请求或加速时间线', (tester) async {
    final gate = Completer<void>();
    late _SlowFrameCodec codec;
    Future<ui.Codec> factory(Uint8List bytes, int width) async {
      codec = _SlowFrameCodec(await decodeCoverAnimation(bytes, width), gate);
      return codec;
    }

    Future<Uint8List> loader(String _, CancelToken _) async => _gif();
    Widget app() => _app(playing: true, loader: loader, codecFactory: factory);
    await tester.pumpWidget(app());
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pump();
    expect(codec.requests, 1);
    await tester.pump(const Duration(milliseconds: 100));
    expect(codec.requests, 2);
    for (var i = 0; i < 4; i++) {
      await tester.pumpWidget(app());
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(codec.requests, 2);
    expect(codec.maximumInflight, 1);
    await tester.runAsync(() async {
      gate.complete();
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();
    expect(codec.requests, 2);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('80ms资源准备与确认并行，120ms激活不重载且完整显示首帧', (tester) async {
    final phase = ValueNotifier(CoverPlaybackPhase.preparing);
    final ready = Completer<Uint8List>();
    var loads = 0;
    await tester.pumpWidget(
      _app(
        playing: false,
        phase: phase,
        loader: (_, _) {
          loads++;
          return ready.future;
        },
      ),
    );
    expect(loads, 1);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.runAsync(() async {
      ready.complete(_gif());
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pump();
    expect(find.byType(RawImage), findsNothing);
    await tester.pump(const Duration(milliseconds: 40));
    phase.value = CoverPlaybackPhase.playing;
    await tester.pump();
    expect(loads, 1);
    final first = tester.widget<RawImage>(find.byType(RawImage)).image!;
    await tester.pump(const Duration(milliseconds: 99));
    expect(tester.widget<RawImage>(find.byType(RawImage)).image, same(first));
    await tester.pump(const Duration(milliseconds: 1));
    // 首帧的100ms来自真实GIF时间线，不从准备阶段计时，也不修改帧延迟。
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();
    expect(
      tester.widget<RawImage>(find.byType(RawImage)).image,
      isNot(same(first)),
    );
    phase.value = CoverPlaybackPhase.idle;
    await tester.pump();
    expect(find.byType(RawImage), findsNothing);
    await tester.pumpWidget(const SizedBox());
    phase.dispose();
  });

  testWidgets('确认前撤销准备同步取消请求且迟到数据不能解码播放', (tester) async {
    final phase = ValueNotifier(CoverPlaybackPhase.preparing);
    final ready = Completer<Uint8List>();
    late CancelToken token;
    await tester.pumpWidget(
      _app(
        playing: false,
        phase: phase,
        loader: (_, cancel) {
          token = cancel;
          return ready.future;
        },
      ),
    );
    phase.value = CoverPlaybackPhase.idle;
    expect(token.isCancelled, isTrue);
    ready.complete(_gif());
    await tester.pump();
    expect(find.byType(RawImage), findsNothing);
    await tester.pumpWidget(const SizedBox());
    phase.dispose();
  });
  for (final succeeds in [true, false]) {
    testWidgets('缓存能读但无法解码时仅重取一次，重取成功=$succeeds', (tester) async {
      final source = _InvalidCacheSource(
        succeeds ? _gif() : Uint8List.fromList([0]),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 100,
            height: 100,
            child: ControlledCoverAnimation(
              url: 'https://cdn.example/cover.gif',
              playing: true,
              source: source,
              poster: const ColoredBox(
                key: Key('cached-poster'),
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();
      expect(source.loads, 2);
      expect(source.invalidations, succeeds ? 1 : 2);
      expect(find.byType(RawImage), succeeds ? findsOneWidget : findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  }
  testWidgets('真实动画WebP的两轮契约、多帧像素和停止释放', (tester) async {
    final bytes = File(
      'test/fixtures/cover-animation/hello_loop_2.webp',
    ).readAsBytesSync();
    await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(bytes);
      expect(codec.frameCount, greaterThan(1));
      expect(codec.repetitionCount, 1);
      final first = await codec.getNextFrame();
      final second = await codec.getNextFrame();
      final firstPixels = (await first.image.toByteData())!.buffer
          .asUint8List();
      final secondPixels = (await second.image.toByteData())!.buffer
          .asUint8List();
      expect(secondPixels, isNot(equals(firstPixels)));
      first.image.dispose();
      second.image.dispose();
      codec.dispose();
    });
    final lease = ValueNotifier(true);
    await tester.pumpWidget(
      _app(
        playing: false,
        lease: lease,
        url: 'https://cdn.example/animation.webp',
        loader: (_, _) async => bytes,
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pump();
    final frame = tester.widget<RawImage>(find.byType(RawImage)).image!;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    lease.value = false;
    expect(frame.debugDisposed, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.byType(RawImage), findsNothing);
    expect(frame.debugDisposed, isTrue);
    await tester.pumpWidget(const SizedBox());
    lease.dispose();
  });
  testWidgets('独立核对GIF语料帧数、循环次数与末帧像素', (tester) async {
    final decoded = image.decodeGif(_gif())!;
    expect(decoded.frames.length, 2);
    expect(decoded.frames.last.getPixel(0, 0).b, greaterThan(200));
    await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(_gif());
      expect(codec.frameCount, 2);
      expect(codec.repetitionCount, 1);
      for (var i = 0; i < 2; i++) {
        final frame = await codec.getNextFrame();
        final bytes = await frame.image.toByteData();
        if (i == 1) expect(bytes!.getUint8(2), greaterThan(200));
        frame.image.dispose();
      }
      codec.dispose();
    });
  });
  testWidgets('未选中不请求，下载迟到不能创建解码帧', (tester) async {
    final pending = Completer<Uint8List>();
    var calls = 0;
    CancelToken? cancellation;
    Future<Uint8List> loader(String _, CancelToken cancel) {
      calls++;
      cancellation = cancel;
      return pending.future;
    }

    await tester.pumpWidget(_app(playing: false, loader: loader));
    expect(calls, 0);
    await tester.pumpWidget(_app(playing: true, loader: loader));
    expect(calls, 1);
    await tester.pumpWidget(_app(playing: false, loader: loader));
    expect(cancellation!.isCancelled, isTrue);
    pending.complete(_gif());
    await tester.pump();
    expect(find.byType(RawImage), findsNothing);
    expect(find.byKey(const Key('poster')), findsOneWidget);
  });

  testWidgets('租约失效同步取消下载，换源丢弃旧响应', (tester) async {
    final lease = ValueNotifier(true);
    final requests = <CancelToken>[];
    final completions = <Completer<Uint8List>>[];
    Future<Uint8List> loader(String _, CancelToken cancel) {
      requests.add(cancel);
      final result = Completer<Uint8List>();
      completions.add(result);
      return result.future;
    }

    await tester.pumpWidget(_app(playing: false, lease: lease, loader: loader));
    lease.value = false;
    expect(requests.single.isCancelled, isTrue);
    lease.value = true;
    expect(requests.length, 2);
    await tester.pumpWidget(
      _app(
        playing: false,
        lease: lease,
        loader: loader,
        url: 'https://cdn.example/other.gif',
      ),
    );
    expect(requests[1].isCancelled, isTrue);
    lease.value = false;
    for (final result in completions) {
      result.complete(_gif());
    }
    await tester.pump();
    expect(find.byType(RawImage), findsNothing);
    await tester.pumpWidget(const SizedBox());
    lease.dispose();
  });

  testWidgets('真实有限循环GIF停止在末帧，撤销租约释放帧', (tester) async {
    final lease = ValueNotifier(true);
    Future<Uint8List> loader(String _, CancelToken cancel) async => _gif();
    await tester.pumpWidget(_app(playing: false, lease: lease, loader: loader));
    // Engine codec completes outside the fake clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pump();
    expect(find.byType(RawImage), findsOneWidget);
    final observed = <ui.Image>{
      tester.widget<RawImage>(find.byType(RawImage)).image!,
    };
    for (var index = 0; index < 20; index++) {
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
      observed.add(tester.widget<RawImage>(find.byType(RawImage)).image!);
    }
    expect(observed.length, 4);
    final last = tester.widget<RawImage>(find.byType(RawImage)).image;
    final pixels = await tester.runAsync(() => last!.toByteData());
    expect(pixels!.getUint8(0), lessThan(50));
    expect(pixels.getUint8(2), greaterThan(200));
    await tester.pump(const Duration(seconds: 2));
    expect(tester.widget<RawImage>(find.byType(RawImage)).image, same(last));
    lease.value = false;
    await tester.pump();
    expect(find.byType(RawImage), findsNothing);
    expect(last!.debugDisposed, isTrue);
    await tester.pumpWidget(const SizedBox());
    lease.dispose();
  });

  testWidgets('替换为未选中租约立即取消旧请求', (tester) async {
    final previous = ValueNotifier(true);
    final next = ValueNotifier(false);
    CancelToken? cancel;
    Future<Uint8List> loader(String _, CancelToken token) {
      cancel = token;
      return Completer<Uint8List>().future;
    }

    await tester.pumpWidget(
      _app(playing: false, lease: previous, loader: loader),
    );
    await tester.pumpWidget(_app(playing: false, lease: next, loader: loader));
    expect(cancel!.isCancelled, isTrue);
    expect(find.byType(RawImage), findsNothing);
    await tester.pumpWidget(const SizedBox());
    previous.dispose();
    next.dispose();
  });
}

class _InvalidCacheSource implements CoverAnimationSource {
  _InvalidCacheSource(this.fresh);
  final Uint8List fresh;
  int loads = 0;
  int invalidations = 0;
  @override
  Future<CoverAnimationData> load(String url, CancelToken cancel) async =>
      ++loads == 1
      ? CoverAnimationData(Uint8List.fromList([0]), fromCache: true)
      : CoverAnimationData(fresh);
  @override
  Future<void> invalidate(String url) async {
    invalidations++;
  }

  @override
  void changeViewer(String? accountId, {required bool purge}) {}
  @override
  void releaseMemory() {}
  @override
  void dispose() {}
}

class _SlowFrameCodec implements ui.Codec {
  _SlowFrameCodec(this.delegate, this.gate);
  final ui.Codec delegate;
  final Completer<void> gate;
  int requests = 0;
  int inflight = 0;
  int maximumInflight = 0;
  @override
  int get frameCount => delegate.frameCount;
  @override
  int get repetitionCount => delegate.repetitionCount;
  @override
  Future<ui.FrameInfo> getNextFrame() async {
    requests++;
    inflight++;
    if (inflight > maximumInflight) maximumInflight = inflight;
    try {
      if (requests == 2) await gate.future;
      return await delegate.getNextFrame();
    } finally {
      inflight--;
    }
  }

  @override
  void dispose() => delegate.dispose();
}
