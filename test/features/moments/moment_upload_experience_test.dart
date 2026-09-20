import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/application/pending_media_file_store_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_repository.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_comment_composer.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_page.dart';

import '../../support/moment_test_draft_store.dart';
import 'moment_pages_content_media_fixtures.dart';
import 'moment_pages_session_wallet_fixtures.dart';

void main() {
  testWidgets('评论进入后台暂停并取消发布意图，回前台恢复图片', (tester) async {
    final gateway = MomentPagesTestControlledBatchUploadGateway();
    final sent = <MomentCommentInput>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'owner',
          ),
          pendingMediaFileStoreProvider.overrideWithValue(
            MomentTestPendingMediaStore(),
          ),
          editorImagePickerPortProvider.overrideWithValue(
            MomentPagesTestFakeImagePicker(),
          ),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: MomentCommentComposer(
              replyTo: null,
              isSending: false,
              onCancelReply: () {},
              onClose: () {},
              onSend: (input) async {
                sent.add(input);
                return true;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-comment-image')));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(const Key('moment-comment-send')));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(find.text('取消发布'), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();
    expect(gateway.operations, hasLength(2));
    gateway.complete(0);
    gateway.complete(1);
    await tester.pumpAndSettle();
    expect(sent, isEmpty);
  });

  testWidgets('恢复评论媒体终态失败后重试重新上传且不会自动发布', (tester) async {
    final gateway = _TerminalFailureGateway();
    final input = (await MomentPagesTestFakeImagePicker().pickFromGallery())!;
    final sent = <MomentCommentInput>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'owner',
          ),
          pendingMediaFileStoreProvider.overrideWithValue(
            MomentTestPendingMediaStore(),
          ),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: MomentCommentComposer(
              replyTo: null,
              isSending: false,
              onCancelReply: () {},
              onClose: () {},
              initialDraft: MomentCommentDraft(
                pendingInput: input,
                pendingUpload: const PendingMediaUpload(
                  mediaId: 'failed-media',
                  purpose: MediaUploadPurpose.momentComment,
                ),
              ),
              onSend: (value) async {
                sent.add(value);
                return true;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(gateway.resumes, 1);
    expect(find.text('未完成'), findsOneWidget);
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(gateway.resumes, 1);
    expect(gateway.uploads, 1);
    expect(find.text('未完成'), findsNothing);
    expect(sent, isEmpty);
  });

  testWidgets('评论重选图片不复用上一选择的在途持久化结果', (tester) async {
    final store = _DelayedFileStore();
    final gateway = MomentPagesTestControlledBatchUploadGateway();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'owner',
          ),
          pendingMediaFileStoreProvider.overrideWithValue(store),
          editorImagePickerPortProvider.overrideWithValue(_NamedPicker()),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: MomentCommentComposer(
              replyTo: null,
              isSending: false,
              onCancelReply: () {},
              onClose: () {},
              onSend: (_) async => true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-comment-image')));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(const Key('moment-comment-image')));
    await tester.pump();
    await tester.pump();
    expect(store.pending, hasLength(2));
    store.pending[0].complete(store.inputs[0]);
    await tester.pump();
    await tester.pump();
    expect(gateway.inputs, isEmpty);
    store.pending[1].complete(store.inputs[1]);
    await tester.pump();
    await tester.pump();
    expect(gateway.inputs.single.filename, 'choice-2.png');
    gateway.complete(0);
    await tester.pumpAndSettle();
  });

  testWidgets('取消回复将当前本机草稿迁移到动态根评论目标', (tester) async {
    final store = MomentTestPendingMediaStore();
    var replying = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'owner',
          ),
          pendingMediaFileStoreProvider.overrideWithValue(store),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, update) => MomentCommentComposer(
                momentId: 'moment-1',
                replyTo: replying ? momentPagesTestRootComment() : null,
                isSending: false,
                onCancelReply: () => update(() => replying = false),
                onClose: () {},
                onSend: (_) async => true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    momentPagesTestReplaceAtomicEditor(
      tester,
      const Key('moment-comment-input'),
      '保留取消回复后的正文',
    );
    await tester.pump(const Duration(milliseconds: 400));
    final chip = tester.widget<InputChip>(find.byType(InputChip));
    chip.onDeleted!();
    await tester.pumpAndSettle();
    expect(
      store.values['owner:moment-comment:moment-1:root']?['content'],
      '保留取消回复后的正文',
    );
    expect(store.values['owner:moment-comment:moment-1:comment-root'], isEmpty);
    // 旧目录可能仍被待完成图片引用，迁移只清旧元数据，不能删除目录。
  });

  testWidgets('动态处理期间可追加图片、选封面且发布等待保持顺序', (tester) async {
    final gateway = MomentPagesTestControlledBatchUploadGateway();
    final repository = MomentPagesTestPageRepository();
    final router = GoRouter(
      initialLocation: '/compose',
      routes: [
        GoRoute(path: '/compose', builder: (_, _) => const MomentComposePage()),
        GoRoute(
          path: '/moments/:momentId',
          name: 'moment-detail',
          builder: (_, _) => const Scaffold(body: Text('已发布')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(repository),
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'owner',
          ),
          momentDraftStoreProvider.overrideWithValue(MemoryMomentDraftStore()),
          pendingMediaFileStoreProvider.overrideWithValue(
            MomentTestPendingMediaStore(),
          ),
          editorImagePickerPortProvider.overrideWithValue(
            MomentPagesTestFakeImagePicker(),
          ),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('moment-compose-title')),
      '等待图片的动态',
    );
    await tester.tap(find.byKey(const Key('moment-compose-add-image')));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(const Key('moment-compose-add-image')));
    await tester.pump();
    await tester.pump();
    expect(gateway.operations, hasLength(2));
    await tester.tap(find.byKey(const ValueKey('moment-local-thumbnail-1')));
    momentPagesTestReplaceAtomicEditor(
      tester,
      const Key('moment-compose-content'),
      '准备图片时继续写',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('moment-compose-submit')));
    await tester.pump();
    expect(find.text('还有 2 张图片未就绪'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const Key('moment-compose-title')),
              matching: find.byType(TextField),
            ),
          )
          .readOnly,
      isTrue,
    );
    gateway.complete(1);
    await tester.pump();
    await tester.pump();
    expect(repository.createdInputs, isEmpty);
    gateway.complete(0);
    await tester.pumpAndSettle();
    expect(repository.createdInputs, hasLength(1));
    expect(repository.createdInputs.single.mediaIds, [
      'moment-image-1',
      'moment-image-2',
    ]);
    expect(repository.createdInputs.single.coverMediaId, 'moment-image-2');
    expect(repository.createdInputs.single.content, '准备图片时继续写');
    expect(find.text('已发布'), findsOneWidget);
  });

  for (final cancel in [false, true]) {
    testWidgets('评论图片等待发布仅提交一次，取消等待=$cancel', (tester) async {
      final gateway = MomentPagesTestControlledBatchUploadGateway();
      final sent = <MomentCommentInput>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            momentComposerOwnerResolverProvider.overrideWithValue(
              () async => 'owner',
            ),
            pendingMediaFileStoreProvider.overrideWithValue(
              MomentTestPendingMediaStore(),
            ),
            editorImagePickerPortProvider.overrideWithValue(
              MomentPagesTestFakeImagePicker(),
            ),
            mediaUploadGatewayPortProvider.overrideWithValue(gateway),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: MomentCommentComposer(
                replyTo: null,
                isSending: false,
                onCancelReply: () {},
                onClose: () {},
                onSend: (input) async {
                  sent.add(input);
                  return true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('moment-comment-image')));
      await tester.pump();
      await tester.pump();
      expect(gateway.operations, hasLength(1));
      final editor = tester.widget<QuillEditor>(
        find.byKey(const Key('moment-comment-input')),
      );
      expect(editor.controller.readOnly, isFalse);
      momentPagesTestReplaceAtomicEditor(
        tester,
        const Key('moment-comment-input'),
        '图片准备期间仍可输入',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('moment-comment-send')));
      await tester.pump();
      expect(find.text('还有 1 张图片未就绪'), findsOneWidget);
      expect(editor.controller.readOnly, isTrue);
      expect(sent, isEmpty);
      if (cancel) {
        await tester.tap(
          find.byKey(const Key('moment-comment-cancel-publish')),
        );
        await tester.pump();
        expect(editor.controller.readOnly, isFalse);
      }
      gateway.complete(0);
      await tester.pumpAndSettle();
      expect(sent, hasLength(cancel ? 0 : 1));
      if (cancel) {
        await tester.tap(find.byKey(const Key('moment-comment-send')));
        await tester.pumpAndSettle();
      }
      expect(sent, hasLength(1));
      expect(sent.single.mediaId, 'moment-image-1');
      expect(sent.single.content, '图片准备期间仍可输入');
    });
  }

  testWidgets('评论换图失败后移除新选择保留原图', (tester) async {
    final gateway = MomentPagesTestFailingThenSuccessfulUploadGateway();
    final sent = <MomentCommentInput>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'owner',
          ),
          pendingMediaFileStoreProvider.overrideWithValue(
            MomentTestPendingMediaStore(),
          ),
          editorImagePickerPortProvider.overrideWithValue(
            MomentPagesTestFakeImagePicker(),
          ),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: MomentCommentComposer(
              replyTo: null,
              isSending: false,
              onCancelReply: () {},
              onClose: () {},
              initialDraft: const MomentCommentDraft(
                image: UploadedEditorImage(
                  mediaId: 'old-image',
                  url: 'https://example.com/old.png',
                ),
              ),
              onSend: (input) async {
                sent.add(input);
                return true;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-comment-image')));
    await tester.pumpAndSettle();
    expect(find.text('未完成'), findsOneWidget);
    await tester.tap(find.byTooltip('移除图片 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-comment-send')));
    await tester.pumpAndSettle();
    expect(sent.single.mediaId, 'old-image');
  });
}

