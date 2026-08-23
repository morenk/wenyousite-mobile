import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

void main() {
  test('主题详情映射字段、过滤已删除子贴并按 sortOrder 排序', () async {
    final threadsApi = _MockThreadsApi();
    final postsApi = _MockPostsApi();
    when(
      () => threadsApi.threadsFindById(id: 'thread-1'),
    ).thenAnswer((_) async => _threadDetailResponse());

    final detail = await ApiThreadDetailRepository(
      threadsApi,
      postsApi,
    ).fetchThread('thread-1');

    verify(() => threadsApi.threadsFindById(id: 'thread-1')).called(1);
    expect(detail.id, 'thread-1');
    expect(detail.title, '星海旅团');
    expect(detail.owner.id, 'owner-1');
    expect(detail.owner.username, '温柔测试员');
    expect(detail.owner.avatarUrl, 'https://cdn.example.com/owner.png');
    expect(detail.owner.level, 4);
    expect(detail.categorySlug, 'RPG');
    expect(detail.status, ThreadDetailStatus.closed);
    expect(detail.isPrivate, isTrue);
    expect(detail.isPinned, isTrue);
    expect(detail.viewCount, 128);
    expect(detail.likeCount, 12);
    expect(detail.isLiked, isTrue);
    expect(detail.isBookmarked, isTrue);
    expect(detail.bookmarkId, 'bookmark-1');
    expect(detail.hasAutomaticUpdates, isTrue);
    expect(detail.canManageThread, isTrue);
    expect(detail.isCurrentUserPlayer, isFalse);
    expect(detail.isCurrentUserOwner, isFalse);
    expect(detail.currentUserId, 'collaborator-1');
    expect(detail.tipTotal, '42');
    expect(detail.memberCount, 8);
    expect(detail.playerCount, 3);
    expect(detail.postCount, 21);
    expect(detail.tags.single.id, 'tag-1');
    expect(detail.tags.single.name, '太空歌剧');
    expect(detail.defaultSubthreadId, 'subthread-early');
    expect(detail.createdAt, DateTime.utc(2026, 8, 8, 10));
    expect(detail.updatedAt, DateTime.utc(2026, 8, 9, 12));

    expect(detail.subthreads.map((subthread) => subthread.id), [
      'subthread-early',
      'subthread-late',
    ]);
    final early = detail.subthreads.first;
    expect(early.title, '主线');
    expect(early.sortOrder, 10);
    expect(early.postCount, 14);
    expect(early.postingPolicyLabel, '玩家发言');
    expect(early.lastPostAt, DateTime.utc(2026, 8, 9, 11));
    expect(early.body?.markdown, '正文 {{dice:ROLL-BODY}}');
    final bodyRoll = early.body!.diceRolls.single;
    expect(bodyRoll.nodeId, 'roll-body');
    expect(bodyRoll.notation, '2d6+1');
    expect(bodyRoll.results, [4, 5]);
    expect(bodyRoll.total, 10);
    expect(detail.subthreads.last.postingPolicyLabel, '协作者发言');
  });

  test('楼层查询传递 cursor 并映射楼层、骰子和内嵌回复', () async {
    final threadsApi = _MockThreadsApi();
    final postsApi = _MockPostsApi();
    when(
      () => postsApi.postsFindFloors(
        subthreadId: 'subthread-early',
        cursor: 'cursor-1',
        limit: 7,
        order: 'NEWEST',
        authorId: '550e8400-e29b-41d4-a716-446655440000',
      ),
    ).thenAnswer((_) async => _floorsResponse());

    final page = await ApiThreadDetailRepository(threadsApi, postsApi)
        .fetchFloors(
          subthreadId: 'subthread-early',
          cursor: 'cursor-1',
          limit: 7,
          order: ThreadFloorOrder.newest,
          authorId: '550e8400-e29b-41d4-a716-446655440000',
        );

    verify(
      () => postsApi.postsFindFloors(
        subthreadId: 'subthread-early',
        cursor: 'cursor-1',
        limit: 7,
        order: 'NEWEST',
        authorId: '550e8400-e29b-41d4-a716-446655440000',
      ),
    ).called(1);
    expect(page.cursor, 'cursor-2');
    expect(page.hasMore, isTrue);

    final floor = page.items.single;
    expect(floor.id, 'floor-7');
    expect(floor.floorNumber, 7);
    expect(floor.author.username, '楼层作者');
    expect(floor.author.level, 2);
    expect(floor.body.markdown, '楼层正文 {{dice:FLOOR-ROLL}}');
    expect(floor.body.diceRolls.single.nodeId, 'floor-roll');
    expect(floor.body.diceRolls.single.results, [6]);
    expect(floor.body.diceRolls.single.total, 6);
    expect(floor.createdAt, DateTime.utc(2026, 8, 9, 13));
    expect(floor.isDeleted, isFalse);
    expect(floor.replyCount, 6);

    final reply = floor.replies.single;
    expect(reply.id, 'reply-1');
    expect(reply.author.username, '回复作者');
    expect(reply.body.markdown, '回复正文 {{dice:REPLY-ROLL}}');
    expect(reply.body.diceRolls.single.nodeId, 'reply-roll');
    expect(reply.body.diceRolls.single.results, [2, 3]);
    expect(reply.body.diceRolls.single.total, 5);
    expect(reply.replyToUsername, '被回复用户');
    expect(reply.createdAt, DateTime.utc(2026, 8, 9, 13, 5));
    expect(reply.isDeleted, isTrue);
  });

  test('帖子定位直接映射主楼层上下文', () async {
    final threadsApi = _MockThreadsApi();
    final postsApi = _MockPostsApi();
    when(() => postsApi.postsFindById(id: 'floor-7')).thenAnswer(
      (_) async => _postDetailResponse(
        _postDetail(id: 'floor-7', floorNumber: 7, content: '目标楼层'),
      ),
    );

    final target = await ApiThreadDetailRepository(
      threadsApi,
      postsApi,
    ).fetchPostTarget('floor-7');

    verify(() => postsApi.postsFindById(id: 'floor-7')).called(1);
    expect(target.threadId, 'thread-1');
    expect(target.subthreadId, 'subthread-early');
    expect(target.floor.id, 'floor-7');
    expect(target.floor.floorNumber, 7);
    expect(target.floor.body.markdown, '目标楼层');
    expect(target.focusedReplyId, isNull);
  });

  test('楼层列表与帖子定位允许顶层楼层携带 replyToPostId', () async {
    final threadsApi = _MockThreadsApi();
    final postsApi = _MockPostsApi();
    when(
      () => postsApi.postsFindFloors(
        subthreadId: 'subthread-early',
        cursor: null,
        limit: 20,
        order: 'OLDEST',
        authorId: null,
      ),
    ).thenAnswer(
      (_) async => _nullableFloorsResponse(
        _floorsEnvelope(floors: [_floor(replyToPostId: 'reply-target')]),
      ),
    );
    when(() => postsApi.postsFindById(id: 'floor-7')).thenAnswer(
      (_) async => _postDetailResponse(
        _postDetail(
          id: 'floor-7',
          floorNumber: 7,
          replyToPostId: 'reply-target',
          content: '目标楼层',
        ),
      ),
    );
    final repository = ApiThreadDetailRepository(threadsApi, postsApi);

    final page = await repository.fetchFloors(subthreadId: 'subthread-early');
    final target = await repository.fetchPostTarget('floor-7');

    expect(page.items.single.id, 'floor-7');
    expect(page.items.single.floorNumber, 7);
    expect(target.floor.id, 'floor-7');
    expect(target.focusedReplyId, isNull);
    verifyNever(() => postsApi.postsFindById(id: 'reply-target'));
  });

  test('楼中楼定位补取父楼层并注入目标回复', () async {
    final threadsApi = _MockThreadsApi();
    final postsApi = _MockPostsApi();
    when(() => postsApi.postsFindById(id: 'reply-7')).thenAnswer(
      (_) async => _postDetailResponse(
        _postDetail(id: 'reply-7', parentPostId: 'floor-7', content: '目标回复'),
      ),
    );
    when(() => postsApi.postsFindById(id: 'floor-7')).thenAnswer(
      (_) async => _postDetailResponse(
        _postDetail(id: 'floor-7', floorNumber: 7, content: '父楼层'),
      ),
    );

    final target = await ApiThreadDetailRepository(
      threadsApi,
      postsApi,
    ).fetchPostTarget('reply-7');

    verifyInOrder([
      () => postsApi.postsFindById(id: 'reply-7'),
      () => postsApi.postsFindById(id: 'floor-7'),
    ]);
    expect(target.floor.id, 'floor-7');
    expect(target.floor.body.markdown, '父楼层');
    expect(target.focusedReplyId, 'reply-7');
    expect(target.floor.replies.single.id, 'reply-7');
    expect(target.floor.replies.single.body.markdown, '目标回复');
  });

  test('主题详情拒绝空响应、错主题和跨主题子贴', () async {
    final responses = <Response<ThreadsFindById200Response>>[
      Response(requestOptions: RequestOptions(path: '/threads/thread-1')),
      _threadDetailResponse(
        detail: _threadDetail().rebuild(
          (builder) => builder.id = 'other-thread',
        ),
      ),
      _threadDetailResponse(
        detail: _threadDetail().rebuild(
          (builder) => builder.subthreads[0] = builder.subthreads[0].rebuild(
            (subthread) => subthread.threadId = 'other-thread',
          ),
        ),
      ),
      _threadDetailResponse(
        detail: _threadDetail().rebuild(
          (builder) => builder.defaultSubthreadId = 'missing-subthread',
        ),
      ),
    ];

    for (final response in responses) {
      final threadsApi = _MockThreadsApi();
      when(
        () => threadsApi.threadsFindById(id: 'thread-1'),
      ).thenAnswer((_) async => response);

      await expectLater(
        ApiThreadDetailRepository(
          threadsApi,
          _MockPostsApi(),
        ).fetchThread('thread-1'),
        throwsA(isA<ApiFailure>()),
      );
    }
  });

  test('主题详情允许恢复窗口暂无默认子贴', () async {
    final threadsApi = _MockThreadsApi();
    when(() => threadsApi.threadsFindById(id: 'thread-1')).thenAnswer(
      (_) async => _threadDetailResponse(
        detail: _threadDetail().rebuild(
          (builder) => builder.defaultSubthreadId = null,
        ),
      ),
    );

    final detail = await ApiThreadDetailRepository(
      threadsApi,
      _MockPostsApi(),
    ).fetchThread('thread-1');

    expect(detail.defaultSubthreadId, isNull);
    expect(detail.subthreads, isNotEmpty);
  });

  test('楼层列表拒绝空响应、无效游标和层级或归属错配', () async {
    final invalidEnvelopes = <PostsFindFloors200Response?>[
      null,
      _floorsEnvelope(hasMore: true),
      _floorsEnvelope(cursor: '', hasMore: true),
      _floorsEnvelope(
        floors: [
          _floor().rebuild(
            (builder) => builder.subthreadId = 'other-subthread',
          ),
        ],
      ),
      _floorsEnvelope(
        floors: [
          _floor().rebuild(
            (builder) => builder
              ..kind = FloorResponseDtoKindEnum.BODY
              ..floorNumber = null,
          ),
        ],
      ),
      _floorsEnvelope(
        floors: [
          _floor().rebuild((builder) => builder.parentPostId = 'parent'),
        ],
      ),
      _floorsEnvelope(
        floors: [
          _floor().rebuild(
            (builder) => builder.replies[0] = builder.replies[0].rebuild(
              (reply) => reply.parentPostId = 'other-floor',
            ),
          ),
        ],
      ),
      _floorsEnvelope(
        floors: [
          _floor().rebuild(
            (builder) => builder.replies[0] = builder.replies[0].rebuild(
              (reply) => reply.threadId = 'other-thread',
            ),
          ),
        ],
      ),
    ];

    for (final envelope in invalidEnvelopes) {
      final postsApi = _MockPostsApi();
      when(
        () => postsApi.postsFindFloors(
          subthreadId: 'subthread-early',
          cursor: null,
          limit: 20,
          order: 'OLDEST',
          authorId: null,
        ),
      ).thenAnswer((_) async => _nullableFloorsResponse(envelope));

      await expectLater(
        ApiThreadDetailRepository(
          _MockThreadsApi(),
          postsApi,
        ).fetchFloors(subthreadId: 'subthread-early'),
        throwsA(isA<ApiFailure>()),
      );
    }
  });

  test('帖子定位拒绝错请求 ID、BODY 和父楼摘要错配', () async {
    final invalidTargets = <PostDetailResponseDto?>[
      null,
      _postDetail(id: 'other-reply', parentPostId: 'floor-7', content: '回复'),
      _postDetail(
        id: 'reply-7',
        parentPostId: 'floor-7',
        content: '回复',
      ).rebuild((builder) => builder.kind = PostDetailResponseDtoKindEnum.BODY),
      _postDetail(
        id: 'reply-7',
        parentPostId: 'floor-7',
        content: '回复',
      ).rebuild((builder) => builder.parentPost.id = 'other-floor'),
    ];

    for (final detail in invalidTargets) {
      final postsApi = _MockPostsApi();
      when(
        () => postsApi.postsFindById(id: 'reply-7'),
      ).thenAnswer((_) async => _nullablePostDetailResponse(detail));
      when(() => postsApi.postsFindById(id: 'floor-7')).thenAnswer(
        (_) async => _postDetailResponse(
          _postDetail(id: 'floor-7', floorNumber: 7, content: '父楼层'),
        ),
      );

      await expectLater(
        ApiThreadDetailRepository(
          _MockThreadsApi(),
          postsApi,
        ).fetchPostTarget('reply-7'),
        throwsA(isA<ApiFailure>()),
      );
      verifyNever(() => postsApi.postsFindById(id: 'floor-7'));
    }
  });

  test('楼中楼定位拒绝跨主题、跨子贴或非根楼层的父帖子', () async {
    final invalidParents = [
      _postDetail(id: 'floor-7', floorNumber: 7, content: '父楼层').rebuild(
        (builder) => builder
          ..threadId = 'other-thread'
          ..thread.id = 'other-thread',
      ),
      _postDetail(id: 'floor-7', floorNumber: 7, content: '父楼层').rebuild(
        (builder) => builder
          ..subthreadId = 'other-subthread'
          ..subthread.id = 'other-subthread',
      ),
      _postDetail(id: 'floor-7', parentPostId: 'grand-floor', content: '非根楼层'),
    ];

    for (final parent in invalidParents) {
      final postsApi = _MockPostsApi();
      when(() => postsApi.postsFindById(id: 'reply-7')).thenAnswer(
        (_) async => _postDetailResponse(
          _postDetail(id: 'reply-7', parentPostId: 'floor-7', content: '回复'),
        ),
      );
      when(
        () => postsApi.postsFindById(id: 'floor-7'),
      ).thenAnswer((_) async => _postDetailResponse(parent));

      await expectLater(
        ApiThreadDetailRepository(
          _MockThreadsApi(),
          postsApi,
        ).fetchPostTarget('reply-7'),
        throwsA(isA<ApiFailure>()),
      );
    }
  });
}

