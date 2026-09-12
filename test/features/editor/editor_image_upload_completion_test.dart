import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/media/media_display.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/fake_image_crop_processor.dart';
import '../moments/moment_animation_fixture.dart';
import '../posts/post_replies_page_test_support.dart';
import 'thread_compose_page_test_support.dart';

const _sourceUrl = 'https://cdn.example.com/uploaded.gif';
const _displayUrl = 'https://cdn.example.com/uploaded.webp';
const _imageMarkdown = '![图片]($_sourceUrl)';
const _display = MediaDisplay(
  url: _displayUrl,
  width: 320,
  height: 180,
  bytes: 180,
  animated: true,
  frameCount: 2,
  durationMs: 360,
  loopCount: 2,
);
const _uploaded = UploadedEditorImage(
  mediaId: 'gif-upload',
  url: _sourceUrl,
  contentType: 'image/gif',
  animated: true,
  display: _display,
);

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('主题 GIF 安全处理跨帧完成后插入预览并保留发布正文', (tester) async {
    await MomentAnimationFixture.run(tester, (fixture) async {
      final repository = ThreadComposePageTestFakeRepository();
      final controller =
          await threadComposePageTestReadyController(
              ThreadComposePageTestMemorySnapshotStore(),
              repository: repository,
            )
            ..updateTitle('GIF 上传回归主题')
            ..updateCategory('TRPG')
            ..updateBody('上传前正文');
      final gateway = _DelayedUploadGateway();
      await threadComposePageTestPumpPage(
        tester,
        controller,
        picker: _GifPicker(),
        mediaGateway: gateway,
        cropProcessor: const _GifCropProcessor(),
        withThreadRoute: true,
      );
      await tester.tap(find.byKey(const Key('editor-image')));
      await threadComposePageTestConfirmImageCrop(tester);
      final editor = tester
          .widget<QuillEditor>(find.byKey(const Key('compose-body')))
          .controller;
      expect(find.text('图片正在安全处理中…'), findsOneWidget);
      expect(editor.readOnly, isTrue);
      expect(controller.state.body, '上传前正文');
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('compose-publish')))
            .onPressed,
        isNull,
      );

      // 完成结果进入微任务后才泵下一帧，模拟真实网络轮询完成。
      gateway.complete();
      await tester.pump();
      expect(controller.state.body, contains(_imageMarkdown));
      expect(controller.state.body, contains('上传前正文'));
      expect(controller.state.mediaDisplays[_sourceUrl], same(_display));
      expect(editor.readOnly, isFalse);
      expect(find.text('图片正在安全处理中…'), findsNothing);
      await _pumpImage(tester);
      expect(fixture.requests, contains(_displayUrl));
      expect(fixture.requests, isNot(contains(_sourceUrl)));

      await tester.tap(find.byKey(const Key('compose-publish')));
      await tester.pumpAndSettle();
      expect(repository.createPayload?.body, contains(_imageMarkdown));
      expect(repository.savedBody, contains(_imageMarkdown));
      expect(tester.takeException(), isNull);
    }, resources: _resources());
  });

  for (final kind in PostComposerKind.values) {
    testWidgets('${kind.name} GIF 安全处理跨帧完成后预览、保存和重开保留图片', (tester) async {
      await MomentAnimationFixture.run(tester, (fixture) async {
        final gateway = _DelayedUploadGateway();
        final repository = _RecordingPostRepository(
          isBody: kind == PostComposerKind.upsertBody,
        );
        final container = ProviderContainer(
          overrides: [
            tokenStoreProvider.overrideWithValue(
              PostRepliesPageTestMemoryTokenStore(),
            ),
            sessionRemoteProvider.overrideWithValue(
              PostRepliesPageTestFakeSessionRemote(),
            ),
            stickersEnabledProvider.overrideWithValue(false),
            postRepositoryProvider.overrideWithValue(repository),
            imageCropProcessorPortProvider.overrideWithValue(
              const _GifCropProcessor(),
            ),
            editorImagePickerPortProvider.overrideWithValue(_GifPicker()),
            mediaUploadGatewayPortProvider.overrideWithValue(gateway),
          ],
        );
        addTearDown(container.dispose);
        await container
            .read(sessionControllerProvider.notifier)
            .authenticate(postRepliesPageTestTokensFor('root-author'));
        var target = _target(kind);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () =>
                        showPostComposerSheet(context: context, target: target),
                    child: const Text('打开编辑器'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('打开编辑器'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('editor-image')));
        await postRepliesPageTestConfirmImageCrop(tester);
        final editor = tester
            .widget<QuillEditor>(find.byKey(const Key('post-composer-body')))
            .controller;
        expect(editor.readOnly, isTrue);
        expect(find.text('图片正在安全处理中…'), findsOneWidget);
        expect(repository.saved, isEmpty);

        gateway.complete();
        await tester.pump();
        expect(
          MarkdownDeltaCodec.encode(editor.document.toDelta()),
          contains(_imageMarkdown),
        );
        expect(editor.readOnly, isFalse);
        expect(find.text('图片正在安全处理中…'), findsNothing);
        await _pumpImage(tester);
        expect(fixture.requests, contains(_displayUrl));
        expect(fixture.requests, isNot(contains(_sourceUrl)));
        expect(
          find.descendant(
            of: find.byType(QuillEditor),
            matching: find.byWidgetPredicate(
              (widget) => widget is RawImage && widget.image?.width == 320,
            ),
          ),
          findsOneWidget,
        );

        // 图片后继续输入，独立检查可编辑行及正文/图片块归属。
        editor.replaceText(editor.document.length - 1, 0, '\n图片后文字', null);
        await tester.pump();
        await tester.tap(find.byKey(const Key('editor-submit')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('post-composer-body')), findsNothing);
        expect(repository.saved, hasLength(1));
        final markdown = repository.saved.single;
        expect(_imageMarkdown.allMatches(markdown), hasLength(1));
        expect(markdown.split('\n'), contains(_imageMarkdown));
        expect(markdown, contains('上传前正文'));
        expect(markdown, contains('图片后文字'));
        expect(markdown, isNot(contains(_displayUrl)));

        target = _target(
          kind == PostComposerKind.upsertBody
              ? PostComposerKind.upsertBody
              : PostComposerKind.editPost,
        );
        await tester.tap(find.text('打开编辑器'));
        await tester.pumpAndSettle();
        final reopened = tester
            .widget<QuillEditor>(find.byKey(const Key('post-composer-body')))
            .controller;
        expect(
          MarkdownDeltaCodec.encode(reopened.document.toDelta()),
          markdown,
        );
        expect(reopened.document.toPlainText(), contains('图片后文字'));
        expect(reopened.readOnly, isFalse);
        expect(tester.takeException(), isNull);
      }, resources: _resources());
    });
  }
}

