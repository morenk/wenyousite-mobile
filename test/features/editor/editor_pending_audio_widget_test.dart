import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/audio_playback.dart';
import 'package:wenyousite_mobile/core/markdown/local_audio_marker.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_submission_guard.dart';
import 'package:wenyousite_mobile/core/media/audio_upload_policy.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/core/widgets/audio_playback_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_audio_player.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_audio_embed_builder.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_pending_audio_widget.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_pending_audios.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_pending_audio_document.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'package:wenyousite_mobile/features/media/data/audio_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/audio_upload_models.dart';

import '../../support/audio_test_fonts.dart';

final _audio = MediaAudio.parse({
  'sourceUrl': 'https://storage.example/audio.mp3',
  'mediaId': 'ready',
  'contentType': 'audio/mpeg',
  'size': 16000,
  'durationMs': 123000,
})!;
const _input = AudioUploadInput(
  filename: '雨夜与片段.wav',
  path: '/private/audio.wav',
  size: 16000,
  contentType: 'audio/wav',
);
final _policy = AudioUploadPolicy.parse({
  'version': 1,
  'maxBytes': 31457280,
  'maxDurationMs': 600000,
  'contentTypes': ['audio/wav'],
  'outputContentType': 'audio/mpeg',
})!;
String _pending(String id) =>
    '[雨夜与片段：远处的雨声与沿街的脚步.wav]($localAudioMarkerPrefix$id)';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final width in [320, 360]) {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('上传卡片与完成播放器 $width $dark $scale', (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(
            width.toDouble(),
            scale == 1 ? 650 : 900,
          );
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          final harness = _Harness();
          await tester.pumpWidget(harness.app(dark: dark, scale: scale));
          await tester.pumpAndSettle();
          expect(find.byType(EditorPendingAudioCard), findsNWidgets(3));
          expect(find.byType(WenyouAudioPlayer), findsOneWidget);
          expect(find.byTooltip('保存到本地'), findsNothing);
          expect(find.byType(Slider), findsOneWidget);
          final values = tester
              .widgetList<LinearProgressIndicator>(
                find.byType(LinearProgressIndicator),
              )
              .map((widget) => widget.value)
              .toList();
          expect(values, [.45, 1, .45]);
          final buttons = tester
              .widgetList<AudioPlaybackButton>(find.byType(AudioPlaybackButton))
              .toList();
          expect(
            buttons.take(3).every((button) => button.onPressed == null),
            isTrue,
          );
          expect(harness.loads, 0);
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byKey(const Key('pending-frame')),
            matchesGoldenFile(
              'goldens/audio_pending_${width}_${dark ? 'dark' : 'light'}${scale == 2 ? '_200' : ''}.png',
            ),
          );
          await harness.close(tester);
        });
      }
    }
  }

  testWidgets('卡片取消可撤销，显式重试原位完成，选区/原名/发布拦截不丢失', (tester) async {
    final harness = _Harness();
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();
    final editor = harness.editor;
    await editor.flush();
    expect(
      () => MarkdownSubmissionGuard.validate(editor.localMarkdown),
      throwsException,
    );
    editor.controller.document.history.clear();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('pending-audio-processing')),
        matching: find.byTooltip('取消上传'),
      ),
    );
    await tester.pumpAndSettle();
    expect(editor.localAudioIds, {'uploading', 'failed'});
    editor.controller.undo();
    await tester.pumpAndSettle();
    expect(editor.localAudioIds, {'uploading', 'processing', 'failed'});
    expect(harness.audios.items['processing']!.awaitingContinue, isTrue);
    expect(harness.repository.calls, 0);
    final before = editor.controller.selection;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(harness.repository.calls, 1);
    expect(editor.controller.selection, before);
    expect(find.byType(EditorPendingAudioCard), findsNWidgets(3));
    harness.repository.result.complete(_audio);
    await tester.pumpAndSettle();
    expect(find.byType(EditorPendingAudioCard), findsNWidgets(2));
    expect(find.byType(WenyouAudioPlayer), findsNWidgets(2));
    expect(editor.controller.selection, before);
    expect(editor.localMarkdown, isNot(contains('wenyou_audio_view')));
    expect(editor.localMarkdown, contains(_audio.sourceUrl));
    expect(harness.loads, 0);
    await harness.close(tester);
  });

  testWidgets('未知本机标记仍是可移除卡片，未完成发布继续拦截', (tester) async {
    final harness = _Harness(missing: true);
    await tester.pumpWidget(harness.app());
    await tester.pumpAndSettle();
    expect(find.byType(EditorPendingAudioCard), findsOneWidget);
    expect(find.byType(WenyouAudioPlayer), findsNothing);
    expect(find.byTooltip('保存到本地'), findsNothing);
    await harness.editor.flush();
    expect(
      () => MarkdownSubmissionGuard.validate(harness.editor.localMarkdown),
      throwsException,
    );
    await tester.tap(find.byTooltip('移除音频'));
    await tester.pumpAndSettle();
    expect(harness.editor.localAudioIds, isEmpty);
    expect(find.byType(EditorPendingAudioCard), findsNothing);
    expect(harness.loads, 0);
    await harness.close(tester);
  });
}

