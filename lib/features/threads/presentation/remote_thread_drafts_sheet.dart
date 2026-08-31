import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/thread_category_catalog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/application/remote_thread_drafts_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';

Future<ThreadRemoteDraftSummary?> showRemoteThreadDraftsSheet({
  required BuildContext context,
  String? currentDraftId,
}) {
  return showModalBottomSheet<ThreadRemoteDraftSummary>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.9,
      child: RemoteThreadDraftsSheet(currentDraftId: currentDraftId),
    ),
  );
}

class RemoteThreadDraftsSheet extends ConsumerWidget {
  const RemoteThreadDraftsSheet({this.currentDraftId, super.key});

  final String? currentDraftId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(remoteThreadDraftsControllerProvider);
    final tokens = context.wenyouTokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.space16,
        0,
        tokens.space16,
        tokens.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WenyouSectionHeader(
            title: '云端主题草稿',
            trailing: IconButton(
              key: const Key('remote-drafts-refresh'),
              tooltip: '刷新云端草稿',
              onPressed: state.isRemoving
                  ? null
                  : () async {
                      await Future.wait([
                        ref
                            .read(remoteThreadDraftsControllerProvider.notifier)
                            .load(),
                        ref
                            .read(
                              threadCategoryCatalogControllerProvider.notifier,
                            )
                            .refresh(),
                      ]);
                    },
              icon: const WenyouIcon(WenyouIconIds.actionRefresh),
            ),
          ),
          SizedBox(height: tokens.space12),
          if (state.removeFailure != null) ...[
            WenyouStatusBanner(
              key: const Key('remote-drafts-remove-failure'),
              message: state.removeFailure!.userMessage,
              detail: wenyouFailureDetail(
                state.removeFailure,
                treatAsWrite: true,
              ),
              tone: WenyouStatusTone.error,
            ),
            SizedBox(height: tokens.space12),
          ],
          Expanded(child: _buildBody(context, ref, state)),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    RemoteThreadDraftsState state,
  ) {
    return switch (state.phase) {
      RemoteThreadDraftsPhase.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      RemoteThreadDraftsPhase.failed => WenyouEmptyState(
        icon: WenyouIconIds.statusOffline,
        title: '云端草稿加载失败',
        message: state.failure?.userMessage ?? '请检查网络后重试。',
        detail: wenyouFailureDetail(state.failure),
        action: FilledButton.icon(
          onPressed: () async {
            await Future.wait([
              ref.read(remoteThreadDraftsControllerProvider.notifier).load(),
              ref
                  .read(threadCategoryCatalogControllerProvider.notifier)
                  .refresh(),
            ]);
          },
          icon: const WenyouIcon(WenyouIconIds.actionRefresh),
          label: const Text('重试'),
        ),
      ),
      RemoteThreadDraftsPhase.ready when state.drafts.isEmpty =>
        const WenyouEmptyState(
          icon: WenyouIconIds.statusSynced,
          title: '还没有云端主题草稿',
        ),
      RemoteThreadDraftsPhase.ready => ListView.separated(
        key: const Key('remote-drafts-list'),
        itemCount: state.drafts.length,
        separatorBuilder: (_, _) =>
            SizedBox(height: context.wenyouTokens.space8),
        itemBuilder: (context, index) {
          final draft = state.drafts[index];
          final isCurrent = draft.id == currentDraftId;
          return _DraftCard(
            draft: draft,
            isCurrent: isCurrent,
            removing: state.removingId == draft.id,
            actionsLocked: state.isRemoving,
            onOpen: () => Navigator.pop(context, draft),
            onRemove: isCurrent
                ? null
                : () => _confirmRemove(context, ref, draft),
          );
        },
      ),
    };
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    ThreadRemoteDraftSummary draft,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除云端草稿？'),
        content: Text('“${draft.displayTitle}”删除后无法恢复，其他设备也将无法继续编辑。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final removed = await ref
        .read(remoteThreadDraftsControllerProvider.notifier)
        .remove(draft);
    if (removed && context.mounted) {
      showWenyouSnackBar(context, '云端草稿已删除。');
    }
  }
}

class _DraftCard extends ConsumerWidget {
  const _DraftCard({
    required this.draft,
    required this.isCurrent,
    required this.removing,
    required this.actionsLocked,
    required this.onOpen,
    required this.onRemove,
  });

  final ThreadRemoteDraftSummary draft;
  final bool isCurrent;
  final bool removing;
  final bool actionsLocked;
  final VoidCallback onOpen;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final category = ref
        .watch(threadCategoryCatalogControllerProvider)
        .resolve(draft.categorySlug);
    final metadata = <String>[
      ?category?.label,
      draft.visibility.label,
      '${draft.subthreadCount} 个子贴',
      '${draft.postCount} 条内容',
    ];
    return WenyouPanel(
      padding: EdgeInsets.all(tokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  draft.displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (isCurrent)
                const Chip(
                  avatar: WenyouIcon(WenyouIconIds.actionEdit, size: 16),
                  label: Text('正在编辑'),
                ),
            ],
          ),
          SizedBox(height: tokens.space8),
          Text(
            metadata.join(' · '),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
          ),
          SizedBox(height: tokens.space4),
          Text(
            '更新于 ${DateFormat('yyyy-MM-dd HH:mm').format(draft.updatedAt.toLocal())}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
          ),
          if (draft.tags.isNotEmpty) ...[
            SizedBox(height: tokens.space8),
            Wrap(
              spacing: tokens.space4,
              runSpacing: tokens.space4,
              children: draft.tags
                  .map((tag) => Chip(label: Text('#$tag')))
                  .toList(growable: false),
            ),
          ],
          SizedBox(height: tokens.space12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: Key('remote-draft-open-${draft.id}'),
                  onPressed: actionsLocked ? null : onOpen,
                  icon: const WenyouIcon(WenyouIconIds.contentDraft),
                  label: Text(isCurrent ? '返回当前编辑' : '继续编辑'),
                ),
              ),
              SizedBox(width: tokens.space8),
              IconButton(
                key: Key('remote-draft-remove-${draft.id}'),
                tooltip: isCurrent ? '当前编辑中的草稿不能删除' : '删除云端草稿',
                onPressed: actionsLocked ? null : onRemove,
                icon: removing
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const WenyouIcon(WenyouIconIds.actionDelete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
