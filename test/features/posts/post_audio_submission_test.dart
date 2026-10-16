import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/local_audio_marker.dart';
import 'package:wenyousite_mobile/core/media/audio_upload_policy.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_audio_player.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_pending_audio_document.dart';
import 'package:wenyousite_mobile/features/media/data/audio_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/audio_upload_models.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_draft.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet_layout.dart';

import 'post_replies_page_test_support.dart';

final _audio = MediaAudio.parse({
  'sourceUrl': 'https://storage.example/song.mp3',
  'mediaId': 'song',
  'contentType': 'audio/mpeg',
  'size': 100,
  'durationMs': 60000,
})!;
const _target = (
  kind: PostComposerKind.createFloor,
  threadId: 'thread',
  subthreadId: 'subthread',
  postId: null,
  parentPostId: null,
  replyToPostId: null,
  version: null,
  initialContent: '',
  label: '发表楼层',
);

void main() {
  for (final prefix in ['', '正文\n\n']) {
    testWidgets('真实发表页：${prefix.isEmpty ? "仅音频" : "正文与音频"}上传完成立即提交', (
      tester,
    ) async {
      final repository = PostRepliesPageTestFakePostRepository();
      final container = await postRepliesPageTestPostContainer(
        repository,
        userId: 'author-1',
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ProviderScope(
            overrides: [
              audioUploadRepositoryProvider.overrideWithValue(_Upload()),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                body: PostComposerSheet(
                  target: _target,
                  baseline: const PostComposerBaseline(
                    content: '',
                    postId: null,
                    version: null,
                  ),
                  onClose: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await postRepliesPageTestPumpUi(tester);
      final region = tester.widget<PostComposerEditorRegion>(
        find.byType(PostComposerEditorRegion),
      );
      final editor = region.editorSession;
      if (prefix.isNotEmpty) editor.applyExternalMarkdown(prefix);
      editor.insertLocalAudio('selected', filename: '雨夜 [原声].wav');
      await editor.flush();
      region.pendingImages!.audios.restore([
        {
          'id': 'selected',
          'input': {
            'filename': '雨夜 [原声].wav',
            'path': '/private/a.wav',
            'size': 100,
            'contentType': 'audio/wav',
          },
          'pending': {'mediaId': 'song', 'stage': 'processing'},
        },
      ]);
      await region.pendingImages!.audios.retry('selected');
      await tester.pump();
      expect(editor.codecFailure, isNull);
      expect(editor.localAudioIds, isEmpty);
      await tester.tap(find.byTooltip('发表楼层'));
      await postRepliesPageTestPumpUi(tester);
      expect(repository.createInputs, hasLength(1));
      expect(repository.createInputs.single.content, contains('雨夜'));
      expect(
        repository.createInputs.single.content,
        contains(_audio.sourceUrl),
      );
      expect(
        repository.createInputs.single.content,
        isNot(contains('wenyou_audio_view')),
      );
      expect(tester.takeException(), isNull);
      final submitted = repository.createInputs.single.content;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: WenyouMarkdown(
                data: submitted,
                mediaAudios: {_audio.sourceUrl: _audio},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WenyouAudioPlayer), findsOneWidget, reason: submitted);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }
  testWidgets('恢复可信音频文档后发布读取当前canonical正文', (tester) async {
    final repository = PostRepliesPageTestFakePostRepository();
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'author-1',
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: PostComposerSheet(
              target: _target,
              baseline: const PostComposerBaseline(
                content: '',
                postId: null,
                version: null,
              ),
              onClose: (_) {},
            ),
          ),
        ),
      ),
    );
    await postRepliesPageTestPumpUi(tester);
    final editor = tester
        .widget<PostComposerEditorRegion>(find.byType(PostComposerEditorRegion))
        .editorSession;
    editor.applyExternalMarkdown(
      '[原文件名.mp3](${_audio.sourceUrl})',
      mediaAudios: {_audio.sourceUrl: _audio},
    );
    expect(
      container.read(postComposerControllerProvider(_target)).content,
      isEmpty,
    );
    await tester.pump();
    await tester.tap(find.byTooltip('发表楼层'));
    await postRepliesPageTestPumpUi(tester);
    expect(repository.createInputs, hasLength(1));
    expect(
      repository.createInputs.single.content,
      '[原文件名.mp3](${_audio.sourceUrl})',
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
  test('空正文和未完成/失效本机音频继续拒绝发送', () async {
    for (final content in ['', '[音频](${localAudioMarkerPrefix}missing)']) {
      final repository = PostRepliesPageTestFakePostRepository();
      final controller = PostComposerController(repository, _target);
      controller.updateContent(content);
      expect(await controller.submit(), isNull);
      expect(repository.createInputs, isEmpty);
      controller.dispose();
    }
  });
}

class _Upload implements AudioUploadRepository {
  @override
  Future<MediaAudio> upload(
    AudioUploadInput? input,
    AudioUploadPolicy? policy, {
    required CancelToken cancelToken,
    required Future<void> Function(PendingAudioUpload) savePending,
    PendingAudioUpload? pending,
    void Function(AudioUploadProgress)? onProgress,
  }) async => _audio;
}
