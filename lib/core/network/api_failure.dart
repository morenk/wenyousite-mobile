import 'package:dio/dio.dart';

class ApiFailure implements Exception {
  const ApiFailure({
    required this.userMessage,
    this.httpStatus,
    this.businessCode,
    this.requestId,
    this.contractVersion,
    this.retryAfter,
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
      userMessage: _messageFor(exception, businessCode),
      cause: exception,
    );
  }

  final int? httpStatus;
  final int? businessCode;
  final String? requestId;
  final String? contractVersion;
  final Duration? retryAfter;
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
      case 40008:
        return '最低投入 2 升，且只能填写可用范围内的整数。';
      case 40002:
        return '内容已在其他位置修改，请读取最新版后再决定是否覆盖。';
      case 40005:
        return '私聊消息内容不符合要求。';
      case 40006:
        return '图片不符合表情规格，请换一张后重试。';
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
      case 40300:
        return '当前账号没有执行这项操作的权限。';
      case 40301:
        return '只有主题楼主可以执行这项操作。';
      case 40302:
        return '这个子贴只允许楼主或协作者发言。';
      case 40303:
        return '这个子贴只允许帖内玩家发言。';
      case 40305:
        return '你们之间存在拉黑关系，当前不能发送私聊。';
      case 40306:
        return '当前会话状态不允许执行这项操作。';
      case 40307:
        return '当前不能向这个目标加油，请检查是否为本人或互动受限。';
      case 40411:
        return '这个私聊会话不存在或已不可访问。';
      case 40412:
        return '这条私聊消息不存在或已不可访问。';
      case 40413:
        return '这个表情或导入任务已不存在，请重新加载。';
      case 40415:
        return '这条动态或评论不存在，可能已经被删除。';
      case 40901:
        return '该邮箱已经注册，请直接登录。';
      case 40902:
        return '该用户名已被使用，请换一个。';
      case 40906:
        return '消息请求仍在等待对方处理。';
      case 40907:
        return '对方已拒绝此前的消息请求。';
      case 40908:
        return '这条消息已超过十分钟撤回时限。';
      case 40909:
        return '这张图片已用于其他私聊消息，请重新选择。';
      case 40910:
        return '表情收藏已满，请先移除一些表情。';
      case 40911:
        return '收藏夹已在其他设备修改，请刷新后重试。';
      case 40912:
        return '这次操作与待确认请求冲突，请重新发起。';
      case 40913:
        return '温油余额不足，请减少投入升数后重试。';
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
        'requestId: $requestId, retryAfter: $retryAfter, '
        'message: $userMessage)';
  }
}
