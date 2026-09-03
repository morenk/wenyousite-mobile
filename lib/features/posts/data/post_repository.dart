import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

export 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart'
    show PostRepository, postRepositoryProvider;

class ApiPostRepository implements PostRepository {
  ApiPostRepository(this._api);

  final PostsApi _api;

  @override
  Future<PostItem> fetchPost(String postId) async {
    try {
      final dto = (await _api.postsFindById(id: postId)).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '帖子加载失败，请重新加载。');
      }
      _validateDetail(dto, expectedId: postId);
      return _mapDetail(dto);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<PostReplyPage> fetchReplies({
    required String rootPostId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  }) async {
    try {
      final envelope = (await _api.postsFindReplies(
        id: rootPostId,
        cursor: cursor,
        limit: limit,
        order: order.apiValue,
        authorId: authorId,
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '回复加载失败，请稍后重试。');
      }
      _validateReplyPage(envelope.data, rootPostId: rootPostId);
      return PostReplyPage(
        items: envelope.data.map(_mapReply).toList(growable: false),
        cursor: _validatePageCursor(
          envelope.meta.cursor,
          envelope.meta.hasMore,
          message: '回复列表已经发生变化，请重新加载。',
        ),
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<PostItem> create(PostCreateInput input) async {
    try {
      final payload = CreatePostDto((builder) {
        builder
          ..content = input.content
          ..clientRequestId = input.clientRequestId;
        if (input.parentPostId != null) {
          builder.parentPostId = input.parentPostId;
        }
        if (input.replyToPostId != null) {
          builder.replyToPostId = input.replyToPostId;
        }
      });
      final dto = (await _api.postsCreate(
        subthreadId: input.subthreadId,
        extra: ApiRequestPolicy.idempotentCreate.extra,
        createPostDto: payload,
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '发帖失败，请重新加载。');
      }
      _validatePost(dto, message: '发帖失败，请重新加载。');
      if (dto.subthreadId != input.subthreadId ||
          dto.parentPostId != input.parentPostId ||
          dto.replyToPostId != input.replyToPostId ||
          dto.clientRequestId != input.clientRequestId) {
        throw const ApiFailure(userMessage: '发帖结果已经发生变化，请重新加载。');
      }
      return _mapPost(dto);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<PostItem> update({
    required String postId,
    required String content,
    required int version,
  }) async {
    try {
      final payload = UpdatePostDto(
        (builder) => builder
          ..content = content
          ..version = version,
      );
      final dto = (await _api.postsUpdate(
        id: postId,
        extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
        updatePostDto: payload,
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '帖子更新失败，请重新加载。');
      }
      _validatePost(dto, message: '帖子更新失败，请重新加载。');
      if (dto.id != postId) {
        throw const ApiFailure(userMessage: '帖子已经发生变化，请重新加载。');
      }
      return _mapPost(dto);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<PostItem> upsertBody({
    required String subthreadId,
    required String content,
    int? version,
  }) async {
    try {
      final payload = UpsertBodyDto((builder) {
        builder.content = content;
        if (version != null) builder.version = version;
      });
      final dto = (await _api.postsUpsertBody(
        subthreadId: subthreadId,
        extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
        upsertBodyDto: payload,
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '正文更新失败，请重新加载。');
      }
      _validatePost(dto, message: '正文更新失败，请重新加载。');
      if (dto.subthreadId != subthreadId ||
          dto.kind != PostResponseDtoKindEnum.BODY) {
        throw const ApiFailure(userMessage: '正文已经发生变化，请重新加载。');
      }
      return _mapPost(dto);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> remove(String postId) async {
    try {
      final data = (await _api.postsRemove(id: postId)).data?.data;
      if (data == null || data.message.trim().isEmpty) {
        throw const ApiFailure(userMessage: '删除失败，请重新加载。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> setPinned(String postId, {required bool pinned}) async {
    try {
      final data = pinned
          ? (await _api.postsPin(
              id: postId,
              extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
            )).data?.data
          : (await _api.postsUnpin(id: postId)).data?.data;
      if (data == null || data.message.trim().isEmpty) {
        throw const ApiFailure(userMessage: '楼层置顶状态没有更新，请重新加载。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  void _validateDetail(
    PostDetailResponseDto dto, {
    required String expectedId,
  }) {
    const message = '帖子已经发生变化，请重新加载。';
    _validatePostShape(
      id: dto.id,
      authorId: dto.authorId,
      author: dto.author,
      isBody: dto.kind == PostDetailResponseDtoKindEnum.BODY,
      isFloor: dto.kind == PostDetailResponseDtoKindEnum.FLOOR,
      floorNumber: dto.floorNumber,
      pinnedAt: dto.pinnedAt,
      parentPostId: dto.parentPostId,
      replyToPostId: dto.replyToPostId,
      clientRequestId: dto.clientRequestId,
      diceRolls: dto.diceRolls,
      message: message,
    );
    final parent = dto.parentPost;
    if (dto.id != expectedId ||
        dto.thread.id != dto.threadId ||
        dto.subthread.id != dto.subthreadId ||
        (dto.parentPostId == null && parent != null) ||
        (dto.parentPostId != null &&
            (parent == null ||
                parent.id != dto.parentPostId ||
                parent.floorNumber == null))) {
      throw const ApiFailure(userMessage: message);
    }
  }

  void _validatePost(PostResponseDto dto, {required String message}) {
    _validatePostShape(
      id: dto.id,
      authorId: dto.authorId,
      author: dto.author,
      isBody: dto.kind == PostResponseDtoKindEnum.BODY,
      isFloor: dto.kind == PostResponseDtoKindEnum.FLOOR,
      floorNumber: dto.floorNumber,
      pinnedAt: dto.pinnedAt,
      parentPostId: dto.parentPostId,
      replyToPostId: dto.replyToPostId,
      clientRequestId: dto.clientRequestId,
      diceRolls: dto.diceRolls,
      message: message,
    );
  }

  void _validateReplyPage(
    Iterable<ReplyResponseDto> replies, {
    required String rootPostId,
  }) {
    const message = '回复列表已经发生变化，请重新加载。';
    String? threadId;
    String? subthreadId;
    for (final reply in replies) {
      _validatePostShape(
        id: reply.id,
        authorId: reply.authorId,
        author: reply.author,
        isBody: reply.kind == ReplyResponseDtoKindEnum.BODY,
        isFloor: reply.kind == ReplyResponseDtoKindEnum.FLOOR,
        floorNumber: reply.floorNumber,
        pinnedAt: reply.pinnedAt,
        parentPostId: reply.parentPostId,
        replyToPostId: reply.replyToPostId,
        clientRequestId: reply.clientRequestId,
        diceRolls: reply.diceRolls,
        message: message,
      );
      final target = reply.replyToPost;
      if (reply.parentPostId != rootPostId ||
          (threadId != null && reply.threadId != threadId) ||
          (subthreadId != null && reply.subthreadId != subthreadId) ||
          (reply.replyToPostId == null && target != null) ||
          (reply.replyToPostId != null &&
              (target == null ||
                  target.id != reply.replyToPostId ||
                  target.authorId != target.author.id))) {
        throw const ApiFailure(userMessage: message);
      }
      threadId ??= reply.threadId;
      subthreadId ??= reply.subthreadId;
    }
  }

  void _validatePostShape({
    required String id,
    required String authorId,
    required PostAuthorResponseDto author,
    required bool isBody,
    required bool isFloor,
    required num? floorNumber,
    required DateTime? pinnedAt,
    required String? parentPostId,
    required String? replyToPostId,
    required String? clientRequestId,
    required Iterable<DiceRollResponseDto> diceRolls,
    required String message,
  }) {
    final invalidBody =
        isBody &&
        (floorNumber != null ||
            pinnedAt != null ||
            parentPostId != null ||
            replyToPostId != null ||
            clientRequestId != null);
    final invalidFloor =
        isFloor &&
        ((parentPostId == null && floorNumber == null) ||
            (parentPostId != null &&
                (floorNumber != null || pinnedAt != null)));
    if (authorId != author.id ||
        (!isBody && !isFloor) ||
        invalidBody ||
        invalidFloor ||
        diceRolls.any((roll) => roll.postId != id)) {
      throw ApiFailure(userMessage: message);
    }
  }

  String? _validatePageCursor(
    String? cursor,
    bool hasMore, {
    required String message,
  }) {
    if (hasMore && (cursor == null || cursor.trim().isEmpty)) {
      throw ApiFailure(userMessage: message);
    }
    return hasMore ? cursor : null;
  }

  PostItem _mapPost(PostResponseDto dto) {
    return PostItem(
      id: dto.id,
      threadId: dto.threadId,
      subthreadId: dto.subthreadId,
      author: _mapAuthor(dto.author),
      content: dto.content,
      version: dto.version.toInt(),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      isBody: dto.kind == PostResponseDtoKindEnum.BODY,
      isDeleted: dto.deletedAt != null,
      floorNumber: dto.floorNumber?.toInt(),
      pinnedAt: dto.pinnedAt,
      parentPostId: dto.parentPostId,
      replyToPostId: dto.replyToPostId,
      clientRequestId: dto.clientRequestId,
      diceRolls: dto.diceRolls.map(_mapDice).toList(growable: false),
    );
  }

  PostItem _mapReply(ReplyResponseDto dto) {
    return PostItem(
      id: dto.id,
      threadId: dto.threadId,
      subthreadId: dto.subthreadId,
      author: _mapAuthor(dto.author),
      content: dto.content,
      version: dto.version.toInt(),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      isBody: dto.kind == ReplyResponseDtoKindEnum.BODY,
      isDeleted: dto.deletedAt != null,
      floorNumber: dto.floorNumber?.toInt(),
      pinnedAt: dto.pinnedAt,
      parentPostId: dto.parentPostId,
      replyToPostId: dto.replyToPostId,
      replyToAuthor: dto.replyToPost == null
          ? null
          : _mapAuthor(dto.replyToPost!.author),
      clientRequestId: dto.clientRequestId,
      diceRolls: dto.diceRolls.map(_mapDice).toList(growable: false),
    );
  }

  PostItem _mapDetail(PostDetailResponseDto dto) {
    return PostItem(
      id: dto.id,
      threadId: dto.threadId,
      subthreadId: dto.subthreadId,
      author: _mapAuthor(dto.author),
      content: dto.content,
      version: dto.version.toInt(),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      isBody: dto.kind == PostDetailResponseDtoKindEnum.BODY,
      isDeleted: dto.deletedAt != null,
      floorNumber: dto.floorNumber?.toInt(),
      pinnedAt: dto.pinnedAt,
      parentPostId: dto.parentPostId,
      replyToPostId: dto.replyToPostId,
      clientRequestId: dto.clientRequestId,
      replyCount: dto.count.replies.toInt(),
      threadTitle: dto.thread.title,
      subthreadTitle: dto.subthread.title,
      diceRolls: dto.diceRolls.map(_mapDice).toList(growable: false),
    );
  }

  PostAuthor _mapAuthor(PostAuthorResponseDto dto) {
    return PostAuthor(
      id: dto.id,
      username: dto.username,
      level: dto.level.toInt(),
      avatarUrl: _safeHttpUrl(dto.avatar),
    );
  }

  PostDiceRoll _mapDice(DiceRollResponseDto dto) {
    return PostDiceRoll(
      nodeId: dto.nodeId.toLowerCase(),
      notation: dto.notation,
      results: dto.results
          .map((value) => value.toInt())
          .toList(growable: false),
      total: dto.total.toInt(),
    );
  }

  String? _safeHttpUrl(String? value) {
    if (value == null) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return value;
  }
}

final apiPostRepositoryProvider = Provider<PostRepository>((ref) {
  return ApiPostRepository(ref.watch(wenyouApiProvider).getPostsApi());
});
