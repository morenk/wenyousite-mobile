import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/data/sticker_repository.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_collection_page.dart';

import '../../support/fake_image_crop_processor.dart';
import '../../support/foundation_icon_finder.dart';

void main() {
  testWidgets('应用内 capability 覆盖作用域中打开表情包不会触发 Provider 断言', (tester) async {
    final repository = _FakeStickerRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [stickerRepositoryProvider.overrideWithValue(repository)],
        child: ProviderScope(
          overrides: [
            appCapabilitiesProvider.overrideWithValue(
              const AppCapabilities(stickers: true),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const StickerCollectionPage(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('表情包'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('能力关闭时展示收敛状态且不读取收藏', (tester) async {
    final repository = _FakeStickerRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stickersEnabledProvider.overrideWithValue(false),
          stickerRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const StickerCollectionPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('表情包功能当前未开放'), findsOneWidget);
    expect(repository.fetchCalls, 0);
  });

  testWidgets('从相册上传完成后导入媒体并展示新收藏', (tester) async {
    final repository = _FakeStickerRepository();
    final picker = _FakeImagePicker();
    final gateway = _FakeMediaUploadGateway();
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository, picker: picker, gateway: gateway),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const StickerCollectionPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('stickers-add-gallery')));
    await _confirmImageCrop(tester);
    await tester.pumpAndSettle();

    expect(picker.calls, 1);
    expect(gateway.calls, 1);
    expect(gateway.input?.purpose, MediaUploadPurpose.stickerSource);
    expect(repository.importedSources.single, isA<StickerMediaSource>());
    expect(find.text('1/200 个收藏'), findsOneWidget);
    expect(find.text('已添加到表情收藏。'), findsOneWidget);
  });

  testWidgets('上传失败后重试同一文件，完成后才导入收藏', (tester) async {
    final repository = _FakeStickerRepository();
    final picker = _FakeImagePicker();
    final gateway = _RetryingMediaUploadGateway();
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository, picker: picker, gateway: gateway),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const StickerCollectionPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('stickers-add-gallery')));
    await _confirmImageCrop(tester);
    await tester.pumpAndSettle();

    expect(gateway.inputs, hasLength(1));
    expect(repository.importedSources, isEmpty);
    expect(find.byKey(const Key('stickers-upload-failure')), findsOneWidget);
    expect(find.byKey(const Key('stickers-retry-upload')), findsOneWidget);

    await tester.tap(find.byKey(const Key('stickers-retry-upload')));
    await tester.pumpAndSettle();

    expect(picker.calls, 1);
    expect(gateway.inputs, hasLength(2));
    expect(identical(gateway.inputs.first, gateway.inputs.last), isTrue);
    expect(repository.importedSources, hasLength(1));
    expect(find.text('1/200 个收藏'), findsOneWidget);
    expect(find.text('已添加到表情收藏。'), findsOneWidget);
  });

  testWidgets('上传中取消会立即恢复管理页且不导入媒体', (tester) async {
    final repository = _FakeStickerRepository();
    final gateway = _BlockingMediaUploadGateway();
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(
          repository,
          picker: _FakeImagePicker(),
          gateway: gateway,
        ),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const StickerCollectionPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('stickers-add-gallery')));
    await _confirmImageCrop(tester);
    await tester.pump();

    expect(find.text('正在上传 50%'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('stickers-add-gallery')))
          .onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const Key('stickers-cancel-upload')));
    await tester.pump();
    await tester.pump();

    expect(gateway.operation.cancelled, isTrue);
    expect(find.text('正在上传 50%'), findsNothing);
    expect(find.byKey(const Key('stickers-upload-failure')), findsNothing);
    expect(repository.importedSources, isEmpty);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('stickers-add-gallery')))
          .onPressed,
      isNotNull,
    );
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 收藏、排序与移除列表无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 760);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = _FakeStickerRepository(
        initialItems: [
          _sticker(),
          _sticker(id: 'favorite-2', position: 1),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(repository),
          child: MaterialApp(
            theme: AppTheme.light,
            home: const StickerCollectionPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2/200 个收藏'), findsOneWidget);
      expect(findFoundationIcon(WenyouIconIds.actionReorder), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  }
}

List<Override> _overrides(
  _FakeStickerRepository repository, {
  EditorImagePicker? picker,
  MediaUploadGateway? gateway,
}) {
  return [
    stickersEnabledProvider.overrideWithValue(true),
    imageCropProcessorPortProvider.overrideWithValue(
      const FakePassThroughImageCropProcessor(),
    ),
    stickerRepositoryProvider.overrideWithValue(repository),
    stickerCollectionControllerProvider.overrideWith((ref) {
      return StickerCollectionController(
        repository,
        pollInterval: Duration.zero,
      );
    }),
    if (picker != null) editorImagePickerPortProvider.overrideWithValue(picker),
    if (gateway != null)
      mediaUploadGatewayPortProvider.overrideWithValue(gateway),
  ];
}

Future<void> _confirmImageCrop(WidgetTester tester) async {
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('editor-image-crop-dialog')), findsOneWidget);
  tester
      .widget<FilledButton>(find.byKey(const Key('image-crop-confirm')))
      .onPressed!();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

class _FakeStickerRepository implements StickerRepository {
  _FakeStickerRepository({List<UserSticker> initialItems = const []})
    : _items = [...initialItems];

  final List<UserSticker> _items;
  final List<StickerImportSource> importedSources = [];
  var fetchCalls = 0;
  var version = 3;

  @override
  Future<StickerCollection> fetchCollection() async {
    fetchCalls += 1;
    return _collection();
  }

  @override
  Future<StickerImport> fetchImport(String id) {
    throw UnimplementedError();
  }

  @override
  Future<StickerImport> importSource(
    StickerImportSource source, {
    required String clientRequestId,
  }) async {
    importedSources.add(source);
    if (_items.isEmpty) _items.add(_sticker());
    version += 1;
    return StickerImport(
      id: 'import-1',
      status: StickerImportStatus.completed,
      favorite: _items.first,
      alreadySaved: false,
    );
  }

  @override
  Future<StickerCollection> remove(String favoriteId) async {
    _items.removeWhere((item) => item.id == favoriteId);
    version += 1;
    return _collection();
  }

  @override
  Future<StickerCollection> reorder({
    required int version,
    required List<String> favoriteIds,
  }) async {
    final byId = {for (final item in _items) item.id: item};
    _items
      ..clear()
      ..addAll(
        favoriteIds.indexed.map(
          (entry) => UserSticker(
            id: byId[entry.$2]!.id,
            position: entry.$1,
            asset: byId[entry.$2]!.asset,
            markdown: byId[entry.$2]!.markdown,
          ),
        ),
      );
    this.version += 1;
    return _collection();
  }

  StickerCollection _collection() => StickerCollection(
    version: version,
    limit: 200,
    items: List.unmodifiable(_items),
    recent: const [],
    pendingImports: const [],
  );
}

class _FakeImagePicker implements EditorImagePicker {
  var calls = 0;

  @override
  Future<MediaUploadInput?> pickFromGallery() async {
    calls += 1;
    return MediaUploadInput(
      filename: 'sticker.png',
      declaredContentType: 'image/png',
      bytes: Uint8List.fromList([137, 80, 78, 71]),
    );
  }
}

class _FakeMediaUploadGateway implements MediaUploadGateway {
  var calls = 0;
  MediaUploadInput? input;

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    calls += 1;
    this.input = input;
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: input.bytes.length,
        totalBytes: input.bytes.length,
      ),
    );
    return _TestMediaUploadOperation(
      Future.value(
        const UploadedEditorImage(
          mediaId: 'media-1',
          url: 'https://cdn.example.com/upload.png',
        ),
      ),
    );
  }
}

