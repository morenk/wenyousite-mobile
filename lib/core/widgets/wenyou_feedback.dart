import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

String? wenyouRequestDetail(ApiFailure? failure) {
  return wenyouRequestDetailFromId(failure?.requestId);
}

String? wenyouRequestDetailFromId(String? requestId) {
  return requestId == null ? null : '问题编号：$requestId';
}

enum WenyouStatusTone { neutral, accent, error }

class WenyouStatusBanner extends StatelessWidget {
  const WenyouStatusBanner({
    required this.message,
    this.detail,
    this.tone = WenyouStatusTone.neutral,
    this.action,
    super.key,
  });

  final String message;
  final String? detail;
  final WenyouStatusTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground, icon) = switch (tone) {
      WenyouStatusTone.neutral => (
        tokens.softPanel,
        tokens.text,
        WenyouIconIds.statusInfo,
      ),
      WenyouStatusTone.accent => (
        tokens.accentedBackground,
        tokens.onAccentedBackground,
        WenyouIconIds.statusInfo,
      ),
      WenyouStatusTone.error => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        WenyouIconIds.statusError,
      ),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.all(tokens.space12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(tokens.radius12),
          border: Border.all(
            color: tone == WenyouStatusTone.error
                ? scheme.error.withValues(alpha: 0.22)
                : tokens.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WenyouIcon(icon, size: 20, color: foreground),
            SizedBox(width: tokens.space8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message, style: TextStyle(color: foreground)),
                  if (detail != null) ...[
                    SizedBox(height: tokens.space4),
                    SelectableText(
                      detail!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: foreground.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                  if (action != null) ...[
                    SizedBox(height: tokens.space4),
                    action!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WenyouFailureView extends StatelessWidget {
  const WenyouFailureView({
    required this.failure,
    this.action,
    this.onAction,
    this.actionKey,
    this.icon = WenyouIconIds.statusOffline,
    super.key,
  });

  final UserFacingFailure failure;
  final Widget? action;
  final VoidCallback? onAction;
  final Key? actionKey;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final resolvedAction =
        action ??
        (onAction == null || failure.actionLabel == null
            ? null
            : TextButton(
                key: actionKey,
                onPressed: onAction,
                child: Text(failure.actionLabel!),
              ));
    if (failure.placement == FailurePresentationPlacement.page) {
      return WenyouEmptyState(
        icon: icon,
        title: failure.title,
        message: failure.message,
        detail: failure.problemDetail,
        action: resolvedAction,
      );
    }
    return WenyouStatusBanner(
      message: failure.message,
      detail: failure.problemDetail,
      tone: WenyouStatusTone.error,
      action: resolvedAction,
    );
  }
}

class WenyouFailureBanner extends StatelessWidget {
  const WenyouFailureBanner({required this.failure, this.action, super.key});

  final ApiFailure failure;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return WenyouFailureView(
      failure: UserFacingFailure.fromApi(failure),
      action: action,
    );
  }
}

class WenyouWriteOutcomeBanner extends StatelessWidget {
  const WenyouWriteOutcomeBanner({
    required this.status,
    required this.confirmingMessage,
    required this.indeterminateMessage,
    this.requestId,
    this.onRefresh,
    this.refreshKey,
    super.key,
  }) : assert(
         status == WriteOutcomeStatus.confirming ||
             status == WriteOutcomeStatus.indeterminate,
       );

  final WriteOutcomeStatus status;
  final String confirmingMessage;
  final String indeterminateMessage;
  final String? requestId;
  final VoidCallback? onRefresh;
  final Key? refreshKey;

  @override
  Widget build(BuildContext context) {
    final confirming = status == WriteOutcomeStatus.confirming;
    return WenyouStatusBanner(
      tone: WenyouStatusTone.neutral,
      message: confirming ? confirmingMessage : indeterminateMessage,
      detail: wenyouRequestDetailFromId(requestId),
      action: confirming || onRefresh == null
          ? null
          : TextButton(
              key: refreshKey,
              onPressed: onRefresh,
              child: const Text('刷新查看'),
            ),
    );
  }
}

class WenyouEmptyState extends StatelessWidget {
  const WenyouEmptyState({
    required this.icon,
    required this.title,
    this.message,
    this.detail,
    this.action,
    super.key,
  });

  final String icon;
  final String title;
  final String? message;
  final String? detail;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.accentedBackground,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(
            dimension: 64,
            child: WenyouIcon(icon, size: 32, color: tokens.brandForeground),
          ),
        ),
        SizedBox(height: tokens.space16),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.wenyouStatusTitle,
          ),
        ),
        if (message?.trim().isNotEmpty ?? false) ...[
          SizedBox(height: tokens.space8),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
          ),
        ],
        if (detail != null) ...[
          SizedBox(height: tokens.space8),
          SelectableText(
            detail!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (action != null) ...[SizedBox(height: tokens.space20), action!],
      ],
    );
  }
}
