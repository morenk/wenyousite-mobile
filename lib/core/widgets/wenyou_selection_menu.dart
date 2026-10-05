import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/animation/wenyou_motion.dart';

@immutable
class WenyouFilterOption<T> {
  const WenyouFilterOption({
    required this.value,
    required this.label,
    this.keyValue,
    this.supportingLabel,
    this.trailingLabel,
  });

  final T value;
  final String label;
  final Object? keyValue;
  final String? supportingLabel;
  final String? trailingLabel;
}

/// 选择菜单只负责呈现与返回选项，页面继续持有选择和加载状态。
class WenyouSelectionMenu<T> extends StatefulWidget {
  const WenyouSelectionMenu({
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.tooltip,
    required this.anchorBuilder,
    this.enabled = true,
    this.optionKeyPrefix,
    this.menuTitle,
    this.menuSummary,
    this.matchAnchorWidth = false,
    this.showScrollIndicator = false,
    this.optionLeadingBuilder,
    this.optionTrailingBuilder,
    this.optionMaxLines,
    super.key,
  });

  final List<WenyouFilterOption<T>> options;
  final T? selected;
  final ValueChanged<T> onSelected;
  final String tooltip;
  final Widget Function(BuildContext context, bool isOpen) anchorBuilder;
  final bool enabled;
  final String? optionKeyPrefix;
  final String? menuTitle;
  final String? menuSummary;
  final bool matchAnchorWidth;
  final bool showScrollIndicator;
  final Widget Function(BuildContext context, T value)? optionLeadingBuilder;
  final Widget? Function(BuildContext context, T value)? optionTrailingBuilder;
  final int? optionMaxLines;

  @override
  State<WenyouSelectionMenu<T>> createState() => _WenyouSelectionMenuState<T>();
}

class _WenyouSelectionMenuState<T> extends State<WenyouSelectionMenu<T>> {
  bool _open = false;

  void _setOpen(bool value) {
    if (mounted && _open != value) setState(() => _open = value);
  }

  double _menuWidth(BuildContext context, BoxConstraints constraints) {
    final tokens = context.wenyouTokens;
    final media = MediaQuery.of(context);
    final maxWidth = math.max(
      0.0,
      math.min(
        360.0,
        media.size.width - media.padding.horizontal - tokens.space24,
      ),
    );
    final style = Theme.of(
      context,
    ).textTheme.wenyouCompactBody.copyWith(fontWeight: FontWeight.w600);
    double measure(String label) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: Directionality.of(context),
        textScaler: media.textScaler,
        maxLines: 1,
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width;
    }

