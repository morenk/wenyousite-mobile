import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/stickers/data/sticker_repository.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

const _requestId = '123e4567-e89b-42d3-a456-426614174000';

void main() {
  setUpAll(() {
    registerFallbackValue(
      ImportStickerMediaDto(
        (builder) => builder
          ..mediaId = 'media-1'
          ..clientRequestId = _requestId,
      ),
    );
    registerFallbackValue(
      ImportStickerDirectMessageDto(
        (builder) => builder
          ..directMessageId = 'message-1'
          ..clientRequestId = _requestId,
      ),
    );
    registerFallbackValue(
      ImportStickerPostImageDto(
        (builder) => builder
          ..postId = 'post-1'
          ..imageUrl = 'https://cdn.example.com/post.webp'
          ..clientRequestId = _requestId,
      ),
    );
    registerFallbackValue(
      ReorderStickersDto(
        (builder) => builder
          ..version = 3
          ..favoriteIds.addAll(['favorite-2', 'favorite-1']),
      ),
    );
  });

  test('收藏夹与导入状态精确映射，并校验最近列表属于收藏夹', () async {
    final api = _MockStickersApi();
    when(api.stickersGetCollection).thenAnswer(
      (_) async => _collectionResponse(
        items: [
          _favoriteDto(),
          _favoriteDto(id: 'favorite-2', position: 1),
        ],
        recent: [_favoriteDto(id: 'favorite-2', position: 1)],
        pending: [
          _importDto(status: StickerImportResponseDtoStatusEnum.PROCESSING),
        ],
      ),
    );
    when(
      () => api.stickersGetImport(id: 'import-1'),
    ).thenAnswer((_) async => _getImportResponse(_completedImportDto()));
    final repository = ApiStickerRepository(api);

    final collection = await repository.fetchCollection();
    final result = await repository.fetchImport('import-1');

    expect(collection.version, 3);
    expect(collection.items.map((item) => item.id), [
      'favorite-1',
      'favorite-2',
    ]);
    expect(collection.recent.single.id, 'favorite-2');
    expect(
      collection.pendingImports.single.status,
      StickerImportStatus.processing,
    );
    expect(result.status, StickerImportStatus.completed);
    expect(result.favorite?.asset.animated, isFalse);
  });

  test('媒体、私聊消息和帖子图片三种来源均使用稳定幂等 DTO', () async {
    final api = _MockStickersApi();
    when(
      () => api.stickersImportMedia(
        importStickerMediaDto: any(named: 'importStickerMediaDto'),
      ),
    ).thenAnswer((_) async => _mediaImportResponse());
    when(
      () => api.stickersImportDirectMessage(
        importStickerDirectMessageDto: any(
          named: 'importStickerDirectMessageDto',
        ),
      ),
    ).thenAnswer((_) async => _directImportResponse());
    when(
      () => api.stickersImportPostImage(
        importStickerPostImageDto: any(named: 'importStickerPostImageDto'),
      ),
    ).thenAnswer((_) async => _postImportResponse());
    final repository = ApiStickerRepository(api);

    await repository.importSource(
      const StickerMediaSource('media-1'),
      clientRequestId: _requestId,
    );
    await repository.importSource(
      const StickerDirectMessageSource('message-1'),
      clientRequestId: _requestId,
    );
    await repository.importSource(
      const StickerPostImageSource(
        postId: 'post-1',
        imageUrl: 'https://cdn.example.com/post.webp',
      ),
      clientRequestId: _requestId,
    );

    final media =
        verify(
              () => api.stickersImportMedia(
                importStickerMediaDto: captureAny(
                  named: 'importStickerMediaDto',
                ),
              ),
            ).captured.single
            as ImportStickerMediaDto;
    final direct =
        verify(
              () => api.stickersImportDirectMessage(
                importStickerDirectMessageDto: captureAny(
                  named: 'importStickerDirectMessageDto',
                ),
              ),
            ).captured.single
            as ImportStickerDirectMessageDto;
    final post =
        verify(
              () => api.stickersImportPostImage(
                importStickerPostImageDto: captureAny(
                  named: 'importStickerPostImageDto',
                ),
              ),
            ).captured.single
            as ImportStickerPostImageDto;
    expect(media.mediaId, 'media-1');
    expect(media.clientRequestId, _requestId);
    expect(direct.directMessageId, 'message-1');
    expect(direct.clientRequestId, _requestId);
    expect(post.postId, 'post-1');
    expect(post.imageUrl, 'https://cdn.example.com/post.webp');
    expect(post.clientRequestId, _requestId);
  });

  test('排序提交完整 ID 列表，移除使用收藏 ID，并采用服务端新版本', () async {
    final api = _MockStickersApi();
    when(
      () => api.stickersReorder(
        reorderStickersDto: any(named: 'reorderStickersDto'),
      ),
    ).thenAnswer(
      (_) async => _reorderResponse(
        items: [
          _favoriteDto(id: 'favorite-2'),
          _favoriteDto(id: 'favorite-1', position: 1),
        ],
        version: 4,
      ),
    );
    when(() => api.stickersRemove(favoriteId: 'favorite-2')).thenAnswer(
      (_) async =>
          _removeResponse(items: [_favoriteDto(id: 'favorite-1')], version: 5),
    );
    final repository = ApiStickerRepository(api);

    final reordered = await repository.reorder(
      version: 3,
      favoriteIds: const ['favorite-2', 'favorite-1'],
    );
    final removed = await repository.remove('favorite-2');

    final payload =
        verify(
              () => api.stickersReorder(
                reorderStickersDto: captureAny(named: 'reorderStickersDto'),
              ),
            ).captured.single
            as ReorderStickersDto;
    expect(payload.version, 3);
    expect(payload.favoriteIds.toList(), ['favorite-2', 'favorite-1']);
    expect(reordered.version, 4);
    expect(removed.version, 5);
    expect(removed.items.single.id, 'favorite-1');
  });

  test('不安全 URL、异常顺序和未知状态均拒绝展示', () async {
    final api = _MockStickersApi();
    when(api.stickersGetCollection).thenAnswer(
      (_) async => _collectionResponse(items: [_favoriteDto(position: 1)]),
    );
    final repository = ApiStickerRepository(api);

    await expectLater(repository.fetchCollection(), throwsA(isA<ApiFailure>()));

    when(api.stickersGetCollection).thenAnswer(
      (_) async => _collectionResponse(
        items: [_favoriteDto(assetUrl: 'file:///private/sticker.webp')],
      ),
    );
    await expectLater(repository.fetchCollection(), throwsA(isA<ApiFailure>()));

    when(() => api.stickersGetImport(id: 'import-1')).thenAnswer(
      (_) async => _getImportResponse(
        _importDto(
          status: StickerImportResponseDtoStatusEnum.unknownDefaultOpenApi,
        ),
      ),
    );
    await expectLater(
      repository.fetchImport('import-1'),
      throwsA(isA<ApiFailure>()),
    );
  });
}

