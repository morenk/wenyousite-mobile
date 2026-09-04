import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

export 'package:wenyousite_mobile/core/widgets/wenyou_actions.dart';
export 'package:wenyousite_mobile/core/widgets/wenyou_feedback.dart';
export 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';

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

/// Applies the shared responsive horizontal gutter and content width to a
/// page region without taking over scrolling.
class WenyouContentFrame extends StatelessWidget {
  const WenyouContentFrame({
    required this.child,
    this.top = 0,
    this.bottom = 0,
    this.maxWidth,
    super.key,
  });

  final Widget child;
  final double top;
  final double bottom;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final horizontal = wenyouHorizontalPagePadding(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom),
      child: WenyouConstrainedWidth(maxWidth: maxWidth, child: child),
    );
  }
}

/// Compact top chrome for continuous-reading detail pages.
class WenyouReadingAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const WenyouReadingAppBar({
    this.leading,
    this.title,
    this.actions,
    super.key,
  });

  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;

  @override
  Size get preferredSize =>
      Size.fromHeight(WenyouControlContract.minimumTarget);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      leading: leading,
      title: title,
      actions: actions,
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

class WenyouIconLabelActionBar extends StatelessWidget {
  const WenyouIconLabelActionBar({required this.actions, super.key})
    : assert(actions.length > 0);

  final List<WenyouIconLabelAction> actions;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final action in actions) Expanded(child: action)],
      ),
    );
  }
}

class WenyouIconLabelAction extends StatelessWidget {
  const WenyouIconLabelAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.selected,
    this.foregroundColor,
    this.semanticsLabel,
    super.key,
  });

  final String icon;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool? selected;
  final Color? foregroundColor;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final enabled = onPressed != null && !loading;
    final color = enabled || loading
        ? foregroundColor ?? tokens.text
        : tokens.mutedText;
    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: tokens.minimumTouchTarget + tokens.space12,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.space4,
                vertical: tokens.space8,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox.square(
                    dimension: 22,
                    child: loading
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                            color: color,
                          )
                        : WenyouIcon(icon, size: 22, color: color),
                  ),
                  SizedBox(height: tokens.space4),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.wenyouCaptionEmphasis
                        .copyWith(color: color, height: 1.15),
                  ),
                ],
              ),
            ),
          ),
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

class WenyouListSkeleton extends StatelessWidget {
  const WenyouListSkeleton({
    this.label = '内容加载中',
    this.itemCount = 3,
    this.showAvatar = true,
    super.key,
  });

  final String label;
  final int itemCount;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      liveRegion: true,
      label: label,
      child: ExcludeSemantics(
        child: Column(
          key: const Key('wenyou-list-skeleton'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < itemCount; index++) ...[
              if (index > 0) SizedBox(height: tokens.space12),
              WenyouPanel(
                padding: EdgeInsets.all(tokens.space12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showAvatar) ...[
                      WenyouSkeletonBlock(
                        width: 40,
                        height: 40,
                        radius: tokens.radiusPill,
                      ),
                      SizedBox(width: tokens.space12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FractionallySizedBox(
                            widthFactor: index.isEven ? 0.64 : 0.48,
                            child: const WenyouSkeletonBlock(height: 14),
                          ),
                          SizedBox(height: tokens.space12),
                          const WenyouSkeletonBlock(height: 12),
                          SizedBox(height: tokens.space8),
                          const FractionallySizedBox(
                            widthFactor: 0.72,
                            child: WenyouSkeletonBlock(height: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class WenyouDetailSkeleton extends StatelessWidget {
  const WenyouDetailSkeleton({this.label = '详情加载中', super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      liveRegion: true,
      label: label,
      child: ExcludeSemantics(
        child: WenyouPanel(
          key: const Key('wenyou-detail-skeleton'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FractionallySizedBox(
                widthFactor: 0.74,
                child: WenyouSkeletonBlock(height: 24),
              ),
              SizedBox(height: tokens.space16),
              const WenyouSkeletonBlock(height: 14),
              SizedBox(height: tokens.space8),
              const WenyouSkeletonBlock(height: 14),
              SizedBox(height: tokens.space8),
              const FractionallySizedBox(
                widthFactor: 0.58,
                child: WenyouSkeletonBlock(height: 14),
              ),
              SizedBox(height: tokens.space20),
              const WenyouSkeletonBlock(height: 88),
            ],
          ),
        ),
      ),
    );
  }
}

class WenyouSkeletonBlock extends StatelessWidget {
  const WenyouSkeletonBlock({
    required this.height,
    this.width = double.infinity,
    this.radius,
    super.key,
  });

  final double width;
  final double height;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tokens.softPanel,
        borderRadius: BorderRadius.circular(radius ?? tokens.radiusPill),
      ),
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
                  style: Theme.of(context).textTheme.wenyouSectionTitle,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: tokens.space8),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.wenyouCompactBody.copyWith(
                    color: tokens.mutedText,
                  ),
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
    return WenyouAsyncButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      loadingLabel: loadingLabel,
      icon: icon,
      expand: true,
    );
  }
}

class WenyouAsyncButton extends StatelessWidget {
  const WenyouAsyncButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.loadingLabel,
    this.icon,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingLabel;
  final String? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return SizedBox(
      width: expand ? double.infinity : null,
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
    final scheme = Theme.of(context).colorScheme;
    final isUnavailable = !enabled && !loading;
    return IconButton.filled(
      constraints: BoxConstraints.tightFor(
        width: tokens.minimumTouchTarget,
        height: tokens.minimumTouchTarget,
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          isUnavailable ? tokens.border : scheme.primary,
        ),
        foregroundColor: WidgetStatePropertyAll(
          isUnavailable ? tokens.mutedText : scheme.onPrimary,
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
                  color: scheme.onPrimary,
                ),
              ),
            )
          : const WenyouIcon(WenyouIconIds.actionSend),
    );
  }
}
