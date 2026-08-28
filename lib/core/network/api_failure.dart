import 'package:dio/dio.dart';

enum FailureReason {
  offline,
  timeout,
  rateLimited,
  unauthenticated,
  sessionInvalid,
  permissionDenied,
  notFound,
  conflict,
  validation,
  contractViolation,
  localPersistence,
  indeterminateWrite,
  unknown,
}

enum FailureRecoveryAction {
  retry,
  refresh,
  reopen,
  login,
  appeal,
  keepDraft,
  none,
}

class ApiFailure implements Exception {
  const ApiFailure({
    String? userMessage,
    this.reason = FailureReason.unknown,
    this.recoveryAction = FailureRecoveryAction.retry,
    this.httpStatus,
    this.businessCode,
    this.requestId,
    this.contractVersion,
    this.diagnosticCode,
    this.retryAfter,
    this.cause,
  }) : legacyUserMessage = userMessage;

  factory ApiFailure.contractViolation({
    required String userMessage,
    required String diagnosticCode,
    Object? cause,
  }) {
    return ApiFailure(
      userMessage: userMessage,
      reason: FailureReason.contractViolation,
      recoveryAction: FailureRecoveryAction.refresh,
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

    final reason = _reasonFor(exception, businessCode);
    return ApiFailure(
      reason: reason,
      recoveryAction: _recoveryFor(reason, businessCode),
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
  final FailureReason reason;
  final FailureRecoveryAction recoveryAction;

  /// Stable, non-sensitive code for diagnosing rejected response data.
  ///
  /// Presentation code must never show this value to users.
  final String? diagnosticCode;
  final Duration? retryAfter;

  /// Temporary compatibility text for call sites that have not moved their
  /// object-specific wording into the feature presentation mapper yet.
  ///
  /// New transport failures should set [reason] and [recoveryAction] instead.
  @Deprecated('Resolve user-facing copy through UserFacingFailure instead.')
  final String? legacyUserMessage;
  final Object? cause;

  @Deprecated('Resolve user-facing copy through UserFacingFailure instead.')
  String get userMessage => legacyUserMessage ?? defaultFailureMessage(reason);

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

  static FailureReason _reasonFor(DioException exception, int? businessCode) {
    if (businessCode == 40101) return FailureReason.unauthenticated;
    if (businessCode != null &&
        businessCode >= 40103 &&
        businessCode <= 40106) {
      return FailureReason.sessionInvalid;
    }
    if (businessCode == 40108 || businessCode == 40109) {
      return FailureReason.permissionDenied;
    }
    if (businessCode != null && businessCode >= 40300 && businessCode < 40400) {
      return FailureReason.permissionDenied;
    }
    if (businessCode != null && businessCode >= 40400 && businessCode < 40500) {
      return FailureReason.notFound;
    }
    if (businessCode == 40002 ||
        businessCode == 40007 ||
        (businessCode != null &&
            businessCode >= 40900 &&
            businessCode < 41000)) {
      return FailureReason.conflict;
    }
    if (businessCode == 42900 || exception.response?.statusCode == 429) {
      return FailureReason.rateLimited;
    }
    if (businessCode != null && businessCode >= 40000 && businessCode < 40200) {
      return FailureReason.validation;
    }
    if (exception.response?.statusCode == 401) {
      return FailureReason.unauthenticated;
    }
    if (exception.response?.statusCode == 403) {
      return FailureReason.permissionDenied;
    }
    if (exception.response?.statusCode == 404) return FailureReason.notFound;
    if (exception.response?.statusCode == 409) return FailureReason.conflict;
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout) {
      return FailureReason.timeout;
    }
    if (exception.type == DioExceptionType.connectionError) {
      return FailureReason.offline;
    }
    return FailureReason.unknown;
  }

  static FailureRecoveryAction _recoveryFor(
    FailureReason reason,
    int? businessCode,
  ) {
    if (businessCode == 40108 || businessCode == 40109) {
      return FailureRecoveryAction.appeal;
    }
    return switch (reason) {
      FailureReason.sessionInvalid ||
      FailureReason.unauthenticated => FailureRecoveryAction.login,
      FailureReason.conflict ||
      FailureReason.notFound => FailureRecoveryAction.refresh,
      FailureReason.permissionDenied ||
      FailureReason.validation => FailureRecoveryAction.none,
      FailureReason.contractViolation => FailureRecoveryAction.refresh,
      FailureReason.localPersistence => FailureRecoveryAction.reopen,
      FailureReason.indeterminateWrite => FailureRecoveryAction.keepDraft,
      FailureReason.offline ||
      FailureReason.timeout ||
      FailureReason.rateLimited ||
      FailureReason.unknown => FailureRecoveryAction.retry,
    };
  }

  @override
  String toString() {
    return 'ApiFailure(httpStatus: $httpStatus, businessCode: $businessCode, '
        'requestId: $requestId, reason: $reason, '
        'recoveryAction: $recoveryAction, diagnosticCode: $diagnosticCode, '
        'retryAfter: $retryAfter)';
  }
}

String defaultFailureMessage(FailureReason reason) => switch (reason) {
  FailureReason.offline => '暂时无法连接温油站，请检查网络后重试。',
  FailureReason.timeout => '等待时间过长，请检查网络后重试。',
  FailureReason.rateLimited => '操作太频繁，请稍后再试。',
  FailureReason.unauthenticated ||
  FailureReason.sessionInvalid => '登录已失效，请重新登录。',
  FailureReason.permissionDenied => '当前账号不能执行这项操作。',
  FailureReason.notFound => '要查看的内容已不存在。',
  FailureReason.conflict => '内容已有更新，请刷新后重试。',
  FailureReason.validation => '请检查填写的内容后重试。',
  FailureReason.contractViolation => '当前内容暂时无法显示，请重新加载。',
  FailureReason.localPersistence => '本地内容暂时无法读取，请重新打开。',
  FailureReason.indeterminateWrite => '现在无法继续这项操作。请先刷新当前内容查看是否已生效；应用不会自动重复提交。',
  FailureReason.unknown => '操作失败，请稍后重试。',
};
