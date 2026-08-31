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
    this.sourceLabel,
    this.problemNumber,
    this.diagnosticDetail,
    this.shouldDisplay = true,
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
      sourceLabel: _sourceLabelFor(failure),
      problemNumber:
          failure?.shouldExposeRequestId(treatAsWrite: treatAsWrite) ?? false
          ? failure?.requestId
          : null,
      diagnosticDetail: failure?.safeDiagnosticSummary,
      shouldDisplay: !(failure?.isCancellation ?? false),
    );
  }

  final String title;
  final String message;
  final FailureRecoveryAction recoveryAction;
  final FailurePresentationPlacement placement;
  final bool retainContent;
  final String? actionLabel;
  final String? sourceLabel;
  final String? problemNumber;
  final String? diagnosticDetail;
  final bool shouldDisplay;

  String? get problemDetail {
    final lines = <String>[
      if (sourceLabel != null) '问题环节：$sourceLabel',
      if (problemNumber != null) '问题编号：$problemNumber',
    ];
    return lines.isEmpty ? null : lines.join('\n');
  }
}

String? _sourceLabelFor(ApiFailure? failure) =>
    switch (failure?.effectiveSource) {
      null || FailureSource.expected => null,
      FailureSource.device => '本机处理',
      FailureSource.network => '网络连接',
      FailureSource.service => '温油站服务',
      FailureSource.content => '内容处理',
      FailureSource.unknown
          when failure?.requestId != null ||
              failure?.diagnosticCode != null ||
              failure?.cause != null =>
        '暂无法判断',
      FailureSource.unknown => null,
    };

String _titleFor(
  FailureReason reason,
  String objectName,
  String operationName,
) => switch (reason) {
  FailureReason.cancelled => '$operationName已取消',
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
