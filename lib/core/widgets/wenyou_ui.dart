import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

class WenyouConstrainedWidth extends StatelessWidget {
  const WenyouConstrainedWidth({
    required this.child,
    this.maxWidth = 600,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

class WenyouPageBody extends StatelessWidget {
  const WenyouPageBody({
    required this.child,
    this.maxWidth = 520,
    this.bottomPadding = 40,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth <= 400
              ? tokens.space12
              : tokens.space24;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              tokens.space16,
              horizontalPadding,
              bottomPadding,
            ),
            child: WenyouConstrainedWidth(maxWidth: maxWidth, child: child),
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
  final IconData icon;
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
          icon: Icon(icon, size: 20),
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
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final content = Padding(
      padding: padding ?? EdgeInsets.all(tokens.space20),
      child: child,
    );
    return Card(
      color: color ?? tokens.panel,
      clipBehavior: onTap == null ? Clip.none : Clip.antiAlias,
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
        Icons.info_outline_rounded,
      ),
      WenyouStatusTone.accent => (
        tokens.accentedBackground,
        tokens.text,
        Icons.favorite_outline_rounded,
      ),
      WenyouStatusTone.error => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.error_outline_rounded,
      ),
    };
    return Semantics(
      liveRegion: true,
      child: AnimatedContainer(
        duration: tokens.feedbackDuration,
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
            Icon(icon, size: 20, color: foreground),
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
  final IconData? icon;

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
          child: AnimatedSwitcher(
            duration: tokens.feedbackDuration,
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
                        Icon(icon, size: 20),
                        SizedBox(width: tokens.space8),
                      ],
                      Text(label),
                    ],
                  ),
          ),
        ),
      ),
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

  final IconData icon;
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
            child: Icon(icon, size: 32, color: tokens.brand),
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
        SizedBox(height: tokens.space8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
        ),
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
