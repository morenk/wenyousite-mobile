import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/drafts/application/content_drafts_controller.dart';
import 'package:wenyousite_mobile/features/drafts/data/content_draft_repository.dart';
import 'package:wenyousite_mobile/features/drafts/domain/content_draft_models.dart';
import 'package:wenyousite_mobile/features/editor/data/editor_snapshot_store.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/mention_suggestions.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_compose_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_compose_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_compose_page.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('加载态可渲染', (tester) async {
    final controller = ThreadComposeController(
      _FakeRepository(),
      _MemorySnapshotStore(),
      knownOwnerId: 'user-one',
      autoStart: false,
    );

    await _pumpPage(tester, controller);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('恢复本地主题快照并渲染真实创作表单', (tester) async {
    final store = _MemorySnapshotStore(
      snapshot: LocalEditorSnapshot(
        id: DatabaseEditorSnapshotStore.threadSnapshotId('user-one'),
        contextType: EditorContextType.thread,
        body: '恢复的主题正文',
        metadataJson: const ThreadSnapshotMetadata(
          ownerId: 'user-one',
          title: '恢复的标题',
          categorySlug: 'TRPG',
          visibility: ThreadComposeVisibility.private,
          tags: ['奇幻', '跑团'],
        ).toJson(),
        clientRequestId: _requestId,
        updatedAt: DateTime.utc(2026, 8, 10),
      ),
    );
    final controller = await _readyController(store);

    await _pumpPage(tester, controller);

    expect(find.text('已恢复上次未完成的本地内容。'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('compose-title')))
          .controller!
          .text,
      '恢复的标题',
    );
    expect(find.byKey(const Key('compose-title-label')), findsOneWidget);
    expect(controller.state.body, '恢复的主题正文');
    expect(find.byKey(const Key('compose-body')), findsOneWidget);
    expect(find.byType(MentionSuggestions), findsOneWidget);
    expect(
      tester
          .widget<MentionSuggestions>(find.byType(MentionSuggestions))
          .threadId,
      isNull,
    );
    expect(find.byKey(const Key('compose-remote-drafts')), findsOneWidget);
    expect(find.byKey(const Key('compose-save-draft')), findsNothing);

    await tester.tap(find.byKey(const Key('compose-remote-drafts')));
    await tester.pumpAndSettle();
    expect(find.text('保存'), findsOneWidget);
    expect(find.text('打开'), findsOneWidget);
    expect(find.byKey(const Key('compose-save-draft')), findsOneWidget);

    await tester.tap(find.byKey(const Key('compose-save-draft')));
    await tester.pumpAndSettle();
    expect(find.text('已保存到云端草稿'), findsOneWidget);
  });

  testWidgets('发布前在页面内显示验证错误且不调用后端创建', (tester) async {
    final repository = _FakeRepository();
    final controller = await _readyController(
      _MemorySnapshotStore(),
      repository: repository,
    );
    await _pumpPage(tester, controller);
    final publish = find.byKey(const Key('compose-publish'));
    await tester.ensureVisible(publish);

    await tester.tap(publish);
    await tester.pump();

    expect(find.text('请填写主题标题。'), findsOneWidget);
    expect(repository.createCalls, 0);
  });

  testWidgets('图片上传完成后插入安全 Markdown 图片节点', (tester) async {
    final controller = await _readyController(_MemorySnapshotStore());
    await _pumpPage(
      tester,
      controller,
      picker: _FakePicker(),
      mediaRepository: _FakeMediaRepository(),
    );
    final imageButton = find.byKey(const Key('editor-image'));
    await tester.ensureVisible(imageButton);
    await tester.tap(imageButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('描述这张图片'), findsNothing);
    expect(
      controller.state.body,
      contains('![图片](https://cdn.example.com/editor.png)'),
    );
  });

  testWidgets('图片上传中锁定发布，取消后保留原正文', (tester) async {
    final controller = await _readyController(_MemorySnapshotStore())
      ..updateBody('保留的主题正文');
    final mediaRepository = _BlockingMediaRepository();
    await _pumpPage(
      tester,
      controller,
      picker: _FakePicker(),
      mediaRepository: mediaRepository,
    );
    final publish = find.byKey(const Key('compose-publish'));
    expect(tester.widget<FilledButton>(publish).onPressed, isNotNull);

    final imageButton = find.byKey(const Key('editor-image'));
    await tester.ensureVisible(imageButton);
    await tester.tap(imageButton);
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('正在上传图片'), findsOneWidget);
    expect(
      tester
          .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .any((indicator) => indicator.value == .5),
      isTrue,
    );
    expect(tester.widget<FilledButton>(publish).onPressed, isNull);

    await tester.tap(find.text('取消上传'));
    await tester.pump();
    await tester.pump();

    expect(mediaRepository.cancelled, isTrue);
    expect(find.textContaining('正在上传图片'), findsNothing);
    expect(controller.state.body, '保留的主题正文');
    expect(controller.state.body, isNot(contains('wenyou_image')));
    expect(tester.widget<FilledButton>(publish).onPressed, isNotNull);
  });

  testWidgets('上传中系统返回先取消任务且迟到成功不会写入草稿', (tester) async {
    final store = _MemorySnapshotStore();
    final controller = await _readyController(store)
      ..updateBody('返回前正文');
    final gateway = _LateCompletingMediaUploadGateway();
    await _pumpPage(
      tester,
      controller,
      picker: _FakePicker(),
      mediaGateway: gateway,
    );

    await tester.tap(find.byKey(const Key('editor-image')));
    await tester.pump();
    expect(find.textContaining('正在上传图片'), findsOneWidget);

    await tester.binding.handlePopRoute();
    expect(gateway.operation.cancelled, isTrue);
    gateway.operation.complete(
      const UploadedEditorImage(
        mediaId: 'late-image',
        url: 'https://cdn.example.com/late.png',
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(controller.state.body, '返回前正文');
    expect(controller.state.body, isNot(contains('late.png')));
    expect(tester.takeException(), isNull);
  });

  for (final size in const [
    Size(320, 640),
    Size(360, 600),
    Size(400, 800),
    Size(600, 900),
  ]) {
    testWidgets('${size.width}dp 创作页和紧凑顶栏无布局溢出', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = await _readyController(_MemorySnapshotStore());

      await _pumpPage(tester, controller);

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('compose-body')), findsOneWidget);
      expect(
        tester.getTopRight(find.byKey(const Key('compose-publish'))).dx,
        lessThanOrEqualTo(size.width),
      );
    });
  }

  for (final width in const [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 键盘写作固定完整格式栏且保留焦点选区', (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final controller = await _readyController(_MemorySnapshotStore());

      await _pumpPage(tester, controller);
      final editor = tester.widget<QuillEditor>(
        find.byKey(const Key('compose-body')),
      );
      editor.focusNode.requestFocus();
      await tester.pump();
      final selection = editor.controller.selection;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();

      final toolbar = find.byKey(const Key('compose-toolbar'));
      expect(toolbar, findsOneWidget);
      final dock = tester.widget<WenyouComposerDock>(toolbar);
      expect(dock.enabled, isTrue);
      expect(dock.surface, WenyouComposerSurface.page);
      expect(dock.capabilities, WenyouEditorCapabilities.richMarkdown);
      expect(controller.state.isSubmitting, isFalse);
      expect(find.text('当前格式组合暂时不能安全保存。'), findsNothing);
      expect(tester.getSize(toolbar).height, greaterThanOrEqualTo(48));
      if (width <= 400) {
        expect(find.bySemanticsLabel('正文格式工具'), findsOneWidget);
      }
      expect(find.byKey(const Key('editor-heading')), findsOneWidget);
      expect(find.byKey(const Key('editor-bold')), findsOneWidget);
      expect(find.byKey(const Key('editor-italic')), findsOneWidget);
      expect(find.byKey(const Key('editor-image')), findsOneWidget);
      expect(find.byKey(const Key('editor-more')), findsOneWidget);
      expect(editor.focusNode.hasFocus, isTrue);

      await tester.tap(find.byKey(const Key('editor-more')));
      await tester.pump();

      expect(find.byKey(const Key('editor-more-tray')), findsOneWidget);
      expect(editor.controller.selection, selection);
      expect(editor.focusNode.hasFocus, isTrue);
      if (width == 360) {
        await tester.tap(find.byKey(const Key('editor-heading')));
        await tester.pump();
        expect(find.byKey(const Key('editor-heading-tray')), findsOneWidget);

        await tester.tap(find.text('H2'));
        await tester.pump();

        expect(find.byKey(const Key('editor-heading-tray')), findsNothing);
        expect(editor.controller.selection, selection);
        expect(
          editor.controller.getSelectionStyle().attributes['header']?.value,
          2,
        );
        expect(editor.focusNode.hasFocus, isTrue);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('创作首屏固定标题、发布元信息和正文', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await _readyController(_MemorySnapshotStore());

    await _pumpPage(tester, controller);

    final title = find.byKey(const Key('compose-title'));
    final body = find.byKey(const Key('compose-body'));
    final settings = find.byKey(const Key('compose-publish-settings'));
    expect(tester.getTopLeft(title).dy, lessThan(tester.getTopLeft(body).dy));
    expect(tester.getSize(body).height, greaterThanOrEqualTo(300));
    expect(find.byKey(const Key('compose-category')), findsOneWidget);
    expect(find.byKey(const Key('compose-visibility')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('compose-remote-drafts'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.byKey(const Key('compose-publish'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(find.byKey(const Key('compose-save-draft')), findsNothing);

    await tester.tap(find.byKey(const Key('compose-remote-drafts')));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const Key('compose-save-draft'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester
          .getSize(find.byKey(const Key('compose-open-remote-drafts')))
          .height,
      greaterThanOrEqualTo(48),
    );
    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();

    await tester.ensureVisible(settings);
    await tester.tap(find.byKey(const Key('compose-category')));
    await tester.pump();
    expect(find.byKey(const Key('compose-metadata-panel')), findsOneWidget);
    await tester.tap(find.byKey(const Key('compose-visibility')));
    await tester.pump();
    expect(find.text('公开'), findsOneWidget);
    await tester.tap(find.byTooltip('标签'));
    await tester.pump();
    expect(find.byKey(const Key('compose-tags')), findsOneWidget);
  });

  testWidgets('360dp 创作首屏保持标题与正文优先的视觉基线', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await _readyController(_MemorySnapshotStore());

    await _pumpPage(tester, controller);

    await expectLater(
      find.byKey(const Key('compose-text-first-visual')),
      matchesGoldenFile('goldens/thread_compose_text_first_360.png'),
    );

    final editor = tester.widget<QuillEditor>(
      find.byKey(const Key('compose-body')),
    );
    expect(editor.config.customStyles?.paragraph?.style.fontSize, 17);
    expect(editor.config.customStyles?.paragraph?.style.height, 1.8);
    editor.focusNode.requestFocus();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('compose-text-first-visual')),
      matchesGoldenFile('goldens/thread_compose_keyboard_360.png'),
    );
  });

  testWidgets('360dp 长文编辑态与成稿保持舒展文字节奏', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await _readyController(_MemorySnapshotStore());
    controller
      ..updateTitle('雾港接力稿')
      ..updateBody(
        '钟声从雾里传来，守夜人把最后一盏灯留在码头。\n'
        '她没有回头，只把写了一半的航海日志推给下一位旅人。\n\n'
        '接下来的人需要沿着潮痕继续，并保留上一段留下的人物动机。',
      );

    await _pumpPage(tester, controller);

    await expectLater(
      find.byKey(const Key('compose-text-first-visual')),
      matchesGoldenFile('goldens/thread_compose_longform_360.png'),
    );
  });

  testWidgets('工具栏正文草稿与顶栏云端主题草稿保持独立入口', (tester) async {
    final controller = await _readyController(_MemorySnapshotStore());
    controller.updateBody('当前主题正文');
    final contentDraftsController = ContentDraftsController(
      _FakeContentDraftRepository(),
      autoStart: false,
    );
    await contentDraftsController.load();
    await _pumpPage(
      tester,
      controller,
      contentDraftsController: contentDraftsController,
    );
    final draftsButton = find.byKey(const Key('editor-content-drafts'));
    await tester.scrollUntilVisible(
      draftsButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(draftsButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('content-drafts-list')), findsOneWidget);
    expect(find.text('只保存当前正文 · 已用 1/5'), findsOneWidget);

    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('compose-remote-drafts')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('compose-save-draft')), findsOneWidget);
    expect(find.byKey(const Key('compose-open-remote-drafts')), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
    expect(find.text('打开'), findsOneWidget);
  });

  testWidgets('离页强制落盘失败时要求用户明确选择而不静默退出', (tester) async {
    final store = _MemorySnapshotStore(failSaves: true);
    final controller = await _readyController(store);
    await _pumpPage(tester, controller);
    await tester.enterText(find.byKey(const Key('compose-title')), '尚未保存的标题');

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.text('本地内容尚未保存'), findsOneWidget);
    await tester.tap(find.text('留下'));
    await tester.pumpAndSettle();
    expect(find.byType(ThreadComposePage), findsOneWidget);
  });
}