class _MockThreadsApi extends Mock implements ThreadsApi {}

class _MockPostsApi extends Mock implements PostsApi {}

Response<ThreadsFindById200Response> _threadDetailResponse({
  ThreadDetailResponseDto? detail,
}) {
  return Response<ThreadsFindById200Response>(
    requestOptions: RequestOptions(path: '/api/v1/threads/thread-1'),
    data: ThreadsFindById200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(detail ?? _threadDetail()),
    ),
  );
}

ThreadDetailResponseDto _threadDetail() {
  final createdAt = DateTime.utc(2026, 8, 8, 10);
  final updatedAt = DateTime.utc(2026, 8, 9, 12);
  return ThreadDetailResponseDto(
    (thread) => thread
      ..id = 'thread-1'
      ..title = '  星海旅团  '
      ..ownerId = 'owner-1'
      ..category = 'RPG'
      ..status = ThreadDetailResponseDtoStatusEnum.CLOSED
      ..visibility = ThreadDetailResponseDtoVisibilityEnum.PRIVATE
      ..published = true
      ..publishedAt = createdAt
      ..pinned = true
      ..pinnedAt = createdAt
      ..viewCount = 128
      ..version = 4
      ..likeCount = 12
      ..isLiked = true
      ..isBookmarked = true
      ..bookmarkId = 'bookmark-1'
      ..currentMembership.replace(
        CurrentThreadMembershipResponseDto(
          (membership) => membership
            ..id = 'member-1'
            ..userId = 'collaborator-1'
            ..role = CurrentThreadMembershipResponseDtoRoleEnum.COLLABORATOR
            ..playerMarked = false,
        ),
      )
      ..capabilities.replace(
        ThreadCapabilitiesResponseDto(
          (capabilities) => capabilities
            ..canManageThread = true
            ..canManageMembers = true
            ..isOwner = false,
        ),
      )
      ..tipTotal = '42'
      ..defaultSubthreadId = 'subthread-early'
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..owner.replace(
        _author(
          id: 'owner-1',
          username: '温柔测试员',
          level: 4,
          avatar: 'https://cdn.example.com/owner.png',
        ),
      )
      ..subthreads.addAll([
        _subthread(
          id: 'subthread-late',
          title: '支线',
          sortOrder: 20,
          postCount: 7,
          postingPolicy:
              ThreadSubthreadResponseDtoPostingPolicyEnum.COLLABORATORS,
        ),
        _subthread(
          id: 'subthread-deleted',
          title: '已删除',
          sortOrder: 0,
          postCount: 1,
          postingPolicy:
              ThreadSubthreadResponseDtoPostingPolicyEnum.PARTICIPANTS,
          deletedAt: updatedAt,
        ),
        _subthread(
          id: 'subthread-early',
          title: '主线',
          sortOrder: 10,
          postCount: 14,
          postingPolicy: ThreadSubthreadResponseDtoPostingPolicyEnum.PLAYERS,
          lastPostAt: DateTime.utc(2026, 8, 9, 11),
          body: ThreadBodyPostResponseDto(
            (post) => post
              ..id = 'body-1'
              ..content = '正文 {{dice:ROLL-BODY}}'
              ..version = 2
              ..diceRolls.add(
                _diceRoll(
                  id: 'dice-body',
                  postId: 'body-1',
                  nodeId: 'ROLL-BODY',
                  notation: '2d6+1',
                  results: [4, 5],
                  total: 10,
                ),
              ),
          ),
        ),
      ])
      ..topicTags.add(
        ThreadTagRelationResponseDto(
          (relation) => relation
            ..id = 'relation-1'
            ..threadId = 'thread-1'
            ..tagId = 'tag-1'
            ..tag.update(
              (tag) => tag
                ..id = 'tag-1'
                ..name = '太空歌剧'
                ..sortOrder = 1
                ..isActive = true,
            ),
        ),
      )
      ..count.update(
        (count) => count
          ..members = 8
          ..players = 3
          ..posts = 21,
      ),
  );
}

