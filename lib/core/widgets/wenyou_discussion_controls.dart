import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

@immutable
class WenyouDiscussionOrderOption<T extends Object> {
  const WenyouDiscussionOrderOption({
    required this.value,
    required this.label,
    this.summaryLabel,
  });

  final T value;
  final String label;
  final String? summaryLabel;
}

@immutable
class WenyouDiscussionAuthorOption {
  const WenyouDiscussionAuthorOption({
    required this.id,
    required this.label,
    this.supportingLabel,
  });

  final String id;
  final String label;
  final String? supportingLabel;
}

@immutable
class WenyouDiscussionSelection<T extends Object> {
  const WenyouDiscussionSelection({
    required this.order,
    required this.authorId,
  });

  final T order;
  final String? authorId;
}

/// Direct controls for discussion lists whose order and author filters apply
/// immediately. The modal [WenyouDiscussionControls] remains available for
/// surfaces that intentionally keep a draft-and-apply interaction.
class WenyouDiscussionListControls<T extends Object> extends StatelessWidget {
  const WenyouDiscussionListControls({
    required this.countLabel,
    required this.order,
    required this.orderOptions,
    required this.authorId,
    required this.authors,
    required this.onOrderChanged,
    required this.onAuthorChanged,
    this.allAuthorsLabel = '所有人',
    this.enabled = true,
    this.authorsLoading = false,
    this.authorsFailure,
    this.onRetryAuthors,
    this.countKey,
    this.authorKey,
    this.orderKey,
    super.key,
  }) : assert(orderOptions.length > 1);

  const WenyouDiscussionListControls.orderOnly({
    required this.countLabel,
    required this.order,
    required this.orderOptions,
    required this.onOrderChanged,
    this.enabled = true,
    this.countKey,
    this.orderKey,
    super.key,
  }) : authorId = null,
       authors = const [],
       onAuthorChanged = null,
       allAuthorsLabel = '所有人',
       authorsLoading = false,
       authorsFailure = null,
       onRetryAuthors = null,
       authorKey = null,
       assert(orderOptions.length > 1);

  final String countLabel;
  final T order;
  final List<WenyouDiscussionOrderOption<T>> orderOptions;
  final String? authorId;
  final List<WenyouDiscussionAuthorOption> authors;
  final ValueChanged<T> onOrderChanged;
  final ValueChanged<String?>? onAuthorChanged;
  final String allAuthorsLabel;
  final bool enabled;
  final bool authorsLoading;
  final ApiFailure? authorsFailure;
  final VoidCallback? onRetryAuthors;
  final Key? countKey;
  final Key? authorKey;
  final Key? orderKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final count = Text(
      countLabel,
      key: countKey,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: tokens.mutedText,
        fontWeight: FontWeight.w600,
      ),
    );
    final hasAuthorControl = onAuthorChanged != null;
    final actions = hasAuthorControl
        ? _DiscussionDirectActions<T>(
            order: order,
            orderOptions: orderOptions,
            authorId: authorId,
            authors: authors,
            onOrderChanged: onOrderChanged,
            onAuthorChanged: onAuthorChanged!,
            allAuthorsLabel: allAuthorsLabel,
            enabled: enabled,
            authorsLoading: authorsLoading,
            authorsFailure: authorsFailure,
            onRetryAuthors: onRetryAuthors,
            authorKey: authorKey,
            orderKey: orderKey,
          )
        : _DiscussionOrderToggle<T>(
            key: orderKey,
            order: order,
            options: orderOptions,
            enabled: enabled,
            onChanged: onOrderChanged,
          );
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final stackControls = constraints.maxWidth < 312 || textScale > 1.4;
        if (stackControls) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              count,
              SizedBox(height: tokens.space4),
              Align(alignment: Alignment.centerRight, child: actions),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: count),
            SizedBox(width: tokens.space4),
            if (hasAuthorControl)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth >= 480 ? 340 : 268,
                ),
                child: actions,
              )
            else
              actions,
          ],
        );
      },
    );
  }
}