class _RetryingMediaUploadGateway implements MediaUploadGateway {
  final inputs = <MediaUploadInput>[];

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    inputs.add(input);
    if (inputs.length == 1) {
      return _TestMediaUploadOperation(
        Future.error(
          const ApiFailure(userMessage: '图片上传失败。', requestId: 'request-upload'),
        ),
      );
    }
    return _TestMediaUploadOperation(
      Future.value(
        const UploadedEditorImage(
          mediaId: 'media-retried',
          url: 'https://cdn.example.com/retried.png',
        ),
      ),
    );
  }
}

class _BlockingMediaUploadGateway implements MediaUploadGateway {
  final operation = _BlockingMediaUploadOperation();

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

class _BlockingMediaUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  final Completer<UploadedEditorImage> _result =
      Completer<UploadedEditorImage>();
  var cancelled = false;

  @override
  Future<UploadedEditorImage> get result => _result.future;

  @override
  void cancel() => cancelled = true;
}

class _TestMediaUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  _TestMediaUploadOperation(this.result);

  @override
  final Future<UploadedEditorImage> result;

  @override
  void cancel() {}
}

UserSticker _sticker({String id = 'favorite-1', int position = 0}) =>
    UserSticker(
      id: id,
      position: position,
      asset: StickerAsset(
        id: 'asset-$id',
        url: 'https://cdn.example.com/$id.webp',
        thumbnailUrl: 'https://cdn.example.com/${id}_thumb.webp',
        width: 96,
        height: 96,
        animated: false,
        frameCount: 1,
        durationMs: 0,
      ),
      markdown: '![表情](https://cdn.example.com/$id.webp)',
    );
