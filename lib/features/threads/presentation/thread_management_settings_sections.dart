import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';

class ThreadManagementGroupLabel extends StatelessWidget {
  const ThreadManagementGroupLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        label,
        style: Theme.of(context).textTheme.wenyouSubsectionTitle,
      ),
    );
  }
}

class ThreadManagementBasicsSection extends StatelessWidget {
  const ThreadManagementBasicsSection({
    required this.titleController,
    required this.titleFocusNode,
    required this.categories,
    required this.categorySlug,
    required this.tags,
    required this.enabled,
    required this.onTitleChanged,
    required this.onCategoryChanged,
    required this.onEditTags,
    required this.version,
    super.key,
  });

  final TextEditingController titleController;
  final FocusNode titleFocusNode;
  final List<ThreadManagementCategory> categories;
  final String? categorySlug;
  final List<String> tags;
  final bool enabled;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onEditTags;
  final int version;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final selectedCategory = categories
        .where((category) => category.slug == categorySlug)
        .firstOrNull;
    final hasSelectableCategory = categories.any(
      (category) => category.isSelectable,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ThreadManagementGroupLabel('主题信息'),
        SizedBox(height: tokens.space12),
        Text('主题标题', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: tokens.space8),
        TextFormField(
          key: const Key('thread-management-title'),
          controller: titleController,
          focusNode: titleFocusNode,
          enabled: enabled,
          maxLength: 100,
          textInputAction: TextInputAction.done,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: '一句话说明这个主题',
            counterStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tokens.mutedText,
              fontFamily: WenyouFoundationTypography.utility,
              fontFamilyFallback: WenyouFoundationTypography.chineseFallback,
            ),
          ),
          onChanged: onTitleChanged,
          validator: (value) {
            final title = value?.trim() ?? '';
            if (title.isEmpty) return '请输入主题标题';
            if (title.length > 100) return '标题不能超过 100 个字符';
            return null;
          },
        ),
        SizedBox(height: tokens.space4),
        const Divider(height: 1),
        FormField<String>(
          key: ValueKey('thread-management-category-field-$version'),
          initialValue: categorySlug,
          validator: (value) => value == null ? '请选择主题分区' : null,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ThreadSettingRow(
                key: const Key('thread-management-category'),
                label: '所在分区',
                value: selectedCategory == null
                    ? '请选择'
                    : selectedCategory.isSelectable
                    ? selectedCategory.name
                    : '${selectedCategory.name}（已停用）',
                enabled: enabled,
                onTap: !enabled || !hasSelectableCategory
                    ? null
                    : () async {
                        final selected = await _showChoiceSheet<String>(
                          context: context,
                          title: '选择主题分区',
                          selected: field.value,
                          optionKeyPrefix: 'thread-management-category-option',
                          options: [
                            for (final category in categories)
                              WenyouFilterOption(
                                value: category.slug,
                                keyValue: category.slug,
                                label: category.isSelectable
                                    ? category.name
                                    : '${category.name}（已停用）',
                              ),
                          ],
                          isEnabled: (slug) => categories
                              .firstWhere((category) => category.slug == slug)
                              .isSelectable,
                        );
                        if (!context.mounted ||
                            selected == null ||
                            selected == field.value) {
                          return;
                        }
                        field.didChange(selected);
                        onCategoryChanged(selected);
                      },
              ),
              if (field.hasError)
                Padding(
                  padding: EdgeInsets.only(
                    left: tokens.space12,
                    right: tokens.space12,
                    bottom: tokens.space8,
                  ),
                  child: Text(
                    field.errorText!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        _ThreadSettingRow(
          key: const Key('thread-management-edit-tags'),
          label: '主题标签',
          value: tags.isEmpty ? '未添加' : '${tags.length}/5',
          supportingLabel: tags.isEmpty ? null : tags.join('、'),
          enabled: enabled,
          onTap: enabled ? onEditTags : null,
        ),
      ],
    );
  }
}

class ThreadManagementPublishingSection extends StatelessWidget {
  const ThreadManagementPublishingSection({
    required this.status,
    required this.visibility,
    required this.enabled,
    required this.canChangeVisibility,
    required this.onStatusChanged,
    required this.onVisibilityChanged,
    super.key,
  });