class _DiscussionDirectActions<T extends Object> extends StatelessWidget {
  const _DiscussionDirectActions({
    required this.order,
    required this.orderOptions,
    required this.authorId,
    required this.authors,
    required this.onOrderChanged,
    required this.onAuthorChanged,
    required this.allAuthorsLabel,
    required this.enabled,
    required this.authorsLoading,
    required this.authorsFailure,
    required this.onRetryAuthors,
    required this.authorKey,
    required this.orderKey,
  });

  static const _allAuthorsValue = '__all_discussion_authors__';

  final T order;
  final List<WenyouDiscussionOrderOption<T>> orderOptions;
  final String? authorId;
  final List<WenyouDiscussionAuthorOption> authors;
  final ValueChanged<T> onOrderChanged;
  final ValueChanged<String?> onAuthorChanged;
  final String allAuthorsLabel;
  final bool enabled;
  final bool authorsLoading;
  final ApiFailure? authorsFailure;
  final VoidCallback? onRetryAuthors;
  final Key? authorKey;
  final Key? orderKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 112),
          child: _buildAuthorControl(context),
        ),
        SizedBox(width: tokens.space4),
        _DiscussionOrderToggle<T>(
          key: orderKey,
          order: order,
          options: orderOptions,
          enabled: enabled,
          onChanged: onOrderChanged,
        ),
      ],
    );
  }

  Widget _buildAuthorControl(BuildContext context) {
    if (authorsLoading) {
      return _DiscussionAuthorStatus(key: authorKey, label: '正在加载作者');
    }
    if (authorsFailure != null) {
      return _DiscussionAuthorStatus(
        key: authorKey,
        label: '重新加载作者',
        enabled: enabled && onRetryAuthors != null,
        onPressed: onRetryAuthors,
        retry: true,
      );
    }
    if (authors.isEmpty) {
      return _DiscussionAuthorStatus(key: authorKey, label: '暂无可筛选作者');
    }
    final selectedAuthorExists =
        authorId == null || authors.any((author) => author.id == authorId);
    final selectedValue = selectedAuthorExists && authorId != null
        ? authorId!
        : _allAuthorsValue;
    return WenyouDropdownFilter<String>(
      key: authorKey,
      tooltip: '选择讨论作者',
      icon: WenyouIconIds.identityMember,
      appearance: WenyouDropdownFilterAppearance.quiet,
      enabled: enabled,
      options: [
        WenyouFilterOption(value: _allAuthorsValue, label: allAuthorsLabel),
        for (final author in authors)
          WenyouFilterOption(
            value: author.id,
            label: author.label,
            supportingLabel: author.supportingLabel,
          ),
      ],
      selected: selectedValue,
      onSelected: (value) =>
          onAuthorChanged(value == _allAuthorsValue ? null : value),
    );
  }
}

