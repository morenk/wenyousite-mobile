import 'dart:io';

import 'package:dio/dio.dart';
import 'package:wenyou_api/wenyou_api.dart';

enum FailureSource { expected, device, network, service, content, unknown }

enum FailureReason {
  cancelled,
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
    this.source,
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
    String? requestId,
    String? contractVersion,
    Object? cause,
  }) {
    return ApiFailure(
      userMessage: userMessage,
      source: FailureSource.content,
      reason: FailureReason.contractViolation,
      recoveryAction: FailureRecoveryAction.refresh,
      requestId: requestId,
      contractVersion: contractVersion,
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
    final knownBusinessCode = _knownBusinessCode(businessCode);
    final source = _sourceFor(
      exception,
      businessCode: businessCode,
      knownBusinessCode: knownBusinessCode,
    );

    final reason = _reasonFor(exception, businessCode, source);
    return ApiFailure(
      source: source,
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
          featureMessages[businessCode] ??
          _messageFor(exception, businessCode, source),
      cause: exception,
    );
  }

  final FailureSource? source;
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

  FailureSource get effectiveSource {
    final explicitSource = source;
    if (explicitSource != null) return explicitSource;
    if ((httpStatus ?? 0) >= 500 || businessCode == 50000) {
      return FailureSource.service;
    }
    if (businessCode == 40912) return FailureSource.device;
    final knownBusinessCode = _knownBusinessCode(businessCode);
    if (knownBusinessCode != null &&
        knownBusinessCode != BusinessErrorCode.unknownDefaultOpenApi) {
      return FailureSource.expected;
    }
    if (businessCode != null) return FailureSource.content;
    if ((httpStatus ?? 0) >= 400 && (httpStatus ?? 0) < 500) {
      return FailureSource.expected;
    }
    final dioCause = cause;
    if (dioCause is DioException) {
      final inferred = _sourceFor(
        dioCause,
        businessCode: businessCode,
        knownBusinessCode: knownBusinessCode,
      );
      if (inferred != FailureSource.unknown) return inferred;
    }
    return switch (reason) {
      FailureReason.cancelled ||
      FailureReason.rateLimited ||
      FailureReason.unauthenticated ||
      FailureReason.sessionInvalid ||
      FailureReason.permissionDenied ||
      FailureReason.notFound ||
      FailureReason.conflict ||
      FailureReason.validation => FailureSource.expected,
      FailureReason.offline || FailureReason.timeout => FailureSource.network,
      FailureReason.contractViolation => FailureSource.content,
      FailureReason.localPersistence => FailureSource.device,
      FailureReason.indeterminateWrite ||
      FailureReason.unknown => FailureSource.unknown,
    };
  }

  @Deprecated('Resolve user-facing copy through UserFacingFailure instead.')
  String get userMessage => legacyUserMessage ?? defaultFailureMessage(reason);

  bool get isExpiredAccessToken => businessCode == 40101;

  bool get isCancellation => reason == FailureReason.cancelled;

  String? get businessCodeName {
    final code = _knownBusinessCode(businessCode);
    return code == null || code == BusinessErrorCode.unknownDefaultOpenApi
        ? null
        : code.name;
  }

  bool shouldExposeRequestId({bool treatAsWrite = false}) {
    if (requestId == null) return false;
    if (treatAsWrite && hasUnknownWriteOutcome) return true;
    if (businessCode == 40912) return true;
    return effectiveSource == FailureSource.service ||
        effectiveSource == FailureSource.content ||
        effectiveSource == FailureSource.unknown;
  }

  String get safeDiagnosticSummary {
    final dio = cause;
    final parts = <String>[
      'source=${effectiveSource.name}',
      'reason=${reason.name}',
      if (dio is DioException) 'dioType=${dio.type.name}',
      if (httpStatus != null) 'httpStatus=$httpStatus',
      if (businessCode != null) 'businessCode=$businessCode',
      if (businessCodeName != null) 'businessName=$businessCodeName',
      if (requestId != null) 'requestId=$requestId',
      if (contractVersion != null) 'contract=$contractVersion',
      if (diagnosticCode != null) 'diagnosticCode=$diagnosticCode',
    ];
    return parts.join(' ');
  }

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

  static String _messageFor(
    DioException exception,
    int? businessCode,
    FailureSource source,
  ) {
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
        return '这次操作无法继续，请重新打开后再试。';
      case 40914:
        return '你已提交过相同的待处理举报，无需重复提交。';
      case 42900:
        return '操作太频繁，请稍后再试。';
    }
    if (source == FailureSource.service) {
      return '温油站暂时不可用，请稍后重试。';
    }
    if (source == FailureSource.content) {
      return '当前内容暂时无法处理，请重新加载。';
    }
    if (exception.type == DioExceptionType.cancel) {
      return '操作已取消。';
    }
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout) {
      return '连接超时，请检查网络后重试。';
    }
    if (exception.type == DioExceptionType.connectionError) {
      return '暂时无法连接温油站，请检查网络。';
    }
    if (source == FailureSource.network) {
      return '暂时无法建立网络连接，请检查网络和系统时间。';
    }
    return '请求失败，请稍后重试。';
  }

  static FailureReason _reasonFor(
    DioException exception,
    int? businessCode,
    FailureSource source,
  ) {
    if (exception.type == DioExceptionType.cancel) {
      return FailureReason.cancelled;
    }
    if (source == FailureSource.content) {
      return FailureReason.contractViolation;
    }
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
    if (source == FailureSource.network) return FailureReason.offline;
    return FailureReason.unknown;
  }

  static FailureSource _sourceFor(
    DioException exception, {
    required int? businessCode,
    required BusinessErrorCode? knownBusinessCode,
  }) {
    if (exception.type == DioExceptionType.cancel) {
      return FailureSource.expected;
    }
    final response = exception.response;
    if (response != null) {
      final status = response.statusCode ?? 0;
      if (status >= 500 || businessCode == 50000) {
        return FailureSource.service;
      }
      if (businessCode == 40912) return FailureSource.device;
      if (knownBusinessCode != null &&
          knownBusinessCode != BusinessErrorCode.unknownDefaultOpenApi) {
        return FailureSource.expected;
      }
      return FailureSource.content;
    }
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.connectionError ||
        exception.type == DioExceptionType.badCertificate ||
        exception.error is SocketException ||
        exception.error is HandshakeException) {
      return FailureSource.network;
    }
    return FailureSource.unknown;
  }

  static BusinessErrorCode? _knownBusinessCode(Object? value) {
    if (value == null) return null;
    try {
      return standardSerializers.deserializeWith(
        BusinessErrorCode.serializer,
        value,
      );
    } on Object {
      return null;
    }
  }

  static FailureRecoveryAction _recoveryFor(
    FailureReason reason,
    int? businessCode,
  ) {
    if (businessCode == 40108 || businessCode == 40109) {
      return FailureRecoveryAction.appeal;
    }
    return switch (reason) {
      FailureReason.cancelled => FailureRecoveryAction.none,
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
    return 'ApiFailure(source: $effectiveSource, httpStatus: $httpStatus, '
        'businessCode: $businessCode, '
        'requestId: $requestId, reason: $reason, '
        'recoveryAction: $recoveryAction, diagnosticCode: $diagnosticCode, '
        'retryAfter: $retryAfter)';
  }
}

String defaultFailureMessage(FailureReason reason) => switch (reason) {
  FailureReason.cancelled => '操作已取消。',
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
