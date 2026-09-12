import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/drafts/application/content_drafts_controller.dart';
import 'package:wenyousite_mobile/features/drafts/data/content_draft_repository.dart';
import 'package:wenyousite_mobile/features/drafts/domain/content_draft_models.dart';
import 'package:wenyousite_mobile/features/editor/data/editor_snapshot_store.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_repository_ports.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_compose_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_compose_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_compose_page.dart';
import '../../support/fake_image_crop_processor.dart';

Future<ThreadComposeController> threadComposePageTestReadyController(
  ThreadComposePageTestMemorySnapshotStore store, {
  ThreadComposePageTestFakeRepository? repository,
}) async {
  final controller = ThreadComposeController(
    repository ?? ThreadComposePageTestFakeRepository(),
    store,
    knownOwnerId: 'user-one',
    createRequestId: () => threadComposePageTestRequestId,
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

Future<void> threadComposePageTestPumpPage(
  WidgetTester tester,
  ThreadComposeController controller, {
  EditorImagePicker? picker,
  MediaUploadRepository? mediaRepository,
  MediaUploadGateway? mediaGateway,
  ImageCropProcessor? cropProcessor,
  ContentDraftsController? contentDraftsController,
  ThreadComposePageTestComposeStickerRepository? stickerRepository,
  bool markdownAlignment = false,
  bool withThreadRoute = false,
}) async {
  late final Widget app;
  if (stickerRepository == null && !withThreadRoute) {
    app = MaterialApp(
      theme: AppTheme.light,
      home: const RepaintBoundary(
        key: Key('compose-text-first-visual'),
        child: ThreadComposePage(),
      ),
    );
  } else {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const RepaintBoundary(
            key: Key('compose-text-first-visual'),
            child: ThreadComposePage(),
          ),
        ),
        GoRoute(
          path: '/stickers',
          name: 'me-stickers',
          builder: (context, state) => const SizedBox.shrink(),
        ),
        if (withThreadRoute)
          GoRoute(
            path: '/threads/:id',
            builder: (context, state) =>
                const SizedBox(key: Key('published-thread-route')),
          ),
      ],
    );
    addTearDown(router.dispose);
    app = MaterialApp.router(theme: AppTheme.light, routerConfig: router);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appCapabilitiesProvider.overrideWithValue(
          AppCapabilities(markdownAlignment: markdownAlignment),
        ),
        stickersEnabledProvider.overrideWithValue(stickerRepository != null),
        if (stickerRepository != null) ...[
          stickerRepositoryProvider.overrideWithValue(stickerRepository),
          stickerCollectionControllerProvider.overrideWith((ref) {
            return StickerCollectionController(
              stickerRepository,
              pollInterval: Duration.zero,
            );
          }),
        ],
        imageCropProcessorPortProvider.overrideWithValue(
          cropProcessor ?? const FakePassThroughImageCropProcessor(),
        ),
        threadComposeControllerProvider.overrideWith((ref) => controller),
        if (contentDraftsController != null)
          contentDraftsControllerProvider.overrideWith(
            (ref, sessionKey) => contentDraftsController,
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
      child: app,
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 10));
}

Future<void> threadComposePageTestConfirmImageCrop(WidgetTester tester) async {
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('editor-image-crop-dialog')), findsOneWidget);
  tester
      .widget<FilledButton>(find.byKey(const Key('image-crop-confirm')))
      .onPressed!();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

const threadComposePageTestRequestId = '550e8400-e29b-41d4-a716-446655440000';

