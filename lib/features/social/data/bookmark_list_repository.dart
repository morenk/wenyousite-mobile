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
    String? folderId,
    int limit = 20,
  });

  Future<List<BookmarkFolderItem>> fetchFolders();

  Future<BookmarkFolderItem> createFolder(String name);

  Future<void> move(String bookmarkId, String folderId);

  Future<void> remove(String bookmarkId);
}

class ApiBookmarkListRepository implements BookmarkListRepository {
  ApiBookmarkListRepository(this._api);

  final BookmarksApi _api;

  @override
  Future<CursorPage<BookmarkListItem>> fetchPage({
    String? cursor,
    String? folderId,
    int limit = 20,
  }) async {
    try {
      final envelope = (await _api.bookmarksFindAll(
        cursor: cursor,
        folderId: folderId,
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
  Future<List<BookmarkFolderItem>> fetchFolders() async {
    try {
      final envelope = (await _api.bookmarksFindFolders()).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '收藏夹分类响应为空，请稍后重试。');
      }
      return envelope.data.map(_mapFolder).toList(growable: false);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<BookmarkFolderItem> createFolder(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || trimmedName.length > 24) {
      throw const ApiFailure(userMessage: '收藏夹名称需为 1–24 个字符。');
    }
    try {
      final envelope = (await _api.bookmarksCreateFolder(
        createBookmarkFolderDto: CreateBookmarkFolderDto(
          (builder) => builder.name = trimmedName,
        ),
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '新建收藏夹结果不完整，请重新加载确认。');
      }
      return _mapFolder(envelope.data);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(
        error,
        featureMessages: const {40900: '已有同名收藏夹，请换一个名称。'},
      );
    }
  }

  @override
  Future<void> move(String bookmarkId, String folderId) async {
    try {
      final envelope = (await _api.bookmarksMove(
        id: bookmarkId,
        moveBookmarkDto: MoveBookmarkDto(
          (builder) => builder.folderId = folderId,
        ),
      )).data;
      if (envelope == null ||
          envelope.data.id != bookmarkId ||
          envelope.data.folderId != folderId) {
        throw const ApiFailure(userMessage: '移动收藏结果不完整，请重新加载确认。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(
        error,
        featureMessages: const {40400: '收藏或目标收藏夹已不存在，请刷新后重试。'},
      );
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
    final folderId = dto.bookmarkFolderId?.trim();
    return BookmarkListItem(
      bookmarkId: bookmarkId,
      folderId: folderId == null || folderId.isEmpty ? null : folderId,
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

  BookmarkFolderItem _mapFolder(BookmarkFolderResponseDto dto) {
    final id = dto.id.trim();
    final name = dto.name.trim();
    if (id.isEmpty || name.isEmpty) {
      throw const ApiFailure(userMessage: '收藏夹分类信息不完整，请稍后重试。');
    }
    return BookmarkFolderItem(
      id: id,
      name: name,
      isDefault: dto.isDefault,
      bookmarkCount: dto.bookmarkCount.toInt(),
      createdAt: dto.createdAt,
    );
  }
}

final bookmarkListRepositoryProvider = Provider<BookmarkListRepository>((ref) {
  return ApiBookmarkListRepository(
    ref.watch(wenyouApiProvider).getBookmarksApi(),
  );
});
