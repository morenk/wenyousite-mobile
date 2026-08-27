import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';

class ThreadManagementBasicsSection extends StatelessWidget {
  const ThreadManagementBasicsSection({
    required this.titleController,
    required this.titleFocusNode,
    required this.categories,
    required this.categorySlug,
    required this.enabled,
    required this.onTitleChanged,
    required this.onCategoryChanged,
    required this.version,
    super.key,
  });

  final TextEditingController titleController;
  final FocusNode titleFocusNode;
  final List<ThreadManagementCategory> categories;
  final String? categorySlug;
  final bool enabled;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String?> onCategoryChanged;
  final int version;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final selectedCategory = categories
        .where((category) => category.slug == categorySlug)
        .firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const WenyouSectionHeader(title: '基本信息'),
        SizedBox(height: tokens.space12),
        TextFormField(
          key: const Key('thread-management-title'),
          controller: titleController,
          focusNode: titleFocusNode,
          enabled: enabled,
          maxLength: 100,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: '主题标题',
            hintText: '一句话说明这个主题',
          ),
          onChanged: onTitleChanged,
          validator: (value) {
            final title = value?.trim() ?? '';
            if (title.isEmpty) return '请输入主题标题';
            if (title.length > 100) return '标题不能超过 100 个字符';
            return null;
          },
        ),
        SizedBox(height: tokens.space12),
        FormField<String>(
          key: ValueKey('thread-management-category-field-$version'),
          initialValue: categorySlug,
          validator: (value) => value == null ? '请选择主题分区' : null,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('所在分区', style: Theme.of(context).textTheme.titleSmall),
              SizedBox(height: tokens.space8),
              WenyouDropdownFilter<String?>(
                key: const Key('thread-management-category'),
                optionKeyPrefix: 'thread-management-category-option',
                tooltip: '选择主题分区',
                icon: WenyouIconIds.contentCategory,
                enabled: enabled,
                selected: field.value,
                selectedLabel: selectedCategory == null
                    ? '请选择分区'
                    : selectedCategory.isSelectable
                    ? selectedCategory.name
                    : '${selectedCategory.name}（已停用）',
                options: [
                  for (final category in categories)
                    WenyouFilterOption<String?>(
                      value: category.slug,
                      keyValue: category.slug,
                      label: category.isSelectable
                          ? category.name
                          : '${category.name}（已停用）',
                      supportingLabel: category.description,
                    ),
                ],
                onSelected: (value) {
                  field.didChange(value);
                  onCategoryChanged(value);
                },
              ),
              if (field.hasError) ...[
                SizedBox(height: tokens.space4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: tokens.space12),
                  child: Text(
                    field.errorText!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
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
        const WenyouSectionHeader(title: '发布设置'),
        SizedBox(height: tokens.space12),
        _ThreadSettingChoiceGroup<ThreadManagementStatus>(
          key: const Key('thread-management-status'),
          label: '招募状态',
          keyPrefix: 'thread-management-status-choice',
          options: [
            for (final value in ThreadManagementStatus.values)
              WenyouFilterOption(
                value: value,
                label: value.label,
                keyValue: value.name,
              ),
          ],
          selected: status,
          enabled: enabled,
          onSelected: onStatusChanged,
        ),
        SizedBox(height: tokens.space12),
        _ThreadSettingChoiceGroup<ThreadManagementVisibility>(
          key: const Key('thread-management-visibility'),
          label: '可见范围',
          keyPrefix: 'thread-management-visibility-choice',
          options: [
            for (final value in ThreadManagementVisibility.values)
              WenyouFilterOption(
                value: value,
                label: value.label,
                keyValue: value.name,
              ),
          ],
          selected: visibility,
          enabled: enabled && canChangeVisibility,
          onSelected: onVisibilityChanged,
        ),
        SizedBox(height: tokens.space8),
        Text(
          canChangeVisibility ? visibility.description : '仅楼主可修改可见范围。',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
        ),
      ],
    );
  }
}

class ThreadManagementTagsSection extends StatelessWidget {
  const ThreadManagementTagsSection({
    required this.tags,
    required this.enabled,
    required this.onEdit,
    required this.onDeleteTag,
    super.key,
  });

  final List<String> tags;
  final bool enabled;
  final VoidCallback onEdit;
  final ValueChanged<String> onDeleteTag;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WenyouSectionHeader(
          title: '主题标签 ${tags.length}/5',
          subtitle: tags.isEmpty ? '添加后更容易被搜索到。' : null,
          trailing: TextButton.icon(
            key: const Key('thread-management-edit-tags'),
            onPressed: enabled ? onEdit : null,
            icon: const WenyouIcon(WenyouIconIds.contentTag),
            label: Text(tags.isEmpty ? '添加' : '编辑'),
          ),
        ),
        if (tags.isNotEmpty) ...[
          SizedBox(height: tokens.space12),
          Wrap(
            spacing: tokens.space8,
            runSpacing: tokens.space8,
            children: [
              for (final tag in tags)
                InputChip(
                  label: Text(tag),
                  onDeleted: enabled ? () => onDeleteTag(tag) : null,
                  deleteIcon: const WenyouIcon(
                    WenyouIconIds.actionClose,
                    size: 16,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ThreadSettingChoiceGroup<T> extends StatelessWidget {
  const _ThreadSettingChoiceGroup({
    required this.label,
    required this.keyPrefix,
    required this.options,
    required this.selected,
    required this.enabled,
    required this.onSelected,
    super.key,
  });

  final String label;
  final String keyPrefix;
  final List<WenyouFilterOption<T>> options;
  final T selected;
  final bool enabled;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: tokens.space8),
          Wrap(
            spacing: tokens.space8,
            runSpacing: tokens.space8,
            children: [
              for (final option in options)
                ChoiceChip(
                  key: ValueKey(
                    '$keyPrefix-${option.keyValue ?? option.value}',
                  ),
                  label: Text(option.label),
                  selected: option.value == selected,
                  onSelected: enabled
                      ? (isSelected) {
                          if (isSelected && option.value != selected) {
                            onSelected(option.value);
                          }
                        }
                      : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