class _DelayedFileStore extends MomentTestPendingMediaStore {
  final pending = <Completer<MediaUploadInput>>[];
  final inputs = <MediaUploadInput>[];
  @override
  Future<MediaUploadInput> persist(
    MediaUploadInput input, {
    required String accountId,
    required String target,
    required String attachmentId,
  }) {
    inputs.add(input);
    final completion = Completer<MediaUploadInput>();
    pending.add(completion);
    return completion.future;
  }
}

class _NamedPicker implements EditorImagePicker {
  int count = 0;
  @override
  Future<MediaUploadInput?> pickFromGallery() async {
    final original = (await MomentPagesTestFakeImagePicker()
        .pickFromGallery())!;
    return MediaUploadInput(
      filename: 'choice-${++count}.png',
      bytes: original.requiredBytes,
      declaredContentType: 'image/png',
    );
  }
}

class _TerminalFailureGateway
    implements MediaUploadGateway, ResumableMediaUploadGateway {
  int resumes = 0;
  int uploads = 0;
  @override
  MediaUploadOperation<UploadedEditorImage> resumeImageProcessing(
    PendingMediaUpload pending, {
    void Function(MediaUploadProgress)? onProgress,
  }) {
    resumes++;
    return MomentPagesTestImmediateUploadOperation(
      Future.error(const ApiFailure(userMessage: '图片处理失败')),
    );
  }

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress)? onProgress,
  }) {
    uploads++;
    return MomentPagesTestImmediateUploadOperation(
      Future.value(
        const UploadedEditorImage(
          mediaId: 'replacement',
          url: 'https://example.com/replacement.png',
        ),
      ),
    );
  }
}
