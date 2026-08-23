import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

@immutable
class WenyouFilterOption<T> {
  const WenyouFilterOption({
    required this.value,
    required this.label,
    this.keyValue,
    this.supportingLabel,
  });

  final T value;
  final String label;
  final Object? keyValue;
  final String? supportingLabel;
}

enum WenyouTabPlacement { page, embedded }

/// Canonical selection for sibling content and page-leading feed categories.
///
/// This is intentionally tap-driven. Pages keep ownership of the selected
/// value and swap their content without installing a swipeable [TabBarView].
class WenyouContentTabs<T> extends StatelessWidget {
  const WenyouContentTabs({
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.semanticsLabel,
    required this.placement,
    this.keyPrefix = 'content-tab',
    this.enabled = true,
    super.key,
  });

  final List<WenyouFilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final String semanticsLabel;
  final WenyouTabPlacement placement;
  final String keyPrefix;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tabs = _WenyouAdaptiveTabBar<T>(
      options: options,
      selected: selected,
      onSelected: onSelected,
      semanticsLabel: semanticsLabel,
      keyPrefix: keyPrefix,
      enabled: enabled,
    );
    if (placement == WenyouTabPlacement.embedded) return tabs;

    return ColoredBox(
      color: context.wenyouTokens.panel,
      child: WenyouContentFrame(child: tabs),
    );
  }
}

class _WenyouAdaptiveTabBar<T> extends StatefulWidget {
  const _WenyouAdaptiveTabBar({
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.semanticsLabel,
    required this.keyPrefix,
    required this.enabled,
  });

  final List<WenyouFilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final String semanticsLabel;
  final String keyPrefix;
  final bool enabled;

  @override
  State<_WenyouAdaptiveTabBar<T>> createState() =>
      _WenyouAdaptiveTabBarState<T>();
}

class _WenyouAdaptiveTabBarState<T> extends State<_WenyouAdaptiveTabBar<T>> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final labelStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700);
    final labelWidths = [
      for (final option in widget.options)
        _measureLabel(context, option.label, labelStyle),
    ];
    final buttonWidths = [
      for (final width in labelWidths)
        math.max(tokens.minimumTouchTarget, width + tokens.space12 * 2),
    ];
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticsLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.panel,
          border: Border(bottom: BorderSide(color: tokens.border)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final optionCount = widget.options.length;
            final canFill =
                optionCount >= 2 &&
                optionCount <= 4 &&
                constraints.maxWidth.isFinite &&
                buttonWidths.every(
                  (width) => width <= constraints.maxWidth / optionCount,
                );
            if (canFill) {
              return Row(
                children: [
                  for (var index = 0; index < optionCount; index++)
                    Expanded(child: _buildButton(index, labelWidths[index])),
                ],
              );
            }
            _scheduleReveal(buttonWidths, constraints.maxWidth);
            return SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var index = 0; index < optionCount; index++)
                    SizedBox(
                      width: buttonWidths[index],
                      child: _buildButton(index, labelWidths[index]),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButton(int index, double labelWidth) {
    final option = widget.options[index];
    return _ContentTabButton<T>(
      key: ValueKey('${widget.keyPrefix}-${option.keyValue ?? option.value}'),
      option: option,
      labelWidth: labelWidth,
      selected: option.value == widget.selected,
      onSelected: widget.onSelected,
      enabled: widget.enabled,
    );
  }

  double _measureLabel(BuildContext context, String label, TextStyle? style) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return painter.width;
  }

  void _scheduleReveal(List<double> widths, double viewportWidth) {
    final selectedIndex = widget.options.indexWhere(
      (option) => option.value == widget.selected,
    );
    if (selectedIndex < 0 || !viewportWidth.isFinite) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      final start = widths
          .take(selectedIndex)
          .fold<double>(0, (sum, width) => sum + width);
      final end = start + widths[selectedIndex];
      final visibleStart = _scrollController.offset;
      final visibleEnd = visibleStart + position.viewportDimension;
      var target = visibleStart;
      if (start < visibleStart) {
        target = start;
      } else if (end > visibleEnd) {
        target = end - position.viewportDimension;
      }
      target = target.clamp(0.0, position.maxScrollExtent).toDouble();
      if ((target - visibleStart).abs() > 0.5) {
        _scrollController.jumpTo(target);
      }
    });
  }
}

class _ContentTabButton<T> extends StatelessWidget {
  const _ContentTabButton({
    required this.option,
    required this.labelWidth,
    required this.selected,
    required this.onSelected,
    required this.enabled,
    super.key,
  });

  final WenyouFilterOption<T> option;
  final double labelWidth;
  final bool selected;
  final ValueChanged<T> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: InkWell(
        onTap: enabled ? () => onSelected(option.value) : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: tokens.minimumTouchTarget,
            minHeight: tokens.minimumTouchTarget,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final indicatorWidth = math.min(
                labelWidth + tokens.space8,
                math.max(0.0, constraints.maxWidth - tokens.space16),
              );
              return Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: tokens.space12),
                    child: Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected
                            ? tokens.brandForeground
                            : tokens.mutedText,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: indicatorWidth,
                        height: 2,
                        decoration: BoxDecoration(
                          color: tokens.brandForeground,
                          borderRadius: BorderRadius.circular(
                            tokens.radiusPill,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class WenyouDropdownFilter<T> extends StatelessWidget {
  const WenyouDropdownFilter({
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.tooltip,
    required this.icon,
    this.enabled = true,
    super.key,
  });

  final List<WenyouFilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final String tooltip;
  final String icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final selectedLabel = options
        .firstWhere((option) => option.value == selected)
        .label;
    final showLeadingIcon = MediaQuery.sizeOf(context).width >= 480;
    return PopupMenuButton<T>(
      initialValue: selected,
      tooltip: tooltip,
      enabled: enabled,
      onSelected: enabled ? onSelected : null,
      position: PopupMenuPosition.under,
      offset: Offset(0, tokens.space4),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius12),
        side: BorderSide(color: tokens.border),
      ),
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 260),
      itemBuilder: (context) => [
        for (final option in options)
          PopupMenuItem<T>(
            value: option.value,
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: option.value == selected
                      ? WenyouIcon(
                          WenyouIconIds.actionConfirm,
                          size: 18,
                          color: tokens.brandForeground,
                        )
                      : null,
                ),
                SizedBox(width: tokens.space8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (option.supportingLabel case final supportingLabel?)
                        Text(
                          supportingLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: tokens.mutedText),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.panel,
          border: Border.all(color: tokens.border),
          borderRadius: BorderRadius.circular(tokens.radius12),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.space8),
            child: Row(
              children: [
                if (showLeadingIcon) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: tokens.softPanel,
                      borderRadius: BorderRadius.circular(tokens.space4),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(tokens.space4),
                      child: WenyouIcon(
                        icon,
                        size: 16,
                        color: tokens.mutedText,
                      ),
                    ),
                  ),
                  SizedBox(width: tokens.space8),
                ],
                Expanded(
                  child: Text(
                    selectedLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                SizedBox(width: tokens.space4),
                WenyouIcon(
                  WenyouIconIds.navigationExpand,
                  size: 18,
                  color: tokens.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
