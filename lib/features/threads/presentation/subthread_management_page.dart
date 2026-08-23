import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/application/subthread_management_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';

class SubthreadManagementPage extends StatelessWidget {
  const SubthreadManagementPage({required this.threadId, super.key});

  final String threadId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('子贴内容')),
      body: SubthreadManagementContent(threadId: threadId),
    );
  }
}

class SubthreadManagementContent extends ConsumerWidget {
  const SubthreadManagementContent({required this.threadId, super.key});

  final String threadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = subthreadManagementControllerProvider(threadId);
    final state = ref.watch(provider);
    return switch (state.phase) {
      SubthreadManagementPhase.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      SubthreadManagementPhase.failed => _SubthreadsFatalState(
        failure: state.failure,
        onRetry: () => ref.read(provider.notifier).load(),
      ),
      SubthreadManagementPhase.ready => _SubthreadDirectory(
        threadId: threadId,
        state: state,
      ),
    };
  }
}

class _SubthreadDirectory extends ConsumerWidget {
  const _SubthreadDirectory({required this.threadId, required this.state});

  final String threadId;
  final SubthreadManagementState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final bootstrap = state.bootstrap!;
    final items = bootstrap.items
        .where((item) => !item.isDefault)
        .toList(growable: false);
    final provider = subthreadManagementControllerProvider(threadId);
    return WenyouPageBody(
      maxWidth: 640,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: WenyouSectionHeader(title: '子贴内容')),
              IconButton(
                key: const Key('subthread-management-refresh'),
                tooltip: '刷新子贴',
                onPressed: state.isBusy
                    ? null
                    : () => ref.read(provider.notifier).load(),
                icon: const WenyouIcon(WenyouIconIds.actionRefresh),
              ),
            ],
          ),
          if (state.failure != null) ...[
            SizedBox(height: tokens.space12),
            WenyouStatusBanner(
              key: const Key('subthread-management-failure'),
              tone: WenyouStatusTone.error,
              message: state.failure!.userMessage,
              detail: state.failure!.requestId == null
                  ? null
                  : '问题编号：${state.failure!.requestId}',
              action: TextButton(
                onPressed: state.isBusy
                    ? null
                    : () => ref.read(provider.notifier).clearFailure(),
                child: const Text('知道了'),
              ),
            ),
          ],
          if (state.actionOutcome != null) ...[
            SizedBox(height: tokens.space12),
            WenyouWriteOutcomeBanner(
              key: const Key('subthread-management-write-outcome'),
              status: state.actionOutcome!,
              confirmingMessage: '正在确认子贴状态…',
              indeterminateMessage: '子贴操作结果暂时无法确定，请稍后刷新查看。',
              requestId: state.actionRequestId,
              onRefresh: () => ref.read(provider.notifier).load(),
            ),
          ],
          SizedBox(height: tokens.space16),
          FilledButton.icon(
            key: const Key('subthread-management-create'),
            onPressed: state.isBusy ? null : () => _openCreate(context, ref),
            icon: const WenyouIcon(WenyouIconIds.actionAdd),
            label: const Text('添加子贴'),
          ),
          SizedBox(height: tokens.space16),
          if (items.isEmpty)
            const WenyouEmptyState(
              icon: WenyouIconIds.contentList,
              title: '还没有其他子贴',
            )
          else
            DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.panel,
                border: Border.all(color: tokens.border),
                borderRadius: BorderRadius.circular(tokens.radius12),
              ),
              child: ReorderableListView.builder(
                key: const Key('subthread-management-list'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: items.length,
                onReorderItem: state.isBusy
                    ? (_, _) {}
                    : (oldIndex, newIndex) => unawaited(
                        ref
                            .read(provider.notifier)
                            .reorderNonDefault(oldIndex, newIndex),
                      ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Column(
                    key: ValueKey(item.id),
                    children: [
                      _SubthreadRow(
                        threadId: threadId,
                        item: item,
                        index: index,
                        itemCount: items.length,
                        state: state,
                      ),
                      if (index < items.length - 1) const Divider(height: 1),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openCreate(BuildContext context, WidgetRef ref) async {
    final changed = await context.push<bool>(
      AppRouteLocations.subthreadCreate(threadId),
    );
    if (changed == true && context.mounted) {
      await ref
          .read(subthreadManagementControllerProvider(threadId).notifier)
          .load();
    }
  }
}

class _SubthreadRow extends ConsumerWidget {
  const _SubthreadRow({
    required this.threadId,
    required this.item,
    required this.index,
    required this.itemCount,
    required this.state,
  });

  final String threadId;
  final SubthreadManagementItem item;
  final int index;
  final int itemCount;
  final SubthreadManagementState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final provider = subthreadManagementControllerProvider(threadId);
    final pending = state.pendingItemId == item.id;
    return Semantics(
      container: true,
      label:
          '${item.title}，${item.postingPolicy.label}，${item.postCount} 个楼层，${item.hasBody ? '有正文' : '暂无正文'}',
      hint: '点击编辑；拖动排序手柄调整位置',
      customSemanticsActions: {
        if (index > 0)
          const CustomSemanticsAction(label: '上移子贴'): () =>
              ref.read(provider.notifier).move(item.id, -1),
        if (index < itemCount - 1)
          const CustomSemanticsAction(label: '下移子贴'): () =>
              ref.read(provider.notifier).move(item.id, 1),
      },
      child: InkWell(
        key: ValueKey('subthread-edit-${item.id}'),
        onTap: state.isBusy ? null : () => _openEdit(context, ref),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space8,
              vertical: tokens.space12,
            ),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  enabled: !state.isBusy,
                  child: SizedBox.square(
                    dimension: tokens.minimumTouchTarget,
                    child: const Center(
                      child: WenyouIcon(WenyouIconIds.actionReorder),
                    ),
                  ),
                ),
                SizedBox(width: tokens.space8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: tokens.space4),
                      Text(
                        '${item.postingPolicy.label} · ${item.postCount} 个楼层 · ${item.hasBody ? '有正文' : '暂无正文'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (pending)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    key: ValueKey('subthread-delete-${item.id}'),
                    tooltip: '删除 ${item.title}',
                    onPressed: state.isBusy
                        ? null
                        : () => _delete(context, ref),
                    icon: WenyouIcon(
                      WenyouIconIds.actionDelete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEdit(BuildContext context, WidgetRef ref) async {
    final changed = await context.push<bool>(
      AppRouteLocations.subthreadEdit(threadId, item.id),
    );
    if (changed == true && context.mounted) {
      await ref
          .read(subthreadManagementControllerProvider(threadId).notifier)
          .load();
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认删除这个子贴？'),
        content: Text(
          '“${item.title}”${item.hasBody ? '的正文、' : '的'}${item.postCount} 个楼层及其回复会一起删除，且无法恢复。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: ValueKey('subthread-delete-confirm-${item.id}'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final succeeded = await ref
        .read(subthreadManagementControllerProvider(threadId).notifier)
        .remove(item);
    if (succeeded && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('子贴已删除。')));
    }
  }
}

class _SubthreadsFatalState extends StatelessWidget {
  const _SubthreadsFatalState({required this.failure, required this.onRetry});

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      maxWidth: 520,
      child: WenyouEmptyState(
        icon: WenyouIconIds.contentList,
        title: '子贴内容暂时不可用',
        message: failure?.userMessage ?? '请检查网络后重试。',
        detail: failure?.requestId == null
            ? null
            : '问题编号：${failure!.requestId}',
        action: FilledButton.icon(
          key: const Key('subthread-management-retry'),
          onPressed: onRetry,
          icon: const WenyouIcon(WenyouIconIds.actionRefresh),
          label: const Text('重新加载'),
        ),
      ),
    );
  }
}
