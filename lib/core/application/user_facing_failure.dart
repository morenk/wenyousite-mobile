import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum FailurePresentationPlacement { page, inline, transient }

class UserFacingFailure {
  const UserFacingFailure({
    required this.title,
    required this.message,
    required this.recoveryAction,
    required this.placement,
    required this.retainContent,
    this.actionLabel,
    this.problemNumber,
  });

  factory UserFacingFailure.fromApi(
    ApiFailure? failure, {
    String? title,
    String? message,
    String objectName = '内容',
    String operationName = '操作',
    FailureRecoveryAction? recoveryAction,
    FailurePresentationPlacement placement =
        FailurePresentationPlacement.inline,
    bool retainContent = false,
    bool treatAsWrite = false,
  }) {
    final isIndeterminateWrite =
        treatAsWrite && (failure?.hasUnknownWriteOutcome ?? false);
    final reason = isIndeterminateWrite
        ? FailureReason.indeterminateWrite
        : failure?.reason ?? FailureReason.unknown;
    final effectiveRecovery = isIndeterminateWrite
        ? FailureRecoveryAction.keepDraft
        : recoveryAction ??
              failure?.recoveryAction ??
              FailureRecoveryAction.retry;
    return UserFacingFailure(
      title: title ?? _titleFor(reason, objectName, operationName),
      message:
          message ??
          (isIndeterminateWrite
              ? '现在无法继续$operationName。请先刷新$objectName查看是否已生效；应用不会自动重复提交。'
              : failure?.legacyUserMessage ?? defaultFailureMessage(reason)),
      recoveryAction: effectiveRecovery,
      placement: placement,
      retainContent: retainContent || isIndeterminateWrite,
      actionLabel: _actionLabelFor(effectiveRecovery),
      problemNumber: failure?.requestId,
    );
  }

  final String title;
  final String message;
  final FailureRecoveryAction recoveryAction;
  final FailurePresentationPlacement placement;
  final bool retainContent;
  final String? actionLabel;
  final String? problemNumber;

  String? get problemDetail =>
      problemNumber == null ? null : '问题编号：$problemNumber';
}

String _titleFor(
  FailureReason reason,
  String objectName,
  String operationName,
) => switch (reason) {
  FailureReason.offline => '网络连接失败',
  FailureReason.timeout || FailureReason.rateLimited => '$operationName失败',
  FailureReason.unauthenticated || FailureReason.sessionInvalid => '需要重新登录',
  FailureReason.permissionDenied => '无法$operationName',
  FailureReason.notFound => '$objectName已不存在',
  FailureReason.conflict => '$objectName已有更新',
  FailureReason.validation => '请检查输入内容',
  FailureReason.contractViolation => '$objectName加载失败',
  FailureReason.localPersistence => '$objectName读取失败',
  FailureReason.indeterminateWrite => '$operationName失败',
  FailureReason.unknown => '$operationName失败',
};

String? _actionLabelFor(FailureRecoveryAction action) => switch (action) {
  FailureRecoveryAction.retry => '重试',
  FailureRecoveryAction.refresh => '刷新',
  FailureRecoveryAction.reopen => '重新打开',
  FailureRecoveryAction.login => '去登录',
  FailureRecoveryAction.appeal => '申请复核',
  FailureRecoveryAction.keepDraft => '刷新查看',
  FailureRecoveryAction.none => null,
};
