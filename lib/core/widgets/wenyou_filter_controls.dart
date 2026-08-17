import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

@immutable
class WenyouFilterOption<T> {
  const WenyouFilterOption({required this.value, required this.label});

  final T value;
  final String label;
}

class WenyouLineFilterBar<T> extends StatelessWidget {
  const WenyouLineFilterBar({
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.semanticsLabel,
    this.keyPrefix = 'line-filter',
    super.key,
  });

  final List<WenyouFilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final String semanticsLabel;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticsLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: tokens.border)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final option in options)
                _LineFilterButton<T>(
                  key: ValueKey('$keyPrefix-${option.value}'),
                  option: option,
                  selected: option.value == selected,
                  onSelected: onSelected,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineFilterButton<T> extends StatelessWidget {
  const _LineFilterButton({
    required this.option,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final WenyouFilterOption<T> option;
  final bool selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: () => onSelected(option.value),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: tokens.space12),
                child: Text(
                  option.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? tokens.brandForeground : tokens.mutedText,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                Positioned(
                  right: tokens.space8,
                  bottom: 0,
                  left: tokens.space8,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: tokens.brandForeground,
                      borderRadius: BorderRadius.circular(tokens.radiusPill),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class WenyouCategoryFilterBar<T> extends StatelessWidget {
  const WenyouCategoryFilterBar({
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.semanticsLabel,
    this.keyPrefix = 'category-filter',
    super.key,
  });

  final List<WenyouFilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final String semanticsLabel;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticsLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.softPanel,
          borderRadius: BorderRadius.circular(tokens.radius12),
        ),
        child: SizedBox(
          height: tokens.minimumTouchTarget,
          child: ListView.separated(
            padding: EdgeInsets.all(tokens.space4),
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, _) => SizedBox(width: tokens.space4),
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option.value == selected;
              return Semantics(
                button: true,
                selected: isSelected,
                child: InkWell(
                  key: ValueKey('$keyPrefix-${option.value}'),
                  onTap: () => onSelected(option.value),
                  borderRadius: BorderRadius.circular(tokens.radius12),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isSelected ? tokens.panel : Colors.transparent,
                      border: isSelected
                          ? Border.all(color: tokens.border)
                          : null,
                      borderRadius: BorderRadius.circular(tokens.radius12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: tokens.space12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? tokens.brandForeground
                                  : tokens.mutedText,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: tokens.space8),
                          Text(
                            option.label,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
    super.key,
  });

  final List<WenyouFilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final String tooltip;
  final String icon;

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
      onSelected: onSelected,
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
                Text(option.label),
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
