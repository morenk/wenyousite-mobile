import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_member_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_member_management_models.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ThreadMembersUpdateMemberRequest());
  });

  test('加载详情权限与完整成员候选池', () async {
    final api = _MockThreadsApi();
    when(
      () => api.threadsFindById(id: 'thread-1'),
    ).thenAnswer((_) async => _detailResponse(isOwner: true));
    when(
      () => api.threadMembersFindAll(threadId: 'thread-1'),
    ).thenAnswer((_) async => _membersResponse());

    final result = await ApiThreadMemberManagementRepository(
      api,
    ).load('thread-1');

    expect(result.threadTitle, '星海旅团');
    expect(result.actorIsOwner, isTrue);
    expect(result.members.length, 3);
    expect(result.members[0].role, ThreadMemberManagementRole.owner);
    expect(result.members[1].role, ThreadMemberManagementRole.collaborator);
    expect(result.members[2].playerMarked, isTrue);
  });

  test('没有成员管理 capability 时拒绝进入工作台', () async {
    final api = _MockThreadsApi();
    when(
      () => api.threadsFindById(id: 'thread-1'),
    ).thenAnswer((_) async => _detailResponse(canManage: false));
    when(
      () => api.threadMembersFindAll(threadId: 'thread-1'),
    ).thenAnswer((_) async => _membersResponse());

    await expectLater(
      ApiThreadMemberManagementRepository(api).load('thread-1'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.businessCode,
          'businessCode',
          40300,
        ),
      ),
    );
  });

  test('玩家标记更新只发送 playerMarked', () async {
    final api = _MockThreadsApi();
    when(
      () => api.threadMembersUpdateMember(
        threadId: 'thread-1',
        userId: 'player-1',
        threadMembersUpdateMemberRequest: any(
          named: 'threadMembersUpdateMemberRequest',
        ),
      ),
    ).thenAnswer(
      (_) async => _updateResponse(
        _member(
          id: 'member-player',
          userId: 'player-1',
          username: '玩家甲',
          role: ThreadMemberResponseDtoRoleEnum.PARTICIPANT,
          playerMarked: false,
        ),
      ),
    );

    final updated = await ApiThreadMemberManagementRepository(api).updateMember(
      threadId: 'thread-1',
      userId: 'player-1',
      playerMarked: false,
    );

    final request =
        verify(
              () => api.threadMembersUpdateMember(
                threadId: 'thread-1',
                userId: 'player-1',
                threadMembersUpdateMemberRequest: captureAny(
                  named: 'threadMembersUpdateMemberRequest',
                ),
              ),
            ).captured.single
            as ThreadMembersUpdateMemberRequest;
    expect(request.playerMarked, isFalse);
    expect(request.role, isNull);
    expect(updated.playerMarked, isFalse);
  });

  test('协作者身份更新只发送允许的 role', () async {
    final api = _MockThreadsApi();
    when(
      () => api.threadMembersUpdateMember(
        threadId: 'thread-1',
        userId: 'player-1',
        threadMembersUpdateMemberRequest: any(
          named: 'threadMembersUpdateMemberRequest',
        ),
      ),
    ).thenAnswer(
      (_) async => _updateResponse(
        _member(
          id: 'member-player',
          userId: 'player-1',
          username: '玩家甲',
          role: ThreadMemberResponseDtoRoleEnum.COLLABORATOR,
          playerMarked: true,
        ),
      ),
    );

    await ApiThreadMemberManagementRepository(api).updateMember(
      threadId: 'thread-1',
      userId: 'player-1',
      role: ThreadMemberManagementRole.collaborator,
    );

    final request =
        verify(
              () => api.threadMembersUpdateMember(
                threadId: 'thread-1',
                userId: 'player-1',
                threadMembersUpdateMemberRequest: captureAny(
                  named: 'threadMembersUpdateMemberRequest',
                ),
              ),
            ).captured.single
            as ThreadMembersUpdateMemberRequest;
    expect(request.role, ThreadMembersUpdateMemberRequestRoleEnum.COLLABORATOR);
    expect(request.playerMarked, isNull);
  });

  test('成员更新响应必须匹配请求目标', () async {
    final api = _MockThreadsApi();
    when(
      () => api.threadMembersUpdateMember(
        threadId: any(named: 'threadId'),
        userId: any(named: 'userId'),
        threadMembersUpdateMemberRequest: any(
          named: 'threadMembersUpdateMemberRequest',
        ),
      ),
    ).thenAnswer(
      (_) async => _updateResponse(
        _member(
          id: 'wrong',
          userId: 'other-user',
          username: '错误用户',
          role: ThreadMemberResponseDtoRoleEnum.PARTICIPANT,
          playerMarked: true,
        ),
      ),
    );

    await expectLater(
      ApiThreadMemberManagementRepository(api).updateMember(
        threadId: 'thread-1',
        userId: 'player-1',
        playerMarked: true,
      ),
      throwsA(isA<ApiFailure>()),
    );
  });

  test('退出玩家身份必须得到非空服务端确认', () async {
    final api = _MockThreadsApi();
    when(() => api.threadMembersExitMember(threadId: 'thread-1')).thenAnswer(
      (_) async => Response<ThreadMembersExitMember200Response>(
        requestOptions: RequestOptions(
          path: '/api/v1/threads/thread-1/members/me',
        ),
      ),
    );

    await expectLater(
      ApiThreadMemberManagementRepository(api).exitPlayer('thread-1'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'userMessage',
          contains('退出失败'),
        ),
      ),
    );
  });

  test('退出玩家身份接受带消息的服务端确认', () async {
    final api = _MockThreadsApi();
    when(() => api.threadMembersExitMember(threadId: 'thread-1')).thenAnswer(
      (_) async => Response<ThreadMembersExitMember200Response>(
        requestOptions: RequestOptions(
          path: '/api/v1/threads/thread-1/members/me',
        ),
        data: ThreadMembersExitMember200Response(
          (response) => response
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.update((message) => message.message = '已退出玩家身份'),
        ),
      ),
    );

    await ApiThreadMemberManagementRepository(api).exitPlayer('thread-1');

    verify(() => api.threadMembersExitMember(threadId: 'thread-1')).called(1);
  });
}