class ThreadComposePageTestFakeRepository implements ThreadComposeRepository {
  int createCalls = 0;
  ThreadCreatePayload? createPayload;
  String? savedBody;

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
    createPayload = payload;
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
    savedBody = body;
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

class ThreadComposePageTestComposeStickerRepository
    implements StickerRepository {
  @override
  Future<StickerCollection> fetchCollection() async =>
      threadComposePageTestComposeStickerCollection;

  @override
  Future<StickerImport> fetchImport(String id) => throw UnimplementedError();

  @override
  Future<StickerImport> importSource(
    StickerImportSource source, {
    required String clientRequestId,
  }) => throw UnimplementedError();

  @override
  Future<StickerCollection> remove(String favoriteId) =>
      throw UnimplementedError();

  @override
  Future<StickerCollection> reorder({
    required int version,
    required List<String> favoriteIds,
  }) => throw UnimplementedError();
}

const threadComposePageTestComposeStickerAssetId = 'cm1234567890123456789012';

const threadComposePageTestComposeStickerUrl =
    'https://cdn.example.com/stickers/thread-compose.webp';

const threadComposePageTestComposeSticker = UserSticker(
  id: 'favorite-compose',
  position: 0,
  asset: StickerAsset(
    id: threadComposePageTestComposeStickerAssetId,
    url: threadComposePageTestComposeStickerUrl,
    thumbnailUrl: 'https://cdn.example.com/stickers/thread-compose-thumb.webp',
    width: 96,
    height: 96,
    animated: false,
    frameCount: 1,
    durationMs: 0,
  ),
  markdown:
      '![表情]($threadComposePageTestComposeStickerUrl '
      '"wenyousite-sticker:v1:$threadComposePageTestComposeStickerAssetId")',
);

const threadComposePageTestComposeStickerCollection = StickerCollection(
  version: 1,
  limit: 200,
  items: [threadComposePageTestComposeSticker],
  recent: [],
  pendingImports: [],
);

class ThreadComposePageTestFakeContentDraftRepository
    implements ContentDraftRepository {
  ContentDraft threadComposePageTestDraft = ContentDraft(
    id: 'content-draft-one',
    userId: 'user-one',
    slot: 1,
    content: '云端正文',
    version: 1,
    createdAt: DateTime.utc(2026, 8, 9),
    updatedAt: DateTime.utc(2026, 8, 10),
  );
  final List<String> updatedContents = [];

  @override
  Future<ContentDraft> create(
    String content, {
    int? slot,
    required String clientRequestId,
  }) async => threadComposePageTestDraft;

  @override
  Future<ContentDraftCollection> fetchCollection() async {
    return ContentDraftCollection(
      drafts: [threadComposePageTestDraft],
      usage: const ContentDraftSlotUsage(
        usedSlots: 1,
        maxSlots: 5,
        occupiedSlots: {1},
      ),
    );
  }

  @override
  Future<ContentDraft> fetchById(String id) async => threadComposePageTestDraft;

  @override
  Future<void> remove(String id, {required int version}) async {}

  @override
  Future<ContentDraft> update({
    required String id,
    required String content,
    required int version,
  }) async {
    updatedContents.add(content);
    threadComposePageTestDraft = ContentDraft(
      id: threadComposePageTestDraft.id,
      userId: threadComposePageTestDraft.userId,
      slot: threadComposePageTestDraft.slot,
      content: content,
      version: version + 1,
      createdAt: threadComposePageTestDraft.createdAt,
      updatedAt: threadComposePageTestDraft.updatedAt.add(
        const Duration(minutes: 1),
      ),
    );
    return threadComposePageTestDraft;
  }
}

class ThreadComposePageTestMemorySnapshotStore implements EditorSnapshotStore {
  @override
  Future<void> beginThreadCreate(
    LocalEditorSnapshot value,
    PendingCreateOperation operation,
  ) async {
    await saveThreadSnapshot(value);
    await savePendingCreate(operation);
  }

  @override
  Future<void> completeThreadCreate(LocalEditorSnapshot value) async {
    await saveThreadSnapshot(value);
    await deletePendingCreate(value.clientRequestId);
  }

  ThreadComposePageTestMemorySnapshotStore({
    this.snapshot,
    this.failSaves = false,
  });

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

class ThreadComposePageTestFakePicker implements EditorImagePicker {
  @override
  Future<MediaUploadInput?> pickFromGallery() async {
    return MediaUploadInput(
      filename: 'editor.png',
      declaredContentType: 'image/png',
      bytes: Uint8List.fromList(const [137, 80, 78, 71]),
    );
  }
}

class ThreadComposePageTestFakeMediaRepository
    implements MediaUploadRepository {
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

class ThreadComposePageTestBlockingMediaRepository
    implements MediaUploadRepository {
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

class ThreadComposePageTestLateCompletingMediaUploadGateway
    implements MediaUploadGateway {
  final operation = ThreadComposePageTestLateCompletingMediaUploadOperation();

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

class ThreadComposePageTestLateCompletingMediaUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  final threadComposePageTestCompleter = Completer<UploadedEditorImage>();
  var cancelled = false;

  @override
  Future<UploadedEditorImage> get result =>
      threadComposePageTestCompleter.future;

  @override
  void cancel() => cancelled = true;

  void complete(UploadedEditorImage image) =>
      threadComposePageTestCompleter.complete(image);
}
