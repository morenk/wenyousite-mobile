import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

double wenyouHorizontalPagePadding(
  BuildContext context, {
  double? availableWidth,
}) {
  final tokens = context.wenyouTokens;
  final width = availableWidth ?? MediaQuery.sizeOf(context).width;
  return width < tokens.regularHorizontalPaddingFrom
      ? tokens.compactHorizontalPadding
      : tokens.regularHorizontalPadding;
}

String? wenyouRequestDetail(ApiFailure? failure) {
  final requestId = failure?.requestId;
  return requestId == null ? null : '问题编号：$requestId';
}

class WenyouConstrainedWidth extends StatelessWidget {
  const WenyouConstrainedWidth({required this.child, this.maxWidth, super.key});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? tokens.wideContainerMaxWidth,
        ),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

class WenyouPageBody extends StatelessWidget {
  const WenyouPageBody({
    required this.child,
    this.maxWidth,
    this.bottomPadding,
    super.key,
  });

  final Widget child;
  final double? maxWidth;
  final double? bottomPadding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = wenyouHorizontalPagePadding(
            context,
            availableWidth: constraints.maxWidth,
          );
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              tokens.space16,
              horizontalPadding,
              bottomPadding ?? tokens.space32 + tokens.space8,
            ),
            child: WenyouConstrainedWidth(
              maxWidth: maxWidth ?? tokens.pageContentMaxWidth,
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class WenyouComposerAction extends StatelessWidget {
  const WenyouComposerAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final String icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Tooltip(
      message: label,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
        child: FilledButton.tonalIcon(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: Size(0, tokens.minimumTouchTarget),
            padding: EdgeInsets.symmetric(horizontal: tokens.space16),
            foregroundColor: tokens.text,
            backgroundColor: tokens.accentedBackground,
            disabledBackgroundColor: tokens.softPanel,
            disabledForegroundColor: tokens.mutedText,
            elevation: 0,
          ),
          icon: WenyouIcon(icon, size: 20),
          label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

class WenyouPanel extends StatelessWidget {
  const WenyouPanel({
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.clipBehavior,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final Clip? clipBehavior;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final content = Padding(
      padding: padding ?? EdgeInsets.all(tokens.space20),
      child: child,
    );
    return Card(
      color: color ?? tokens.panel,
      clipBehavior:
          clipBehavior ?? (onTap == null ? Clip.none : Clip.antiAlias),
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

class WenyouSectionHeader extends StatelessWidget {
  const WenyouSectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: tokens.space8),
                Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[SizedBox(width: tokens.space12), trailing!],
      ],
    );
  }
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
        tokens.text,
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

class WenyouFailureBanner extends StatelessWidget {
  const WenyouFailureBanner({required this.failure, this.action, super.key});

  final ApiFailure failure;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return WenyouStatusBanner(
      message: failure.userMessage,
      detail: wenyouRequestDetail(failure),
      tone: WenyouStatusTone.error,
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
      detail: requestId == null ? null : '问题编号：$requestId',
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

class WenyouAsyncPrimaryButton extends StatelessWidget {
  const WenyouAsyncPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.loadingLabel,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingLabel;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return SizedBox(
      width: double.infinity,
      height: tokens.minimumTouchTarget,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: Semantics(
          label: isLoading ? (loadingLabel ?? '$label，处理中') : label,
          excludeSemantics: true,
          child: isLoading
              ? const SizedBox.square(
                  key: ValueKey('loading'),
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      WenyouIcon(icon!, size: 20),
                      SizedBox(width: tokens.space8),
                    ],
                    Text(label),
                  ],
                ),
        ),
      ),
    );
  }
}

/// A visually strong, shared submit affordance for inline composers and the
/// editor dock. Loading keeps the enabled brand color so it is not mistaken
/// for an unavailable action; only an actually unavailable submit is muted.
class WenyouComposerSubmitButton extends StatelessWidget {
  const WenyouComposerSubmitButton({
    required this.enabled,
    required this.loading,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final bool enabled;
  final bool loading;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final isUnavailable = !enabled && !loading;
    return IconButton.filled(
      constraints: BoxConstraints.tightFor(
        width: tokens.minimumTouchTarget,
        height: tokens.minimumTouchTarget,
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          isUnavailable ? tokens.border : tokens.brandForeground,
        ),
        foregroundColor: WidgetStatePropertyAll(
          isUnavailable ? tokens.mutedText : tokens.panel,
        ),
      ),
      tooltip: loading ? '$label，处理中' : label,
      onPressed: enabled && !loading ? onPressed : null,
      icon: loading
          ? Semantics(
              liveRegion: true,
              label: '$label，处理中',
              child: SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: tokens.panel,
                ),
              ),
            )
          : const WenyouIcon(WenyouIconIds.actionSend),
    );
  }
}

class WenyouEmptyState extends StatelessWidget {
  const WenyouEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.detail,
    this.action,
    super.key,
  });

  final String icon;
  final String title;
  final String message;
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
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (message.trim().isNotEmpty) ...[
          SizedBox(height: tokens.space8),
          Text(
            message,
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
