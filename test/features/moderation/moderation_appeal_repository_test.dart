import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/features/moderation/data/moderation_appeal_repository.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeIssueAppealTokenDto());
    registerFallbackValue(_FakeCreateModerationAppealDto());
  });

  test('账号密码只换取内存申诉凭据并显式跳过普通会话鉴权', () async {
    final api = _MockModerationAppealsApi();
    when(
      () => api.userModerationAppealsIssueToken(
        issueAppealTokenDto: any(named: 'issueAppealTokenDto'),
        extra: any(named: 'extra'),
      ),
    ).thenAnswer((_) async => _credentialResponse());

    final credential = await ApiModerationAppealRepository(
      api,
    ).issueCredential(account: '  tester  ', password: 'password123');

    final invocation = verify(
      () => api.userModerationAppealsIssueToken(
        issueAppealTokenDto: captureAny(named: 'issueAppealTokenDto'),
        extra: captureAny(named: 'extra'),
      ),
    ).captured;
    final dto = invocation[0] as IssueAppealTokenDto;
    final extra = invocation[1] as Map<String, dynamic>;
    expect(dto.account, 'tester');
    expect(dto.password, 'password123');
    expect(extra['skipAuth'], isTrue);
    expect(credential.token, 'appeal-token');
    expect(credential.expiresAt, DateTime.utc(2026, 8, 12, 12, 15));
  });

  test('专用凭据读取决定时隔离 Authorization 且映射公开字段', () async {
    final api = _MockModerationAppealsApi();
    when(
      () => api.userModerationAppealsMine(
        headers: any(named: 'headers'),
        extra: any(named: 'extra'),
      ),
    ).thenAnswer((_) async => _decisionsResponse());

    final decisions = await ApiModerationAppealRepository(
      api,
    ).fetchMyDecisions(appealToken: 'appeal-token');

    final invocation = verify(
      () => api.userModerationAppealsMine(
        headers: captureAny(named: 'headers'),
        extra: captureAny(named: 'extra'),
      ),
    ).captured;
    expect(invocation[0], <String, dynamic>{
      'Authorization': 'Bearer appeal-token',
    });
    expect((invocation[1] as Map<String, dynamic>)['skipAuth'], isTrue);
    expect(decisions, hasLength(1));
    expect(decisions.single.actionLabel, '暂停账号');
    expect(decisions.single.targetTypeLabel, '账号');
    expect(decisions.single.publicExplanation, '多次骚扰其他用户。');
  });

  test('提交申诉校验 typed decision 与 appellant 后才算成功', () async {
    final api = _MockModerationAppealsApi();
    when(
      () => api.userModerationAppealsAppeal(
        createModerationAppealDto: any(named: 'createModerationAppealDto'),
        headers: any(named: 'headers'),
        extra: any(named: 'extra'),
      ),
    ).thenAnswer((_) async => _appealResponse());

    await ApiModerationAppealRepository(api).submitAppeal(
      decisionId: 'decision-1',
      statement: '  这是需要重新复核的完整事实说明。  ',
      appealToken: 'appeal-token',
    );

    final dto =
        verify(
              () => api.userModerationAppealsAppeal(
                createModerationAppealDto: captureAny(
                  named: 'createModerationAppealDto',
                ),
                headers: any(named: 'headers'),
                extra: any(named: 'extra'),
              ),
            ).captured.single
            as CreateModerationAppealDto;
    expect(dto.decisionId, 'decision-1');
    expect(dto.statement, '这是需要重新复核的完整事实说明。');
  });
}

class _MockModerationAppealsApi extends Mock implements ModerationAppealsApi {}

class _FakeIssueAppealTokenDto extends Fake implements IssueAppealTokenDto {}

class _FakeCreateModerationAppealDto extends Fake
    implements CreateModerationAppealDto {}

Response<UserModerationAppealsIssueToken200Response> _credentialResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/moderation/appeal-token'),
    data: UserModerationAppealsIssueToken200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..appealToken = 'appeal-token'
            ..expiresAt = DateTime.utc(2026, 8, 12, 12, 15),
        ),
    ),
  );
}

Response<UserModerationAppealsMine200Response> _decisionsResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/moderation/decisions/mine'),
    data: UserModerationAppealsMine200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.add(
          ModerationDecisionPublicResponseDto(
            (decision) => decision
              ..id = 'decision-1'
              ..targetType =
                  ModerationDecisionPublicResponseDtoTargetTypeEnum.USER
              ..targetId = 'user-1'
              ..action =
                  ModerationDecisionPublicResponseDtoActionEnum.SUSPEND_USER
              ..policyCode =
                  ModerationDecisionPublicResponseDtoPolicyCodeEnum.HARASSMENT
              ..publicExplanation = '多次骚扰其他用户。'
              ..active = true
              ..createdAt = DateTime.utc(2026, 8, 12),
          ),
        ),
    ),
  );
}

Response<UserModerationAppealsAppeal201Response> _appealResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/moderation/appeals'),
    data: UserModerationAppealsAppeal201Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (appeal) => appeal
            ..id = 'appeal-1'
            ..statement = '这是需要重新复核的完整事实说明。'
            ..status = ModerationAppealResponseDtoStatusEnum.PENDING
            ..decision.update(
              (decision) => decision
                ..id = 'decision-1'
                ..targetType =
                    ModerationAppealDecisionResponseDtoTargetTypeEnum.USER
                ..targetId = 'user-1'
                ..action =
                    ModerationAppealDecisionResponseDtoActionEnum.SUSPEND_USER
                ..policyCode =
                    ModerationAppealDecisionResponseDtoPolicyCodeEnum.HARASSMENT
                ..publicExplanation = '多次骚扰其他用户。'
                ..active = true
                ..createdAt = DateTime.utc(2026, 8, 12),
            )
            ..appellant.update(
              (appellant) => appellant
                ..id = 'user-1'
                ..username = '测试用户',
            )
            ..createdAt = DateTime.utc(2026, 8, 12, 12, 1),
        ),
    ),
  );
}
