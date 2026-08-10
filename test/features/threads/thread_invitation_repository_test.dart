import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_invitation_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_invitation_models.dart';

void main() {
  test('生成邀请链接校验主题并组合当前 Web origin', () async {
    final api = _MockThreadsApi();
    when(
      () => api.threadsCreateInviteLink(id: 'thread-1'),
    ).thenAnswer((_) async => _inviteLinkResponse());

    final result = await ApiThreadInvitationRepository(
      api,
      'https://wenyou.site',
    ).generateLink('thread-1');

    expect(result.threadId, 'thread-1');
    expect(result.token, 'Abcd_1234-efGh56');
    expect(result.url.toString(), 'https://wenyou.site/join/Abcd_1234-efGh56');
  });

  test('生成邀请响应目标不一致时不返回可分享链接', () async {
    final api = _MockThreadsApi();
    when(
      () => api.threadsCreateInviteLink(id: 'thread-1'),
    ).thenAnswer((_) async => _inviteLinkResponse(threadId: 'other-thread'));

    await expectLater(
      ApiThreadInvitationRepository(
        api,
        'https://wenyou.site',
      ).generateLink('thread-1'),
      throwsA(isA<ApiFailure>()),
    );
  });

  test('预览映射私密主题概要与已加入事实', () async {
    final api = _MockThreadsApi();
    when(
      () => api.threadsPreviewInviteLink(token: 'Abcd_1234-efGh56'),
    ).thenAnswer((_) async => _previewResponse(alreadyJoined: true));

    final preview = await ApiThreadInvitationRepository(
      api,
      'https://wenyou.site',
    ).preview('Abcd_1234-efGh56');

    expect(preview.threadId, 'thread-1');
    expect(preview.title, '星海密谈');
    expect(preview.categorySlug, 'RPG');
    expect(preview.status, ThreadInvitationStatus.recruiting);
    expect(preview.ownerId, 'owner-1');
    expect(preview.ownerName, '楼主');
    expect(preview.memberCount, 8);
    expect(preview.alreadyJoined, isTrue);
  });

  test('格式错误的邀请 token 在发请求前确定失败', () async {
    final api = _MockThreadsApi();

    await expectLater(
      ApiThreadInvitationRepository(
        api,
        'https://wenyou.site',
      ).preview('invalid'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.businessCode,
          'businessCode',
          40408,
        ),
      ),
    );
    verifyNever(() => api.threadsPreviewInviteLink(token: any(named: 'token')));
  });

  test('幂等加入映射成员与稳定主题目标', () async {
    final api = _MockThreadsApi();
    when(
      () => api.threadsJoinByInviteLink(token: 'Abcd_1234-efGh56'),
    ).thenAnswer((_) async => _joinResponse());

    final joined = await ApiThreadInvitationRepository(
      api,
      'https://wenyou.site',
    ).join('Abcd_1234-efGh56');

    expect(joined.memberId, 'member-1');
    expect(joined.threadId, 'thread-1');
    expect(joined.threadTitle, '星海密谈');
    expect(joined.userId, 'user-1');
  });

  test('加入响应中的主题目标不一致时拒绝导航', () async {
    final api = _MockThreadsApi();
    when(
      () => api.threadsJoinByInviteLink(token: 'Abcd_1234-efGh56'),
    ).thenAnswer((_) async => _joinResponse(threadReferenceId: 'other'));

    await expectLater(
      ApiThreadInvitationRepository(
        api,
        'https://wenyou.site',
      ).join('Abcd_1234-efGh56'),
      throwsA(isA<ApiFailure>()),
    );
  });
}

class _MockThreadsApi extends Mock implements ThreadsApi {}

Response<ThreadsCreateInviteLink200Response> _inviteLinkResponse({
  String threadId = 'thread-1',
}) {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/threads/thread-1/invite-link',
    ),
    data: ThreadsCreateInviteLink200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (invite) => invite
            ..id = 'invite-1'
            ..threadId = threadId
            ..token = 'Abcd_1234-efGh56'
            ..createdAt = DateTime.utc(2026, 8, 10),
        ),
    ),
  );
}

Response<ThreadsPreviewInviteLink200Response> _previewResponse({
  bool alreadyJoined = false,
}) {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/threads/join-by-link/<redacted>',
    ),
    data: ThreadsPreviewInviteLink200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (preview) => preview
            ..alreadyJoined = alreadyJoined
            ..thread.update(
              (thread) => thread
                ..id = 'thread-1'
                ..title = ' 星海密谈 '
                ..category = 'RPG'
                ..status = InviteThreadPreviewResponseDtoStatusEnum.RECRUITING
                ..memberCount = 8
                ..createdAt = DateTime.utc(2026, 8, 9)
                ..owner.update(
                  (owner) => owner
                    ..id = 'owner-1'
                    ..username = '楼主'
                    ..avatar = 'https://cdn.example.com/owner.png',
                ),
            ),
        ),
    ),
  );
}

Response<ThreadsJoinByInviteLink200Response> _joinResponse({
  String threadReferenceId = 'thread-1',
}) {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/threads/join-by-link/<redacted>',
    ),
    data: ThreadsJoinByInviteLink200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (member) => member
            ..id = 'member-1'
            ..threadId = 'thread-1'
            ..userId = 'user-1'
            ..role = JoinedThreadMemberResponseDtoRoleEnum.PARTICIPANT
            ..playerMarked = false
            ..joinedAt = DateTime.utc(2026, 8, 10)
            ..user.update(
              (user) => user
                ..id = 'user-1'
                ..username = '受邀用户'
                ..level = 2,
            )
            ..thread.update(
              (thread) => thread
                ..id = threadReferenceId
                ..title = '星海密谈',
            ),
        ),
    ),
  );
}
