import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/animation/wenyou_motion.dart';
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

enum WenyouDropdownFilterAppearance { outlined, quiet }

enum WenyouTabPlacement { page, embedded }

/// Canonical outlined dropdown for form fields.
///
/// Flutter's default dropdown route and tap state use smaller, unrelated
/// corners. Keeping these values here makes the closed field, transient state
/// layer, expanded menu and menu rows share the mobile control geometry.
class WenyouDropdownFormField<T> extends StatelessWidget {
  const WenyouDropdownFormField({
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.decoration = const InputDecoration(),
    this.hint,
    this.validator,
    this.autovalidateMode,
    super.key,
  });

  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? initialValue;
  final InputDecoration decoration;
  final Widget? hint;
  final FormFieldValidator<T>? validator;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final radius = BorderRadius.circular(tokens.radius16);
    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      decoration: decoration,
      hint: hint,
      items: items,
      onChanged: onChanged,
      validator: validator,
      autovalidateMode: autovalidateMode,
      isExpanded: true,
      itemHeight: tokens.minimumTouchTarget,
      menuMaxHeight: MediaQuery.sizeOf(context).height * 0.5,
      dropdownColor: tokens.panel,
      focusColor: tokens.accentedBackground,
      borderRadius: radius,
      icon: WenyouIcon(
        WenyouIconIds.navigationExpand,
        size: 18,
        color: onChanged == null ? tokens.mutedText : tokens.text,
      ),
    );
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
    required this.icon,
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
  final String icon;
  final bool enabled;
  final WenyouDropdownFilterAppearance appearance;
  final String? optionKeyPrefix;
  final String? selectedLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final resolvedSelectedLabel =
        selectedLabel ??
        options.firstWhere((option) => option.value == selected).label;
    final showLeadingIcon =
        appearance == WenyouDropdownFilterAppearance.outlined &&
        MediaQuery.sizeOf(context).width >= 480;
    final radius = BorderRadius.circular(tokens.radius16);
    return LayoutBuilder(
      builder: (context, constraints) {
        final alignedMenuConstraints =
            appearance == WenyouDropdownFilterAppearance.quiet
            ? const BoxConstraints(minWidth: 160, maxWidth: 260)
            : constraints.hasBoundedWidth
            ? BoxConstraints.tightFor(width: constraints.maxWidth)
            : const BoxConstraints(minWidth: 160, maxWidth: 260);
        return PopupMenuButton<T>(
          initialValue: selected,
          tooltip: tooltip,
          enabled: enabled,
          onSelected: enabled ? onSelected : null,
          position: PopupMenuPosition.under,
          offset: Offset(0, tokens.space4),
          elevation: 4,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: tokens.border),
          ),
          constraints: alignedMenuConstraints,
          itemBuilder: (context) => [
            for (final option in options)
              PopupMenuItem<T>(
                key: optionKeyPrefix == null || option.keyValue == null
                    ? null
                    : Key('$optionKeyPrefix-${option.keyValue}'),
                value: option.value,
                height: tokens.minimumTouchTarget,
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
                          if (option.supportingLabel
                              case final supportingLabel?)
                            Text(
                              supportingLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.wenyouCaption
                                  .copyWith(color: tokens.mutedText),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
          child: _DropdownFilterAnchor(
            appearance: appearance,
            selectedLabel: resolvedSelectedLabel,
            icon: icon,
            showLeadingIcon: showLeadingIcon,
          ),
        );
      },
    );
  }
}

class _DropdownFilterAnchor extends StatelessWidget {
  const _DropdownFilterAnchor({
    required this.appearance,
    required this.selectedLabel,
    required this.icon,
    required this.showLeadingIcon,
  });

  final WenyouDropdownFilterAppearance appearance;
  final String selectedLabel;
  final String icon;
  final bool showLeadingIcon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final quiet = appearance == WenyouDropdownFilterAppearance.quiet;
    final labelStyle = quiet
        ? Theme.of(context).textTheme.wenyouCaption.copyWith(
            color: tokens.mutedText,
            fontWeight: FontWeight.w500,
          )
        : Theme.of(context).textTheme.wenyouCaptionEmphasis;
    final content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: quiet ? tokens.space4 : tokens.space8,
        ),
        child: Row(
          mainAxisSize: quiet ? MainAxisSize.min : MainAxisSize.max,
          children: [
            if (showLeadingIcon) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.softPanel,
                  borderRadius: BorderRadius.circular(tokens.space4),
                ),
                child: Padding(
                  padding: EdgeInsets.all(tokens.space4),
                  child: WenyouIcon(icon, size: 16, color: tokens.mutedText),
                ),
              ),
              SizedBox(width: tokens.space8),
            ],
            Flexible(
              fit: quiet ? FlexFit.loose : FlexFit.tight,
              child: Text(
                selectedLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
            ),
            SizedBox(width: tokens.space4),
            WenyouIcon(
              WenyouIconIds.navigationExpand,
              size: quiet ? 16 : 18,
              color: tokens.mutedText,
            ),
          ],
        ),
      ),
    );
    if (appearance == WenyouDropdownFilterAppearance.quiet) return content;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border.all(color: tokens.border),
        borderRadius: BorderRadius.circular(tokens.radius16),
      ),
      child: content,
    );
  }
}
