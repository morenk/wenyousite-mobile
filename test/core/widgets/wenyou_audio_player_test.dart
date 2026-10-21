import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/audio_download.dart';
import 'package:wenyousite_mobile/core/application/audio_playback.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/core/widgets/audio_playback_button.dart';
import 'package:wenyousite_mobile/core/widgets/audio_save_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_audio_player.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

import '../../support/audio_download.dart';
import '../../support/audio_driver.dart';
import '../../support/audio_test_fonts.dart';

final _audio = MediaAudio.parse({
  'sourceUrl': 'https://storage.example/audio.mp3',
  'mediaId': 'audio',
  'contentType': 'audio/mpeg',
  'size': 16000,
  'durationMs': 123000,
})!;
const _label = '雨夜小记：远处的雨声与沿街的脚步';
String get _body =>
    '雨停之前，我们在屋檐下等了一会儿。\n\n[**雨夜**与*片段*](${_audio.sourceUrl})\n\n这是同行人留下的一小段声音。\n\n[$_label](${_audio.sourceUrl})\n\n故事还在继续。';

void main() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('同正文音频投影迟到会重建解析缓存，等价投影不打断播放', (tester) async {
    final driver = Driver();
    final controller = AudioPlaybackController(() => driver);
    addTearDown(controller.dispose);
    final source =
        r'[原声\.现场回忆\-\-\+1段\#ABC123\.mp3]'
        '(${_audio.sourceUrl})\n<br />';
    await tester.pumpWidget(_app(controller, body: source, audios: const {}));
    await tester.pumpAndSettle();
    expect(find.byType(WenyouAudioPlayer), findsNothing);
    await tester.pumpWidget(_app(controller, body: source));
    await tester.pumpAndSettle();
    expect(find.byType(WenyouAudioPlayer), findsOneWidget);
    expect(
      find.byKey(const ValueKey('wenyou-markdown-empty-paragraph-0')),
      findsOneWidget,
    );
    expect(driver.loads, isEmpty);
    await tester.tap(
      find.descendant(
        of: find.byType(AudioPlaybackButton),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();
    final playerState = tester.state(find.byType(WenyouAudioPlayer));
    await tester.pumpWidget(
      _app(
        controller,
        body: source,
        audios: {_audio.sourceUrl: MediaAudio.parse(_audio.toJson())!},
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.state(find.byType(WenyouAudioPlayer)), same(playerState));
    expect(driver.loads, hasLength(1));
    expect(driver.stops, 0);
    unawaited(tester.binding.reassembleApplication());
    await tester.pumpAndSettle();
    expect(find.byType(WenyouAudioPlayer), findsOneWidget);
    await tester.pumpWidget(_app(controller, body: source, audios: const {}));
    await tester.pumpAndSettle();
    expect(find.byType(WenyouAudioPlayer), findsNothing);
    expect(driver.loads, hasLength(1));
    expect(driver.stops, greaterThanOrEqualTo(1));
  });
  testWidgets('独占音频后接协议空段保留播放器与空行高度', (tester) async {
    final controller = AudioPlaybackController(() => throw StateError('不得加载'));
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(controller, body: '[原文件名.mp3](${_audio.sourceUrl})\n<br />'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WenyouAudioPlayer), findsOneWidget);
    final blank = find.byKey(
      const ValueKey('wenyou-markdown-empty-paragraph-0'),
    );
    expect(blank, findsOneWidget);
    expect(tester.getSize(blank).height, closeTo(30.6, .01));
  });
  testWidgets('标签样式不传给播放和保存控件，混排和无投影保持普通正文', (tester) async {
    final controller = AudioPlaybackController(() => throw StateError('不得加载'));
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(controller, body: '[原名](${_audio.sourceUrl})'),
    );
    await tester.pumpAndSettle();
    final styles = {
      for (final type in [AudioPlaybackButton, AudioSaveButton])
        type: DefaultTextStyle.of(tester.element(find.byType(type))).style,
    };
    final icons = {
      for (final type in [AudioPlaybackButton, AudioSaveButton])
        type: IconTheme.of(tester.element(find.byType(type))),
    };
    for (final label in [
      '**[原名](${_audio.sourceUrl})**',
      '*[**原名**](${_audio.sourceUrl})*',
      '~~[***原名***](${_audio.sourceUrl})~~',
    ]) {
      await tester.pumpWidget(_app(controller, body: label));
      await tester.pumpAndSettle();
      expect(find.byType(WenyouAudioPlayer), findsOneWidget);
      expect(find.byTooltip('保存到本地'), findsOneWidget);
      for (final type in [AudioPlaybackButton, AudioSaveButton]) {
        final context = tester.element(find.byType(type));
        expect(DefaultTextStyle.of(context).style, styles[type]);
        expect(IconTheme.of(context), icons[type]);
      }
    }
    for (final source in [
      '前文 **[原名](${_audio.sourceUrl})**',
      '**[原名](${_audio.sourceUrl})** 后文',
      '- **[原名](${_audio.sourceUrl})**',
      '> **[原名](${_audio.sourceUrl})**',
      '`[原名](${_audio.sourceUrl})`',
    ]) {
      await tester.pumpWidget(_app(controller, body: source));
      await tester.pumpAndSettle();
      expect(find.byType(WenyouAudioPlayer), findsNothing, reason: source);
    }
  });
  testWidgets('音频前后多个独占空段保留高度和marks，inline换行不拆混排', (tester) async {
    final controller = AudioPlaybackController(() => throw StateError('不得加载'));
    addTearDown(controller.dispose);
    final link = '**[*原名*](${_audio.sourceUrl})**';
    for (final body in [
      '<br />\n$link\n<br />\n<br />',
      '  <br> \n$link\n<br/>\n <br /> ',
    ]) {
      await tester.pumpWidget(_app(controller, body: body));
      await tester.pumpAndSettle();
      expect(find.byType(WenyouAudioPlayer), findsOneWidget);
      final player = tester.widget<WenyouAudioPlayer>(
        find.byType(WenyouAudioPlayer),
      );
      expect(player.labelRuns.single.marks, containsAll(['strong', 'em']));
      for (var i = 0; i < 3; i++) {
        final blank = find.byKey(
          ValueKey('wenyou-markdown-empty-paragraph-$i'),
        );
        expect(tester.getSize(blank).height, closeTo(30.6, .01));
      }
    }
    await tester.pumpWidget(
      _app(controller, body: '前文\n<br />\n$link\n<br />\n后文'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WenyouAudioPlayer), findsOneWidget);
    expect(find.textContaining('前文', findRichText: true), findsOneWidget);
    expect(find.textContaining('后文', findRichText: true), findsOneWidget);
    for (final body in [
      '$link\n后文\n<br />',
      '前文\n$link\n<br />',
      '$link<br />',
      '$link  \n后文',
      '$link\\\n后文',
      '- $link\n<br />',
      '> $link\n> <br />',
    ]) {
      await tester.pumpWidget(_app(controller, body: body));
      await tester.pumpAndSettle();
      expect(find.byType(WenyouAudioPlayer), findsNothing, reason: body);
    }
  });
  testWidgets('独立粗体文件名链接按可信投影显示播放器', (tester) async {
    final controller = AudioPlaybackController(() => throw StateError('不得加载'));
    addTearDown(controller.dispose);
    const name = '原声.现场回忆--+1段#ABC123.mp3';
    await tester.pumpWidget(
      _app(controller, body: '**[$name](${_audio.sourceUrl})**'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WenyouAudioPlayer), findsOneWidget);
    final player = tester.widget<WenyouAudioPlayer>(
      find.byType(WenyouAudioPlayer),
    );
    expect(player.label, name);
    expect(
      player.labelRuns.every((run) => run.marks.contains('strong')),
      isTrue,
    );
  });
  testWidgets('音频投影不改变引用或列表内部空行与段落几何', (tester) async {
    final controller = AudioPlaybackController(() => throw StateError('不得加载'));
    addTearDown(controller.dispose);
    final link = '[原名](${_audio.sourceUrl})';
    for (final source in [
      '> $link\n> <br />\n> <br />\n> 后文',
      '- $link\n  <br />\n  <br />\n  后文',
      '> <br />\n> $link\n> <br />',
    ]) {
      await tester.pumpWidget(_app(controller, body: source, audios: const {}));
      await tester.pumpAndSettle();
      final height = tester.getSize(find.byType(WenyouMarkdown)).height;
      final textRects = tester
          .widgetList<RichText>(find.byType(RichText))
          .where((widget) => widget.text.toPlainText().contains('原名'))
          .map((widget) => tester.getRect(find.byWidget(widget)))
          .toList();
      await tester.pumpWidget(_app(controller, body: source));
      await tester.pumpAndSettle();
      expect(find.byType(WenyouAudioPlayer), findsNothing);
      expect(tester.getSize(find.byType(WenyouMarkdown)).height, height);
      final withProjection = tester
          .widgetList<RichText>(find.byType(RichText))
          .where((widget) => widget.text.toPlainText().contains('原名'))
          .map((widget) => tester.getRect(find.byWidget(widget)))
          .toList();
      expect(withProjection, textRects);
    }
  });
  for (final dark in [false, true]) {
    for (final width in [320, 360]) {
      testWidgets('$width ${dark ? 'dark' : 'light'} 正文播放器静态候选不加载音源', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width.toDouble(), 640);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        var creations = 0;
        final controller = AudioPlaybackController(() {
          creations++;
          return Driver();
        });
        addTearDown(controller.dispose);
        await tester.pumpWidget(_app(controller, dark: dark));
        await tester.pumpAndSettle();
        expect(find.byType(WenyouAudioPlayer), findsNWidgets(2));
        expect(creations, 0);
        final player = find.byType(WenyouAudioPlayer).first;
        for (final type in [IconButton, Slider]) {
          final control = find.descendant(
            of: player,
            matching: find.byType(type),
          );
          for (final match in control.evaluate()) {
            expect(
              tester.getSize(find.byWidget(match.widget)).height,
              greaterThanOrEqualTo(48),
            );
          }
        }
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            'goldens/audio_body_${width}_${dark ? 'dark' : 'light'}.png',
          ),
        );
      });
    }
  }
  testWidgets('点击才加载，互斥播放、后台停止、回前台不续播与离页释放', (tester) async {
    final semantics = tester.ensureSemantics();
    final driver = Driver();
    final controller = AudioPlaybackController(() => driver);
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();
    expect(driver.loads, isEmpty);
    final buttons = find.descendant(
      of: find.byType(WenyouAudioPlayer),
      matching: find.descendant(
        of: find.byType(AudioPlaybackButton),
        matching: find.byType(IconButton),
      ),
    );
    await tester.tap(buttons.first);
    await tester.pump();
    expect(driver.plays, 1);
    final track = tester.getRect(find.byType(Slider).first);
    for (final dy in [-20.0, 20.0]) {
      final before = driver.seeks;
      final point = Offset(
        track.left + track.width * 0.4,
        track.center.dy + dy,
      );
      await tester.tapAt(point);
      await tester.pump();
      expect(driver.seeks, greaterThan(before));
      final afterTap = driver.seeks;
      await tester.dragFrom(point, const Offset(30, 0));
      await tester.pump();
      expect(driver.seeks, greaterThan(afterTap));
    }
    await tester.tap(buttons.last);
    await tester.pump();
    expect(driver.plays, 2);
    expect(find.bySemanticsLabel('雨夜与片段，播放'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(driver.stops, 1);
    expect(controller.status.playing, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(driver.plays, 2);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(driver.stops, 2);
    semantics.dispose();
  });
  testWidgets('普通链接和无投影正文不挂播放器，二倍字号不溢出', (tester) async {
    final controller = AudioPlaybackController(() => throw StateError('不得加载'));
    addTearDown(controller.dispose);
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(_app(controller, scale: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      _app(controller, body: '[音频](${_audio.sourceUrl})', audios: const {}),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WenyouAudioPlayer), findsNothing);
    await tester.pumpWidget(
      _app(controller, body: '内联 [音频](${_audio.sourceUrl}) 与正文'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WenyouAudioPlayer), findsNothing);
  });
}

Widget _app(
  AudioPlaybackController controller, {
  bool dark = false,
  double scale = 1,
  String? body,
  Map<String, MediaAudio>? audios,
}) => ProviderScope(
  overrides: [
    audioDownloadProvider.overrideWithValue(FakeAudioDownload()),
    audioPlaybackProvider.overrideWithValue(controller),
  ],
  child: MaterialApp(
    theme: dark ? AppTheme.dark : AppTheme.light,
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: WenyouMarkdown(
            data: body ?? _body,
            mediaAudios: audios ?? {_audio.sourceUrl: _audio},
          ),
        ),
      ),
    ),
  ),
);