ThreadSubthreadResponseDto _subthread({
  required String id,
  required String title,
  required int sortOrder,
  required int postCount,
  required ThreadSubthreadResponseDtoPostingPolicyEnum postingPolicy,
  DateTime? lastPostAt,
  DateTime? deletedAt,
  ThreadBodyPostResponseDto? body,
}) {
  return ThreadSubthreadResponseDto((subthread) {
    subthread
      ..id = id
      ..threadId = 'thread-1'
      ..title = title
      ..sortOrder = sortOrder
      ..postingPolicy = postingPolicy
      ..postingCapability.update((capability) => capability.canPost = true)
      ..version = 1
      ..lastPostAt = lastPostAt
      ..deletedAt = deletedAt
      ..createdAt = DateTime.utc(2026, 8, 8)
      ..count.update((count) => count.posts = postCount);
    if (body != null) {
      subthread.bodyPost.replace(body);
    }
  });
}

Response<PostsFindFloors200Response> _floorsResponse() {
  return Response<PostsFindFloors200Response>(
    requestOptions: RequestOptions(
      path: '/api/v1/subthreads/subthread-early/posts',
    ),
    data: PostsFindFloors200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..meta.update(
          (meta) => meta
            ..cursor = 'cursor-2'
            ..hasMore = true,
        )
        ..data.add(_floor()),
    ),
  );
}