    var width = math.min(200.0, maxWidth);
    for (final option in widget.options) {
      final labelWidth = math.max(
        measure(option.label),
        measure(option.supportingLabel ?? ''),
      );
      final trailingWidth = option.trailingLabel == null
          ? 0.0
          : measure(option.trailingLabel!) + tokens.space12;
      final leadingWidth = widget.optionLeadingBuilder == null
          ? 0
          : 32 + tokens.space12;
      final actionWidth = widget.optionTrailingBuilder == null
          ? 0
          : tokens.minimumTouchTarget + tokens.space8;
      width = math.max(
        width,
        labelWidth + trailingWidth + leadingWidth + actionWidth + 68,
      );
    }
    if (widget.menuTitle != null) {
      width = math.max(
        width,
        measure(widget.menuTitle!) + measure(widget.menuSummary ?? '') + 48,
      );
    }
    if (widget.matchAnchorWidth && constraints.hasBoundedWidth) {
      width = math.max(width, constraints.maxWidth);
    }
    return width.clamp(0.0, maxWidth);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final enabled = widget.enabled && widget.options.isNotEmpty;
    return LayoutBuilder(
      builder: (context, constraints) {
        final menuWidth = _menuWidth(context, constraints);
        // Scaffold 的正文会移除已避让的键盘 inset；浮层应读取 Navigator 的窗口。
        final media = MediaQuery.of(Navigator.of(context).context);
        final preferredHeight = math.max(
          tokens.minimumTouchTarget,
          math.min(
            media.size.height * 0.5,
            media.size.height -
                media.viewInsets.bottom -
                media.padding.vertical -
                tokens.space24,
          ),
        );
        List<PopupMenuEntry<T>> items(BuildContext context, double menuHeight) {
          final items = <PopupMenuEntry<T>>[
            if (widget.menuTitle case final title?)
              PopupMenuItem<T>(
                enabled: false,
                padding: EdgeInsets.symmetric(horizontal: tokens.space12),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: tokens.space8),
                  child: Wrap(
                    spacing: tokens.space12,
                    runSpacing: tokens.space4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.wenyouCompactTitle,
                      ),
                      if (widget.menuSummary case final summary?)
                        Text(
                          summary,
                          style: Theme.of(context).textTheme.wenyouCaption,
                        ),
                    ],
                  ),
                ),
              ),
            for (final option in widget.options)
              if (widget.optionTrailingBuilder != null)
                _SelectionActionEntry<T>(
                  key: widget.optionKeyPrefix == null || option.keyValue == null
                      ? null
                      : Key('${widget.optionKeyPrefix}-${option.keyValue}'),
                  option: option,
                  selected: option.value == widget.selected,
                  leadingBuilder: widget.optionLeadingBuilder,
                  actionBuilder: widget.optionTrailingBuilder!,
                  maxLines: widget.optionMaxLines,
                )
              else
                PopupMenuItem<T>(
                  key: widget.optionKeyPrefix == null || option.keyValue == null
                      ? null
                      : Key('${widget.optionKeyPrefix}-${option.keyValue}'),
                  value: option.value,
                  height: tokens.minimumTouchTarget,
                  padding: EdgeInsets.zero,
                  child: WenyouSelectionRow(
                    leading: widget.optionLeadingBuilder == null
                        ? null
                        : SizedBox.square(
                            dimension: 32,
                            child: widget.optionLeadingBuilder!(
                              context,
                              option.value,
                            ),
                          ),
                    label: option.label,
                    supportingLabel: option.supportingLabel,
                    trailingLabel: option.trailingLabel,
                    selected: option.value == widget.selected,
                    maxLines: widget.optionMaxLines,
                  ),
                ),
          ];
          if (!widget.showScrollIndicator) return items;
          return [
            _ScrollableSelectionEntries<T>(
              width: menuWidth,
              maxHeight: menuHeight - tokens.space16,
              children: items,
            ),
          ];
        }

        Future<void> open() async {
          if (_open || !enabled) return;
          final button = context.findRenderObject()! as RenderBox;
          final overlay =
              Navigator.of(context).overlay!.context.findRenderObject()!
                  as RenderBox;
          final anchor =
              button.localToGlobal(Offset.zero, ancestor: overlay) &
              button.size;
          final safeBottom =
              media.size.height -
              math.max(media.viewInsets.bottom, media.padding.bottom);
          final belowTop = anchor.bottom + tokens.space4;
          final belowHeight = safeBottom - belowTop - tokens.space8;
          final canOpenBelow =
              belowHeight >= tokens.minimumTouchTarget + tokens.space16;
          final menuHeight = canOpenBelow
              ? math.min(preferredHeight, belowHeight)
              : preferredHeight;
          final top = canOpenBelow
              ? belowTop
              : math.max(
                  media.padding.top + tokens.space8,
                  anchor.top - menuHeight - tokens.space4,
                );
          _setOpen(true);
          final value = await showMenu<T>(
            context: context,
            position: RelativeRect.fromRect(
              Rect.fromLTWH(anchor.left, top, anchor.width, 0),
              Offset.zero & overlay.size,
            ),
            constraints: BoxConstraints(
              minWidth: menuWidth,
              maxWidth: menuWidth,
              maxHeight: menuHeight,
            ),
            clipBehavior: Clip.antiAlias,
            popUpAnimationStyle: wenyouAnimationsDisabled(context)
                ? AnimationStyle.noAnimation
                : null,
            items: items(context, menuHeight),
          );
          if (!mounted) return;
          _setOpen(false);
          if (value != null && value != widget.selected) {
            widget.onSelected(value);
          }
        }

        return Material(
          type: MaterialType.transparency,
          child: Tooltip(
            message: widget.tooltip,
            child: InkWell(
              borderRadius: BorderRadius.circular(tokens.radiusPanel),
              onTap: enabled ? open : null,
              child: Semantics(
                button: true,
                enabled: enabled,
                expanded: _open,
                child: widget.anchorBuilder(context, _open),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 同一视觉行中的选择和次要动作分别可聚焦，不合并读屏点击语义。
class _SelectionActionEntry<T> extends PopupMenuEntry<T> {
  const _SelectionActionEntry({
    required this.option,
    required this.selected,
    required this.actionBuilder,
    this.leadingBuilder,
    this.maxLines,
    super.key,
  });
  final WenyouFilterOption<T> option;
  final bool selected;
  final Widget Function(BuildContext, T)? leadingBuilder;
  final Widget? Function(BuildContext, T) actionBuilder;
  final int? maxLines;
  @override
  double get height => 48;
  @override
  bool represents(T? value) => option.value == value;
  @override
  State<_SelectionActionEntry<T>> createState() =>
      _SelectionActionEntryState<T>();
}

class _SelectionActionEntryState<T> extends State<_SelectionActionEntry<T>> {
  @override
  Widget build(BuildContext context) {
    final option = widget.option;
    final tokens = context.wenyouTokens;
    final action = widget.actionBuilder(context, option.value);
    final row = WenyouSelectionRow(
      label: option.label,
      supportingLabel: option.supportingLabel,
      trailingLabel: option.trailingLabel,
      selected: widget.selected,
      maxLines: widget.maxLines,
      leading: widget.leadingBuilder == null
          ? null
          : SizedBox.square(
              dimension: 32,
              child: widget.leadingBuilder!(context, option.value),
            ),
    );
    if (action == null) {
      return PopupMenuItem<T>(
        value: option.value,
        padding: EdgeInsets.zero,
        child: row,
      );
    }
    return Row(
      children: [
        Expanded(
          child: Semantics(
            container: true,
            button: true,
            selected: widget.selected,
            child: InkWell(
              borderRadius: BorderRadius.circular(tokens.radiusControl),
              onTap: () => Navigator.of(context).pop(option.value),
              child: row,
            ),
          ),
        ),
        action,
        SizedBox(width: tokens.space4),
      ],
    );
  }
}

/// 菜单自己持有滚动控制器，让移动端也能常显滚动提示。
class _ScrollableSelectionEntries<T> extends PopupMenuEntry<T> {
  const _ScrollableSelectionEntries({
    required this.width,
    required this.maxHeight,
    required this.children,
  });

  final double width;
  final double maxHeight;
  final List<PopupMenuEntry<T>> children;

  @override
  double get height => 0;

  @override
  bool represents(T? value) => false;

  @override
  State<_ScrollableSelectionEntries<T>> createState() =>
      _ScrollableSelectionEntriesState<T>();
}

class _ScrollableSelectionEntriesState<T>
    extends State<_ScrollableSelectionEntries<T>> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.width,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      child: Scrollbar(
        controller: _controller,
        thumbVisibility: true,
        scrollbarOrientation: ScrollbarOrientation.right,
        child: SingleChildScrollView(
          controller: _controller,
          primary: false,
          padding: EdgeInsets.only(right: context.wenyouTokens.space8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.children,
          ),
        ),
      ),
    ),
  );
}

/// 菜单和抽屉共用文字层级、行内留白与右侧选中标记。
class WenyouSelectionRow extends StatelessWidget {
  const WenyouSelectionRow({
    required this.label,
    required this.selected,
    this.supportingLabel,
    this.trailingLabel,
    this.leading,
    this.enabled = true,
    this.emphasizeSelected = true,
    this.maxLines,
    super.key,
  });

  final String label;
  final bool selected;
  final String? supportingLabel;
  final String? trailingLabel;
  final Widget? leading;
  final bool enabled;
  final bool emphasizeSelected;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final theme = Theme.of(context).textTheme;
    return Semantics(
      selected: selected,
      child: Ink(
        decoration: BoxDecoration(
          color: selected ? tokens.accentedBackground : null,
          borderRadius: BorderRadius.circular(tokens.radiusControl),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space12,
              vertical: tokens.space8,
            ),
            child: Row(
              children: [
                if (leading != null) ...[
                  ExcludeSemantics(child: leading!),
                  SizedBox(width: tokens.space12),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: maxLines,
                        overflow: maxLines == null
                            ? null
                            : TextOverflow.ellipsis,
                        style: theme.wenyouCompactBody.copyWith(
                          color: !enabled
                              ? Theme.of(context).disabledColor
                              : selected
                              ? tokens.onAccentedBackground
                              : tokens.text,
                          fontWeight: selected && emphasizeSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (supportingLabel case final supporting?)
                        Text(supporting, style: theme.wenyouCaption),
                      if (trailingLabel case final trailing?)
                        Text(trailing, style: theme.wenyouUtilityCaption),
                    ],
                  ),
                ),
                SizedBox(width: tokens.space12),
                SizedBox.square(
                  dimension: 18,
                  child: selected
                      ? WenyouIcon(
                          WenyouIconIds.actionConfirm,
                          size: 18,
                          color: enabled
                              ? tokens.brandForeground
                              : Theme.of(context).disabledColor,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 页面与抽屉里的整行选择入口，选择和禁用状态共用菜单的呈现。
class WenyouSelectionTile extends StatelessWidget {
  const WenyouSelectionTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.supportingLabel,
    this.leading,
    this.emphasizeSelected = true,
    this.maxLines,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final String? supportingLabel;
  final Widget? leading;
  final bool emphasizeSelected;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null,
    child: InkWell(
      borderRadius: BorderRadius.circular(context.wenyouTokens.radiusControl),
      onTap: onTap,
      child: WenyouSelectionRow(
        label: label,
        selected: selected,
        enabled: onTap != null,
        supportingLabel: supportingLabel,
        leading: leading,
        emphasizeSelected: emphasizeSelected,
        maxLines: maxLines,
      ),
    ),
  );
}

class WenyouMenuActionLabel extends StatelessWidget {
  const WenyouMenuActionLabel({
    required this.icon,
    required this.label,
    this.destructive = false,
    super.key,
  });

  final String icon;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final color = destructive ? tokens.destructive : tokens.text;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.space8),
      child: Row(
        children: [
          WenyouIcon(icon, size: 18, color: color),
          SizedBox(width: tokens.space12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.wenyouCompactBody.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
