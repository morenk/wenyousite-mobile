import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';

void main() {
  test('订阅列表只映射当前主题的 THREAD 与 USER 记录', () async {
    final subscriptionsApi = _MockSubscriptionsApi();
    when(
      subscriptionsApi.subscriptionsFindAll,
    ).thenAnswer((_) async => _subscriptionsResponse());
    final repository = ApiThreadSubscriptionRepository(
      subscriptionsApi,
      _MockThreadsApi(),
    );

    final records = await repository.fetchSubscriptions('thread-1');

    expect(records, hasLength(2));
    expect(records.first.type, ThreadSubscriptionType.thread);
    expect(records.last.type, ThreadSubscriptionType.user);
    expect(records.last.targetUserId, 'player-1');
  });

  test('玩家候选仅保留已标记普通玩家并排除当前用户', () async {
    final threadsApi = _MockThreadsApi();
    when(
      () => threadsApi.threadMembersFindAll(threadId: 'thread-1'),
    ).thenAnswer((_) async => _membersResponse());
    final repository = ApiThreadSubscriptionRepository(
      _MockSubscriptionsApi(),
      threadsApi,
    );

    final candidates = await repository.fetchCandidates(
      'thread-1',
      viewerUserId: 'self-player',
    );

    expect(candidates.map((item) => item.userId), ['player-1']);
    expect(candidates.single.username, '骰子猫');
  });

  test('创建两类订阅提交正确 DTO，并按记录 ID 取消', () async {
    final subscriptionsApi = _MockSubscriptionsApi();
    final threadDto = CreateSubscriptionDto(
      (builder) => builder
        ..threadId = 'thread-1'
        ..type = CreateSubscriptionDtoTypeEnum.THREAD,
    );
    final userDto = CreateSubscriptionDto(
      (builder) => builder
        ..threadId = 'thread-1'
        ..type = CreateSubscriptionDtoTypeEnum.USER
        ..targetUserId = 'player-1',
    );
    when(
      () => subscriptionsApi.subscriptionsCreate(
        createSubscriptionDto: threadDto,
      ),
    ).thenAnswer((_) async => _createResponse(_subscription(id: 'official-1')));
    when(
      () =>
          subscriptionsApi.subscriptionsCreate(createSubscriptionDto: userDto),
    ).thenAnswer(
      (_) async => _createResponse(
        _subscription(
          id: 'user-sub-1',
          type: SubscriptionResponseDtoTypeEnum.USER,
          targetUserId: 'player-1',
        ),
      ),
    );
    when(
      () => subscriptionsApi.subscriptionsRemove(id: 'user-sub-1'),
    ).thenAnswer((_) async => _removeResponse());
    final repository = ApiThreadSubscriptionRepository(
      subscriptionsApi,
      _MockThreadsApi(),
    );

    expect(
      (await repository.create(
        threadId: 'thread-1',
        type: ThreadSubscriptionType.thread,
      )).id,
      'official-1',
    );
    expect(
      (await repository.create(
        threadId: 'thread-1',
        type: ThreadSubscriptionType.user,
        targetUserId: 'player-1',
      )).id,
      'user-sub-1',
    );
    await repository.remove('user-sub-1');

    verify(
      () => subscriptionsApi.subscriptionsCreate(
        createSubscriptionDto: threadDto,
      ),
    ).called(1);
    verify(
      () =>
          subscriptionsApi.subscriptionsCreate(createSubscriptionDto: userDto),
    ).called(1);
    verify(
      () => subscriptionsApi.subscriptionsRemove(id: 'user-sub-1'),
    ).called(1);
  });

  test('订阅端点空响应不伪装成空列表或成功', () async {
    final subscriptionsApi = _MockSubscriptionsApi();
    when(subscriptionsApi.subscriptionsFindAll).thenAnswer(
      (_) async => Response<SubscriptionsFindAll200Response>(
        requestOptions: RequestOptions(path: '/api/v1/subscriptions'),
      ),
    );
    final repository = ApiThreadSubscriptionRepository(
      subscriptionsApi,
      _MockThreadsApi(),
    );

    await expectLater(
      repository.fetchSubscriptions('thread-1'),
      throwsA(isA<ApiFailure>()),
    );
  });
}

class _MockSubscriptionsApi extends Mock implements SubscriptionsApi {}

class _MockThreadsApi extends Mock implements ThreadsApi {}

Response<SubscriptionsFindAll200Response> _subscriptionsResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/subscriptions'),
    data: SubscriptionsFindAll200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.addAll([
          _subscription(id: 'official-1'),
          _subscription(
            id: 'user-sub-1',
            type: SubscriptionResponseDtoTypeEnum.USER,
            targetUserId: 'player-1',
          ),
          _subscription(id: 'other-thread', threadId: 'thread-2'),
        ]),
    ),
  );
}

Response<SubscriptionsCreate201Response> _createResponse(
  SubscriptionResponseDto subscription,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/subscriptions'),
    data: SubscriptionsCreate201Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(subscription),
    ),
  );
}

Response<SubscriptionsRemove200Response> _removeResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/subscriptions/user-sub-1'),
    data: SubscriptionsRemove200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '已取消订阅'),
    ),
  );
}

SubscriptionResponseDto _subscription({
  required String id,
  String threadId = 'thread-1',
  SubscriptionResponseDtoTypeEnum type = SubscriptionResponseDtoTypeEnum.THREAD,
  String? targetUserId,
}) {
  return SubscriptionResponseDto(
    (dto) => dto
      ..id = id
      ..userId = 'viewer-1'
      ..threadId = threadId
      ..targetUserId = targetUserId
      ..type = type
      ..createdAt = DateTime.utc(2026, 8, 10)
      ..thread.update(
        (thread) => thread
          ..id = threadId
          ..title = '雾港来信',
      ),
  );
}

Response<ThreadMembersFindAll200Response> _membersResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads/thread-1/members'),
    data: ThreadMembersFindAll200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.addAll([
          _member('player-1', playerMarked: true, username: '骰子猫'),
          _member('self-player', playerMarked: true),
          _member('not-player', playerMarked: false),
          _member(
            'collaborator',
            playerMarked: true,
            role: ThreadMemberResponseDtoRoleEnum.COLLABORATOR,
          ),
        ]),
    ),
  );
}

ThreadMemberResponseDto _member(
  String userId, {
  required bool playerMarked,
  String username = '用户',
  ThreadMemberResponseDtoRoleEnum role =
      ThreadMemberResponseDtoRoleEnum.PARTICIPANT,
}) {
  return ThreadMemberResponseDto(
    (member) => member
      ..id = 'member-$userId'
      ..threadId = 'thread-1'
      ..userId = userId
      ..role = role
      ..playerMarked = playerMarked
      ..joinedAt = DateTime.utc(2026, 8, 10)
      ..user.update(
        (user) => user
          ..id = userId
          ..username = username
          ..level = 3,
      ),
  );
}