PostsFindFloors200Response _floorsEnvelope({
  List<FloorResponseDto>? floors,
  String? cursor,
  bool hasMore = false,
}) {
  return PostsFindFloors200Response(
    (response) => response
      ..code = ApiSuccessEnvelopeCodeEnum.number0
      ..message = 'ok'
      ..meta.update(
        (meta) => meta
          ..cursor = cursor
          ..hasMore = hasMore,
      )
      ..data.addAll(floors ?? [_floor()]),
  );
}

Response<PostsFindFloors200Response> _nullableFloorsResponse(
  PostsFindFloors200Response? envelope,
) {
  return Response(
    requestOptions: RequestOptions(path: '/subthreads/subthread-early/posts'),
    data: envelope,
  );
}

FloorResponseDto _floor({String? replyToPostId}) {
  final createdAt = DateTime.utc(2026, 8, 9, 13);
  return FloorResponseDto(
    (floor) => floor
      ..id = 'floor-7'
      ..threadId = 'thread-1'
      ..subthreadId = 'subthread-early'
      ..authorId = 'floor-author'
      ..kind = FloorResponseDtoKindEnum.FLOOR
      ..floorNumber = 7
      ..replyToPostId = replyToPostId
      ..content = '楼层正文 {{dice:FLOOR-ROLL}}'
      ..diceRolls.add(
        _diceRoll(
          id: 'dice-floor',
          postId: 'floor-7',
          nodeId: 'FLOOR-ROLL',
          notation: '1d6',
          results: [6],
          total: 6,
        ),
      )
      ..version = 3
      ..createdAt = createdAt
      ..updatedAt = createdAt
      ..author.replace(_author(id: 'floor-author', username: '楼层作者', level: 2))
      ..count.update((count) => count.replies = 6)
      ..replies.add(_reply()),
  );
}

