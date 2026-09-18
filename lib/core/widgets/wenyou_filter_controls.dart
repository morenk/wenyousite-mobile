import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/animation/wenyou_motion.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selection_menu.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

export 'wenyou_selection_menu.dart' show WenyouFilterOption;

enum WenyouDropdownFilterAppearance { outlined, quiet }

enum WenyouTabPlacement { page, embedded }

/// 表单字段与筛选复用同一选项菜单，保留 Form 的校验和重置行为。
class WenyouDropdownFormField<T> extends StatelessWidget {
  const WenyouDropdownFormField({
    required this.options,
    required this.onChanged,
    this.initialValue,
    this.decoration = const InputDecoration(),
    this.hint,
    this.validator,
    this.autovalidateMode,
    super.key,
  });
  final List<WenyouFilterOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final T? initialValue;
  final InputDecoration decoration;
  final Widget? hint;
  final FormFieldValidator<T>? validator;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return _SelectionFormField<T>(
      initialValue: initialValue,
      enabled: onChanged != null,
      validator: validator,
      autovalidateMode: autovalidateMode,
      onReset: () => onChanged?.call(initialValue),
      builder: (field) => WenyouSelectionMenu<T>(
        options: options,
        selected: field.value,
        enabled: onChanged != null,
        tooltip: decoration.labelText ?? '选择选项',
        matchAnchorWidth: true,
        onSelected: (value) {
          field.didChange(value);
          onChanged?.call(value);
        },
        anchorBuilder: (context, isOpen) => InputDecorator(
          decoration: decoration.copyWith(
            enabled: onChanged != null,
            errorText: field.errorText,
            suffixIcon: WenyouIcon(
              isOpen
                  ? WenyouIconIds.navigationCollapse
                  : WenyouIconIds.navigationExpand,
              size: 16,
              color: onChanged == null ? tokens.mutedText : tokens.text,
            ),
          ),
          isEmpty: field.value == null,
          isFocused: isOpen,
          child: field.value == null
              ? hint ?? const SizedBox.shrink()
              : Text(
                  options
                          .where((option) => option.value == field.value)
                          .firstOrNull
                          ?.label ??
                      '',
                  style: Theme.of(context).textTheme.wenyouCompactBody.copyWith(
                    color: onChanged == null ? tokens.mutedText : tokens.text,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SelectionFormField<T> extends FormField<T> {
  const _SelectionFormField({
    required super.builder,
    super.initialValue,
    super.enabled,
    super.validator,
    super.autovalidateMode,
    super.onReset,
  });

  @override
  FormFieldState<T> createState() => _SelectionFormFieldState<T>();
}

class _SelectionFormFieldState<T> extends FormFieldState<T> {
  @override
  void didUpdateWidget(covariant _SelectionFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 与原 DropdownButtonFormField 保持一致，接收页面回填的新初始值。
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }
}

/// Canonical selection for sibling content and page-leading feed categories.
///
/// Pages keep ownership of the selected value and swap their content without
/// installing a [TabBarView]. A page can pair this bar with
/// [WenyouSwipeTabRegion] when its content should also support swipe switching.
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

/// Adds adjacent-tab switching to a page's content region.
///
/// The horizontal recognizer does not claim vertical drags, so feed scrolling
/// and pull-to-refresh remain owned by the child. Keep horizontally scrollable
/// tab bars outside this region when their own drag interaction is required.
class WenyouSwipeTabRegion<T> extends StatefulWidget {
  const WenyouSwipeTabRegion({
    required this.values,
    required this.selected,
    required this.onSelected,
    required this.child,
    this.minimumDragDistance = 48,
    super.key,
  }) : assert(minimumDragDistance > 0);

  final List<T> values;
  final T selected;
  final ValueChanged<T> onSelected;
  final Widget child;
  final double minimumDragDistance;

  @override
  State<WenyouSwipeTabRegion<T>> createState() =>
      _WenyouSwipeTabRegionState<T>();
}

class _WenyouSwipeTabRegionState<T> extends State<WenyouSwipeTabRegion<T>>
    with SingleTickerProviderStateMixin {
  double _horizontalDistance = 0;
  var _direction = 1;
  late final AnimationController _contentTransitionController;

  @override
  void initState() {
    super.initState();
    _contentTransitionController = AnimationController(
      vsync: this,
      duration: WenyouFoundationMotion.standard,
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant WenyouSwipeTabRegion<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected == widget.selected) return;
    final previousIndex = widget.values.indexOf(oldWidget.selected);
    final currentIndex = widget.values.indexOf(widget.selected);
    if (previousIndex >= 0 && currentIndex >= 0) {
      _direction = currentIndex >= previousIndex ? 1 : -1;
    }
    if (wenyouAnimationsDisabled(context)) {
      _contentTransitionController.value = 1;
    } else {
      _contentTransitionController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _contentTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = _contentTransitionController
        .drive(CurveTween(curve: wenyouStandardMotionCurve))
        .drive(
          Tween<Offset>(begin: Offset(_direction * 0.06, 0), end: Offset.zero),
        );
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => _horizontalDistance = 0,
      onHorizontalDragUpdate: (details) {
        _horizontalDistance += details.primaryDelta ?? 0;
      },
      onHorizontalDragCancel: _resetDrag,
      onHorizontalDragEnd: (_) {
        final distance = _horizontalDistance;
        _resetDrag();
        if (distance.abs() < widget.minimumDragDistance) return;

        final currentIndex = widget.values.indexOf(widget.selected);
        if (currentIndex < 0) return;
        final targetIndex = distance < 0 ? currentIndex + 1 : currentIndex - 1;
        if (targetIndex < 0 || targetIndex >= widget.values.length) return;
        widget.onSelected(widget.values[targetIndex]);
      },
      child: ClipRect(
        child: ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SlideTransition(position: position, child: widget.child),
        ),
      ),
    );
  }

  void _resetDrag() {
    _horizontalDistance = 0;
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
    ).textTheme.wenyouLabel.copyWith(fontWeight: FontWeight.w700);
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
            final horizontalPadding = optionCount == 4
                ? tokens.space8
                : tokens.space12;
            final canFill =
                optionCount >= 2 &&
                optionCount <= 4 &&
                constraints.maxWidth.isFinite &&
                labelWidths.every(
                  (width) =>
                      width + horizontalPadding * 2 <=
                      constraints.maxWidth / optionCount,
                );
            if (canFill) {
              return Row(
                children: [
                  for (var index = 0; index < optionCount; index++)
                    Expanded(
                      child: _buildButton(
                        index,
                        labelWidths[index],
                        horizontalPadding,
                      ),
                    ),
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
                      child: _buildButton(
                        index,
                        labelWidths[index],
                        tokens.space12,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButton(int index, double labelWidth, double horizontalPadding) {
    final option = widget.options[index];
    return _ContentTabButton<T>(
      key: ValueKey('${widget.keyPrefix}-${option.keyValue ?? option.value}'),
      option: option,
      labelWidth: labelWidth,
      horizontalPadding: horizontalPadding,
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
    required this.horizontalPadding,
    required this.selected,
    required this.onSelected,
    required this.enabled,
    super.key,
  });

  final WenyouFilterOption<T> option;
  final double labelWidth;
  final double horizontalPadding;
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
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: Theme.of(context).textTheme.wenyouLabel.copyWith(
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
    this.enabled = true,
    this.appearance = WenyouDropdownFilterAppearance.outlined,
    this.optionKeyPrefix,
    this.selectedLabel,
    super.key,
  });
  final List<WenyouFilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final String tooltip;
  final bool enabled;
  final WenyouDropdownFilterAppearance appearance;
  final String? optionKeyPrefix;
  final String? selectedLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final quiet = appearance == WenyouDropdownFilterAppearance.quiet;
    final label =
        selectedLabel ??
        options
            .where((option) => option.value == selected)
            .firstOrNull
            ?.label ??
        '';
    return WenyouSelectionMenu<T>(
      options: options,
      selected: selected,
      onSelected: onSelected,
      tooltip: tooltip,
      enabled: enabled,
      optionKeyPrefix: optionKeyPrefix,
      matchAnchorWidth: !quiet,
      anchorBuilder: (context, isOpen) => Container(
        constraints: BoxConstraints(
          minWidth: tokens.minimumTouchTarget,
          minHeight: tokens.minimumTouchTarget,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: quiet ? tokens.space8 : tokens.space12,
        ),
        decoration: BoxDecoration(
          color: isOpen
              ? tokens.accentedBackground
              : quiet
              ? null
              : tokens.panel,
          border: quiet
              ? null
              : Border.all(color: isOpen ? tokens.focus : tokens.input),
          borderRadius: BorderRadius.circular(tokens.radius16),
        ),
        child: Row(
          mainAxisSize: quiet ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Flexible(
              fit: quiet ? FlexFit.loose : FlexFit.tight,
              child: Text(
                label,
                maxLines: quiet ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style:
                    (quiet
                            ? Theme.of(context).textTheme.wenyouCaption
                            : Theme.of(context).textTheme.wenyouCompactBody)
                        .copyWith(
                          color: !enabled
                              ? tokens.mutedText
                              : isOpen
                              ? tokens.onAccentedBackground
                              : quiet
                              ? tokens.mutedText
                              : tokens.text,
                          fontWeight: quiet ? FontWeight.w500 : FontWeight.w400,
                        ),
              ),
            ),
            SizedBox(width: tokens.space8),
            WenyouIcon(
              isOpen
                  ? WenyouIconIds.navigationCollapse
                  : WenyouIconIds.navigationExpand,
              size: 16,
              color: tokens.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}
