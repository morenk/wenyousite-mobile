import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selection_menu.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_row.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_sheet.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';

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
    return WenyouSettingsGroup(
      title: '基本信息',
      children: [
        Padding(
          padding: EdgeInsets.all(tokens.space16),
          child: Semantics(
            label: '主题标题',
            child: TextFormField(
              key: const Key('thread-management-title'),
              controller: titleController,
              focusNode: titleFocusNode,
              enabled: enabled,
              maxLength: 100,
              textInputAction: TextInputAction.done,
              style: Theme.of(context).textTheme.wenyouBody,
              decoration: InputDecoration(
                hintText: '输入主题标题',
                counterText: '',
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: tokens.space8),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
              onChanged: onTitleChanged,
              validator: (value) {
                final title = value?.trim() ?? '';
                if (title.isEmpty) return '请输入主题标题';
                if (title.runes.length > 100) return '标题不能超过 100 个字符';
                return null;
              },
            ),
          ),
        ),
        FormField<String>(
          key: ValueKey('thread-management-category-field-$version'),
          initialValue: categorySlug,
          validator: (value) => value == null ? '请选择主题分区' : null,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WenyouSettingsLink(
                key: const Key('thread-management-category'),
                title: '所在分区',
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
                    style: Theme.of(context).textTheme.wenyouCaption.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
        _ThreadManagementTags(tags: tags, enabled: enabled, onEdit: onEditTags),
      ],
    );
  }
}

class _ThreadManagementTags extends StatelessWidget {
  const _ThreadManagementTags({
    required this.tags,
    required this.enabled,
    required this.onEdit,
  });
  final List<String> tags;
  final bool enabled;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    if (tags.isEmpty) {
      return WenyouSettingsLink(
        key: const Key('thread-management-edit-tags'),
        title: '主题标签',
        value: '添加标签',
        enabled: enabled,
        onTap: enabled ? onEdit : null,
      );
    }
    return Semantics(
      button: true,
      enabled: enabled,
      child: InkWell(
        key: const Key('thread-management-edit-tags'),
        onTap: enabled ? onEdit : null,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.space16,
            0,
            tokens.space16,
            tokens.space12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: tokens.minimumTouchTarget + tokens.space8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '主题标签',
                        style: Theme.of(context).textTheme.wenyouRowTitle
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),
                    const WenyouIcon(WenyouIconIds.navigationNext),
                  ],
                ),
              ),
              Wrap(
                key: const Key('thread-management-tag-summary'),
                spacing: tokens.space12,
                runSpacing: tokens.space8,
                children: [
                  for (final tag in tags)
                    Text(
                      WenyouElementContract.topicTagPrefix + tag,
                      style: Theme.of(context).textTheme.wenyouLabel.copyWith(
                        color: tokens.brandForeground,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThreadManagementPublishingSection extends StatelessWidget {
  const ThreadManagementPublishingSection({
    required this.status,
    required this.visibility,
    required this.postingPolicy,
    required this.enabled,
    required this.canChangeVisibility,
    required this.onStatusChanged,
    required this.onVisibilityChanged,
    required this.onPostingPolicyChanged,
    this.identitySetting,
    super.key,
  });

  final ThreadManagementStatus status;
  final ThreadManagementVisibility visibility;
  final SubthreadPostingPolicy? postingPolicy;
  final bool enabled;
  final bool canChangeVisibility;
  final ValueChanged<ThreadManagementStatus> onStatusChanged;
  final ValueChanged<ThreadManagementVisibility> onVisibilityChanged;
  final ValueChanged<SubthreadPostingPolicy> onPostingPolicyChanged;
  final Widget? identitySetting;

  @override
  Widget build(BuildContext context) {
    return WenyouSettingsGroup(
      title: '访问与互动',
      children: [
        WenyouSettingsLink(
          key: const Key('thread-management-status'),
          title: '招募状态',
          value: status.label,
          enabled: enabled,
          onTap: !enabled
              ? null
              : () async {
                  final selected =
                      await _showChoiceSheet<ThreadManagementStatus>(
                        context: context,
                        title: '选择招募状态',
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
        WenyouSettingsLink(
          key: const Key('thread-management-visibility'),
          title: '可见范围',
          value: canChangeVisibility
              ? visibility.label
              : '${visibility.label} · 仅楼主可改',
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
        if (postingPolicy != null) ...[
          WenyouSettingsLink(
            key: const Key('thread-management-posting-policy'),
            title: '主贴发言权限',
            value: postingPolicy!.label,
            enabled: enabled,
            onTap: !enabled
                ? null
                : () async {
                    final selected =
                        await _showChoiceSheet<SubthreadPostingPolicy>(
                          context: context,
                          title: '主贴发言权限',
                          selected: postingPolicy,
                          optionKeyPrefix:
                              'thread-management-posting-policy-choice',
                          options: [
                            for (final value in SubthreadPostingPolicy.values)
                              WenyouFilterOption(
                                value: value,
                                keyValue: value.name,
                                label: value.label,
                                supportingLabel: switch (value) {
                                  SubthreadPostingPolicy.participants =>
                                    '有权查看的登录用户均可发言',
                                  SubthreadPostingPolicy.collaborators =>
                                    '只有楼主和协作者可以发言',
                                  SubthreadPostingPolicy.players =>
                                    '玩家、楼主和协作者可以发言',
                                },
                              ),
                          ],
                        );
                    if (!context.mounted ||
                        selected == null ||
                        selected == postingPolicy) {
                      return;
                    }
                    onPostingPolicyChanged(selected);
                  },
          ),
        ],
        ?identitySetting,
      ],
    );
  }
}

Future<T?> _showChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required T? selected,
  required String optionKeyPrefix,
  required List<WenyouFilterOption<T>> options,
  bool Function(T value)? isEnabled,
}) {
  return showWenyouSheet<T>(
    context: context,
    builder: (sheetContext) => WenyouSheetBody(
      title: title,
      slivers: [
        SliverList.separated(
          itemCount: options.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final option = options[index];
            final enabled = isEnabled?.call(option.value) ?? true;
            return WenyouSelectionTile(
              key: ValueKey(
                '$optionKeyPrefix-${option.keyValue ?? option.value}',
              ),
              selected: option.value == selected,
              label: option.label,
              supportingLabel: option.supportingLabel,
              onTap: enabled
                  ? () => Navigator.pop(sheetContext, option.value)
                  : null,
            );
          },
        ),
      ],
    ),
  );
}
