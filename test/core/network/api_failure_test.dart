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

  test('登录凭据错误按业务码展示稳定提示', () {
    final options = RequestOptions(path: '/api/v1/auth/login');
    final failure = ApiFailure.fromDio(
      DioException(
        requestOptions: options,
        response: Response<Object?>(
          requestOptions: options,
          statusCode: 401,
          data: {'code': 40110, 'message': 'server wording'},
        ),
      ),
    );

    expect(failure.userMessage, '账号或密码错误。');
    expect(failure.userMessage, isNot(contains('server wording')));
  });

  test('注册限流提取 Retry-After 并使用稳定提示', () {
    final options = RequestOptions(path: '/api/v1/auth/register/request-code');
    final failure = ApiFailure.fromDio(
      DioException(
        requestOptions: options,
        response: Response<Object?>(
          requestOptions: options,
          statusCode: 429,
          data: {'code': 42900, 'message': 'server wording'},
          headers: Headers.fromMap({
            'retry-after': ['42'],
            'x-request-id': ['rate-limit-request-id'],
          }),
        ),
      ),
    );

    expect(failure.retryAfter, const Duration(seconds: 42));
    expect(failure.requestId, 'rate-limit-request-id');
    expect(failure.userMessage, '操作太频繁，请稍后再试。');
  });

  test('注册验证码和占用错误按业务码返回专用提示', () {
    String messageFor(int code) {
      final options = RequestOptions(path: '/api/v1/auth/register');
      return ApiFailure.fromDio(
        DioException(
          requestOptions: options,
          response: Response<Object?>(
            requestOptions: options,
            data: {'code': code, 'message': 'server wording'},
          ),
        ),
      ).userMessage;
    }

    expect(messageFor(40111), contains('过期'));
    expect(messageFor(40112), contains('不正确'));
    expect(messageFor(40113), contains('错误次数过多'));
    expect(messageFor(40114), contains('先获取'));
    expect(messageFor(40116), '当前密码不正确。');
    expect(messageFor(40901), contains('邮箱已经注册'));
    expect(messageFor(40902), contains('用户名已被使用'));
  });
}
