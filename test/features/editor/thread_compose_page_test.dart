import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/features/drafts/application/content_drafts_controller.dart';
import 'package:wenyousite_mobile/features/drafts/data/content_draft_repository.dart';
import 'package:wenyousite_mobile/features/drafts/domain/content_draft_models.dart';
import 'package:wenyousite_mobile/features/editor/application/thread_compose_controller.dart';
import 'package:wenyousite_mobile/features/editor/data/editor_snapshot_store.dart';
import 'package:wenyousite_mobile/features/editor/data/thread_compose_repository.dart';
import 'package:wenyousite_mobile/features/editor/domain/thread_compose_models.dart';
import 'package:wenyousite_mobile/features/editor/presentation/thread_compose_page.dart';
import 'package:wenyousite_mobile/features/media/data/editor_image_picker.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

void main() {
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
    expect(controller.state.body, '恢复的主题正文');
    expect(find.byKey(const Key('compose-body')), findsOneWidget);
    expect(find.text('保存到服务端草稿'), findsOneWidget);
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
    await tester.pumpAndSettle();
    expect(find.text('描述这张图片'), findsOneWidget);

    await tester.tap(find.text('继续上传'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      controller.state.body,
      contains('![主题正文插图](https://cdn.example.com/editor.png)'),
    );
  });

  testWidgets('360dp 窄屏表单和编辑器无横向溢出', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await _readyController(_MemorySnapshotStore());

    await _pumpPage(tester, controller);
    await tester.scrollUntilVisible(
      find.byKey(const Key('compose-body')),
      240,
      scrollable: find.byType(Scrollable).first,
    );

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('compose-body')), findsOneWidget);
  });

  testWidgets('工具栏正文草稿打开五槽位面板而页面按钮保留主题实体草稿', (tester) async {
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
    final draftsButton = find.byIcon(Icons.cloud_outlined);
    await tester.scrollUntilVisible(
      draftsButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(draftsButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('content-drafts-list')), findsOneWidget);
    expect(find.text('只保存当前正文 · 已用 1/5'), findsOneWidget);
    expect(find.text('保存到服务端草稿'), findsOneWidget);
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
  ContentDraftsController? contentDraftsController,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        threadComposeControllerProvider.overrideWith((ref) => controller),
        if (contentDraftsController != null)
          contentDraftsControllerProvider.overrideWith(
            (ref) => contentDraftsController,
          ),
        if (picker != null) editorImagePickerProvider.overrideWithValue(picker),
        if (mediaRepository != null)
          mediaUploadRepositoryProvider.overrideWithValue(mediaRepository),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const ThreadComposePage(),
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
  Future<ThreadComposeBootstrap> fetchBootstrap() async {
    return const ThreadComposeBootstrap(
      userId: 'user-one',
      emailVerified: true,
      categories: [
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
