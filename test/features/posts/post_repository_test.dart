import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

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
    expect(page.cursor, 'cursor-2');
    expect(page.hasMore, isTrue);
    expect(page.items.single.parentPostId, 'floor');
    expect(page.items.single.replyToAuthor?.username, '作者甲');
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
            ..data.replace(_postDto(id: 'created')),
        ),
      );
    });
    when(
      () => api.postsUpdate(
        id: 'created',
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
    expect(bodyPayload.content, '子贴正文');
    expect(bodyPayload.version, 8);
    expect(body.isBody, isTrue);
    verify(() => api.postsRemove(id: 'created')).called(1);
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
      ..floorNumber = body ? null : 1
      ..clientRequestId = body ? null : 'request-id'
      ..content = body ? '子贴正文' : '楼层内容'
      ..version = version
      ..createdAt = DateTime.utc(2026, 8, 10)
      ..updatedAt = DateTime.utc(2026, 8, 10)
      ..author.replace(_authorDto()),
  );
}

PostDetailResponseDto _detailDto() {
  return PostDetailResponseDto(
    (builder) => builder
      ..id = 'floor'
      ..threadId = 'thread'
      ..subthreadId = 'subthread'
      ..authorId = 'author-1'
      ..kind = PostDetailResponseDtoKindEnum.FLOOR
      ..floorNumber = 1
      ..clientRequestId = 'request-id'
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
      ..count.update((count) => count.replies = 2),
  );
}

ReplyResponseDto _replyDto() {
  return ReplyResponseDto(
    (builder) => builder
      ..id = 'reply'
      ..threadId = 'thread'
      ..subthreadId = 'subthread'
      ..authorId = 'author-2'
      ..kind = ReplyResponseDtoKindEnum.FLOOR
      ..parentPostId = 'floor'
      ..replyToPostId = 'floor'
      ..clientRequestId = 'reply-request'
      ..content = '回复内容'
      ..version = 2
      ..createdAt = DateTime.utc(2026, 8, 10, 1)
      ..updatedAt = DateTime.utc(2026, 8, 10, 1)
      ..author.replace(_authorDto(id: 'author-2'))
      ..replyToPost.update(
        (target) => target
          ..id = 'floor'
          ..authorId = 'author-1'
          ..author.replace(_authorDto()),
      ),
  );
}
