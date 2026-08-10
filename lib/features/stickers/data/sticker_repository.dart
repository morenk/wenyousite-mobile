import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

abstract interface class StickerRepository {
  Future<StickerCollection> fetchCollection();

  Future<StickerImport> fetchImport(String id);

  Future<StickerImport> importSource(
    StickerImportSource source, {
    required String clientRequestId,
  });

  Future<StickerCollection> reorder({
    required int version,
    required List<String> favoriteIds,
  });

  Future<StickerCollection> remove(String favoriteId);
}

class ApiStickerRepository implements StickerRepository {
  ApiStickerRepository(this._api);

  final StickersApi _api;

  @override
  Future<StickerCollection> fetchCollection() async {
    try {
      final dto = (await _api.stickersGetCollection()).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '表情收藏响应为空，请稍后重试。');
      }
      return _collection(dto);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<StickerImport> fetchImport(String id) async {
    final importId = _requiredText(id, '导入记录 ID');
    try {
      final dto = (await _api.stickersGetImport(id: importId)).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '表情处理状态响应为空，请稍后重试。');
      }
      final result = _import(dto);
      if (result.id != importId) {
        throw const ApiFailure(userMessage: '表情处理状态与当前任务不匹配，请重新加载。');
      }
      return result;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<StickerImport> importSource(
    StickerImportSource source, {
    required String clientRequestId,
  }) async {
    final requestId = _requiredText(clientRequestId, '导入请求 ID');
    try {
      final StickerImportResponseDto? dto;
      switch (source) {
        case StickerMediaSource(:final mediaId):
          dto = (await _api.stickersImportMedia(
            importStickerMediaDto: ImportStickerMediaDto(
              (builder) => builder
                ..mediaId = _requiredText(mediaId, '媒体 ID')
                ..clientRequestId = requestId,
            ),
          )).data?.data;
        case StickerDirectMessageSource(:final directMessageId):
          dto = (await _api.stickersImportDirectMessage(
            importStickerDirectMessageDto: ImportStickerDirectMessageDto(
              (builder) => builder
                ..directMessageId = _requiredText(directMessageId, '私聊消息 ID')
                ..clientRequestId = requestId,
            ),
          )).data?.data;
        case StickerPostImageSource(:final postId, :final imageUrl):
          final uri = _safeHttpUri(imageUrl, '帖子图片地址');
          dto = (await _api.stickersImportPostImage(
            importStickerPostImageDto: ImportStickerPostImageDto(
              (builder) => builder
                ..postId = _requiredText(postId, '帖子 ID')
                ..imageUrl = uri.toString()
                ..clientRequestId = requestId,
            ),
          )).data?.data;
      }
      if (dto == null) {
        throw const ApiFailure(userMessage: '服务端没有确认表情导入，请使用原请求重试。');
      }
      return _import(dto);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<StickerCollection> reorder({
    required int version,
    required List<String> favoriteIds,
  }) async {
    if (version < 1) {
      throw const ApiFailure(userMessage: '收藏夹版本无效，请重新加载。');
    }
    final ids = favoriteIds
        .map((id) => _requiredText(id, '收藏表情 ID'))
        .toList(growable: false);
    if (ids.toSet().length != ids.length) {
      throw const ApiFailure(userMessage: '表情排序包含重复项目，请重新加载。');
    }
    try {
      final dto = (await _api.stickersReorder(
        reorderStickersDto: ReorderStickersDto(
          (builder) => builder
            ..version = version
            ..favoriteIds.replace(ids),
        ),
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '表情排序响应为空，请重新加载。');
      }
      return _collection(dto);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<StickerCollection> remove(String favoriteId) async {
    final id = _requiredText(favoriteId, '收藏表情 ID');
    try {
      final dto = (await _api.stickersRemove(favoriteId: id)).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '移除表情响应为空，请重新加载。');
      }
      return _collection(dto);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  StickerCollection _collection(StickerCollectionResponseDto dto) {
    final version = _positiveInteger(dto.version, '收藏夹版本');
    final limit = _positiveInteger(dto.limit, '收藏夹上限');
    final items = dto.items.map(_favorite).toList(growable: false);
    if (items.length > limit) {
      throw const ApiFailure(userMessage: '表情收藏数量超过服务端声明上限，请重新加载。');
    }
    final ids = <String>{};
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      if (!ids.add(item.id) || item.position != index) {
        throw const ApiFailure(userMessage: '表情收藏顺序异常，请重新加载。');
      }
    }
    final recent = dto.recent.map(_favorite).toList(growable: false);
    if (recent.any((item) => !ids.contains(item.id)) ||
        recent.map((item) => item.id).toSet().length != recent.length) {
      throw const ApiFailure(userMessage: '最近使用表情与收藏夹不一致，请重新加载。');
    }
    final pending = dto.pendingImports.map(_import).toList(growable: false);
    if (pending.any((item) => item.status != StickerImportStatus.processing) ||
        pending.map((item) => item.id).toSet().length != pending.length ||
        items.length + pending.length > limit) {
      throw const ApiFailure(userMessage: '表情处理任务状态异常，请重新加载。');
    }
    return StickerCollection(
      version: version,
      limit: limit,
      items: List.unmodifiable(items),
      recent: List.unmodifiable(recent),
      pendingImports: List.unmodifiable(pending),
    );
  }

  UserSticker _favorite(UserStickerResponseDto dto) {
    final asset = dto.asset;
    return UserSticker(
      id: _requiredText(dto.id, '收藏表情 ID'),
      position: _nonNegativeInteger(dto.position, '表情位置'),
      lastUsedAt: dto.lastUsedAt,
      asset: StickerAsset(
        id: _requiredText(asset.id, '表情资产 ID'),
        url: _safeHttpUri(asset.url, '表情地址').toString(),
        thumbnailUrl: _safeHttpUri(asset.thumbnailUrl, '表情缩略图地址').toString(),
        width: _positiveInteger(asset.width, '表情宽度'),
        height: _positiveInteger(asset.height, '表情高度'),
        animated: asset.animated,
        frameCount: _positiveInteger(asset.frameCount, '表情帧数'),
        durationMs: _nonNegativeInteger(asset.durationMs, '表情时长'),
      ),
      markdown: _requiredText(dto.markdown, '表情 Markdown'),
    );
  }

  StickerImport _import(StickerImportResponseDto dto) {
    final status = switch (dto.status) {
      StickerImportResponseDtoStatusEnum.PROCESSING =>
        StickerImportStatus.processing,
      StickerImportResponseDtoStatusEnum.COMPLETED =>
        StickerImportStatus.completed,
      StickerImportResponseDtoStatusEnum.FAILED => StickerImportStatus.failed,
      _ => throw const ApiFailure(userMessage: '当前版本不支持服务端返回的表情处理状态。'),
    };
    final favorite = dto.favorite == null ? null : _favorite(dto.favorite!);
    if ((status == StickerImportStatus.completed && favorite == null) ||
        (status != StickerImportStatus.completed && favorite != null)) {
      throw const ApiFailure(userMessage: '表情处理结果不完整，请重新加载。');
    }
    return StickerImport(
      id: _requiredText(dto.id, '导入记录 ID'),
      status: status,
      favorite: favorite,
      failureCode: _optionalText(dto.failureCode),
      alreadySaved: dto.alreadySaved,
    );
  }

  String _requiredText(String value, String label) {
    final normalized = value.trim();
    if (normalized.isEmpty) throw ApiFailure(userMessage: '$label不能为空。');
    return normalized;
  }

  String? _optionalText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  Uri _safeHttpUri(String value, String label) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw ApiFailure(userMessage: '$label不安全，请重新加载。');
    }
    return uri;
  }

  int _positiveInteger(num value, String label) {
    final integer = value.toInt();
    if (!value.isFinite || integer != value || integer < 1) {
      throw ApiFailure(userMessage: '$label无效，请重新加载。');
    }
    return integer;
  }

  int _nonNegativeInteger(num value, String label) {
    final integer = value.toInt();
    if (!value.isFinite || integer != value || integer < 0) {
      throw ApiFailure(userMessage: '$label无效，请重新加载。');
    }
    return integer;
  }
}

final stickerRepositoryProvider = Provider<StickerRepository>((ref) {
  return ApiStickerRepository(ref.watch(wenyouApiProvider).getStickersApi());
});
