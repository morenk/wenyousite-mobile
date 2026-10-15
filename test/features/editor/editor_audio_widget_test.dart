import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/core/widgets/audio_playback_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_audio_player.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_audio_embed_builder.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_embed_builders.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'package:wenyousite_mobile/features/media/application/audio_playback.dart';
import 'package:wenyousite_mobile/features/media/data/device_audio_download.dart';
import 'package:wenyousite_mobile/features/media/data/just_audio_playback_driver.dart';

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
final _body =
    '雨停之前，我们在屋檐下等了一会儿。\n\n'
    '[**雨夜**与*片段*：远处的雨声与沿街的脚步](${_audio.sourceUrl})\n\n故事还在继续。';

void main() {
  setUpAll(loadAudioTestFonts);
  testWidgets('编辑态保存按钮不改变选区、正文或触发播放', (tester) async {
    final editor = RichEditorSession(
      initialMarkdown: '[原文件名.wav](${_audio.sourceUrl})',
      initialMediaAudios: {_audio.sourceUrl: _audio},
      onMarkdownChanged: (_) {},
    );
    addTearDown(editor.dispose);
    final driver = Driver();
    final playback = AudioPlaybackController(() => driver);
    addTearDown(playback.dispose);
    final download = FakeAudioDownload();
    await tester.pumpWidget(_app(editor, playback, download: download));
    await tester.pumpAndSettle();
    final before = editor.controller.selection;
    final delta = editor.controller.document.toDelta().toJson();
    await tester.tap(find.byTooltip('保存到本地'));
    await tester.pump();
    expect(download.labels, ['原文件名.wav']);
    expect(editor.controller.selection, before);
    expect(editor.controller.document.toDelta().toJson(), delta);
    expect(driver.loads, isEmpty);
    download.operations.single.completion.complete(false);
    await tester.pumpWidget(const SizedBox());
  });
  for (final scale in [1.0, 2.0]) {
    for (final dark in [false, true]) {
      for (final width in [320, 360]) {
        testWidgets('编辑器播放器 $width $dark $scale', (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(
            width.toDouble(),
            scale == 1 ? 440 : 720,
          );
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          final driver = Driver();
          final playback = AudioPlaybackController(() => driver);
          final editor = RichEditorSession(
            initialMarkdown: _body,
            initialMediaAudios: {_audio.sourceUrl: _audio},
            onMarkdownChanged: (_) {},
          );
          addTearDown(editor.dispose);
          addTearDown(playback.dispose);
          await tester.pumpWidget(
            _app(editor, playback, dark: dark, scale: scale),
          );
          await tester.pumpAndSettle();
          expect(find.byType(WenyouAudioPlayer), findsOneWidget);
          expect(driver.loads, isEmpty);
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byKey(const Key('editor-frame')),
            matchesGoldenFile(
              'goldens/audio_editor_${width}_${dark ? 'dark' : 'light'}${scale == 2 ? '_200' : ''}.png',
            ),
          );
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }

  testWidgets('真实编辑器按钮滑块不改选区，选块删除undo redo释放播放', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 440);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final driver = Driver();
    final playback = AudioPlaybackController(() => driver);
    final editor = RichEditorSession(
      initialMarkdown: _body,
      initialMediaAudios: {_audio.sourceUrl: _audio},
      onMarkdownChanged: (_) {},
    );
    addTearDown(editor.dispose);
    addTearDown(playback.dispose);
    await tester.pumpWidget(_app(editor, playback));
    await tester.pumpAndSettle();
    final selection = editor.controller.selection;
    await tester.tap(
      find.descendant(
        of: find.byType(AudioPlaybackButton),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(driver.loads, [_audio.sourceUrl]);
    expect(editor.controller.selection, selection);
    final slider = tester.getRect(find.byType(Slider));
    final drag = await tester.startGesture(slider.center);
    await drag.moveBy(const Offset(25, 0));
    await tester.pump(const Duration(milliseconds: 700));
    await drag.moveTo(Offset(slider.right + 80, slider.bottom + 80));
    await tester.pump();
    expect(editor.controller.selection, selection);
    await drag.up();
    await tester.pumpAndSettle();
    expect(driver.seeks, 1);
    expect(editor.controller.selection, selection);
    await tester.tap(
      find.descendant(
        of: find.byType(AudioPlaybackButton),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(
      find.descendant(
        of: find.byType(AudioPlaybackButton),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(editor.controller.selection, selection);
    expect(tester.takeException(), isNull);
    final title = find.descendant(
      of: find.byType(WenyouAudioPlayer),
      matching: find.byWidgetPredicate(
        (widget) => widget is Text && widget.textSpan != null,
      ),
    );
    await tester.tap(title);
    await tester.pump();
    final selected = editor.controller.selection;
    expect(selected.extentOffset - selected.baseOffset, 1);
    expect(editor.focusNode.hasFocus, isTrue);
    final selectedBorders = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .where(
          (box) =>
              box.position == DecorationPosition.foreground &&
              box.decoration is BoxDecoration &&
              (box.decoration as BoxDecoration).border != null,
        );
    expect(selectedBorders, isNotEmpty);
    await expectLater(
      find.byKey(const Key('editor-frame')),
      matchesGoldenFile('goldens/audio_editor_selected_360_light.png'),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pumpAndSettle();
    expect(find.byType(WenyouAudioPlayer), findsNothing);
    expect(driver.stops, greaterThanOrEqualTo(1));
    editor.controller.undo();
    await tester.pumpAndSettle();
    expect(find.byType(WenyouAudioPlayer), findsOneWidget);
    expect(driver.loads, hasLength(1));
    editor.controller.redo();
    await tester.pumpAndSettle();
    expect(find.byType(WenyouAudioPlayer), findsNothing);
    expect(await editor.flush(), isTrue);
    await tester.tapAt(const Offset(80, 30));
    await tester.pump();
    expect(editor.controller.selection.isCollapsed, isTrue);
    expect(editor.controller.selection.start, lessThan(selected.start));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('滚动后的音频命中及取消指针不阻止正文选择', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 440);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final driver = Driver();
    final playback = AudioPlaybackController(() => driver);
    final editor = RichEditorSession(
      initialMarkdown: '${List.filled(12, '故事还在继续。').join('\n\n')}\n\n$_body',
      initialMediaAudios: {_audio.sourceUrl: _audio},
      onMarkdownChanged: (_) {},
    );
    addTearDown(editor.dispose);
    addTearDown(playback.dispose);
    await tester.pumpWidget(_app(editor, playback));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(WenyouAudioPlayer));
    await tester.pumpAndSettle();
    final before = editor.controller.selection;
    await tester.tap(
      find.descendant(
        of: find.byType(AudioPlaybackButton),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(editor.controller.selection, before);
    final pointer = await tester.startGesture(
      tester.getCenter(find.byType(Slider)),
    );
    await tester.pump(const Duration(milliseconds: 700));
    await pointer.moveBy(const Offset(60, 80));
    await tester.pump();
    expect(editor.controller.selection, before);
    await pointer.cancel();
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(25, 30));
    await tester.pump();
    expect(editor.controller.selection, isNot(before));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('无可信投影不挂播放器，切草稿释放已播放卡片', (tester) async {
    final driver = Driver();
    final playback = AudioPlaybackController(() => driver);
    final editor = RichEditorSession(
      initialMarkdown: _body,
      onMarkdownChanged: (_) {},
    );
    addTearDown(editor.dispose);
    addTearDown(playback.dispose);
    await tester.pumpWidget(_app(editor, playback));
    await tester.pumpAndSettle();
    expect(find.byType(WenyouAudioPlayer), findsNothing);
    expect(driver.loads, isEmpty);
    editor.applyExternalMarkdown(
      _body,
      mediaAudios: {_audio.sourceUrl: _audio},
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AudioPlaybackButton),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();
    editor.applyExternalMarkdown('故事还在继续。', mediaAudios: {});
    await tester.pumpAndSettle();
    expect(find.byType(WenyouAudioPlayer), findsNothing);
    expect(driver.stops, greaterThanOrEqualTo(1));
    await tester.pumpWidget(const SizedBox());
  });
}

Widget _app(
  RichEditorSession editor,
  AudioPlaybackController playback, {
  bool dark = false,
  double scale = 1,
  FakeAudioDownload? download,
}) => ProviderScope(
  overrides: [
    audioPlaybackProvider.overrideWithValue(playback),
    if (download != null) audioDownloadProvider.overrideWithValue(download),
  ],
  child: MaterialApp(
    theme: dark ? AppTheme.dark : AppTheme.light,
    locale: const Locale('zh', 'CN'),
    localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: RepaintBoundary(
          key: const Key('editor-frame'),
          child: ListenableBuilder(
            listenable: editor,
            builder: (context, _) => ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: QuillEditor(
                controller: editor.controller,
                focusNode: editor.focusNode,
                scrollController: editor.scrollController,
                config: QuillEditorConfig(
                  onTapUp: (details, _) =>
                      editorAudioOwnsPointer(context, details.globalPosition),
                  onSingleLongTapStart: (details, _) =>
                      editorAudioOwnsPointer(context, details.globalPosition),
                  onSingleLongTapEnd: (details, _) =>
                      editorAudioOwnsPointer(context, details.globalPosition),
                  scrollable: true,
                  expands: true,
                  showCursor: false,
                  padding: const EdgeInsets.all(16),
                  customStyles: wenyouEditorTextStyles(context),
                  embedBuilders: wenyouEditorEmbedBuilders(
                    mediaAudios: editor.mediaAudios,
                    editorFocusNode: editor.focusNode,
                  ),
                  customShortcuts: editor.clipboardShortcuts,
                  customActions: editor.clipboardActions,
                  contextMenuBuilder: editor.buildContextMenu,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);