ReplyResponseDto _reply() {
  final createdAt = DateTime.utc(2026, 8, 9, 13, 5);
  return ReplyResponseDto(
    (reply) => reply
      ..id = 'reply-1'
      ..threadId = 'thread-1'
      ..subthreadId = 'subthread-early'
      ..authorId = 'reply-author'
      ..kind = ReplyResponseDtoKindEnum.FLOOR
      ..parentPostId = 'floor-7'
      ..replyToPostId = 'reply-target'
      ..content = '回复正文 {{dice:REPLY-ROLL}}'
      ..diceRolls.add(
        _diceRoll(
          id: 'dice-reply',
          postId: 'reply-1',
          nodeId: 'REPLY-ROLL',
          notation: '2d4',
          results: [2, 3],
          total: 5,
        ),
      )
      ..version = 2
      ..createdAt = createdAt
      ..updatedAt = createdAt
      ..deletedAt = createdAt.add(const Duration(minutes: 1))
      ..author.replace(_author(id: 'reply-author', username: '回复作者', level: 3))
      ..replyToPost.update(
        (target) => target
          ..id = 'reply-target'
          ..authorId = 'target-author'
          ..author.replace(
            _author(id: 'target-author', username: '被回复用户', level: 5),
          ),
      ),
  );
}

