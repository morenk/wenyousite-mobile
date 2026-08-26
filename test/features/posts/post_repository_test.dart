import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

const _clientRequestId = '123e4567-e89b-42d3-a456-426614174000';
const _replyClientRequestId = '123e4567-e89b-42d3-a456-426614174001';
const _otherClientRequestId = '123e4567-e89b-42d3-a456-426614174003';

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeCreatePostDto());
    registerFallbackValue(_FakeUpdatePostDto());
    registerFallbackValue(_FakeUpsertBodyDto());
  });

  test('详情和楼中楼读取完整映射版本、上下文、筛选与分页', () async {
    final api = _MockPostsApi();
    when(() => api.postsFindById(id: 'floor')).thenAnswer(
      (_) async => _response(
        '/api/v1/posts/floor',
        PostsFindById200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.replace(_detailDto()),
        ),
      ),
    );
    when(
      () => api.postsFindReplies(
        id: 'floor',
        cursor: 'cursor-1',
        limit: 7,
        order: 'NEWEST',
        authorId: 'author-2',
      ),
    ).thenAnswer(
      (_) async => _response(
        '/api/v1/posts/floor/replies',
        PostsFindReplies200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..meta.update(
              (meta) => meta
                ..cursor = 'cursor-2'
                ..hasMore = true,
            )
            ..data.add(_replyDto()),
        ),
      ),
    );
    final repository = ApiPostRepository(api);

    final detail = await repository.fetchPost('floor');
    final page = await repository.fetchReplies(
      rootPostId: 'floor',
      cursor: 'cursor-1',
      limit: 7,
      order: PostReplyOrder.newest,
      authorId: 'author-2',
    );

    expect(detail.version, 3);
    expect(detail.replyCount, 2);
    expect(detail.threadTitle, '远行主题');
    expect(detail.subthreadTitle, '主线');
    expect(detail.author.avatarUrl, isNull);
    expect(
      detail.diceRolls.single.nodeId,
      '550e8400-e29b-41d4-a716-446655440000',
    );
    expect(detail.diceRolls.single.notation, '2d6+1');
    expect(detail.diceRolls.single.results, [4, 5]);
    expect(detail.diceRolls.single.total, 10);
    expect(page.cursor, 'cursor-2');
    expect(page.hasMore, isTrue);
    expect(page.items.single.parentPostId, 'floor');
    expect(page.items.single.replyToAuthor?.username, '作者甲');
    expect(
      page.items.single.diceRolls.single.nodeId,
      '550e8400-e29b-41d4-a716-446655440001',
    );
    expect(page.items.single.diceRolls.single.results, [6]);
  });

  test('创建、编辑、正文 upsert 与删除严格透传幂等和版本载荷', () async {
    final api = _MockPostsApi();
    late CreatePostDto createPayload;
    late UpdatePostDto updatePayload;
    late UpsertBodyDto bodyPayload;
    when(
      () => api.postsCreate(
        subthreadId: 'subthread',
        extra: ApiRequestPolicy.idempotentCreate.extra,
        createPostDto: any(named: 'createPostDto'),
      ),
    ).thenAnswer((invocation) async {
      createPayload =
          invocation.namedArguments[#createPostDto]! as CreatePostDto;
      return _response(
        '/api/v1/subthreads/subthread/posts',
        PostsCreate201Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.replace(
              _postDto(
                id: 'created',
                parentPostId: 'floor',
                replyToPostId: 'reply-target',
                clientRequestId: '123e4567-e89b-42d3-a456-426614174000',
              ),
            ),
        ),
      );
    });
    when(
      () => api.postsUpdate(
        id: 'created',
        extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
        updatePostDto: any(named: 'updatePostDto'),
      ),
    ).thenAnswer((invocation) async {
      updatePayload =
          invocation.namedArguments[#updatePostDto]! as UpdatePostDto;
      return _response(
        '/api/v1/posts/created',
        PostsUpdate200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.replace(_postDto(id: 'created', version: 4)),
        ),
      );
    });
    when(
      () => api.postsUpsertBody(
        subthreadId: 'subthread',
        extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
        upsertBodyDto: any(named: 'upsertBodyDto'),
      ),
    ).thenAnswer((invocation) async {
      bodyPayload = invocation.namedArguments[#upsertBodyDto]! as UpsertBodyDto;
      return _response(
        '/api/v1/subthreads/subthread/body',
        PostsUpsertBody200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.replace(_postDto(id: 'body', body: true, version: 9)),
        ),
      );
    });
    when(() => api.postsRemove(id: 'created')).thenAnswer(
      (_) async => _response(
        '/api/v1/posts/created',
        PostsRemove200Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.update((data) => data.message = '已删除'),
        ),
      ),
    );
    final repository = ApiPostRepository(api);

    final created = await repository.create(
      const PostCreateInput(
        subthreadId: 'subthread',
        content: '新回复',
        clientRequestId: '123e4567-e89b-42d3-a456-426614174000',
        parentPostId: 'floor',
        replyToPostId: 'reply-target',
      ),
    );
    final updated = await repository.update(
      postId: created.id,
      content: '编辑后的内容',
      version: 3,
    );
    final body = await repository.upsertBody(
      subthreadId: 'subthread',
      content: '子贴正文',
      version: 8,
    );
    await repository.remove(created.id);

    expect(createPayload.content, '新回复');
    expect(
      createPayload.clientRequestId,
      '123e4567-e89b-42d3-a456-426614174000',
    );
    expect(createPayload.parentPostId, 'floor');
    expect(createPayload.replyToPostId, 'reply-target');
    expect(updatePayload.content, '编辑后的内容');
    expect(updatePayload.version, 3);
    expect(updated.version, 4);
    expect(created.diceRolls.single.notation, '1d20');
    expect(updated.diceRolls.single.total, 16);
    expect(bodyPayload.content, '子贴正文');
    expect(bodyPayload.version, 8);
    expect(body.isBody, isTrue);
    expect(
      body.diceRolls.single.nodeId,
      '550e8400-e29b-41d4-a716-446655440002',
    );
    verify(() => api.postsRemove(id: 'created')).called(1);
  });

  test('详情与创建允许顶层楼层携带 replyToPostId', () async {
    final api = _MockPostsApi();
    when(() => api.postsFindById(id: 'floor')).thenAnswer(
      (_) async =>
          _postDetailResponse(_detailDto(replyToPostId: 'reply-target')),
    );
    when(
      () => api.postsCreate(
        subthreadId: 'subthread',
        extra: ApiRequestPolicy.idempotentCreate.extra,
        createPostDto: any(named: 'createPostDto'),
      ),
    ).thenAnswer(
      (_) async => _response(
        '/posts',
        PostsCreate201Response(
          (builder) => builder
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.replace(
              _postDto(
                id: 'created',
                replyToPostId: 'reply-target',
                clientRequestId: _clientRequestId,
              ),
            ),
        ),
      ),
    );
    final repository = ApiPostRepository(api);

    final detail = await repository.fetchPost('floor');
    final created = await repository.create(
      const PostCreateInput(
        subthreadId: 'subthread',
        content: '顶层回复',
        clientRequestId: _clientRequestId,
        replyToPostId: 'reply-target',
      ),
    );

    expect(detail.parentPostId, isNull);
    expect(detail.floorNumber, 1);
    expect(detail.replyToPostId, 'reply-target');
    expect(created.parentPostId, isNull);
    expect(created.floorNumber, 1);
    expect(created.replyToPostId, 'reply-target');
  });

  test('详情读取拒绝空响应和与请求、主题、子贴或层级不一致的帖子', () async {
    final invalidDetails = <PostDetailResponseDto?>[
      null,
      _detailDto(id: 'other-floor'),
      _detailDto().rebuild((builder) => builder.thread.id = 'other-thread'),
      _detailDto().rebuild(
        (builder) => builder.subthread.id = 'other-subthread',
      ),
      _detailDto().rebuild(
        (builder) => builder
          ..kind = PostDetailResponseDtoKindEnum.BODY
          ..floorNumber = 1,
      ),
      _detailDto().rebuild(
        (builder) => builder
          ..floorNumber = null
          ..parentPostId = 'parent',
      ),
    ];

    for (final detail in invalidDetails) {
      final api = _MockPostsApi();
      when(
        () => api.postsFindById(id: 'floor'),
      ).thenAnswer((_) async => _postDetailResponse(detail));

      await expectLater(
        ApiPostRepository(api).fetchPost('floor'),
        throwsA(isA<ApiFailure>()),
      );
    }
  });

  test('回复列表拒绝空响应、无效游标和与讨论根不一致的条目', () async {
    final invalidEnvelopes = <PostsFindReplies200Response?>[
      null,
      _repliesEnvelope(hasMore: true),
      _repliesEnvelope(cursor: '', hasMore: true),
      _repliesEnvelope(replies: [_replyDto(parentPostId: 'other-floor')]),
      _repliesEnvelope(
        replies: [
          _replyDto(),
          _replyDto(id: 'reply-2', subthreadId: 'other-subthread'),
        ],
      ),
      _repliesEnvelope(
        replies: [_replyDto(kind: ReplyResponseDtoKindEnum.BODY)],
      ),
      _repliesEnvelope(replies: [_replyDto(replyTargetId: 'other-target')]),
    ];

    for (final envelope in invalidEnvelopes) {
      final api = _MockPostsApi();
      when(
        () => api.postsFindReplies(
          id: 'floor',
          cursor: null,
          limit: 20,
          order: 'OLDEST',
          authorId: null,
        ),
      ).thenAnswer((_) async => _nullableResponse('/replies', envelope));

      await expectLater(
        ApiPostRepository(api).fetchReplies(rootPostId: 'floor'),
        throwsA(isA<ApiFailure>()),
      );
    }
  });

  test('创建拒绝与子贴、父楼、回复目标或幂等键不一致的结果', () async {
    const input = PostCreateInput(
      subthreadId: 'subthread',
      content: '新回复',
      clientRequestId: '123e4567-e89b-42d3-a456-426614174000',
      parentPostId: 'floor',
      replyToPostId: 'reply-target',
    );
    final invalidPosts = [
      _postDto(
        id: 'created',
        parentPostId: 'floor',
        replyToPostId: 'reply-target',
      ).rebuild((builder) => builder.subthreadId = 'other-subthread'),
      _postDto(
        id: 'created',
        parentPostId: 'other-floor',
        replyToPostId: 'reply-target',
      ),
      _postDto(
        id: 'created',
        parentPostId: 'floor',
        replyToPostId: 'other-target',
      ),
      _postDto(
        id: 'created',
        parentPostId: 'floor',
        replyToPostId: 'reply-target',
        clientRequestId: _otherClientRequestId,
      ),
      _postDto(
        id: 'created',
        body: true,
        parentPostId: 'floor',
        replyToPostId: 'reply-target',
      ),
    ];

    for (final post in invalidPosts) {
      final api = _MockPostsApi();
      when(
        () => api.postsCreate(
          subthreadId: 'subthread',
          extra: ApiRequestPolicy.idempotentCreate.extra,
          createPostDto: any(named: 'createPostDto'),
        ),
      ).thenAnswer(
        (_) async => _response(
          '/posts',
          PostsCreate201Response(
            (builder) => builder
              ..code = ApiSuccessEnvelopeCodeEnum.number0
              ..message = 'ok'
              ..data.replace(post),
          ),
        ),
      );

      await expectLater(
        ApiPostRepository(api).create(input),
        throwsA(isA<ApiFailure>()),
      );
    }
  });

  test('编辑和正文写入拒绝错贴子或错子贴结果', () async {
    final updateApi = _MockPostsApi();
    when(
      () => updateApi.postsUpdate(
        id: 'floor',
        extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
        updatePostDto: any(named: 'updatePostDto'),
      ),
    ).thenAnswer((_) async => _postUpdateResponse(_postDto(id: 'other-floor')));
    await expectLater(
      ApiPostRepository(
        updateApi,
      ).update(postId: 'floor', content: '修改', version: 3),
      throwsA(isA<ApiFailure>()),
    );

    final bodyApi = _MockPostsApi();
    when(
      () => bodyApi.postsUpsertBody(
        subthreadId: 'subthread',
        extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
        upsertBodyDto: any(named: 'upsertBodyDto'),
      ),
    ).thenAnswer(
      (_) async => _bodyResponse(
        _postDto(
          id: 'body',
          body: true,
        ).rebuild((builder) => builder.subthreadId = 'other-subthread'),
      ),
    );
    await expectLater(
      ApiPostRepository(
        bodyApi,
      ).upsertBody(subthreadId: 'subthread', content: '正文'),
      throwsA(isA<ApiFailure>()),
    );
  });

  test('创建、编辑、正文写入和删除都不把空响应当成成功', () async {
    final api = _MockPostsApi();
    when(
      () => api.postsCreate(
        subthreadId: 'subthread',
        extra: ApiRequestPolicy.idempotentCreate.extra,
        createPostDto: any(named: 'createPostDto'),
      ),
    ).thenAnswer((_) async => _nullableResponse('/posts', null));
    when(
      () => api.postsUpdate(
        id: 'floor',
        extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
        updatePostDto: any(named: 'updatePostDto'),
      ),
    ).thenAnswer((_) async => _nullableResponse('/posts/floor', null));
    when(
      () => api.postsUpsertBody(
        subthreadId: 'subthread',
        extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
        upsertBodyDto: any(named: 'upsertBodyDto'),
      ),
    ).thenAnswer((_) async => _nullableResponse('/body', null));
    when(
      () => api.postsRemove(id: 'floor'),
    ).thenAnswer((_) async => _nullableResponse('/posts/floor', null));
    final repository = ApiPostRepository(api);

    await expectLater(
      repository.create(
        const PostCreateInput(
          subthreadId: 'subthread',
          content: '新楼层',
          clientRequestId: '123e4567-e89b-42d3-a456-426614174000',
        ),
      ),
      throwsA(isA<ApiFailure>()),
    );
    await expectLater(
      repository.update(postId: 'floor', content: '修改', version: 1),
      throwsA(isA<ApiFailure>()),
    );
    await expectLater(
      repository.upsertBody(subthreadId: 'subthread', content: '正文'),
      throwsA(isA<ApiFailure>()),
    );
    await expectLater(repository.remove('floor'), throwsA(isA<ApiFailure>()));
  });
}

