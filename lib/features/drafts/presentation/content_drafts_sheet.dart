import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/drafts/application/content_drafts_controller.dart';
import 'package:wenyousite_mobile/features/drafts/domain/content_draft_models.dart';

Future<void> showContentDraftsSheet({
  required BuildContext context,
  required Object draftSessionKey,
  required String currentContent,
  required ValueChanged<String> onRestore,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.9,
      child: ContentDraftsSheet(
        draftSessionKey: draftSessionKey,
        currentContent: currentContent,
        onRestore: onRestore,
      ),
    ),
  );
}

class ContentDraftsSheet extends ConsumerStatefulWidget {
  const ContentDraftsSheet({
    required this.draftSessionKey,
    required this.currentContent,
    required this.onRestore,
    super.key,
  });

  final Object draftSessionKey;
  final String currentContent;
  final ValueChanged<String> onRestore;

  @override
  ConsumerState<ContentDraftsSheet> createState() => _ContentDraftsSheetState();
}

class _ContentDraftsSheetState extends ConsumerState<ContentDraftsSheet> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref
          .read(
            contentDraftsControllerProvider(widget.draftSessionKey).notifier,
          )
          .load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = contentDraftsControllerProvider(widget.draftSessionKey);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final tokens = context.wenyouTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.space16,
            0,
            tokens.space8,
            tokens.space12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WenyouIcon(WenyouIconIds.statusCloud),
              SizedBox(width: tokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '正文草稿',
                      style: Theme.of(context).textTheme.wenyouOverlayTitle,
                    ),
                    SizedBox(height: tokens.space4),
                    Text(
                      '只保存当前正文 · 已用 ${state.usage.usedSlots}/${state.usage.maxSlots}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: '关闭正文草稿',
                onPressed: () => Navigator.pop(context),
                icon: const WenyouIcon(WenyouIconIds.actionClose),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: switch (state.phase) {
            ContentDraftsPhase.loading => const Padding(
              padding: EdgeInsets.all(12),
              child: WenyouListSkeleton(label: '正在加载正文草稿', showAvatar: false),
            ),
            ContentDraftsPhase.failed => _LoadFailure(
              state: state,
              onRetry: controller.load,
            ),
            ContentDraftsPhase.ready => _ReadyDrafts(
              draftSessionKey: widget.draftSessionKey,
              state: state,
              currentContent: widget.currentContent,
              onRestore: widget.onRestore,
            ),
          },
        ),
      ],
    );
  }
}

class _ReadyDrafts extends ConsumerWidget {
  const _ReadyDrafts({
    required this.draftSessionKey,
    required this.state,
    required this.currentContent,
    required this.onRestore,
  });

