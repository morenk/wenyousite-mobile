import 'package:dio/dio.dart';

class ApiFailure implements Exception {
  const ApiFailure({
    required this.userMessage,
    this.httpStatus,
    this.businessCode,
    this.requestId,
    this.contractVersion,
    this.cause,
  });

  factory ApiFailure.fromDio(DioException exception) {
    final response = exception.response;
    final body = response?.data;
    final envelope = body is Map ? body.cast<Object?, Object?>() : null;
    final codeValue = envelope?['code'];
    final businessCode = switch (codeValue) {
      int value => value,
      num value => value.toInt(),
      String value => int.tryParse(value),
      _ => null,
    };
    final requestId =
        response?.headers.value('x-request-id') ??
        exception.requestOptions.headers['X-Request-ID']?.toString();
    final contractVersion = response?.headers.value('x-api-contract-version');

    return ApiFailure(
      httpStatus: response?.statusCode,
      businessCode: businessCode,
      requestId: requestId,
      contractVersion: contractVersion,
      userMessage: _messageFor(exception, businessCode),
      cause: exception,
    );
  }

  final int? httpStatus;
  final int? businessCode;
  final String? requestId;
  final String? contractVersion;
  final String userMessage;
  final Object? cause;

  bool get isExpiredAccessToken => businessCode == 40101;

  bool get invalidatesSession =>
      businessCode != null && businessCode! >= 40103 && businessCode! <= 40106;

  bool get isInvalidCursor => businessCode == 40007;

  static String _messageFor(DioException exception, int? businessCode) {
    switch (businessCode) {
      case 40007:
        return '列表位置已失效，正在重新加载。';
      case 40103:
        return '登录已被撤销，请重新登录。';
      case 40104:
        return '检测到登录安全风险，请重新登录。';
      case 40105:
        return '账号已被锁定，请联系站点管理员。';
      case 40106:
        return '账号已注销。';
      case 40107:
        return '请先完成邮箱验证。';
      case 40110:
        return '账号或密码错误。';
      case 40912:
        return '这次操作与待确认请求冲突，请重新发起。';
      case 42900:
        return '操作太频繁，请稍后再试。';
    }
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout) {
      return '连接超时，请检查网络后重试。';
    }
    if (exception.type == DioExceptionType.connectionError) {
      return '暂时无法连接温油站，请检查网络。';
    }
    if ((exception.response?.statusCode ?? 0) >= 500) {
      return '服务器暂时开小差了，请稍后重试。';
    }
    return '请求没有完成，请稍后重试。';
  }

  @override
  String toString() {
    return 'ApiFailure(httpStatus: $httpStatus, businessCode: $businessCode, '
        'requestId: $requestId, message: $userMessage)';
  }
}
