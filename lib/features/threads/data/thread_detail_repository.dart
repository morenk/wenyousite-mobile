import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

export 'package:wenyousite_mobile/features/threads/application/thread_detail_repository_ports.dart'
    show ThreadDetailRepository, threadDetailRepositoryProvider;

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
        throw const ApiFailure(userMessage: '主题加载失败，请稍后重试。');
      }
      _validateThread(dto, expectedId: threadId);
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
        throw const ApiFailure(userMessage: '目标楼层加载失败，请稍后重试。');
      }
      _validatePostDetail(target, expectedId: postId);
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
        throw const ApiFailure(userMessage: '目标楼层加载失败，请稍后重试。');
      }
      _validatePostDetail(parent, expectedId: target.parentPostId!);
      if (parent.threadId != target.threadId ||
          parent.subthreadId != target.subthreadId ||
          parent.parentPostId != null ||
          parent.floorNumber != target.parentPost?.floorNumber) {
        throw const ApiFailure(userMessage: '目标楼层已经发生变化，请返回搜索后重试。');
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
    ThreadFloorOrder order = ThreadFloorOrder.oldest,
    String? authorId,
  }) async {
    try {
      final response = await _postsApi.postsFindFloors(
        subthreadId: subthreadId,
        cursor: cursor,
        limit: limit,
        order: order.apiValue,
        authorId: authorId,
      );
      final envelope = response.data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '楼层加载失败，请稍后重试。');
      }
      _validateFloors(envelope.data, expectedSubthreadId: subthreadId);
      return CursorPage(
        items: envelope.data.map(_mapFloor).toList(growable: false),
        cursor: _validatePageCursor(
          envelope.meta.cursor,
          envelope.meta.hasMore,
        ),
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  void _validateThread(
    ThreadDetailResponseDto dto, {
    required String expectedId,
  }) {
    const message = '主题已经发生变化，请重新加载。';
    final activeSubthreads = dto.subthreads.where(
      (subthread) => subthread.deletedAt == null,
    );
    if (dto.id != expectedId ||
        dto.ownerId != dto.owner.id ||
        dto.subthreads.any((subthread) => subthread.threadId != dto.id) ||
        (dto.defaultSubthreadId != null &&
            !activeSubthreads.any(
              (subthread) => subthread.id == dto.defaultSubthreadId,
            )) ||
        dto.topicTags.any(
          (relation) =>
              relation.threadId != dto.id || relation.tagId != relation.tag.id,
        ) ||
        dto.subthreads.any(
          (subthread) =>
              subthread.bodyPost?.diceRolls.any(
                (roll) => roll.postId != subthread.bodyPost!.id,
              ) ??
              false,
        )) {
      throw const ApiFailure(userMessage: message);
    }
  }

  void _validateFloors(
    Iterable<FloorResponseDto> floors, {
    required String expectedSubthreadId,
  }) {
    const message = '楼层列表已经发生变化，请重新加载。';
    String? threadId;
    for (final floor in floors) {
      _validateFloor(floor, message: message);
      if (floor.subthreadId != expectedSubthreadId ||
          (threadId != null && floor.threadId != threadId)) {
        throw const ApiFailure(userMessage: message);
      }
      threadId ??= floor.threadId;
      for (final reply in floor.replies) {
        _validateReply(reply, parent: floor, message: message);
      }
    }
  }

  void _validateFloor(FloorResponseDto dto, {required String message}) {
    if (dto.kind != FloorResponseDtoKindEnum.FLOOR ||
        dto.floorNumber == null ||
        dto.parentPostId != null ||
        dto.authorId != dto.author.id ||
        dto.diceRolls.any((roll) => roll.postId != dto.id)) {
      throw ApiFailure(userMessage: message);
    }
  }

  void _validateReply(
    ReplyResponseDto dto, {
    required FloorResponseDto parent,
    required String message,
  }) {
    final target = dto.replyToPost;
    if (dto.kind != ReplyResponseDtoKindEnum.FLOOR ||
        dto.floorNumber != null ||
        dto.parentPostId != parent.id ||
        dto.threadId != parent.threadId ||
        dto.subthreadId != parent.subthreadId ||
        dto.authorId != dto.author.id ||
        dto.diceRolls.any((roll) => roll.postId != dto.id) ||
        (dto.replyToPostId == null && target != null) ||
        (dto.replyToPostId != null &&
            (target == null ||
                target.id != dto.replyToPostId ||
                target.authorId != target.author.id))) {
      throw ApiFailure(userMessage: message);
    }
  }

  void _validatePostDetail(
    PostDetailResponseDto dto, {
    required String expectedId,
  }) {
    const message = '目标楼层已经发生变化，请返回搜索后重试。';
    final parent = dto.parentPost;
    if (dto.id != expectedId ||
        dto.kind != PostDetailResponseDtoKindEnum.FLOOR ||
        dto.thread.id != dto.threadId ||
        dto.subthread.id != dto.subthreadId ||
        dto.authorId != dto.author.id ||
        dto.diceRolls.any((roll) => roll.postId != dto.id) ||
        (dto.parentPostId == null &&
            (dto.floorNumber == null || parent != null)) ||
        (dto.parentPostId != null &&
            (dto.floorNumber != null ||
                parent == null ||
                parent.id != dto.parentPostId ||
                parent.floorNumber == null))) {
      throw const ApiFailure(userMessage: message);
    }
  }

  String? _validatePageCursor(String? cursor, bool hasMore) {
    if (hasMore && (cursor == null || cursor.trim().isEmpty)) {
      throw const ApiFailure(userMessage: '楼层列表已经发生变化，请重新加载。');
    }
    return hasMore ? cursor : null;
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
      isCurrentUserPlayer: dto.currentMembership?.playerMarked ?? false,
      isCurrentUserOwner:
          dto.capabilities?.isOwner ??
          dto.currentMembership?.role ==
              CurrentThreadMembershipResponseDtoRoleEnum.OWNER,
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

final apiThreadDetailRepositoryProvider = Provider<ThreadDetailRepository>((
  ref,
) {
  final api = ref.watch(wenyouApiProvider);
  return ApiThreadDetailRepository(api.getThreadsApi(), api.getPostsApi());
});
