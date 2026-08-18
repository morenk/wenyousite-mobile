import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/models/thread_feed_models.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/social/application/bookmark_list_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';

export 'package:wenyousite_mobile/features/social/application/bookmark_list_repository_ports.dart'
    show BookmarkListRepository, bookmarkListRepositoryProvider;

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
        throw const ApiFailure(userMessage: '收藏列表加载失败，请稍后重试。');
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
        throw const ApiFailure(userMessage: '收藏夹加载失败，请稍后重试。');
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
        throw const ApiFailure(userMessage: '新建收藏夹失败，请重试。');
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
        throw const ApiFailure(userMessage: '移动收藏失败，请重试。');
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
        throw const ApiFailure(userMessage: '取消收藏失败，请重试。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  BookmarkListItem _mapItem(OwnBookmarkThreadResponseDto dto) {
    final bookmarkId = dto.bookmarkId.trim();
    if (bookmarkId.isEmpty) {
      throw const ApiFailure(userMessage: '收藏记录缺少管理 ID，请稍后重试。');
    }
    final title = dto.title.trim();
    final folderId = dto.bookmarkFolderId.trim();
    return BookmarkListItem(
      bookmarkId: bookmarkId,
      folderId: folderId.isEmpty ? null : folderId,
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
      isPublished: dto.published,
      ownerId: dto.owner.id,
      ownerName: dto.owner.username,
      ownerAvatarUrl: _safeHttpUrl(dto.owner.avatar),
      ownerLevel: dto.owner.level.toInt(),
      createdAt: dto.createdAt,
      lastActivityAt: dto.defaultSubthread?.lastPostAt ?? dto.updatedAt,
      preview: _optionalText(dto.preview),
      tags: dto.topicTags
          .map(
            (relation) =>
                HomeThreadTag(id: relation.tag.id, name: relation.tag.name),
          )
          .toList(growable: false),
      coverImageUrls: dto.coverImages
          .map(_safeHttpUrl)
          .whereType<String>()
          .take(1)
          .toList(growable: false),
      memberCount: dto.count.members.toInt(),
      playerCount: dto.count.players.toInt(),
      postCount: dto.count.posts.toInt(),
      tipTotal: dto.tipTotal,
    );
  }

  BookmarkFolderItem _mapFolder(BookmarkFolderResponseDto dto) {
    final id = dto.id.trim();
    final name = dto.name.trim();
    if (id.isEmpty || name.isEmpty) {
      throw const ApiFailure(userMessage: '收藏夹分类加载失败，请稍后重试。');
    }
    return BookmarkFolderItem(
      id: id,
      name: name,
      isDefault: dto.isDefault,
      bookmarkCount: dto.bookmarkCount.toInt(),
      momentBookmarkCount: dto.momentBookmarkCount.toInt(),
      createdAt: dto.createdAt,
    );
  }

  String? _optionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _safeHttpUrl(String? value) {
    if (value == null) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      return null;
    }
    return value;
  }
}

final apiBookmarkListRepositoryProvider = Provider<BookmarkListRepository>((
  ref,
) {
  return ApiBookmarkListRepository(
    ref.watch(wenyouApiProvider).getBookmarksApi(),
  );
});