class _MockPostsApi extends Mock implements PostsApi {}

class _FakeCreatePostDto extends Fake implements CreatePostDto {}

class _FakeUpdatePostDto extends Fake implements UpdatePostDto {}

class _FakeUpsertBodyDto extends Fake implements UpsertBodyDto {}

Response<T> _response<T>(String path, T data) {
  return Response(
    requestOptions: RequestOptions(path: path),
    data: data,
  );
}

Response<T> _nullableResponse<T>(String path, T? data) {
  return Response<T>(
    requestOptions: RequestOptions(path: path),
    data: data,
  );
}

PostAuthorResponseDto _authorDto({String id = 'author-1'}) {
  return PostAuthorResponseDto(
    (builder) => builder
      ..id = id
      ..username = id == 'author-1' ? '作者甲' : '作者乙'
      ..avatar = 'javascript:unsafe'
      ..level = 3,
  );
}

PostResponseDto _postDto({
  required String id,
  int version = 3,
  bool body = false,
  String? parentPostId,
  String? replyToPostId,
  String? clientRequestId,
}) {
  return PostResponseDto(
    (builder) => builder
      ..id = id
      ..threadId = 'thread'
      ..subthreadId = 'subthread'
      ..authorId = 'author-1'
      ..kind = body
          ? PostResponseDtoKindEnum.BODY
          : PostResponseDtoKindEnum.FLOOR
      ..floorNumber = body || parentPostId != null ? null : 1
      ..parentPostId = parentPostId
      ..replyToPostId = replyToPostId
      ..clientRequestId = body ? null : clientRequestId ?? _clientRequestId
      ..content = body ? '子贴正文' : '楼层内容'
      ..version = version
      ..createdAt = DateTime.utc(2026, 8, 10)
      ..updatedAt = DateTime.utc(2026, 8, 10)
      ..author.replace(_authorDto())
      ..diceRolls.add(
        _diceRollDto(
          postId: id,
          nodeId: body
              ? '550E8400-E29B-41D4-A716-446655440002'
              : '550E8400-E29B-41D4-A716-446655440000',
          notation: body ? '2d6' : '1d20',
          results: body ? const [3, 4] : const [16],
          total: body ? 7 : 16,
        ),
      ),
  );
}

