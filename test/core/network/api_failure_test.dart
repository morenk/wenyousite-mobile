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

  test('乐观锁冲突提示用户先读取最新版且不透传后端文案', () {
    final options = RequestOptions(path: '/api/v1/drafts/draft-one');
    final failure = ApiFailure.fromDio(
      DioException(
        requestOptions: options,
        response: Response<Object?>(
          requestOptions: options,
          statusCode: 409,
          data: {'code': 40002, 'message': 'internal conflict wording'},
        ),
      ),
    );

    expect(failure.userMessage, contains('最新版'));
    expect(failure.userMessage, isNot(contains('internal')));
  });

  test('子贴发言权限按协作者和玩家业务码提供稳定提示', () {
    String messageFor(int code) {
      final options = RequestOptions(path: '/api/v1/subthreads/sub/posts');
      return ApiFailure.fromDio(
        DioException(
          requestOptions: options,
          response: Response<Object?>(
            requestOptions: options,
            statusCode: 403,
            data: {'code': code, 'message': 'server permission wording'},
          ),
        ),
      ).userMessage;
    }

    expect(messageFor(40302), contains('楼主或协作者'));
    expect(messageFor(40303), contains('帖内玩家'));
    expect(messageFor(40302), isNot(contains('server')));
  });

  test('私聊权限、目标、状态和媒体冲突使用稳定提示', () {
    String messageFor(int code) {
      final options = RequestOptions(path: '/api/v1/direct-conversations/c1');
      return ApiFailure.fromDio(
        DioException(
          requestOptions: options,
          response: Response<Object?>(
            requestOptions: options,
            data: {'code': code, 'message': 'private server wording'},
          ),
        ),
      ).userMessage;
    }

    expect(messageFor(40005), contains('内容'));
    expect(messageFor(40305), contains('拉黑'));
    expect(messageFor(40306), contains('会话状态'));
    expect(messageFor(40411), contains('会话'));
    expect(messageFor(40412), contains('消息'));
    expect(messageFor(40906), contains('等待'));
    expect(messageFor(40907), contains('拒绝'));
    expect(messageFor(40908), contains('十分钟'));
    expect(messageFor(40909), contains('图片'));
    expect(messageFor(40305), isNot(contains('private server wording')));
  });

  test('动态或评论不存在使用 40415 稳定提示', () {
    final options = RequestOptions(path: '/api/v1/moments/moment-1');
    final failure = ApiFailure.fromDio(
      DioException(
        requestOptions: options,
        response: Response<Object?>(
          requestOptions: options,
          statusCode: 404,
          data: {'code': 40415, 'message': 'private deletion detail'},
        ),
      ),
    );

    expect(failure.userMessage, contains('动态或评论'));
    expect(failure.userMessage, isNot(contains('private deletion detail')));
  });

  test('温油金额、目标限制和余额不足使用稳定业务提示', () {
    String messageFor(int code) {
      final options = RequestOptions(path: '/api/v1/users/user-1/tips');
      return ApiFailure.fromDio(
        DioException(
          requestOptions: options,
          response: Response<Object?>(
            requestOptions: options,
            data: {'code': code, 'message': 'private economy wording'},
          ),
        ),
      ).userMessage;
    }

    expect(messageFor(40008), contains('最低投入 2 升'));
    expect(messageFor(40307), contains('当前不能'));
    expect(messageFor(40913), contains('余额不足'));
    expect(messageFor(40913), isNot(contains('private economy wording')));
  });
}
