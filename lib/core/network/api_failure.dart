import 'package:dio/dio.dart';

class ApiFailure implements Exception {
  const ApiFailure({
    required this.userMessage,
    this.httpStatus,
    this.businessCode,
    this.requestId,
    this.contractVersion,
    this.diagnosticCode,
    this.retryAfter,
    this.cause,
  });

  factory ApiFailure.contractViolation({
    required String userMessage,
    required String diagnosticCode,
    Object? cause,
  }) {
    return ApiFailure(
      userMessage: userMessage,
      diagnosticCode: diagnosticCode,
      cause: cause,
    );
  }

  factory ApiFailure.fromDio(
    DioException exception, {
    Map<int, String> featureMessages = const {},
  }) {
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
    final retryAfterSeconds = int.tryParse(
      response?.headers.value('retry-after') ?? '',
    );

    return ApiFailure(
      httpStatus: response?.statusCode,
      businessCode: businessCode,
      requestId: requestId,
      contractVersion: contractVersion,
      retryAfter: retryAfterSeconds == null
          ? null
          : Duration(seconds: retryAfterSeconds < 0 ? 0 : retryAfterSeconds),
      userMessage:
          featureMessages[businessCode] ?? _messageFor(exception, businessCode),
      cause: exception,
    );
  }

  final int? httpStatus;
  final int? businessCode;
  final String? requestId;
  final String? contractVersion;

  /// Stable, non-sensitive code for diagnosing rejected response data.
  ///
  /// Presentation code must never show this value to users.
  final String? diagnosticCode;
  final Duration? retryAfter;
  final String userMessage;
  final Object? cause;

  bool get isExpiredAccessToken => businessCode == 40101;

  bool get hasUnknownWriteOutcome {
    final dio = cause;
    final transientTransport =
        dio is DioException &&
        (dio.type == DioExceptionType.connectionTimeout ||
            dio.type == DioExceptionType.sendTimeout ||
            dio.type == DioExceptionType.receiveTimeout ||
            dio.type == DioExceptionType.connectionError);
    return transientTransport ||
        httpStatus == 429 ||
        businessCode == 42900 ||
        (httpStatus ?? 0) >= 500;
  }

  bool get invalidatesSession =>
      businessCode != null && businessCode! >= 40103 && businessCode! <= 40106;

  bool get isInvalidCursor => businessCode == 40007;

  static String _messageFor(DioException exception, int? businessCode) {
    switch (businessCode) {
      case 40101:
        return '登录状态已续期，请手动重试这次操作。';
      case 40007:
        return '列表位置已失效，正在重新加载。';
      case 40002:
        return '内容已有更新，请读取最新版后选择要保留的内容。';
      case 40003:
        return '骰子格式无效，请返回正文重新插入。';
      case 40004:
        return '当前正文最多可插入 20 个骰子，请删除一个后重试。';
      case 40103:
        return '登录已被撤销，请重新登录。';
      case 40104:
        return '检测到登录安全风险，请重新登录。';
      case 40105:
        return '账号已被锁定，请联系站点管理员。';
      case 40106:
        return '账号已注销。';
      case 40108:
        return '账号已被暂停，可在“治理决定与申诉”中申请复核。';
      case 40109:
        return '账号已被封禁，可在“治理决定与申诉”中申请复核。';
      case 40110:
        return '账号或密码错误。';
      case 40111:
        return '验证码已过期，请重新获取。';
      case 40112:
        return '验证码不正确，请检查后重试。';
      case 40113:
        return '验证码错误次数过多，请重新获取。';
      case 40114:
        return '请先获取邮箱验证码。';
      case 40116:
        return '当前密码不正确。';
      case 40120:
        return '申诉凭据已过期，请重新验证账号密码。';
      case 40300:
        return '当前账号没有执行这项操作的权限。';
      case 40301:
        return '只有主题楼主可以执行这项操作。';
      case 40302:
        return '这个子贴只允许楼主或协作者发言。';
      case 40303:
        return '这个子贴只允许帖内玩家发言。';
      case 40901:
        return '该邮箱已经注册，请直接登录。';
      case 40902:
        return '该用户名已被使用，请换一个。';
      case 40912:
        return '这次操作与待确认请求冲突，请重新发起。';
      case 40914:
        return '你已提交过相同的待处理举报，无需重复提交。';
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
      return '温油站暂时不可用，请稍后重试。';
    }
    return '请求失败，请稍后重试。';
  }

  @override
  String toString() {
    return 'ApiFailure(httpStatus: $httpStatus, businessCode: $businessCode, '
        'requestId: $requestId, diagnosticCode: $diagnosticCode, '
        'retryAfter: $retryAfter, '
        'message: $userMessage)';
  }
}
