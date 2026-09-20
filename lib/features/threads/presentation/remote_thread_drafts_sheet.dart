import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_sheet.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_time_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/thread_feed/thread_feed_catalog.dart';
import 'package:wenyousite_mobile/features/threads/application/remote_thread_drafts_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';

Future<ThreadRemoteDraftSummary?> showRemoteThreadDraftsSheet({
  required BuildContext context,
  String? currentDraftId,
}) {
  return showWenyouSheet<ThreadRemoteDraftSummary>(
    context: context,
    builder: (context) =>
        RemoteThreadDraftsSheet(currentDraftId: currentDraftId),
  );
}

class RemoteThreadDraftsSheet extends ConsumerWidget {
  const RemoteThreadDraftsSheet({this.currentDraftId, super.key});

  final String? currentDraftId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(remoteThreadDraftsControllerProvider);
    return WenyouSheetBody(
      title: '云端主题草稿',
      scrollKey: const Key('remote-drafts-list'),
      actions: [
        IconButton(
          key: const Key('remote-drafts-refresh'),
          tooltip: '刷新云端草稿',
          onPressed: state.isRemoving ? null : () => _refresh(ref),
          icon: const WenyouIcon(WenyouIconIds.actionRefresh),
        ),
      ],
      slivers: [
        if (state.removeFailure != null)
          SliverToBoxAdapter(
            child: WenyouStatusBanner(
              key: const Key('remote-drafts-remove-failure'),
              message: state.removeFailure!.userMessage,
              detail: wenyouFailureDetail(
                state.removeFailure,
                treatAsWrite: true,
              ),
              tone: WenyouStatusTone.error,
            ),
          ),
        if (state.phase == RemoteThreadDraftsPhase.ready &&
            state.drafts.isNotEmpty)
          SliverList.separated(
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
          )
        else
          SliverToBoxAdapter(
            child: switch (state.phase) {
              RemoteThreadDraftsPhase.loading => const WenyouListSkeleton(
                label: '正在加载云端主题草稿',
                showAvatar: false,
              ),
              RemoteThreadDraftsPhase.failed => WenyouEmptyState(
                icon: WenyouIconIds.statusOffline,
                title: '云端草稿加载失败',
                message: state.failure?.userMessage ?? '请检查网络后重试。',
                detail: wenyouFailureDetail(state.failure),
                action: FilledButton.icon(
                  onPressed: () => _refresh(ref),
                  icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                  label: const Text('重试'),
                ),
              ),
              RemoteThreadDraftsPhase.ready => const WenyouEmptyState(
                icon: WenyouIconIds.statusSynced,
                title: '还没有云端主题草稿',
              ),
            },
          ),
      ],
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.read(remoteThreadDraftsControllerProvider.notifier).load(),
      ref.read(threadCategoryCatalogControllerProvider.notifier).refresh(),
    ]);
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    ThreadRemoteDraftSummary draft,
  ) async {
    final confirmed = await showWenyouConfirmationDialog(
      context: context,
      title: '删除云端草稿？',
      message: '“${draft.displayTitle}”删除后无法恢复，其他设备也将无法继续编辑。',
      confirmLabel: '确认删除',
      cancelLabel: '取消',
      tone: WenyouConfirmationTone.destructive,
    );
    if (confirmed != true || !context.mounted) return;
    final removed = await ref
        .read(remoteThreadDraftsControllerProvider.notifier)
        .remove(draft);
    if (removed && context.mounted) {
      showWenyouSnackBar(context, '云端草稿已删除。', tone: WenyouSnackBarTone.success);
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
                  style: Theme.of(context).textTheme.wenyouRowTitle,
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
            ).textTheme.wenyouCaption.copyWith(color: tokens.mutedText),
          ),
          SizedBox(height: tokens.space4),
          WenyouTimeText(
            value: draft.updatedAt,
            prefix: '更新于 ',
            semanticsPrefix: '更新于 ',
            style: Theme.of(
              context,
            ).textTheme.wenyouCaption.copyWith(color: tokens.mutedText),
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
              WenyouAsyncIconButton(
                key: Key('remote-draft-remove-${draft.id}'),
                label: isCurrent ? '当前编辑中的草稿不能删除' : '删除云端草稿',
                icon: WenyouIconIds.actionDelete,
                isLoading: removing,
                onPressed: actionsLocked ? null : onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
