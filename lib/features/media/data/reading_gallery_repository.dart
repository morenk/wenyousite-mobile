import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/media_display_mapper.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/media/domain/reading_image_gallery.dart';

final apiReadingGalleryRepositoryProvider = Provider<ReadingGalleryRepository>(
  (ref) => ApiReadingGalleryRepository(
    ref.watch(wenyouApiProvider).getImageGalleryApi(),
  ),
);

class ApiReadingGalleryRepository implements ReadingGalleryRepository {
  ApiReadingGalleryRepository(this._api);
  final ImageGalleryApi _api;

  @override
  ReadingGalleryOperation load(
    ReadingGalleryRequest request, {
    String? cursor,
  }) {
    final token = CancelToken();
    return _Operation(token, _load(request, cursor, token));
  }

  Future<ReadingGalleryPage> _load(
    ReadingGalleryRequest request,
    String? cursor,
    CancelToken token,
  ) async {
    try {
      final dto = (await _api.galleryList(
        scope: switch (request.scope) {
          ReadingGalleryScope.subthread => 'SUBTHREAD',
          ReadingGalleryScope.postReplies => 'POST_REPLIES',
          ReadingGalleryScope.moment => 'MOMENT',
          ReadingGalleryScope.momentComments => 'MOMENT_COMMENTS',
          ReadingGalleryScope.momentReplies => 'MOMENT_REPLIES',
        },
        scopeId: request.scopeId,
        anchorId: cursor == null ? request.anchorId : null,
        anchorIndex: cursor == null ? request.anchorIndex : null,
        anchorVersion: cursor == null ? request.anchorVersion : null,
        order: request.order == ReadingGalleryOrder.oldest
            ? 'OLDEST'
            : 'NEWEST',
        authorId: request.authorId,
        cursor: cursor,
        limit: 20,
        cancelToken: token,
      )).data?.data;
      if (dto == null ||
          dto.previousCursor == '' ||
          dto.nextCursor == '' ||
          (cursor == null &&
              (dto.anchorItemId == null || dto.anchorItemId!.isEmpty))) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'gallery_page_invalid',
        );
      }
      final ids = <String>{};
      final items = [for (final item in dto.items) _map(item, request.scope)];
      if (items.any((image) => !ids.add(image.id))) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'gallery_duplicate_identity',
        );
      }
      return ReadingGalleryPage(
        items: List.unmodifiable(items),
        previousCursor: dto.previousCursor,
        nextCursor: dto.nextCursor,
        anchorItemId: dto.anchorItemId,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  ReadingGalleryImage _map(GalleryImageDto dto, ReadingGalleryScope scope) {
    final uri = Uri.tryParse(dto.url);
    bool positiveInteger(num value, {int minimum = 1}) =>
        value.isFinite && value >= minimum && value == value.toInt();
    final post =
        scope == ReadingGalleryScope.subthread ||
        scope == ReadingGalleryScope.postReplies;
    if (dto.id.isEmpty ||
        dto.sourceId.isEmpty ||
        !positiveInteger(dto.sourceVersion) ||
        !positiveInteger(dto.imageIndex, minimum: 0) ||
        !positiveInteger(dto.imageCount) ||
        dto.imageIndex >= dto.imageCount ||
        uri == null ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.host == 'local.invalid' ||
        (post && (dto.threadId == null || dto.subthreadId == null)) ||
        (!post && (dto.momentId == null || dto.mediaId == null)) ||
        (scope == ReadingGalleryScope.postReplies &&
            dto.parentPostId == null) ||
        (scope == ReadingGalleryScope.momentReplies &&
            dto.parentCommentId == null)) {
      throw const ApiFailure.invalidResponse(
        diagnosticCode: 'gallery_image_invalid',
      );
    }
    return ReadingGalleryImage(
      id: dto.id,
      sourceId: dto.sourceId,
      sourceVersion: dto.sourceVersion.toInt(),
      imageIndex: dto.imageIndex.toInt(),
      imageCount: dto.imageCount.toInt(),
      url: uri.toString(),
      display: mapMediaDisplay(dto.display),
      mediaId: dto.mediaId,
      width: dto.width?.toInt(),
      height: dto.height?.toInt(),
      animated: dto.animated,
      threadId: dto.threadId,
      subthreadId: dto.subthreadId,
      parentPostId: dto.parentPostId,
      momentId: dto.momentId,
      parentCommentId: dto.parentCommentId,
      floorNumber: dto.floorNumber?.toInt(),
    );
  }
}

class _Operation implements ReadingGalleryOperation {
  _Operation(this.token, this.result);
  final CancelToken token;
  @override
  final Future<ReadingGalleryPage> result;
  @override
  void cancel() => token.cancel();
}