PostDetailResponseDto _detailDto({String id = 'floor', String? replyToPostId}) {
  return PostDetailResponseDto(
    (builder) => builder
      ..id = id
      ..threadId = 'thread'
      ..subthreadId = 'subthread'
      ..authorId = 'author-1'
      ..kind = PostDetailResponseDtoKindEnum.FLOOR
      ..floorNumber = 1
      ..replyToPostId = replyToPostId
      ..clientRequestId = _clientRequestId
      ..content = '楼层内容'
      ..version = 3
      ..createdAt = DateTime.utc(2026, 8, 10)
      ..updatedAt = DateTime.utc(2026, 8, 10)
      ..author.replace(_authorDto())
      ..thread.update(
        (thread) => thread
          ..id = 'thread'
          ..title = '远行主题',
      )
      ..subthread.update(
        (subthread) => subthread
          ..id = 'subthread'
          ..title = '主线',
      )
      ..count.update((count) => count.replies = 2)
      ..diceRolls.add(
        _diceRollDto(
          postId: id,
          nodeId: '550E8400-E29B-41D4-A716-446655440000',
          notation: '2d6+1',
          results: const [4, 5],
          total: 10,
        ),
      ),
  );
}

ReplyResponseDto _replyDto({
  String id = 'reply',
  String threadId = 'thread',
  String subthreadId = 'subthread',
  String parentPostId = 'floor',
  ReplyResponseDtoKindEnum kind = ReplyResponseDtoKindEnum.FLOOR,
  String replyToPostId = 'floor',
  String? replyTargetId,
}) {
  return ReplyResponseDto(
    (builder) => builder
      ..id = id
      ..threadId = threadId
      ..subthreadId = subthreadId
      ..authorId = 'author-2'
      ..kind = kind
      ..parentPostId = parentPostId
      ..replyToPostId = replyToPostId
      ..clientRequestId = _replyClientRequestId
      ..content = '回复内容'
      ..version = 2
      ..createdAt = DateTime.utc(2026, 8, 10, 1)
      ..updatedAt = DateTime.utc(2026, 8, 10, 1)
      ..author.replace(_authorDto(id: 'author-2'))
      ..replyToPost.update(
        (target) => target
          ..id = replyTargetId ?? replyToPostId
          ..authorId = 'author-1'
          ..author.replace(_authorDto()),
      )
      ..diceRolls.add(
        _diceRollDto(
          postId: id,
          nodeId: '550E8400-E29B-41D4-A716-446655440001',
          notation: '1d6',
          results: const [6],
          total: 6,
        ),
      ),
  );
}