class _MockStickersApi extends Mock implements StickersApi {}

StickerAssetResponseDto _assetDto({
  String id = 'asset-1',
  String url = 'https://cdn.example.com/sticker.webp',
}) {
  return StickerAssetResponseDto(
    (builder) => builder
      ..id = id
      ..url = url
      ..thumbnailUrl = 'https://cdn.example.com/sticker-thumb.webp'
      ..width = 128
      ..height = 96
      ..animated = false
      ..frameCount = 1
      ..durationMs = 0,
  );
}

UserStickerResponseDto _favoriteDto({
  String id = 'favorite-1',
  int position = 0,
  String assetUrl = 'https://cdn.example.com/sticker.webp',
}) {
  return UserStickerResponseDto(
    (builder) => builder
      ..id = id
      ..position = position
      ..asset.replace(_assetDto(id: 'asset-$id', url: assetUrl))
      ..markdown = '![表情]($assetUrl "wenyousite-sticker:v1:asset-$id")',
  );
}

StickerImportResponseDto _importDto({
  StickerImportResponseDtoStatusEnum status =
      StickerImportResponseDtoStatusEnum.PROCESSING,
}) {
  return StickerImportResponseDto(
    (builder) => builder
      ..id = 'import-1'
      ..status = status
      ..alreadySaved = false,
  );
}

StickerImportResponseDto _completedImportDto() {
  return StickerImportResponseDto(
    (builder) => builder
      ..id = 'import-1'
      ..status = StickerImportResponseDtoStatusEnum.COMPLETED
      ..favorite.replace(_favoriteDto())
      ..alreadySaved = false,
  );
}

Response<StickersGetCollection200Response> _collectionResponse({
  List<UserStickerResponseDto> items = const [],
  List<UserStickerResponseDto> recent = const [],
  List<StickerImportResponseDto> pending = const [],
  int version = 3,
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/stickers'),
    data: StickersGetCollection200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..version = version
            ..limit = 200
            ..items.replace(items)
            ..recent.replace(recent)
            ..pendingImports.replace(pending),
        ),
    ),
  );
}

Response<StickersGetImport200Response> _getImportResponse(
  StickerImportResponseDto value,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/stickers/imports/import-1'),
    data: StickersGetImport200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(value),
    ),
  );
}

Response<StickersImportMedia201Response> _mediaImportResponse() => Response(
  requestOptions: RequestOptions(path: '/api/v1/stickers/imports/media'),
  data: StickersImportMedia201Response(
    (builder) => builder
      ..code = ApiSuccessEnvelopeCodeEnum.number0
      ..message = 'ok'
      ..data.replace(_completedImportDto()),
  ),
);

Response<StickersImportDirectMessage201Response> _directImportResponse() =>
    Response(
      requestOptions: RequestOptions(
        path: '/api/v1/stickers/imports/direct-message',
      ),
      data: StickersImportDirectMessage201Response(
        (builder) => builder
          ..code = ApiSuccessEnvelopeCodeEnum.number0
          ..message = 'ok'
          ..data.replace(_completedImportDto()),
      ),
    );

Response<StickersImportPostImage201Response> _postImportResponse() => Response(
  requestOptions: RequestOptions(path: '/api/v1/stickers/imports/post-image'),
  data: StickersImportPostImage201Response(
    (builder) => builder
      ..code = ApiSuccessEnvelopeCodeEnum.number0
      ..message = 'ok'
      ..data.replace(_completedImportDto()),
  ),
);

Response<StickersReorder200Response> _reorderResponse({
  required List<UserStickerResponseDto> items,
  required int version,
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/stickers/reorder'),
    data: StickersReorder200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..version = version
            ..limit = 200
            ..items.replace(items)
            ..recent.clear()
            ..pendingImports.clear(),
        ),
    ),
  );
}

Response<StickersRemove200Response> _removeResponse({
  required List<UserStickerResponseDto> items,
  required int version,
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/stickers/favorite-2'),
    data: StickersRemove200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..version = version
            ..limit = 200
            ..items.replace(items)
            ..recent.clear()
            ..pendingImports.clear(),
        ),
    ),
  );
}
