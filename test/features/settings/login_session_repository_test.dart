import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/settings/data/login_session_repository.dart';
import 'package:wenyousite_mobile/features/settings/domain/login_session_models.dart';

void main() {
  test('登录终端按当前优先和最近活动排序且只映射平台级信息', () async {
    final api = _MockAuthApi();
    when(api.authListSessions).thenAnswer((_) async => _listResponse());

    final sessions = await ApiLoginSessionRepository(api).fetchSessions();

    verify(api.authListSessions).called(1);
    expect(sessions.map((session) => session.id), [
      'mobile-current',
      'web-recent',
      'unknown-old',
    ]);
    expect(sessions.first.platform, LoginSessionPlatform.mobile);
    expect(sessions[1].platform, LoginSessionPlatform.web);
    expect(sessions.last.platform, LoginSessionPlatform.unknown);
    expect(sessions.first.signedInAt, DateTime.utc(2026, 8, 5, 9));
  });

  test('缺少稳定终端 ID 时整页失败而不是生成不可管理条目', () async {
    final api = _MockAuthApi();
    when(
      api.authListSessions,
    ).thenAnswer((_) async => _listResponse(currentId: '   '));

    await expectLater(
      ApiLoginSessionRepository(api).fetchSessions(),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('管理 ID'),
        ),
      ),
    );
  });

  test('撤销使用稳定终端 ID，空响应不伪装成功', () async {
    final api = _MockAuthApi();
    when(
      () => api.authRevokeSession(id: 'web-recent'),
    ).thenAnswer((_) async => _revokeResponse());
    final repository = ApiLoginSessionRepository(api);

    await repository.revokeSession('web-recent');
    verify(() => api.authRevokeSession(id: 'web-recent')).called(1);

    when(() => api.authRevokeSession(id: 'empty')).thenAnswer(
      (_) async => Response<AuthRevokeSession200Response>(
        requestOptions: RequestOptions(path: '/api/v1/auth/sessions/empty'),
      ),
    );
    await expectLater(
      repository.revokeSession('empty'),
      throwsA(isA<ApiFailure>()),
    );
  });
}

class _MockAuthApi extends Mock implements AuthApi {}

Response<AuthListSessions200Response> _listResponse({
  String currentId = 'mobile-current',
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/auth/sessions'),
    data: AuthListSessions200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.addAll([
          _session(
            id: 'unknown-old',
            platform: SessionResponseDtoPlatformEnum.unknownDefaultOpenApi,
            lastActiveAt: DateTime.utc(2026, 8, 6, 8),
          ),
          _session(
            id: currentId,
            platform: SessionResponseDtoPlatformEnum.mobile,
            isCurrent: true,
            lastActiveAt: DateTime.utc(2026, 8, 5, 9, 15),
          ),
          _session(
            id: 'web-recent',
            platform: SessionResponseDtoPlatformEnum.web,
            lastActiveAt: DateTime.utc(2026, 8, 9, 10),
          ),
        ]),
    ),
  );
}

SessionResponseDto _session({
  required String id,
  required SessionResponseDtoPlatformEnum platform,
  required DateTime lastActiveAt,
  bool isCurrent = false,
}) {
  final signedInAt = DateTime.utc(2026, 8, 5, 9);
  return SessionResponseDto(
    (session) => session
      ..id = id
      ..platform = platform
      ..deviceInfo = 'Mozilla/5.0 should-never-reach-ui'
      ..isCurrent = isCurrent
      ..signedInAt = signedInAt
      ..lastActiveAt = lastActiveAt
      ..expiresAt = DateTime.utc(2026, 8, 12, 9)
      ..createdAt = signedInAt,
  );
}

Response<AuthRevokeSession200Response> _revokeResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/auth/sessions/web-recent'),
    data: AuthRevokeSession200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '终端已退出'),
    ),
  );
}
