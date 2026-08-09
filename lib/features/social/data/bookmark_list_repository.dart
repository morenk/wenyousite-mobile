import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';

abstract interface class BookmarkListRepository {
  Future<CursorPage<BookmarkListItem>> fetchPage({
    String? cursor,
    int limit = 20,
  });

  Future<void> remove(String bookmarkId);
}

class ApiBookmarkListRepository implements BookmarkListRepository {
  ApiBookmarkListRepository(this._api);

  final BookmarksApi _api;

  @override
  Future<CursorPage<BookmarkListItem>> fetchPage({
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final envelope = (await _api.bookmarksFindAll(
        cursor: cursor,
        limit: limit,
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '收藏列表响应为空，请稍后重试。');
      }
      return CursorPage(
        items: envelope.data.map(_mapItem).toList(growable: false),
        cursor: envelope.meta.cursor,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> remove(String bookmarkId) async {
    try {
      final data = (await _api.bookmarksRemove(id: bookmarkId)).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '取消收藏结果不完整，请重新加载确认。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  BookmarkListItem _mapItem(OwnBookmarkThreadResponseDto dto) {
    final bookmarkId = dto.bookmarkId?.trim();
    if (bookmarkId == null || bookmarkId.isEmpty) {
      throw const ApiFailure(userMessage: '收藏记录缺少管理 ID，请稍后重试。');
    }
    final title = dto.title.trim();
    return BookmarkListItem(
      bookmarkId: bookmarkId,
      threadId: dto.id,
      title: title.isEmpty ? '未命名主题' : title,
      categorySlug: dto.category,
      status: switch (dto.status) {
        OwnBookmarkThreadResponseDtoStatusEnum.RECRUITING =>
          BookmarkedThreadStatus.recruiting,
        OwnBookmarkThreadResponseDtoStatusEnum.CLOSED =>
          BookmarkedThreadStatus.closed,
        OwnBookmarkThreadResponseDtoStatusEnum.FINISHED =>
          BookmarkedThreadStatus.finished,
        _ => BookmarkedThreadStatus.unknown,
      },
      isPrivate:
          dto.visibility == OwnBookmarkThreadResponseDtoVisibilityEnum.PRIVATE,
      isPinned: dto.pinned,
      ownerName: dto.owner.username,
      ownerLevel: dto.owner.level.toInt(),
      createdAt: dto.createdAt,
      memberCount: dto.count.members.toInt(),
      postCount: dto.count.posts.toInt(),
      tipTotal: dto.tipTotal,
    );
  }
}

final bookmarkListRepositoryProvider = Provider<BookmarkListRepository>((ref) {
  return ApiBookmarkListRepository(
    ref.watch(wenyouApiProvider).getBookmarksApi(),
  );
});