class _DiscussionAuthorStatus extends StatelessWidget {
  const _DiscussionAuthorStatus({
    required this.label,
    this.enabled = false,
    this.onPressed,
    this.retry = false,
    super.key,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onPressed;
  final bool retry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        minimumSize: Size(0, tokens.minimumTouchTarget),
        padding: EdgeInsets.symmetric(horizontal: tokens.space4),
        foregroundColor: tokens.mutedText,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WenyouIcon(
            retry ? WenyouIconIds.actionRefresh : WenyouIconIds.identityMember,
            size: 16,
          ),
          SizedBox(width: tokens.space4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tokens.mutedText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscussionOrderToggle<T extends Object> extends StatelessWidget {
  const _DiscussionOrderToggle({
    required this.order,
    required this.options,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final T order;
  final List<WenyouDiscussionOrderOption<T>> options;
  final bool enabled;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final currentIndex = options.indexWhere((option) => option.value == order);
    final resolvedIndex = currentIndex < 0 ? 0 : currentIndex;
    final current = options[resolvedIndex];
    final next = options[(resolvedIndex + 1) % options.length];
    final currentLabel = current.summaryLabel ?? current.label;
    return Semantics(
      button: true,
      enabled: enabled,
      label: '当前${current.label}，点击切换为${next.label}',
      child: ExcludeSemantics(
        child: TextButton(
          onPressed: enabled ? () => onChanged(next.value) : null,
          style: TextButton.styleFrom(
            minimumSize: Size(0, tokens.minimumTouchTarget),
            padding: EdgeInsets.symmetric(horizontal: tokens.space4),
            foregroundColor: tokens.mutedText,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const WenyouIcon(WenyouIconIds.actionSort, size: 16),
              SizedBox(width: tokens.space4),
              Flexible(
                child: Text(
                  currentLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.mutedText,
                    fontWeight: FontWeight.w500,
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

class WenyouDiscussionControls<T extends Object> extends StatelessWidget {
  const WenyouDiscussionControls({
    required this.countLabel,
    required this.order,
    required this.defaultOrder,
    required this.orderOptions,
    required this.authorId,
    required this.authors,
    required this.onApply,
    this.orderSectionLabel = '显示顺序',
    this.authorSectionLabel = '只看作者',
    this.allAuthorsLabel = '全部作者',
    this.enabled = true,
    this.authorsLoading = false,
    this.authorsFailure,
    this.onRetryAuthors,
    this.countKey,
    this.settingsKey,
    this.sheetKey,
    super.key,
  });

  final String countLabel;
  final T order;
  final T defaultOrder;
  final List<WenyouDiscussionOrderOption<T>> orderOptions;
  final String? authorId;
  final List<WenyouDiscussionAuthorOption> authors;
  final ValueChanged<WenyouDiscussionSelection<T>> onApply;
  final String orderSectionLabel;
  final String authorSectionLabel;
  final String allAuthorsLabel;
  final bool enabled;
  final bool authorsLoading;
  final ApiFailure? authorsFailure;
  final VoidCallback? onRetryAuthors;
  final Key? countKey;
  final Key? settingsKey;
  final Key? sheetKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final selectedAuthor = authors
        .where((author) => author.id == authorId)
        .firstOrNull;
    final selectedOrder = orderOptions.firstWhere(
      (option) => option.value == order,
    );
    final orderLabel = selectedOrder.summaryLabel ?? selectedOrder.label;
    final settingsLabel = selectedAuthor == null
        ? orderLabel
        : '$orderLabel · ${selectedAuthor.label}';
    final filtered = order != defaultOrder || authorId != null;
    return Row(
      children: [
        Expanded(
          child: Text(
            countLabel,
            key: countKey,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: tokens.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton.icon(
          key: settingsKey,
          onPressed: enabled ? () => _showSettings(context) : null,
          style: TextButton.styleFrom(
            foregroundColor: tokens.mutedText,
            padding: EdgeInsets.symmetric(horizontal: tokens.space8),
          ),
          icon: WenyouIcon(
            WenyouIconIds.actionSettings,
            size: 20,
            color: filtered ? tokens.brandForeground : tokens.mutedText,
          ),
          label: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 144),
            child: Text(
              settingsLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showSettings(BuildContext context) async {
    final selected = await showModalBottomSheet<WenyouDiscussionSelection<T>>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _WenyouDiscussionSettingsSheet<T>(
        key: sheetKey,
        order: order,
        defaultOrder: defaultOrder,
        orderOptions: orderOptions,
        authorId: authorId,
        authors: authors,
        orderSectionLabel: orderSectionLabel,
        authorSectionLabel: authorSectionLabel,
        allAuthorsLabel: allAuthorsLabel,
        authorsLoading: authorsLoading,
        authorsFailure: authorsFailure,
        onRetryAuthors: onRetryAuthors,
      ),
    );
    if (!context.mounted || selected == null) return;
    if (selected.order != order || selected.authorId != authorId) {
      onApply(selected);
    }
  }
}

class _WenyouDiscussionSettingsSheet<T extends Object> extends StatefulWidget {
  const _WenyouDiscussionSettingsSheet({
    required this.order,
    required this.defaultOrder,
    required this.orderOptions,
    required this.authorId,
    required this.authors,
    required this.orderSectionLabel,
    required this.authorSectionLabel,
    required this.allAuthorsLabel,
    required this.authorsLoading,
    required this.authorsFailure,
    required this.onRetryAuthors,
    super.key,
  });

  final T order;
  final T defaultOrder;
  final List<WenyouDiscussionOrderOption<T>> orderOptions;
  final String? authorId;
  final List<WenyouDiscussionAuthorOption> authors;
  final String orderSectionLabel;
  final String authorSectionLabel;
  final String allAuthorsLabel;
  final bool authorsLoading;
  final ApiFailure? authorsFailure;
  final VoidCallback? onRetryAuthors;

  @override
  State<_WenyouDiscussionSettingsSheet<T>> createState() =>
      _WenyouDiscussionSettingsSheetState<T>();
}

class _WenyouDiscussionSettingsSheetState<T extends Object>
    extends State<_WenyouDiscussionSettingsSheet<T>> {
  late T _order = widget.order;
  late String? _authorId = widget.authorId;

  bool get _isDefault => _order == widget.defaultOrder && _authorId == null;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space24,
                0,
                tokens.space8,
                tokens.space8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '讨论设置',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    key: const Key('discussion-settings-close'),
                    onPressed: () => Navigator.pop(context),
                    tooltip: '关闭',
                    icon: const WenyouIcon(WenyouIconIds.actionClose),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: tokens.space8),
                children: [
                  _SectionLabel(label: widget.orderSectionLabel),
                  RadioGroup<T>(
                    groupValue: _order,
                    onChanged: (value) {
                      if (value != null) setState(() => _order = value);
                    },
                    child: Column(
                      children: [
                        for (final option in widget.orderOptions)
                          RadioListTile<T>(
                            value: option.value,
                            title: Text(option.label),
                          ),
                      ],
                    ),
                  ),
                  Divider(height: tokens.space16),
                  _SectionLabel(label: widget.authorSectionLabel),
                  if (widget.authorsLoading)
                    Padding(
                      padding: EdgeInsets.all(tokens.space16),
                      child: const Center(
                        child: SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (widget.authorsFailure case final failure?)
                    Padding(
                      padding: EdgeInsets.all(tokens.space16),
                      child: WenyouFailureBanner(
                        failure: failure,
                        action: widget.onRetryAuthors == null
                            ? null
                            : TextButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onRetryAuthors!();
                                },
                                icon: const WenyouIcon(
                                  WenyouIconIds.actionRefresh,
                                  size: 18,
                                ),
                                label: const Text('重新加载作者'),
                              ),
                      ),
                    )
                  else
                    RadioGroup<String>(
                      groupValue: _authorId ?? '',
                      onChanged: (value) => setState(
                        () => _authorId = value == null || value.isEmpty
                            ? null
                            : value,
                      ),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            value: '',
                            title: Text(widget.allAuthorsLabel),
                          ),
                          for (final author in widget.authors)
                            RadioListTile<String>(
                              value: author.id,
                              title: Text(author.label),
                              subtitle: author.supportingLabel == null
                                  ? null
                                  : Text(author.supportingLabel!),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space16,
                tokens.space8,
                tokens.space16,
                tokens.space16,
              ),
              child: Row(
                children: [
                  if (!_isDefault)
                    TextButton.icon(
                      key: const Key('discussion-settings-reset'),
                      onPressed: () => setState(() {
                        _order = widget.defaultOrder;
                        _authorId = null;
                      }),
                      icon: const WenyouIcon(WenyouIconIds.actionClearFilter),
                      label: const Text('恢复默认'),
                    ),
                  const Spacer(),
                  FilledButton(
                    key: const Key('discussion-settings-apply'),
                    onPressed: () => Navigator.pop(
                      context,
                      WenyouDiscussionSelection<T>(
                        order: _order,
                        authorId: _authorId,
                      ),
                    ),
                    child: const Text('应用'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.space24),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: tokens.mutedText),
      ),
    );
  }
}