PostsFindReplies200Response _repliesEnvelope({
  List<ReplyResponseDto>? replies,
  String? cursor,
  bool hasMore = false,
}) {
  return PostsFindReplies200Response(
    (builder) => builder
      ..code = ApiSuccessEnvelopeCodeEnum.number0
      ..message = 'ok'
      ..meta.update(
        (meta) => meta
          ..cursor = cursor
          ..hasMore = hasMore,
      )
      ..data.addAll(replies ?? [_replyDto()]),
  );
}

Response<PostsFindById200Response> _postDetailResponse(
  PostDetailResponseDto? detail,
) {
  if (detail == null) {
    return _nullableResponse('/posts/floor', null);
  }
  return _response(
    '/posts/floor',
    PostsFindById200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(detail),
    ),
  );
}

Response<PostsUpdate200Response> _postUpdateResponse(PostResponseDto post) {
  return _response(
    '/posts/floor',
    PostsUpdate200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(post),
    ),
  );
}

Response<PostsUpsertBody200Response> _bodyResponse(PostResponseDto post) {
  return _response(
    '/subthreads/subthread/body',
    PostsUpsertBody200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(post),
    ),
  );
}

DiceRollResponseDto _diceRollDto({
  required String postId,
  required String nodeId,
  required String notation,
  required List<int> results,
  required int total,
}) {
  return DiceRollResponseDto(
    (builder) => builder
      ..id = 'roll-$postId'
      ..postId = postId
      ..nodeId = nodeId
      ..protocolVersion = 1
      ..notation = notation
      ..quantity = results.length
      ..sides = notation.contains('20') ? 20 : 6
      ..modifier = notation.contains('+1') ? 1 : 0
      ..results.addAll(results)
      ..total = total
      ..createdAt = DateTime.utc(2026, 8, 10),
  );
}