PostComposerTarget _target(PostComposerKind kind) => (
  kind: kind,
  threadId: 'thread',
  subthreadId: 'subthread',
  postId:
      kind == PostComposerKind.editPost || kind == PostComposerKind.upsertBody
      ? 'root'
      : null,
  parentPostId: kind == PostComposerKind.createReply ? 'parent' : null,
  replyToPostId: null,
  version: 2,
  initialContent: '上传前正文',
  label: 'GIF 回归正文',
);

class _RecordingPostRepository extends PostRepliesPageTestFakePostRepository {
  _RecordingPostRepository({required this.isBody});
  final bool isBody;
  final saved = <String>[];

  PostItem get latest => PostItem(
    id: 'root',
    threadId: 'thread',
    subthreadId: 'subthread',
    author: postRepliesPageTestRootAuthor,
    content: saved.isEmpty ? '上传前正文' : saved.last,
    mediaDisplays: saved.isEmpty ? const {} : const {_sourceUrl: _display},
    version: 2 + saved.length,
    createdAt: DateTime.utc(2026, 9, 13),
    updatedAt: DateTime.utc(2026, 9, 13),
    isBody: isBody,
    isDeleted: false,
  );
  @override
  Future<PostItem> fetchPost(String postId) async => latest;
  @override
  Future<PostItem> create(PostCreateInput input) async {
    saved.add(input.content);
    return latest;
  }

  @override
  Future<PostItem> update({
    required String postId,
    required String content,
    required int version,
  }) async {
    saved.add(content);
    return latest;
  }

  @override
  Future<PostItem> upsertBody({
    required String subthreadId,
    required String content,
    int? version,
  }) async {
    saved.add(content);
    return latest;
  }
}

class _GifCropProcessor extends FakePassThroughImageCropProcessor {
  const _GifCropProcessor();
  @override
  Future<CropImageSource> prepare(MediaUploadInput input) async =>
      CropImageSource(
        original: input,
        previewBytes: File(
          'test/fixtures/animation-webp-all-surfaces/poster.png',
        ).readAsBytesSync(),
        width: 320,
        height: 180,
        canCrop: false,
      );
}

Map<String, Uint8List> _resources() => {
  _displayUrl: File(
    'test/fixtures/animation-webp-all-surfaces/full.webp',
  ).readAsBytesSync(),
};

Future<void> _pumpImage(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

class _GifPicker implements EditorImagePicker {
  @override
  Future<MediaUploadInput?> pickFromGallery() async => MediaUploadInput(
    filename: 'original.gif',
    declaredContentType: 'image/gif',
    bytes: File(
      'test/fixtures/animation-webp-all-surfaces/original.gif',
    ).readAsBytesSync(),
  );
}

class _DelayedUploadGateway implements MediaUploadGateway {
  final _completer = Completer<UploadedEditorImage>();

  void complete() => _completer.complete(_uploaded);

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    onProgress?.call(
      const MediaUploadProgress(stage: MediaUploadStage.processing),
    );
    return _DelayedUploadOperation(_completer.future);
  }
}

class _DelayedUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  _DelayedUploadOperation(this.result);
  @override
  final Future<UploadedEditorImage> result;
  @override
  void cancel() {}
}
