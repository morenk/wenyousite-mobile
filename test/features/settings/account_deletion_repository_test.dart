import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/settings/data/account_deletion_repository.dart';

void main() {
  test('注销当前账号调用生成端点并确认服务端消息', () async {
    final api = _MockUsersApi();
    when(() => api.usersDeleteMe()).thenAnswer((_) async => _successResponse());

    await ApiAccountDeletionRepository(api).deleteAccount();

    verify(() => api.usersDeleteMe()).called(1);
  });

  test('成功响应缺少 data 时不伪装账号已注销', () async {
    final api = _MockUsersApi();
    when(() => api.usersDeleteMe()).thenAnswer(
      (_) async => Response<UsersDeleteMe200Response>(
        requestOptions: RequestOptions(path: '/api/v1/users/me'),
      ),
    );

    expect(
      ApiAccountDeletionRepository(api).deleteAccount(),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'userMessage',
          contains('结果不完整'),
        ),
      ),
    );
  });
}

class _MockUsersApi extends Mock implements UsersApi {}

Response<UsersDeleteMe200Response> _successResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/me'),
    data: UsersDeleteMe200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '账号已注销'),
    ),
  );
}