class _MockThreadsApi extends Mock implements ThreadsApi {}

Response<ThreadsFindById200Response> _detailResponse({
  bool isOwner = false,
  bool canManage = true,
}) {
  final now = DateTime.utc(2026, 8, 10);
  final membershipRole = isOwner
      ? CurrentThreadMembershipResponseDtoRoleEnum.OWNER
      : canManage
      ? CurrentThreadMembershipResponseDtoRoleEnum.COLLABORATOR
      : CurrentThreadMembershipResponseDtoRoleEnum.PARTICIPANT;
  final detail = ThreadDetailResponseDto(
    (thread) => thread
      ..id = 'thread-1'
      ..title = '星海旅团'
      ..ownerId = 'owner-1'
      ..category = 'RPG'
      ..status = ThreadDetailResponseDtoStatusEnum.RECRUITING
      ..visibility = ThreadDetailResponseDtoVisibilityEnum.PUBLIC
      ..published = true
      ..pinned = false
      ..viewCount = 0
      ..version = 1
      ..likeCount = 0
      ..tipTotal = '0'
      ..createdAt = now
      ..updatedAt = now
      ..owner.update(
        (owner) => owner
          ..id = 'owner-1'
          ..username = '楼主'
          ..level = 1,
      )
      ..count.update(
        (count) => count
          ..members = 3
          ..posts = 1
          ..players = 1,
      )
      ..currentMembership.update(
        (membership) => membership
          ..id = 'actor-membership'
          ..userId = isOwner ? 'owner-1' : 'actor-1'
          ..role = membershipRole
          ..playerMarked = false,
      )
      ..capabilities.update(
        (capabilities) => capabilities
          ..canManageThread = canManage
          ..canManageMembers = canManage
          ..isOwner = isOwner,
      ),
  );
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads/thread-1'),
    data: ThreadsFindById200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(detail),
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
          _member(
            id: 'member-owner',
            userId: 'owner-1',
            username: '楼主',
            role: ThreadMemberResponseDtoRoleEnum.OWNER,
            playerMarked: false,
          ),
          _member(
            id: 'member-collaborator',
            userId: 'collaborator-1',
            username: '协作者',
            role: ThreadMemberResponseDtoRoleEnum.COLLABORATOR,
            playerMarked: false,
          ),
          _member(
            id: 'member-player',
            userId: 'player-1',
            username: '玩家甲',
            role: ThreadMemberResponseDtoRoleEnum.PARTICIPANT,
            playerMarked: true,
          ),
        ]),
    ),
  );
}

Response<ThreadMembersUpdateMember200Response> _updateResponse(
  ThreadMemberResponseDto member,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads/thread-1/members'),
    data: ThreadMembersUpdateMember200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(member),
    ),
  );
}

ThreadMemberResponseDto _member({
  required String id,
  required String userId,
  required String username,
  required ThreadMemberResponseDtoRoleEnum role,
  required bool playerMarked,
}) {
  return ThreadMemberResponseDto(
    (member) => member
      ..id = id
      ..threadId = 'thread-1'
      ..userId = userId
      ..role = role
      ..playerMarked = playerMarked
      ..joinedAt = DateTime.utc(2026, 8, 10)
      ..user.update(
        (user) => user
          ..id = userId
          ..username = username
          ..level = 2,
      ),
  );
}
