import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/core/widgets/audio_playback_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_audio_player.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/media/application/audio_playback.dart';
import 'package:wenyousite_mobile/features/media/data/just_audio_playback_driver.dart';

import '../../support/audio_driver.dart';
import '../../support/audio_test_fonts.dart';

final _audio = MediaAudio.parse({
  'sourceUrl': 'https://storage.example/audio.mp3',
  'mediaId': 'audio',
  'contentType': 'audio/mpeg',
  'size': 16000,
  'durationMs': 123000,
})!;
final _body =
    '雨停之前，我们在屋檐下等了一会儿。\n\n'
    '[**雨夜**与*片段*：远处的雨声与沿街的脚步](${_audio.sourceUrl})\n\n故事还在继续。';

void main() {
  setUpAll(loadAudioTestFonts);
  testWidgets('密集拖动仅更新进度且缓冲不打断，松手一次提交最终目标', (tester) async {
    final driver = _SeekDriver();
    final controller = AudioPlaybackController(() => driver);
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(controller));
    await tester.tap(
      find.descendant(
        of: find.byType(AudioPlaybackButton),
        matching: find.descendant(
          of: find.byType(AudioPlaybackButton),
          matching: find.byType(IconButton),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final rect = tester.getRect(find.byType(Slider));
    final gesture = await tester.startGesture(
      Offset(rect.left + rect.width * .2, rect.center.dy),
    );
    await gesture.moveBy(const Offset(12, 0));
    await tester.pump();
    driver.state.add(
      const AudioPlaybackStatus(
        playing: true,
        loading: true,
        position: Duration(seconds: 1),
      ),
    );
    await tester.pump();
    final button = tester.widget<AudioPlaybackButton>(
      find.byType(AudioPlaybackButton),
    );
    final title = tester.widget<Text>(find.text('雨夜与片段'));
    for (var i = 3; i <= 8; i++) {
      await gesture.moveTo(
        Offset(rect.left + rect.width * i / 10, rect.center.dy),
      );
      await tester.pump(const Duration(milliseconds: 16));
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.onChanged, isNotNull);
      expect(slider.value, closeTo(_audio.durationMs * i / 10, 2));
      expect(
        tester.widget<AudioPlaybackButton>(find.byType(AudioPlaybackButton)),
        same(button),
      );
      expect(tester.widget<Text>(find.text('雨夜与片段')), same(title));
      expect(driver.targets, isEmpty);
    }
    await gesture.up();
    await tester.pump();
    expect(driver.targets, hasLength(1));
    expect(
      driver.targets.single.inMilliseconds,
      closeTo(_audio.durationMs * .8, 2),
    );
    await tester.pumpWidget(const SizedBox());
  });
  for (final scale in [1.0, 2.0]) {
    for (final dark in [false, true]) {
      for (final width in [320, 360]) {
        testWidgets('状态对照 $width $dark $scale', (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(
            width.toDouble(),
            scale == 1 ? 1000 : 1800,
          );
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          final drivers = List.generate(3, (_) => _SeekDriver());
          final controllers = [
            for (final driver in drivers) AudioPlaybackController(() => driver),
          ];
          for (final controller in controllers) {
            addTearDown(controller.dispose);
          }
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              home: Scaffold(
                body: MediaQuery(
                  data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                  child: SingleChildScrollView(
                    child: RepaintBoundary(
                      key: const ValueKey('states'),
                      child: ColoredBox(
                        color: (dark ? AppTheme.dark : AppTheme.light)
                            .scaffoldBackgroundColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < 3; i++)
                              ProviderScope(
                                overrides: [
                                  audioPlaybackProvider.overrideWithValue(
                                    controllers[i],
                                  ),
                                ],
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(['idle', 'playing', 'dragging'][i]),
                                      WenyouMarkdown(
                                        data: _body,
                                        mediaAudios: {_audio.sourceUrl: _audio},
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          for (final i in [1, 2]) {
            await tester.tap(
              find
                  .descendant(
                    of: find.byType(AudioPlaybackButton),
                    matching: find.byType(IconButton),
                  )
                  .at(i),
            );
            await tester.pump();
            drivers[i].emit(42000);
          }
          await tester.pumpAndSettle();
          final rect = tester.getRect(find.byType(Slider).at(2));
          final gesture = await tester.startGesture(
            Offset(rect.left + rect.width * .3, rect.center.dy),
          );
          await gesture.moveTo(
            Offset(rect.left + rect.width * .7, rect.center.dy),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 180));
          final dragTheme = tester.widget<SliderTheme>(
            find.byType(SliderTheme).at(2),
          );
          expect(
            (dragTheme.data.thumbShape! as RoundSliderThumbShape)
                .enabledThumbRadius,
            6,
          );
          expect(
            (tester
                        .widget<SliderTheme>(find.byType(SliderTheme).at(1))
                        .data
                        .thumbShape!
                    as RoundSliderThumbShape)
                .enabledThumbRadius,
            4,
          );
          final target = tester.widget<Slider>(find.byType(Slider).at(2)).value;
          drivers[2].emit(43000);
          await tester.pump();
          expect(
            tester.widget<Slider>(find.byType(Slider).at(2)).value,
            target,
          );
          expect(drivers[0].loads, isEmpty);
          expect(drivers[2].targets, isEmpty);
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byKey(const ValueKey('states')),
            matchesGoldenFile(
              'goldens/audio_states_${width}_${dark ? 'dark' : 'light'}${scale == 2 ? '_200' : ''}.png',
            ),
          );
          await gesture.cancel();
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }

  testWidgets('拖动保护旧事件、取消释放、连续seek串行且不因旧完成回弹', (tester) async {
    final driver = _SeekDriver()..delaySeek = true;
    final controller = AudioPlaybackController(() => driver);
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(controller));
    await tester.tap(
      find.descendant(
        of: find.byType(AudioPlaybackButton),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();
    driver.emit(10000);
    await tester.pump();
    final rect = tester.getRect(find.byType(Slider));
    Future<TestGesture> drag(double fraction) async {
      final gesture = await tester.startGesture(
        Offset(rect.left + rect.width * .2, rect.center.dy),
      );
      await gesture.moveTo(
        Offset(rect.left + rect.width * fraction, rect.center.dy),
      );
      await tester.pump();
      return gesture;
    }

    var gesture = await drag(.6);
    var target = tester.widget<Slider>(find.byType(Slider)).value;
    driver.emit(12000);
    await tester.pump();
    expect(tester.widget<Slider>(find.byType(Slider)).value, target);
    await gesture.cancel();
    await tester.pump();
    expect(driver.targets, isEmpty);
    expect(tester.widget<Slider>(find.byType(Slider)).value, 12000);
    gesture = await drag(.5);
    await gesture.up();
    await tester.pump();
    expect(driver.targets, hasLength(1));
    gesture = await drag(.8);
    target = tester.widget<Slider>(find.byType(Slider)).value;
    await gesture.up();
    await tester.pump();
    expect(driver.targets, hasLength(1));
    driver.pending.removeAt(0).complete();
    await tester.pump();
    expect(driver.targets, hasLength(2));
    expect(tester.widget<Slider>(find.byType(Slider)).value, target);
    driver.pending.removeAt(0).complete();
    await tester.pump();
    expect(
      tester.widget<Slider>(find.byType(Slider)).value,
      closeTo(target, 1),
    );
    driver.emit(target.round() + 800);
    await tester.pump();
    expect(
      tester.widget<Slider>(find.byType(Slider)).value,
      target.round() + 800,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('键盘聚焦放大圆点、方向键seek、失焦与失败解除目标', (tester) async {
    final driver = _SeekDriver();
    final controller = AudioPlaybackController(() => driver);
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(controller));
    await tester.tap(
      find.descendant(
        of: find.byType(AudioPlaybackButton),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();
    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.focusNode!.requestFocus();
    await tester.pumpAndSettle();
    final theme = tester.widget<SliderTheme>(find.byType(SliderTheme));
    expect(
      (theme.data.thumbShape! as RoundSliderThumbShape).enabledThumbRadius,
      6,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(driver.targets, isNotEmpty);
    slider.focusNode!.unfocus();
    await tester.pumpAndSettle();
    expect(
      (tester.widget<SliderTheme>(find.byType(SliderTheme)).data.thumbShape!
              as RoundSliderThumbShape)
          .enabledThumbRadius,
      4,
    );
    driver.state.addError(StateError('unavailable'));
    await tester.pumpAndSettle();
    expect(find.text('音频播放失败，点击重试。'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AudioPlaybackButton),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(driver.loads, hasLength(2));
  });

  testWidgets('按压缩放内部48dp、图标120ms、边框180ms且始终无渐变', (tester) async {
    final driver = _SeekDriver();
    final controller = AudioPlaybackController(() => driver);
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(controller));
    final rect = tester.getRect(
      find.descendant(
        of: find.byType(AudioPlaybackButton),
        matching: find.byType(IconButton),
      ),
    );
    final gesture = await tester.startGesture(rect.center);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(
      tester
          .widget<ScaleTransition>(
            find.descendant(
              of: find.byType(AnimatedScale),
              matching: find.byType(ScaleTransition),
            ),
          )
          .scale
          .value,
      .96,
    );
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, .96);
    expect(
      tester.getRect(
        find.descendant(
          of: find.byType(AudioPlaybackButton),
          matching: find.byType(IconButton),
        ),
      ),
      rect,
    );
    expect(rect.height, greaterThanOrEqualTo(48));
    await gesture.up();
    await tester.pump();
    expect(
      tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      const Duration(milliseconds: 120),
    );
    expect(
      tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).duration,
      const Duration(milliseconds: 180),
    );
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(
      (tester
                  .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                  .decoration!
              as BoxDecoration)
          .gradient,
      isNull,
    );
    await tester.tap(
      find.descendant(
        of: find.byType(AudioPlaybackButton),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();
    final box =
        tester
                .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                .decoration!
            as BoxDecoration;
    expect(box.gradient, isNull);
  });

  testWidgets('减少动态无缩放过渡或Slider动画，后台停播，离屏仅停视觉', (tester) async {
    final driver = _SeekDriver();
    final controller = AudioPlaybackController(() => driver);
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(controller, reduce: true, scroll: true));
    final gesture = await tester.startGesture(
      tester.getCenter(
        find.descendant(
          of: find.byType(AudioPlaybackButton),
          matching: find.byType(IconButton),
        ),
      ),
    );
    await tester.pump();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(
      tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      Duration.zero,
    );
    expect(
      tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).duration,
      Duration.zero,
    );
    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(
      TickerMode.valuesOf(tester.element(find.byType(Slider))).enabled,
      isFalse,
    );
    slider.focusNode!.requestFocus();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(
      (tester.widget<SliderTheme>(find.byType(SliderTheme)).data.thumbShape!
              as RoundSliderThumbShape)
          .enabledThumbRadius,
      4,
    );
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(_app(controller, scroll: true));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -800),
    );
    await tester.pumpAndSettle();
    expect(
      TickerMode.valuesOf(
        tester.element(find.byType(AudioPlaybackButton)),
      ).enabled,
      isFalse,
    );
    expect(driver.stops, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(driver.stops, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('读屏播放与进度adjust提交，暂停和结束忠于真实时间', (tester) async {
    final semantics = tester.ensureSemantics();
    final driver = _SeekDriver();
    final controller = AudioPlaybackController(() => driver);
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(controller));
    final play = tester.getSemantics(find.bySemanticsLabel('雨夜与片段，播放'));
    play.owner!.performAction(play.id, SemanticsAction.tap);
    await tester.pumpAndSettle();
    expect(driver.loads, hasLength(1));
    final adjustable = <SemanticsNode>[];
    void collect(SemanticsNode node) {
      if (node.getSemanticsData().hasAction(SemanticsAction.increase)) {
        adjustable.add(node);
      }
      node.visitChildren((child) {
        collect(child);
        return true;
      });
    }

    collect(tester.getSemantics(find.byType(Slider)));
    expect(adjustable, hasLength(1));
    final slider = adjustable.single;
    slider.owner!.performAction(slider.id, SemanticsAction.increase);
    await tester.pumpAndSettle();
    expect(driver.targets, hasLength(1));
    driver.state.add(
      const AudioPlaybackStatus(position: Duration(seconds: 42)),
    );
    await tester.pumpAndSettle();
    expect(find.text('0:42 / 2:03'), findsOneWidget);
    expect(tester.widget<Slider>(find.byType(Slider)).value, 42000);
    final trackRect = tester.getRect(find.byType(Slider));
    driver.state.add(
      const AudioPlaybackStatus(
        completed: true,
        position: Duration(seconds: 123),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<Slider>(find.byType(Slider)).value, 123000);
    expect(tester.getRect(find.byType(Slider)), trackRect);
    expect(
      tester
          .widget<AudioPlaybackButton>(find.byType(AudioPlaybackButton))
          .playing,
      isFalse,
    );
    semantics.dispose();
  });

  testWidgets('seek无位置回报超时释放，拖动切换播放器不提交旧目标', (tester) async {
    final driver = _SeekDriver()..delaySeek = true;
    final controller = AudioPlaybackController(() => driver);
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(controller, second: true));
    await tester.tap(
      find
          .descendant(
            of: find.byType(AudioPlaybackButton),
            matching: find.byType(IconButton),
          )
          .first,
    );
    await tester.pumpAndSettle();
    driver.emit(12000);
    await tester.pump();
    final rect = tester.getRect(find.byType(Slider).first);
    await tester.tapAt(Offset(rect.left + rect.width * .7, rect.center.dy));
    await tester.pump();
    expect(
      tester.widget<Slider>(find.byType(Slider).first).value,
      greaterThan(50000),
    );
    await tester.pump(const Duration(seconds: 3));
    expect(tester.widget<Slider>(find.byType(Slider).first).value, 12000);
    driver.pending.removeAt(0).complete();
    await tester.pumpAndSettle();
    final before = driver.targets.length;
    final drag = await tester.startGesture(rect.center);
    await drag.moveBy(const Offset(20, 0));
    await tester.pump();
    await tester.tap(
      find
          .descendant(
            of: find.byType(AudioPlaybackButton),
            matching: find.byType(IconButton),
          )
          .last,
    );
    await tester.pump();
    await drag.up();
    await tester.pumpAndSettle();
    expect(driver.targets.length, before);
    expect(tester.widget<Slider>(find.byType(Slider).first).value, 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('减少动态加载仍在按钮内但没有无限动画', (tester) async {
    final driver = _SeekDriver()..wait = true;
    final controller = AudioPlaybackController(() => driver);
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(controller, reduce: true));
    await tester.tap(
      find.descendant(
        of: find.byType(AudioPlaybackButton),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      .7,
    );
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(const SizedBox());
    driver.waiting.single.complete();
    await tester.pump();
  });
}

Widget _app(
  AudioPlaybackController controller, {
  bool reduce = false,
  bool scroll = false,
  bool second = false,
}) => ProviderScope(
  overrides: [audioPlaybackProvider.overrideWithValue(controller)],
  child: MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(disableAnimations: reduce),
        child: SingleChildScrollView(
          child: Column(
            children: [
              WenyouAudioPlayer(audio: _audio, label: '雨夜与片段'),
              if (second) WenyouAudioPlayer(audio: _audio, label: '片段'),
              if (scroll) const SizedBox(height: 1800),
            ],
          ),
        ),
      ),
    ),
  ),
);

class _SeekDriver extends Driver {
  bool delaySeek = false;
  final targets = <Duration>[];
  final pending = <Completer<void>>[];
  void emit(int milliseconds) => state.add(
    AudioPlaybackStatus(
      playing: true,
      position: Duration(milliseconds: milliseconds),
    ),
  );
  @override
  Future<void> seek(Duration position) async {
    targets.add(position);
    if (delaySeek) {
      final completer = Completer<void>();
      pending.add(completer);
      await completer.future;
    }
    emit(position.inMilliseconds);
  }
}