class _Harness {
  _Harness({this.missing = false}) {
    editor = RichEditorSession(
      initialMarkdown: missing
          ? _pending('missing')
          : '雨停之前，我们在屋檐下等了一会儿。\n\n${_pending('uploading')}\n\n${_pending('processing')}\n\n${_pending('failed')}\n\n[雨夜与片段.wav](${_audio.sourceUrl})\n\n故事还在继续。',
      initialMediaAudios: {_audio.sourceUrl: _audio},
      onMarkdownChanged: (_) {},
    );
    playback = AudioPlaybackController(() {
      loads++;
      throw StateError('不得请求音源');
    });
  }
  final bool missing;
  late final RichEditorSession editor;
  late final AudioPlaybackController playback;
  late EditorPendingAudios audios;
  final repository = _Repository();
  bool initialized = false;
  int loads = 0;
  Widget app({bool dark = false, double scale = 1}) => ProviderScope(
    overrides: [
      audioPlaybackProvider.overrideWithValue(playback),
      audioUploadRepositoryProvider.overrideWithValue(repository),
      appCapabilitiesProvider.overrideWithValue(
        AppCapabilities(audioUpload: _policy),
      ),
    ],
    child: Consumer(
      builder: (context, ref, _) {
        if (!initialized) {
          initialized = true;
          audios = EditorPendingAudios(
            ref: ref,
            editor: editor,
            accountId: 'fixture',
            target: 'post:fixture',
            isCurrent: () => true,
            save: () async => true,
          );
          if (!missing) {
            for (final id in ['uploading', 'processing', 'failed']) {
              audios.items[id] = EditorPendingAudio(id, _input)
                ..active = id != 'failed'
                ..progress = id == 'processing'
                    ? const AudioUploadProgress(AudioUploadStage.processing)
                    : const AudioUploadProgress(
                        AudioUploadStage.uploading,
                        sent: 45,
                        total: 100,
                      )
                ..failure = id == 'failed' ? '音频上传失败，请重试。' : null;
            }
          }
        }
        return MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          localizationsDelegates:
              FlutterQuillLocalizations.localizationsDelegates,
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: RepaintBoundary(
                key: const Key('pending-frame'),
                child: ListenableBuilder(
                  listenable: editor,
                  builder: (context, _) => ColoredBox(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: QuillEditor(
                      controller: editor.controller,
                      focusNode: editor.focusNode,
                      scrollController: editor.scrollController,
                      config: QuillEditorConfig(
                        onTapUp: (details, _) => editorAudioOwnsPointer(
                          context,
                          details.globalPosition,
                        ),
                        scrollable: true,
                        expands: true,
                        showCursor: false,
                        padding: const EdgeInsets.all(16),
                        customStyles: wenyouEditorTextStyles(context),
                        embedBuilders: [
                          EditorAudioEmbedBuilder(
                            editor.mediaAudios,
                            editor.focusNode,
                            audios,
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
      },
    ),
  );
  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    audios.dispose();
    editor.dispose();
    playback.dispose();
  }
}

class _Repository implements AudioUploadRepository {
  int calls = 0;
  final result = Completer<MediaAudio>();
  @override
  Future<MediaAudio> upload(
    AudioUploadInput? input,
    AudioUploadPolicy? policy, {
    required CancelToken cancelToken,
    required Future<void> Function(PendingAudioUpload) savePending,
    PendingAudioUpload? pending,
    void Function(AudioUploadProgress)? onProgress,
  }) {
    calls++;
    return result.future;
  }
}