PostAuthorResponseDto _author({
  required String id,
  required String username,
  required int level,
  String? avatar,
}) {
  return PostAuthorResponseDto(
    (author) => author
      ..id = id
      ..username = username
      ..avatar = avatar
      ..level = level,
  );
}

DiceRollResponseDto _diceRoll({
  required String id,
  required String postId,
  required String nodeId,
  required String notation,
  required List<int> results,
  required int total,
}) {
  return DiceRollResponseDto(
    (roll) => roll
      ..id = id
      ..postId = postId
      ..nodeId = nodeId
      ..protocolVersion = 2
      ..notation = notation
      ..quantity = results.length
      ..sides = 6
      ..modifier = 0
      ..results.addAll(results)
      ..total = total
      ..createdAt = DateTime.utc(2026, 8, 9, 13),
  );
}

Response<PostsFindById200Response> _postDetailResponse(
  PostDetailResponseDto detail,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/posts/${detail.id}'),
    data: PostsFindById200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(detail),
    ),
  );
}

Response<PostsFindById200Response> _nullablePostDetailResponse(
  PostDetailResponseDto? detail,
) {
  if (detail == null) {
    return Response(
      requestOptions: RequestOptions(path: '/api/v1/posts/reply-7'),
    );
  }
  return _postDetailResponse(detail);
}

PostDetailResponseDto _postDetail({
  required String id,
  required String content,
  int? floorNumber,
  String? parentPostId,
  String? replyToPostId,
}) {
  final createdAt = DateTime.utc(2026, 8, 10, 8);
  return PostDetailResponseDto((post) {
    post
      ..id = id
      ..threadId = 'thread-1'
      ..subthreadId = 'subthread-early'
      ..authorId = 'post-author'
      ..kind = PostDetailResponseDtoKindEnum.FLOOR
      ..floorNumber = floorNumber
      ..parentPostId = parentPostId
      ..replyToPostId = replyToPostId
      ..content = content
      ..version = 1
      ..createdAt = createdAt
      ..updatedAt = createdAt
      ..author.replace(_author(id: 'post-author', username: '定位作者', level: 2))
      ..thread.update(
        (thread) => thread
          ..id = 'thread-1'
          ..title = '星海旅团',
      )
      ..subthread.update(
        (subthread) => subthread
          ..id = 'subthread-early'
          ..title = '主线',
      )
      ..count.update((count) => count.replies = parentPostId == null ? 3 : 0);
    if (parentPostId != null) {
      post.parentPost.update(
        (parent) => parent
          ..id = parentPostId
          ..floorNumber = 7,
      );
    }
  });
}
