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
    final style = Theme.of(context).textTheme.wenyouCompactBody;
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
      width = math.max(width, labelWidth + trailingWidth + 68);
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
        return Material(
          type: MaterialType.transparency,
          child: PopupMenuButton<T>(
            tooltip: widget.tooltip,
            enabled: enabled,
            // 不传 initialValue：Flutter 会据此把已选行移到锚点上，破坏下拉定位。
            position: PopupMenuPosition.under,
            offset: Offset(0, tokens.space4),
            borderRadius: BorderRadius.circular(tokens.radius16),
            clipBehavior: Clip.antiAlias,
            popUpAnimationStyle: wenyouAnimationsDisabled(context)
                ? AnimationStyle.noAnimation
                : null,
            constraints: BoxConstraints(
              minWidth: menuWidth,
              maxWidth: menuWidth,
              maxHeight: MediaQuery.sizeOf(context).height * 0.5,
            ),
            onOpened: () => _setOpen(true),
            onCanceled: () => _setOpen(false),
            onSelected: (value) {
              _setOpen(false);
              // 重选只收起菜单，不重新加载列表或重复提交字段。
              if (value != widget.selected) widget.onSelected(value);
            },
            itemBuilder: (context) {
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
                            style: Theme.of(
                              context,
                            ).textTheme.wenyouCompactTitle,
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
                  PopupMenuItem<T>(
                    key:
                        widget.optionKeyPrefix == null ||
                            option.keyValue == null
                        ? null
                        : Key('${widget.optionKeyPrefix}-${option.keyValue}'),
                    value: option.value,
                    height: tokens.minimumTouchTarget,
                    padding: EdgeInsets.zero,
                    child: WenyouSelectionRow(
                      label: option.label,
                      supportingLabel: option.supportingLabel,
                      trailingLabel: option.trailingLabel,
                      selected: option.value == widget.selected,
                    ),
                  ),
              ];
              if (!widget.showScrollIndicator) return items;
              return [
                _ScrollableSelectionEntries<T>(
                  width: menuWidth,
                  maxHeight:
                      MediaQuery.sizeOf(context).height * 0.5 - tokens.space8,
                  children: items,
                ),
              ];
            },
            child: Semantics(
              expanded: _open,
              child: widget.anchorBuilder(context, _open),
            ),
          ),
        );
      },
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
    super.key,
  });

  final String label;
  final bool selected;
  final String? supportingLabel;
  final String? trailingLabel;
  final Widget? leading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final theme = Theme.of(context).textTheme;
    return Semantics(
      selected: selected,
      child: Ink(
        decoration: BoxDecoration(
          color: selected ? tokens.accentedBackground : null,
          borderRadius: BorderRadius.circular(tokens.radius12),
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
                        style: theme.wenyouCompactBody.copyWith(
                          color: !enabled
                              ? Theme.of(context).disabledColor
                              : selected
                              ? tokens.onAccentedBackground
                              : tokens.text,
                          fontWeight: selected
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
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final String? supportingLabel;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null,
    child: InkWell(
      borderRadius: BorderRadius.circular(context.wenyouTokens.radius12),
      onTap: onTap,
      child: WenyouSelectionRow(
        label: label,
        selected: selected,
        enabled: onTap != null,
        supportingLabel: supportingLabel,
        leading: leading,
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