  final ThreadManagementStatus status;
  final ThreadManagementVisibility visibility;
  final bool enabled;
  final bool canChangeVisibility;
  final ValueChanged<ThreadManagementStatus> onStatusChanged;
  final ValueChanged<ThreadManagementVisibility> onVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ThreadManagementGroupLabel('发布与访问'),
        SizedBox(height: tokens.space8),
        _ThreadSettingRow(
          key: const Key('thread-management-status'),
          label: '招募状态',
          value: status.label,
          enabled: enabled,
          onTap: !enabled
              ? null
              : () async {
                  final selected =
                      await _showChoiceSheet<ThreadManagementStatus>(
                        context: context,
                        title: '选择招募状态',
                        supportingText: '状态只用于展示，不会限制发帖；发帖权限可在子贴管理中设置。',
                        selected: status,
                        optionKeyPrefix: 'thread-management-status-choice',
                        options: [
                          for (final value in ThreadManagementStatus.values)
                            WenyouFilterOption(
                              value: value,
                              keyValue: value.name,
                              label: value.label,
                            ),
                        ],
                      );
                  if (!context.mounted ||
                      selected == null ||
                      selected == status) {
                    return;
                  }
                  onStatusChanged(selected);
                },
        ),
        const Divider(height: 1),
        _ThreadSettingRow(
          key: const Key('thread-management-visibility'),
          label: '可见范围',
          value: visibility.label,
          supportingLabel: canChangeVisibility
              ? visibility.description
              : '仅楼主可修改可见范围。',
          enabled: enabled,
          onTap: !enabled || !canChangeVisibility
              ? null
              : () async {
                  final selected =
                      await _showChoiceSheet<ThreadManagementVisibility>(
                        context: context,
                        title: '选择可见范围',
                        selected: visibility,
                        optionKeyPrefix: 'thread-management-visibility-choice',
                        options: [
                          for (final value in ThreadManagementVisibility.values)
                            WenyouFilterOption(
                              value: value,
                              keyValue: value.name,
                              label: value.label,
                              supportingLabel: value.description,
                            ),
                        ],
                      );
                  if (!context.mounted ||
                      selected == null ||
                      selected == visibility) {
                    return;
                  }
                  onVisibilityChanged(selected);
                },
        ),
      ],
    );
  }
}

class _ThreadSettingRow extends StatelessWidget {
  const _ThreadSettingRow({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
    this.supportingLabel,
    super.key,
  });

  final String label;
  final String value;
  final String? supportingLabel;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final actionable = enabled && onTap != null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: enabled,
      titleTextStyle: Theme.of(context).textTheme.titleMedium,
      subtitleTextStyle: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
      title: Text(label),
      subtitle: supportingLabel == null ? null : Text(supportingLabel!),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .45,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
              ),
            ),
            if (actionable) ...[
              SizedBox(width: tokens.space4),
              WenyouIcon(
                WenyouIconIds.navigationNext,
                size: 18,
                color: tokens.mutedText,
              ),
            ],
          ],
        ),
      ),
      onTap: actionable ? onTap : null,
    );
  }
}

Future<T?> _showChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required T? selected,
  required String optionKeyPrefix,
  required List<WenyouFilterOption<T>> options,
  String? supportingText,
  bool Function(T value)? isEnabled,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final tokens = sheetContext.wenyouTokens;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * .9,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(bottom: tokens.space16),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space16,
                0,
                tokens.space16,
                tokens.space8,
              ),
              child: Text(
                title,
                style: Theme.of(sheetContext).textTheme.wenyouOverlayTitle,
              ),
            ),
            if (supportingText != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.space16,
                  0,
                  tokens.space16,
                  tokens.space12,
                ),
                child: Text(
                  supportingText,
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
              ),
            for (var index = 0; index < options.length; index++) ...[
              if (index > 0) const Divider(height: 1),
              Builder(
                builder: (context) {
                  final option = options[index];
                  final enabled = isEnabled?.call(option.value) ?? true;
                  final isSelected = option.value == selected;
                  return Semantics(
                    selected: isSelected,
                    child: ListTile(
                      key: ValueKey(
                        '$optionKeyPrefix-${option.keyValue ?? option.value}',
                      ),
                      enabled: enabled,
                      selected: isSelected,
                      titleTextStyle: Theme.of(
                        sheetContext,
                      ).textTheme.titleMedium,
                      subtitleTextStyle: Theme.of(
                        sheetContext,
                      ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
                      title: Text(option.label),
                      subtitle: option.supportingLabel == null
                          ? null
                          : Text(option.supportingLabel!),
                      trailing: isSelected
                          ? const WenyouIcon(WenyouIconIds.actionConfirm)
                          : null,
                      onTap: enabled
                          ? () => Navigator.pop(sheetContext, option.value)
                          : null,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      );
    },
  );
}
