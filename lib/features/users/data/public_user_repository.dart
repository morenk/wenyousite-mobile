import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart';
import 'package:wenyousite_mobile/features/users/data/profile_cover_mapper.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';

export 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart'
    show PublicUserRepository, publicUserRepositoryProvider;

class ApiPublicUserRepository implements PublicUserRepository {
  ApiPublicUserRepository(this._api);

  final UsersApi _api;

  @override
  Future<PublicUserProfileModel> fetchUser(String userId) async {
    try {
      final response = await _api.usersGetUser(id: userId);
      final dto = response.data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '用户资料返回不完整，请稍后重试。');
      }
      final bio = dto.bio?.trim();
      return PublicUserProfileModel(
        id: dto.id,
        username: dto.username,
        avatarUrl: _safeHttpUrl(dto.avatar),
        bio: bio == null || bio.isEmpty ? null : bio,
        profileCover: mapProfileCover(dto.profileCover),
        level: dto.level?.toInt() ?? 0,
        followingCount: dto.count?.following.toInt() ?? 0,
        followerCount: dto.count?.followers.toInt() ?? 0,
        receivedTipTotal: dto.receivedTipTotal ?? '0',
        receivedTipCount: dto.receivedTipCount?.toInt() ?? 0,
        showRecentReplies: dto.showRecentReplies ?? false,
        showPlayedThreads: dto.showPlayerBadges ?? false,
        showBookmarks: dto.showBookmarks ?? false,
        isFollowing: dto.isFollowing ?? false,
        isFollowedBy: dto.isFollowedBy ?? false,
        isBlocked: dto.isBlocked ?? false,
        isBlockedBy: dto.isBlockedBy ?? false,
        isDeactivated: dto.isDeactivated ?? false,
        createdAt: dto.createdAt,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<PublicUserActivitySummary> fetchActivitySummary(String userId) async {
    try {
      final response = await _api.usersGetUserActivitySummary(id: userId);
      final dto = response.data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '创作活动汇总返回不完整，请稍后重试。');
      }
      return PublicUserActivitySummary(
        momentCount: _nonNegativeCount(dto.momentCount, '动态数'),
        createdThreadCount: _nonNegativeCount(dto.createdThreadCount, '创建主题数'),
        playedThreadCount: dto.playedThreadCount == null
            ? null
            : _nonNegativeCount(dto.playedThreadCount!, '参与主题数'),
        replyCount: dto.replyCount == null
            ? null
            : _nonNegativeCount(dto.replyCount!, '回复数'),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchCreatedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async {
    try {
      final response = await _api.usersGetUserCreatedThreads(
        id: userId,
        cursor: cursor,
        limit: limit,
      );
      final envelope = response.data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '创建主题列表返回不完整，请稍后重试。');
      }
      return CursorPage(
        items: envelope.data.map(_mapThread).toList(growable: false),
        cursor: envelope.meta.cursor,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchPlayedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async {
    try {
      final response = await _api.usersGetUserPlayedThreads(
        id: userId,
        cursor: cursor,
        limit: limit,
      );
      final envelope = response.data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '参与主题列表返回不完整，请稍后重试。');
      }
      return CursorPage(
        items: envelope.data.map(_mapThread).toList(growable: false),
        cursor: envelope.meta.cursor,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<List<PublicUserReplyModel>> fetchRecentReplies(String userId) async {
    try {
      final response = await _api.usersGetUserRecentReplies(id: userId);
      final data = response.data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '最近回复返回不完整，请稍后重试。');
      }
      return List.unmodifiable(data.map(_mapReply));
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchBookmarks(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async {
    try {
      final response = await _api.usersGetUserBookmarks(
        id: userId,
        cursor: cursor,
        limit: limit,
      );
      final envelope = response.data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '收藏列表返回不完整，请稍后重试。');
      }
      return CursorPage(
        items: envelope.data.map(_mapBookmark).toList(growable: false),
        cursor: envelope.meta.cursor,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  PublicUserThreadModel _mapThread(ThreadListItemResponseDto dto) {
    return PublicUserThreadModel(
      id: dto.id,
      title: _safeTitle(dto.title),
      categorySlug: dto.category,
      status: _mapThreadStatus(dto.status),
      isPrivate:
          dto.visibility == ThreadListItemResponseDtoVisibilityEnum.PRIVATE,
      ownerName: dto.owner.username,
      ownerLevel: dto.owner.level.toInt(),
      createdAt: dto.createdAt,
      memberCount: dto.count.members.toInt(),
      postCount: dto.count.posts.toInt(),
    );
  }

  PublicUserThreadModel _mapBookmark(BookmarkThreadResponseDto dto) {
    return PublicUserThreadModel(
      id: dto.id,
      title: _safeTitle(dto.title),
      categorySlug: dto.category,
      status: _mapBookmarkStatus(dto.status),
      isPrivate:
          dto.visibility == BookmarkThreadResponseDtoVisibilityEnum.PRIVATE,
      ownerName: dto.owner.username,
      ownerLevel: dto.owner.level.toInt(),
      createdAt: dto.createdAt,
      memberCount: dto.count.members.toInt(),
      postCount: dto.count.posts.toInt(),
    );
  }

  PublicUserReplyModel _mapReply(RecentReplyResponseDto dto) {
    final source = dto.preview.trim().isEmpty ? dto.content : dto.preview;
    return PublicUserReplyModel(
      id: dto.id,
      threadId: dto.threadId,
      threadTitle: dto.thread.title,
      subthreadId: dto.subthreadId,
      subthreadTitle: dto.subthread.title,
      preview: MarkdownContent.toPlainTextPreview(source),
      createdAt: dto.createdAt,
      floorNumber: dto.floorNumber?.toInt(),
      parentPostId: dto.parentPostId,
    );
  }

  PublicUserThreadStatus _mapThreadStatus(
    ThreadListItemResponseDtoStatusEnum status,
  ) {
    if (status == ThreadListItemResponseDtoStatusEnum.RECRUITING) {
      return PublicUserThreadStatus.recruiting;
    }
    if (status == ThreadListItemResponseDtoStatusEnum.CLOSED) {
      return PublicUserThreadStatus.closed;
    }
    if (status == ThreadListItemResponseDtoStatusEnum.FINISHED) {
      return PublicUserThreadStatus.finished;
    }
    return PublicUserThreadStatus.unknown;
  }

  PublicUserThreadStatus _mapBookmarkStatus(
    BookmarkThreadResponseDtoStatusEnum status,
  ) {
    if (status == BookmarkThreadResponseDtoStatusEnum.RECRUITING) {
      return PublicUserThreadStatus.recruiting;
    }
    if (status == BookmarkThreadResponseDtoStatusEnum.CLOSED) {
      return PublicUserThreadStatus.closed;
    }
    if (status == BookmarkThreadResponseDtoStatusEnum.FINISHED) {
      return PublicUserThreadStatus.finished;
    }
    return PublicUserThreadStatus.unknown;
  }

  String _safeTitle(String title) {
    final trimmed = title.trim();
    return trimmed.isEmpty ? '未命名主题' : trimmed;
  }

  int _nonNegativeCount(num value, String field) {
    if (!value.isFinite || value < 0 || value % 1 != 0) {
      throw ApiFailure(userMessage: '$field返回不正确，请稍后重试。');
    }
    return value.toInt();
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

final apiPublicUserRepositoryProvider = Provider<PublicUserRepository>((ref) {
  return ApiPublicUserRepository(ref.watch(wenyouApiProvider).getUsersApi());
});
