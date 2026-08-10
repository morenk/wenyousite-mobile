import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

abstract interface class ThreadDetailRepository {
  Future<ThreadDetailModel> fetchThread(String threadId);

  Future<ThreadPostTargetModel> fetchPostTarget(String postId);

  Future<CursorPage<ThreadFloorModel>> fetchFloors({
    required String subthreadId,
    String? cursor,
    int limit = 20,
  });
}

class ApiThreadDetailRepository implements ThreadDetailRepository {
  ApiThreadDetailRepository(this._threadsApi, this._postsApi);

  final ThreadsApi _threadsApi;
  final PostsApi _postsApi;

  @override
  Future<ThreadDetailModel> fetchThread(String threadId) async {
    try {
      final response = await _threadsApi.threadsFindById(id: threadId);
      final dto = response.data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '主题详情返回不完整，请稍后重试。');
      }
      return _mapThread(dto);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<ThreadPostTargetModel> fetchPostTarget(String postId) async {
    try {
      final targetResponse = await _postsApi.postsFindById(id: postId);
      final target = targetResponse.data?.data;
      if (target == null) {
        throw const ApiFailure(userMessage: '目标楼层返回不完整，请稍后重试。');
      }
      if (target.parentPostId == null) {
        return ThreadPostTargetModel(
          requestedPostId: target.id,
          threadId: target.threadId,
          subthreadId: target.subthreadId,
          floor: _mapPostDetailFloor(target),
        );
      }
      final parentResponse = await _postsApi.postsFindById(
        id: target.parentPostId!,
      );
      final parent = parentResponse.data?.data;
      if (parent == null) {
        throw const ApiFailure(userMessage: '目标楼层上下文返回不完整，请稍后重试。');
      }
      if (parent.threadId != target.threadId ||
          parent.subthreadId != target.subthreadId ||
          parent.parentPostId != null) {
        throw const ApiFailure(userMessage: '目标楼层上下文不一致，请返回搜索后重试。');
      }
      return ThreadPostTargetModel(
        requestedPostId: target.id,
        threadId: target.threadId,
        subthreadId: target.subthreadId,
        floor: _mapPostDetailFloor(
          parent,
          focusedReply: _mapPostDetailReply(target),
        ),
        focusedReplyId: target.id,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<CursorPage<ThreadFloorModel>> fetchFloors({
    required String subthreadId,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _postsApi.postsFindFloors(
        subthreadId: subthreadId,
        cursor: cursor,
        limit: limit,
      );
      final envelope = response.data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '楼层列表返回不完整，请稍后重试。');
      }
      return CursorPage(
        items: envelope.data.map(_mapFloor).toList(growable: false),
        cursor: envelope.meta.cursor,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  ThreadDetailModel _mapThread(ThreadDetailResponseDto dto) {
    final canManageThread =
        dto.capabilities?.canManageThread ??
        (dto.currentMembership?.role ==
                CurrentThreadMembershipResponseDtoRoleEnum.OWNER ||
            dto.currentMembership?.role ==
                CurrentThreadMembershipResponseDtoRoleEnum.COLLABORATOR);
    final subthreads =
        dto.subthreads
            .where((item) => item.deletedAt == null)
            .map(
              (item) => ThreadSubthreadModel(
                id: item.id,
                title: item.title,
                sortOrder: item.sortOrder.toInt(),
                postCount: item.count.posts.toInt(),
                postingPolicyLabel: _postingPolicyLabel(item.postingPolicy),
                lastPostAt: item.lastPostAt,
                body: item.bodyPost == null
                    ? null
                    : ThreadBodyModel(
                        markdown: item.bodyPost!.content,
                        postId: item.bodyPost!.id,
                        version: item.bodyPost!.version.toInt(),
                        diceRolls: item.bodyPost!.diceRolls
                            .map(_mapDiceRoll)
                            .toList(growable: false),
                      ),
              ),
            )
            .toList()
          ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    return ThreadDetailModel(
      id: dto.id,
      title: dto.title?.trim().isNotEmpty == true ? dto.title!.trim() : '未命名主题',
      owner: _mapAuthor(dto.owner),
      categorySlug: dto.category,
      status: _mapStatus(dto.status),
      isPrivate: dto.visibility != ThreadDetailResponseDtoVisibilityEnum.PUBLIC,
      isPinned: dto.pinned,
      viewCount: dto.viewCount.toInt(),
      likeCount: dto.likeCount.toInt(),
      isLiked: dto.isLiked ?? false,
      isBookmarked: dto.isBookmarked ?? false,
      bookmarkId: dto.bookmarkId,
      hasAutomaticUpdates: canManageThread,
      canManageThread: canManageThread,
      currentUserId: dto.currentMembership?.userId,
      tipTotal: dto.tipTotal,
      memberCount: dto.count.members.toInt(),
      playerCount: dto.count.players.toInt(),
      postCount: dto.count.posts.toInt(),
      tags: dto.topicTags
          .map(
            (relation) =>
                ThreadTagModel(id: relation.tag.id, name: relation.tag.name),
          )
          .toList(growable: false),
      subthreads: List.unmodifiable(subthreads),
      defaultSubthreadId: dto.defaultSubthreadId,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  ThreadFloorModel _mapFloor(FloorResponseDto dto) {
    return ThreadFloorModel(
      id: dto.id,
      floorNumber: dto.floorNumber?.toInt(),
      author: _mapAuthor(dto.author),
      body: ThreadBodyModel(
        markdown: dto.content,
        diceRolls: dto.diceRolls.map(_mapDiceRoll).toList(growable: false),
      ),
      createdAt: dto.createdAt,
      isDeleted: dto.deletedAt != null,
      version: dto.version.toInt(),
      replyCount: dto.count.replies.toInt(),
      replies: dto.replies
          .map(
            (reply) => ThreadReplyModel(
              id: reply.id,
              author: _mapAuthor(reply.author),
              body: ThreadBodyModel(
                markdown: reply.content,
                diceRolls: reply.diceRolls
                    .map(_mapDiceRoll)
                    .toList(growable: false),
              ),
              createdAt: reply.createdAt,
              isDeleted: reply.deletedAt != null,
              version: reply.version.toInt(),
              replyToUsername: reply.replyToPost?.author.username,
            ),
          )
          .toList(growable: false),
    );
  }

  ThreadFloorModel _mapPostDetailFloor(
    PostDetailResponseDto dto, {
    ThreadReplyModel? focusedReply,
  }) {
    return ThreadFloorModel(
      id: dto.id,
      floorNumber: dto.floorNumber?.toInt(),
      author: _mapAuthor(dto.author),
      body: ThreadBodyModel(
        markdown: dto.content,
        diceRolls: dto.diceRolls.map(_mapDiceRoll).toList(growable: false),
      ),
      createdAt: dto.createdAt,
      isDeleted: dto.deletedAt != null,
      version: dto.version.toInt(),
      replyCount: dto.count.replies.toInt(),
      replies: focusedReply == null ? const [] : [focusedReply],
    );
  }

  ThreadReplyModel _mapPostDetailReply(PostDetailResponseDto dto) {
    return ThreadReplyModel(
      id: dto.id,
      author: _mapAuthor(dto.author),
      body: ThreadBodyModel(
        markdown: dto.content,
        diceRolls: dto.diceRolls.map(_mapDiceRoll).toList(growable: false),
      ),
      createdAt: dto.createdAt,
      isDeleted: dto.deletedAt != null,
      version: dto.version.toInt(),
      replyToUsername: null,
    );
  }

  ThreadAuthorModel _mapAuthor(PostAuthorResponseDto dto) {
    return ThreadAuthorModel(
      id: dto.id,
      username: dto.username,
      avatarUrl: _safeHttpUrl(dto.avatar),
      level: dto.level.toInt(),
    );
  }

  ThreadDiceRollModel _mapDiceRoll(DiceRollResponseDto dto) {
    return ThreadDiceRollModel(
      nodeId: dto.nodeId.toLowerCase(),
      notation: dto.notation,
      results: dto.results.map((item) => item.toInt()).toList(growable: false),
      total: dto.total.toInt(),
    );
  }

  ThreadDetailStatus _mapStatus(ThreadDetailResponseDtoStatusEnum value) {
    if (value == ThreadDetailResponseDtoStatusEnum.RECRUITING) {
      return ThreadDetailStatus.recruiting;
    }
    if (value == ThreadDetailResponseDtoStatusEnum.CLOSED) {
      return ThreadDetailStatus.closed;
    }
    if (value == ThreadDetailResponseDtoStatusEnum.FINISHED) {
      return ThreadDetailStatus.finished;
    }
    return ThreadDetailStatus.unknown;
  }

  String _postingPolicyLabel(
    ThreadSubthreadResponseDtoPostingPolicyEnum value,
  ) {
    if (value == ThreadSubthreadResponseDtoPostingPolicyEnum.PARTICIPANTS) {
      return '参与者发言';
    }
    if (value == ThreadSubthreadResponseDtoPostingPolicyEnum.COLLABORATORS) {
      return '协作者发言';
    }
    if (value == ThreadSubthreadResponseDtoPostingPolicyEnum.PLAYERS) {
      return '玩家发言';
    }
    return '发言权限由主题决定';
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

final threadDetailRepositoryProvider = Provider<ThreadDetailRepository>((ref) {
  final api = ref.watch(wenyouApiProvider);
  return ApiThreadDetailRepository(api.getThreadsApi(), api.getPostsApi());
});
