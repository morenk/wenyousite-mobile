import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

/// 只装配可安全重试的读取失败；容器和滚动归调用方所有。
class WenyouRetryFailure extends StatelessWidget {
  const WenyouRetryFailure({
    required this.failure,
    required this.onRetry,
    this.title,
    this.message,
    this.retryLabel = '重试',
    this.retryKey,
    this.icon = WenyouIconIds.statusOffline,
    this.inline = false,
    this.panel = false,
    super.key,
  });

  final ApiFailure? failure;
  final VoidCallback? onRetry;
  final String? title;
  final String? message;
  final String retryLabel;
  final Key? retryKey;
  final String icon;
  final bool inline;
  final bool panel;

  @override
  Widget build(BuildContext context) {
    final presentation = UserFacingFailure.fromApi(
      failure,
      title: title,
      message: message,
      placement: inline
          ? FailurePresentationPlacement.inline
          : FailurePresentationPlacement.page,
    );
    if (!presentation.shouldDisplay) return const SizedBox.shrink();
    // 文案与重试回调显式配对，不能借用登录、复核等业务恢复动作的标签。
    final action = inline
        ? TextButton(key: retryKey, onPressed: onRetry, child: Text(retryLabel))
        : OutlinedButton.icon(
            key: retryKey,
            onPressed: onRetry,
            icon: const WenyouIcon(WenyouIconIds.actionRefresh),
            label: Text(retryLabel),
          );
    final content = WenyouFailureView(
      failure: presentation,
      icon: icon,
      action: action,
    );
    return panel ? WenyouPanel(child: content) : content;
  }
}