  final Object draftSessionKey;
  final ContentDraftsState state;
  final String currentContent;
  final ValueChanged<String> onRestore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final controller = ref.read(
      contentDraftsControllerProvider(draftSessionKey).notifier,
    );
    final canSave =
        MarkdownContent.hasVisibleContent(currentContent) &&
        currentContent.length <= 10000;
    return ListView(
      key: const Key('content-drafts-list'),
      padding: EdgeInsets.fromLTRB(
        tokens.space12,
        tokens.space16,
        tokens.space12,
        tokens.space24,
      ),
      children: [
        WenyouPanel(
          key: const Key('content-drafts-auto-save'),
          padding: EdgeInsets.all(tokens.space12),
          color: tokens.softPanel,
          child: Row(
            children: [
              const WenyouIcon(WenyouIconIds.actionSync),
              SizedBox(width: tokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '自动保存到草稿位 1',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(height: tokens.space4),
                    Text(
                      _autoSaveDescription(state),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                    ),
                  ],
                ),
              ),
              _AutoSaveSwitch(
                value: state.autoSaveEnabled,
                enabled:
                    !state.isBusy && state.phase == ContentDraftsPhase.ready,
                onChanged: (enabled) =>
                    _toggleAutoSave(context, controller, enabled: enabled),
              ),
            ],
          ),
        ),
        if (state.autoSaveFailure != null) ...[
          SizedBox(height: tokens.space12),
          WenyouFailureBanner(
            key: const Key('content-drafts-auto-save-failure'),
            failure: state.autoSaveFailure!,
          ),
        ],
        SizedBox(height: tokens.space12),
        if (state.actionFailure != null) ...[
          WenyouFailureBanner(
            key: const Key('content-drafts-action-failure'),
            failure: state.actionFailure!,
            action: state.conflict == null
                ? null
                : TextButton.icon(
                    key: const Key('content-drafts-retry-conflict'),
                    onPressed: state.isBusy
                        ? null
                        : () => _confirmConflictRetry(context, controller),
                    icon: const WenyouIcon(WenyouIconIds.actionSync),
                    label: const Text('用当前正文覆盖最新版'),
                  ),
          ),
          SizedBox(height: tokens.space12),
        ],
        if (state.successMessage != null) ...[
          WenyouStatusBanner(
            key: const Key('content-drafts-success'),
            message: state.successMessage!,
            tone: WenyouStatusTone.accent,
          ),
          SizedBox(height: tokens.space12),
        ],
        WenyouPanel(
          padding: EdgeInsets.all(tokens.space12),
          color: tokens.softPanel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.usage.isFull) ...[
                Text(
                  '五个草稿位都已有内容。你仍可选择任一位置保存并确认覆盖。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: tokens.space8),
              ],
              SizedBox(
                height: tokens.minimumTouchTarget,
                child: FilledButton.icon(
                  key: const Key('content-drafts-quick-save'),
                  onPressed: !canSave || state.isBusy || state.usage.isFull
                      ? null
                      : () => controller.saveToNextSlot(currentContent),
                  icon: state.pendingSlot == 0
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const WenyouIcon(WenyouIconIds.actionSave),
                  label: const Text('保存到空闲位'),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.space12),
        for (var slot = 1; slot <= state.usage.maxSlots; slot++) ...[
          _DraftSlotCard(
            draftSessionKey: draftSessionKey,
            slot: slot,
            draft: state.draftAt(slot),
            currentContent: currentContent,
            canSave: canSave,
            state: state,
            onRestore: onRestore,
          ),
          if (slot != state.usage.maxSlots) SizedBox(height: tokens.space8),
        ],
      ],
    );
  }

  Future<void> _toggleAutoSave(
    BuildContext context,
    ContentDraftsController controller, {
    required bool enabled,
  }) async {
    if (!enabled) {
      controller.disableAutoSave();
      return;
    }
    if (!await controller.refreshForAutoSave() || !context.mounted) return;
    final slotOne = controller.draftAt(1);
    if (slotOne != null) {
      final confirmed = await showWenyouConfirmationDialog(
        context: context,
        useRootNavigator: false,
        title: '开启自动保存？',
        message: '开启后，当前编辑器正文会持续保存到草稿位 1，并覆盖该位置的已有内容。',
        confirmLabel: '开启',
      );
      if (!confirmed || !context.mounted) return;
    }
    controller.enableAutoSave(currentContent);
  }

  Future<void> _confirmConflictRetry(
    BuildContext context,
    ContentDraftsController controller,
  ) async {
    final conflict = state.conflict;
    if (conflict == null) return;
    final confirmed = await showWenyouConfirmationDialog(
      context: context,
      useRootNavigator: false,
      title: '覆盖草稿位 ${conflict.latest.slot} 的最新版？',
      message: '这份草稿已在其他设备更新。继续会用当前正文覆盖刚读取的最新版。',
      cancelLabel: '保留云端',
      confirmLabel: '仍然覆盖',
    );
    if (confirmed) await controller.retryConflict();
  }
}

