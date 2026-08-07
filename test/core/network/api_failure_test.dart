import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

void main() {
  test('从错误 envelope 提取业务码、请求 ID 和契约版本', () {
    final options = RequestOptions(
      path: '/api/v1/threads',
      headers: {'X-Request-ID': 'client-request-id'},
    );
    final failure = ApiFailure.fromDio(
      DioException(
        requestOptions: options,
        response: Response<Object?>(
          requestOptions: options,
          statusCode: 401,
          data: {'code': 40105, 'message': 'sensitive server message'},
          headers: Headers.fromMap({
            'x-request-id': ['server-request-id'],
            'x-api-contract-version': ['3.0.0'],
          }),
        ),
      ),
    );

    expect(failure.businessCode, 40105);
    expect(failure.requestId, 'server-request-id');
    expect(failure.contractVersion, '3.0.0');
    expect(failure.invalidatesSession, isTrue);
    expect(failure.userMessage, contains('锁定'));
    expect(failure.userMessage, isNot(contains('sensitive')));
  });
}