Future<ThreadComposeController> _readyController(
  _MemorySnapshotStore store, {
  _FakeRepository? repository,
}) async {
  final controller = ThreadComposeController(
    repository ?? _FakeRepository(),
    store,
    knownOwnerId: 'user-one',
    createRequestId: () => _requestId,
    autoStart: false,
  );
  await controller.load();
  for (
    var attempt = 0;
    attempt < 100 && controller.state.bootstrapLoading;
    attempt++
  ) {
    await Future<void>.value();
  }
  return controller;
}

Future<void> _pumpPage(
  WidgetTester tester,
  ThreadComposeController controller, {
  EditorImagePicker? picker,
  MediaUploadRepository? mediaRepository,
  MediaUploadGateway? mediaGateway,
  ContentDraftsController? contentDraftsController,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        stickersEnabledProvider.overrideWithValue(false),
        threadComposeControllerProvider.overrideWith((ref) => controller),
        if (contentDraftsController != null)
          contentDraftsControllerProvider.overrideWith(
            (ref) => contentDraftsController,
          ),
        if (picker != null)
          editorImagePickerPortProvider.overrideWithValue(picker),
        if (mediaGateway != null)
          mediaUploadGatewayPortProvider.overrideWithValue(mediaGateway)
        else if (mediaRepository != null)
          mediaUploadGatewayPortProvider.overrideWithValue(
            RepositoryMediaUploadGateway(mediaRepository),
          ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const RepaintBoundary(
          key: Key('compose-text-first-visual'),
          child: ThreadComposePage(),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 10));
}

const _requestId = '550e8400-e29b-41d4-a716-446655440000';

class _FakeRepository implements ThreadComposeRepository {
  int createCalls = 0;

  @override
  Future<List<ThreadRemoteDraftSummary>> fetchDrafts() async => const [];

  @override
  Future<ThreadRemoteDraft> fetchDraft({
    required String id,
    required String ownerId,
  }) async {
    return ThreadRemoteDraft(
      id: id,
      version: 3,
      defaultSubthreadId: 'subthread-cloud',
      defaultSubthreadVersion: 4,
      bodyVersion: 5,
      title: '云端草稿',
      categorySlug: 'TRPG',
      visibility: ThreadComposeVisibility.private,
      tags: const ['云端'],
      body: '服务端正文',
    );
  }

  @override
  Future<void> removeDraft(String id) async {}

  @override
  Future<ThreadComposeBootstrap> fetchBootstrap() async {
    return ThreadComposeBootstrap(
      userId: 'user-one',
      categories: const [
        ThreadComposeCategory(slug: 'TRPG', name: '跑团', sortOrder: 1),
      ],
    );
  }

  @override
  Future<ThreadRemoteDraft> createDraft(ThreadCreatePayload payload) async {
    createCalls += 1;
    return ThreadRemoteDraft(
      id: 'thread-one',
      version: 1,
      defaultSubthreadId: 'subthread-one',
      defaultSubthreadVersion: 1,
      title: payload.title,
      categorySlug: payload.categorySlug,
      visibility: payload.visibility,
      tags: payload.tags,
      body: payload.body,
      bodyVersion: payload.body.isEmpty ? null : 1,
    );
  }

  @override
  Future<ThreadRemoteDraft> saveAggregate({
    required ThreadRemoteDraft remoteDraft,
    required String title,
    required String? categorySlug,
    required ThreadComposeVisibility visibility,
    required List<String> tags,
    required String body,
    required bool publish,
  }) async {
    return ThreadRemoteDraft(
      id: remoteDraft.id,
      version: remoteDraft.version + 1,
      defaultSubthreadId: remoteDraft.defaultSubthreadId,
      defaultSubthreadVersion: remoteDraft.defaultSubthreadVersion + 1,
      title: title,
      categorySlug: categorySlug,
      visibility: visibility,
      tags: tags,
      body: body,
      bodyVersion: (remoteDraft.bodyVersion ?? 0) + 1,
    );
  }
}

class _FakeContentDraftRepository implements ContentDraftRepository {
  final _draft = ContentDraft(
    id: 'content-draft-one',
    userId: 'user-one',
    slot: 1,
    content: '云端正文',
    version: 1,
    createdAt: DateTime.utc(2026, 8, 9),
    updatedAt: DateTime.utc(2026, 8, 10),
  );

  @override
  Future<ContentDraft> create(String content, {int? slot}) async => _draft;

  @override
  Future<ContentDraftCollection> fetchCollection() async {
    return ContentDraftCollection(
      drafts: [_draft],
      usage: const ContentDraftSlotUsage(
        usedSlots: 1,
        maxSlots: 5,
        occupiedSlots: {1},
      ),
    );
  }

  @override
  Future<ContentDraft> fetchById(String id) async => _draft;

  @override
  Future<void> remove(String id) async {}

  @override
  Future<ContentDraft> update({
    required String id,
    required String content,
    required int version,
  }) async => _draft;
}

class _MemorySnapshotStore implements EditorSnapshotStore {
  _MemorySnapshotStore({this.snapshot, this.failSaves = false});

  LocalEditorSnapshot? snapshot;
  final bool failSaves;

  @override
  Future<void> deletePendingCreate(String clientRequestId) async {}

  @override
  Future<void> deleteThreadSnapshot(String ownerId) async => snapshot = null;

  @override
  Future<PendingCreateOperation?> findPendingCreate(
    String clientRequestId,
  ) async {
    return null;
  }

  @override
  Future<LocalEditorSnapshot?> findThreadSnapshot(String ownerId) async {
    return snapshot;
  }

  @override
  Future<void> savePendingCreate(PendingCreateOperation operation) async {}

  @override
  Future<void> saveThreadSnapshot(LocalEditorSnapshot value) async {
    if (failSaves) throw StateError('disk full');
    snapshot = value;
  }
}

class _FakePicker implements EditorImagePicker {
  @override
  Future<MediaUploadInput?> pickFromGallery() async {
    return MediaUploadInput(
      filename: 'editor.png',
      declaredContentType: 'image/png',
      bytes: Uint8List.fromList(const [137, 80, 78, 71]),
    );
  }
}

class _FakeMediaRepository implements MediaUploadRepository {
  @override
  Future<UploadedEditorImage> uploadImage(
    MediaUploadInput input, {
    CancelToken? cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
  }) async {
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: input.bytes.length,
        totalBytes: input.bytes.length,
      ),
    );
    return const UploadedEditorImage(
      mediaId: 'media-one',
      url: 'https://cdn.example.com/editor.png',
    );
  }
}

class _BlockingMediaRepository implements MediaUploadRepository {
  var cancelled = false;

  @override
  Future<UploadedEditorImage> uploadImage(
    MediaUploadInput input, {
    CancelToken? cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
  }) async {
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: input.bytes.length ~/ 2,
        totalBytes: input.bytes.length,
      ),
    );
    await cancelToken!.whenCancel;
    cancelled = true;
    throw const ApiFailure(userMessage: '图片上传已取消。');
  }
}

class _LateCompletingMediaUploadGateway implements MediaUploadGateway {
  final operation = _LateCompletingMediaUploadOperation();

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: input.bytes.length ~/ 2,
        totalBytes: input.bytes.length,
      ),
    );
    return operation;
  }
}

class _LateCompletingMediaUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  final _completer = Completer<UploadedEditorImage>();
  var cancelled = false;

  @override
  Future<UploadedEditorImage> get result => _completer.future;

  @override
  void cancel() => cancelled = true;

  void complete(UploadedEditorImage image) => _completer.complete(image);
}
