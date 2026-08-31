import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

void main() {
  test('网络错误映射为稳定原因和恢复动作且不读取后端 message', () {
    final options = RequestOptions(path: '/api/v1/threads');
    final failure = ApiFailure.fromDio(
      DioException(
        requestOptions: options,
        response: Response<Object?>(
          requestOptions: options,
          statusCode: 429,
          data: {'code': 42900, 'message': 'private backend wording'},
        ),
      ),
    );
    final presentation = UserFacingFailure.fromApi(
      failure,
      objectName: '主题',
      operationName: '加载主题',
    );

    expect(failure.reason, FailureReason.rateLimited);
    expect(failure.recoveryAction, FailureRecoveryAction.retry);
    expect(presentation.message, isNot(contains('private backend wording')));
    expect(presentation.actionLabel, '重试');
  });

  test('未知写入结果保留内容并明确不会自动重复提交', () {
    final options = RequestOptions(path: '/api/v1/threads');
    final failure = ApiFailure.fromDio(
      DioException(
        requestOptions: options,
        type: DioExceptionType.receiveTimeout,
      ),
    );
    final presentation = UserFacingFailure.fromApi(
      failure,
      objectName: '主题',
      operationName: '发布主题',
      treatAsWrite: true,
    );

    expect(presentation.retainContent, isTrue);
    expect(presentation.recoveryAction, FailureRecoveryAction.keepDraft);
    expect(presentation.message, contains('刷新主题查看是否已生效'));
    expect(presentation.message, contains('不会自动重复提交'));
    expect(presentation.message, isNot(contains('结果暂时无法确定')));
  });

  test('普通网络错误只显示问题环节，不显示问题编号', () {
    final presentation = UserFacingFailure.fromApi(
      const ApiFailure(reason: FailureReason.offline, requestId: 'request-id'),
    );

    expect(presentation.message, isNot(contains('request-id')));
    expect(presentation.problemDetail, '问题环节：网络连接');
  });

  test('可预期业务错误不显示问题环节或问题编号', () {
    final presentation = UserFacingFailure.fromApi(
      const ApiFailure(
        reason: FailureReason.validation,
        businessCode: 40001,
        requestId: 'validation-request-id',
      ),
    );

    expect(presentation.problemDetail, isNull);
  });

  test('本机错误显示本机处理但不虚构本地错误码', () {
    final presentation = UserFacingFailure.fromApi(
      const ApiFailure(
        reason: FailureReason.localPersistence,
        requestId: 'local-request-id',
      ),
    );

    expect(presentation.problemDetail, '问题环节：本机处理');
  });

  test('服务和内容异常显示环节及可核对的问题编号', () {
    final service = UserFacingFailure.fromApi(
      const ApiFailure(httpStatus: 503, requestId: 'service-request-id'),
    );
    final content = UserFacingFailure.fromApi(
      const ApiFailure(
        reason: FailureReason.contractViolation,
        requestId: 'content-request-id',
      ),
    );

    expect(service.problemDetail, '问题环节：温油站服务\n问题编号：service-request-id');
    expect(content.problemDetail, '问题环节：内容处理\n问题编号：content-request-id');
  });

  test('不确定写入显示网络环节和问题编号', () {
    final options = RequestOptions(
      path: '/api/v1/threads',
      headers: {'X-Request-ID': 'write-request-id'},
    );
    final failure = ApiFailure.fromDio(
      DioException(
        requestOptions: options,
        type: DioExceptionType.receiveTimeout,
      ),
    );
    final presentation = UserFacingFailure.fromApi(failure, treatAsWrite: true);

    expect(presentation.problemDetail, '问题环节：网络连接\n问题编号：write-request-id');
  });

  test('取消操作不生成用户可见错误', () {
    final presentation = UserFacingFailure.fromApi(
      const ApiFailure(reason: FailureReason.cancelled),
    );

    expect(presentation.shouldDisplay, isFalse);
  });
}
