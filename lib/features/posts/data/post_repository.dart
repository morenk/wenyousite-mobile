import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

abstract interface class PostRepository {
  Future<PostItem> fetchPost(String postId);

  Future<PostReplyPage> fetchReplies({
    required String rootPostId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  });

  Future<PostItem> create(PostCreateInput input);

  Future<PostItem> update({
    required String postId,
    required String content,
    required int version,
  });

  Future<PostItem> upsertBody({
    required String subthreadId,
    required String content,
    int? version,
  });

  Future<void> remove(String postId);
}

class ApiPostRepository implements PostRepository {
  ApiPostRepository(this._api);

  final PostsApi _api;

  @override
  Future<PostItem> fetchPost(String postId) async {
    try {
      final dto = (await _api.postsFindById(id: postId)).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '帖子详情响应为空，请重新加载。');
      }
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
        throw const ApiFailure(userMessage: '楼中楼回复响应为空，请稍后重试。');
      }
      return PostReplyPage(
        items: envelope.data.map(_mapReply).toList(growable: false),
        cursor: envelope.meta.cursor,
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
        createPostDto: payload,
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '发帖响应为空，请重新加载确认。');
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
        updatePostDto: payload,
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '帖子更新响应为空，请重新加载确认。');
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
        upsertBodyDto: payload,
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '子贴正文更新响应为空，请重新加载确认。');
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
        throw const ApiFailure(userMessage: '帖子删除响应为空，请重新加载确认。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
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

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return ApiPostRepository(ref.watch(wenyouApiProvider).getPostsApi());
});
