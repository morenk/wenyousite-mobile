import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

class MomentPublishBar extends StatelessWidget {
  const MomentPublishBar({
    required this.editing,
    required this.submitting,
    required this.awaitingConfirmation,
    required this.cleanupPending,
    required this.onPressed,
    super.key,
  });

  final bool editing;
  final bool submitting;
  final bool awaitingConfirmation;
  final bool cleanupPending;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final horizontal = wenyouHorizontalPagePadding(context);
    return Material(
      color: tokens.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            tokens.space8,
            horizontal,
            tokens.space8,
          ),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SizedBox(
                width: double.infinity,
                child: WenyouAsyncPrimaryButton(
                  key: const Key('moment-compose-submit'),
                  label: cleanupPending
                      ? '重试清理'
                      : awaitingConfirmation
                      ? '重试确认'
                      : editing
                      ? '保存'
                      : '发布',
                  loadingLabel: editing ? '正在保存' : '正在发布',
                  isLoading: submitting,
                  icon: editing
                      ? WenyouIconIds.actionSave
                      : WenyouIconIds.actionSend,
                  onPressed: onPressed,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MomentComposeFailure extends StatelessWidget {
  const MomentComposeFailure({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      maxWidth: 600,
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: WenyouIconIds.statusOffline,
          title: '动态加载失败',
          message: failure?.userMessage ?? '请稍后重试。',
          detail: wenyouFailureDetail(failure),
          action: OutlinedButton.icon(
            key: const Key('moment-compose-retry'),
            onPressed: onRetry,
            icon: const WenyouIcon(WenyouIconIds.actionRefresh),
            label: const Text('重新加载'),
          ),
        ),
      ),
    );
  }
}
