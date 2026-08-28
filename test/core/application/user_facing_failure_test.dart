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

  test('问题编号仅作为次要详情展示', () {
    final presentation = UserFacingFailure.fromApi(
      const ApiFailure(reason: FailureReason.offline, requestId: 'request-id'),
    );

    expect(presentation.message, isNot(contains('request-id')));
    expect(presentation.problemDetail, '问题编号：request-id');
  });
}