class _AutoSaveSwitch extends StatelessWidget {
  const _AutoSaveSwitch({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value ? '已开启' : '已关闭',
          key: const Key('content-drafts-auto-save-state'),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: enabled
                ? (value ? tokens.brandForeground : tokens.text)
                : tokens.mutedText,
            fontWeight: FontWeight.w600,
          ),
        ),
        Switch(
          key: const Key('content-drafts-auto-save-switch'),
          value: value,
          onChanged: enabled ? onChanged : null,
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return tokens.mutedText;
            }
            return states.contains(WidgetState.selected)
                ? colorScheme.onPrimary
                : tokens.text;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return tokens.softPanel;
            }
            return states.contains(WidgetState.selected)
                ? colorScheme.primary
                : tokens.panel;
          }),
          trackOutlineColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return states.contains(WidgetState.disabled)
                ? tokens.border
                : tokens.mutedText;
          }),
        ),
      ],
    );
  }
}

class _DraftSlotCard extends ConsumerWidget {
  const _DraftSlotCard({
    required this.draftSessionKey,
    required this.slot,
    required this.draft,
    required this.currentContent,
    required this.canSave,
    required this.state,
    required this.onRestore,
  });

  final Object draftSessionKey;
  final int slot;
  final ContentDraft? draft;
  final String currentContent;
  final bool canSave;
  final ContentDraftsState state;
  final ValueChanged<String> onRestore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final item = draft;
    final pending = state.pendingSlot == slot;
    return WenyouPanel(
      key: Key('content-draft-slot-$slot'),
      padding: EdgeInsets.all(tokens.space12),
      child: item == null
          ? Row(
              children: [
                _SlotNumber(slot: slot, occupied: false),
                SizedBox(width: tokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '草稿位 $slot',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      SizedBox(height: tokens.space4),
                      Text(
                        slot == 1 ? '空闲 · 自动保存位置' : '空闲',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  key: Key('content-draft-save-$slot'),
                  onPressed: !canSave || state.isBusy
                      ? null
                      : () => ref
                            .read(
                              contentDraftsControllerProvider(
                                draftSessionKey,
                              ).notifier,
                            )
                            .createAtSlot(currentContent, slot),
                  child: pending
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('保存到这里'),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SlotNumber(slot: slot, occupied: true),
                    SizedBox(width: tokens.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '草稿位 $slot',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          SizedBox(height: tokens.space4),
                          Text(
                            MarkdownContent.toPlainTextPreview(
                              item.content,
                              maxLength: 100,
                            ).ifEmpty('仅包含格式节点的正文'),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: tokens.space8),
                          Text(
                            '更新于 ${DateFormat('yyyy-MM-dd HH:mm').format(item.updatedAt.toLocal())}'
                            '${slot == 1 ? ' · 自动保存位置' : ''}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: tokens.mutedText),
                          ),
                        ],
                      ),
                    ),
                    if (pending)
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      PopupMenuButton<void>(
                        key: Key('content-draft-more-$slot'),
                        tooltip: '草稿位 $slot 更多操作',
                        icon: const WenyouIcon(WenyouIconIds.actionMore),
                        itemBuilder: (context) => [
                          PopupMenuItem<void>(
                            key: Key('content-draft-delete-$slot'),
                            onTap: () => _delete(context, ref, item),
                            child: Row(
                              children: [
                                const WenyouIcon(WenyouIconIds.actionDelete),
                                SizedBox(width: tokens.space8),
                                const Text('删除草稿'),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: tokens.space8),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: tokens.space4,
                  runSpacing: tokens.space4,
                  children: [
                    TextButton.icon(
                      key: Key('content-draft-restore-$slot'),
                      onPressed: state.isBusy
                          ? null
                          : () => _restore(context, ref, item),
                      icon: const WenyouIcon(WenyouIconIds.actionRestore),
                      label: const Text('恢复'),
                    ),
                    TextButton.icon(
                      key: Key('content-draft-overwrite-$slot'),
                      onPressed: !canSave || state.isBusy
                          ? null
                          : () => _overwrite(context, ref, item),
                      icon: const WenyouIcon(WenyouIconIds.actionSaveAll),
                      label: const Text('保存到这里'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    ContentDraft item,
  ) async {
    final fresh = await ref
        .read(contentDraftsControllerProvider(draftSessionKey).notifier)
        .fetchFreshForRestore(item.id);
    if (fresh == null || !context.mounted) return;
    final needsConfirmation =
        MarkdownContent.hasVisibleContent(currentContent) &&
        currentContent != fresh.content;
    if (needsConfirmation) {
      final confirmed = await showWenyouConfirmationDialog(
        context: context,
        useRootNavigator: false,
        title: '恢复草稿位 ${fresh.slot}？',
        message: '恢复会替换当前编辑器正文；标题、分类和标签不会改变。',
        confirmLabel: '替换并恢复',
      );
      if (!confirmed || !context.mounted) return;
    }
    onRestore(fresh.content);
    Navigator.pop(context);
  }

  Future<void> _overwrite(
    BuildContext context,
    WidgetRef ref,
    ContentDraft item,
  ) async {
    final confirmed = await showWenyouConfirmationDialog(
      context: context,
      useRootNavigator: false,
      title: '保存到草稿位 ${item.slot}？',
      message: '该位置已有草稿。继续会用当前编辑器正文替换已有内容。',
      confirmLabel: '确认保存',
    );
    if (confirmed) {
      await ref
          .read(contentDraftsControllerProvider(draftSessionKey).notifier)
          .overwrite(item, currentContent);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ContentDraft item,
  ) async {
    final confirmed = await showWenyouConfirmationDialog(
      context: context,
      useRootNavigator: false,
      title: '删除草稿位 ${item.slot} 的内容？',
      message: item.slot == 1 && state.autoSaveEnabled
          ? '删除后无法恢复，并会同时关闭当前编辑器的自动保存。当前编辑器正文不会受影响。'
          : '删除后无法恢复。当前编辑器正文不会受影响。',
      confirmLabel: '删除',
      tone: WenyouConfirmationTone.destructive,
    );
    if (confirmed) {
      await ref
          .read(contentDraftsControllerProvider(draftSessionKey).notifier)
          .remove(item);
    }
  }
}

class _SlotNumber extends StatelessWidget {
  const _SlotNumber({required this.slot, required this.occupied});

  final int slot;
  final bool occupied;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Container(
      width: tokens.minimumTouchTarget,
      height: tokens.minimumTouchTarget,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: occupied ? tokens.accentedBackground : tokens.softPanel,
        borderRadius: BorderRadius.circular(tokens.radius12),
        border: Border.all(color: tokens.border),
      ),
      child: Text(
        slot.toString(),
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.state, required this.onRetry});

  final ContentDraftsState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.wenyouTokens.space24),
        child: WenyouEmptyState(
          icon: WenyouIconIds.statusOffline,
          title: '正文草稿加载失败',
          message: state.failure?.userMessage ?? '请稍后重试。',
          detail: wenyouFailureDetail(state.failure),
          action: FilledButton(onPressed: onRetry, child: const Text('重试')),
        ),
      ),
    );
  }
}

String _autoSaveDescription(ContentDraftsState state) {
  return switch (state.autoSaveStatus) {
    ContentDraftAutoSaveStatus.idle => '开启后，当前编辑器正文会自动更新到草稿位 1',
    ContentDraftAutoSaveStatus.waiting => '已开启，编辑后自动更新到草稿位 1',
    ContentDraftAutoSaveStatus.saving => '正在保存到云端…',
    ContentDraftAutoSaveStatus.saved => '当前正文已自动保存',
    ContentDraftAutoSaveStatus.error => '自动保存失败并已关闭，请重新开启',
  };
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
