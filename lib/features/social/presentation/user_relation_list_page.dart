import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_list_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';

class UserRelationListPage extends ConsumerWidget {
  const UserRelationListPage({required this.target, super.key});

  final UserRelationListTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = userRelationListControllerProvider(target);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(_title(target.kind))),
      body: switch (state.phase) {
        UserRelationListPhase.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        UserRelationListPhase.failed => WenyouPageBody(
          maxWidth: 600,
          child: WenyouPanel(
            child: WenyouEmptyState(
              icon: Icons.cloud_off_outlined,
              title: '${_title(target.kind)}没有加载完成',
              message: state.failure?.userMessage ?? '请稍后重试。',
              detail: state.failure?.requestId == null
                  ? null
                  : '请求 ID：${state.failure!.requestId}',
              action: OutlinedButton.icon(
                key: const Key('user-relation-list-retry'),
                onPressed: notifier.load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('重新加载'),
              ),
            ),
          ),
        ),
        UserRelationListPhase.ready => _ReadyRelationList(
          target: target,
          state: state,
          onRefresh: notifier.load,
          onUnblock: (userId) async {
            final succeeded = await notifier.unblock(userId);
            if (!context.mounted || !succeeded) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('已取消拉黑。')));
          },
          onDismissFailure: notifier.clearActionFailure,
        ),
      },
    );
  }
}

class _ReadyRelationList extends StatelessWidget {
  const _ReadyRelationList({
    required this.target,
    required this.state,
    required this.onRefresh,
    required this.onUnblock,
    required this.onDismissFailure,
  });

  final UserRelationListTarget target;
  final UserRelationListState state;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String userId) onUnblock;
  final VoidCallback onDismissFailure;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width <= 400 ? tokens.space12 : tokens.space24;
    return RefreshIndicator(
      onRefresh: state.isMutating ? () async {} : onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          horizontal,
          tokens.space16,
          horizontal,
          tokens.space32,
        ),
        children: [
          if (state.actionFailure != null) ...[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: WenyouStatusBanner(
                  message: state.actionFailure!.userMessage,
                  detail: state.actionFailure!.requestId == null
                      ? null
                      : '请求 ID：${state.actionFailure!.requestId}',
                  tone: WenyouStatusTone.error,
                  action: TextButton(
                    key: const Key('user-relation-action-error-dismiss'),
                    onPressed: onDismissFailure,
                    child: const Text('知道了'),
                  ),
                ),
              ),
            ),
            SizedBox(height: tokens.space12),
          ],
          if (state.items.isEmpty)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: WenyouPanel(
                  child: WenyouEmptyState(
                    icon: _emptyIcon(target.kind),
                    title: _emptyTitle(target.kind),
                    message: _emptyMessage(target.kind),
                  ),
                ),
              ),
            )
          else
            for (var index = 0; index < state.items.length; index++) ...[
              if (index > 0) SizedBox(height: tokens.space8),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: _RelationUserCard(
                    item: state.items[index],
                    showUnblock: target.kind == UserRelationListKind.blocks,
                    isPending:
                        state.pendingUnblockUserId == state.items[index].userId,
                    disableUnblock:
                        state.isMutating &&
                        state.pendingUnblockUserId != state.items[index].userId,
                    onUnblock: () => onUnblock(state.items[index].userId),
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }
}

class _RelationUserCard extends StatelessWidget {
  const _RelationUserCard({
    required this.item,
    required this.showUnblock,
    required this.isPending,
    required this.disableUnblock,
    required this.onUnblock,
  });

  final UserRelationListItem item;
  final bool showUnblock;
  final bool isPending;
  final bool disableUnblock;
  final VoidCallback onUnblock;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Icon(Icons.person_rounded, color: tokens.mutedText),
    );
    return WenyouPanel(
      key: ValueKey('relation-user-${item.userId}'),
      padding: EdgeInsets.all(tokens.space12),
      onTap: () => context.pushNamed(
        'user-profile',
        pathParameters: {'userId': item.userId},
      ),
      child: Row(
        children: [
          Semantics(
            image: true,
            label: '${item.username} 的头像',
            child: ClipOval(
              child: SizedBox.square(
                dimension: tokens.minimumTouchTarget,
                child: item.avatarUrl == null
                    ? fallback
                    : CachedNetworkImage(
                        imageUrl: item.avatarUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => fallback,
                        errorWidget: (_, _, _) => fallback,
                      ),
              ),
            ),
          ),
          SizedBox(width: tokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.space4),
                Text(
                  'Lv.${item.level}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                ),
              ],
            ),
          ),
          if (showUnblock) ...[
            SizedBox(width: tokens.space8),
            OutlinedButton(
              key: ValueKey('unblock-${item.userId}'),
              onPressed: isPending || disableUnblock ? null : onUnblock,
              child: isPending
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('取消拉黑'),
            ),
          ],
        ],
      ),
    );
  }
}

String _title(UserRelationListKind kind) => switch (kind) {
  UserRelationListKind.following => '关注的人',
  UserRelationListKind.followers => '粉丝',
  UserRelationListKind.blocks => '黑名单',
};

String _emptyTitle(UserRelationListKind kind) => switch (kind) {
  UserRelationListKind.following => '还没有关注任何人',
  UserRelationListKind.followers => '还没有粉丝',
  UserRelationListKind.blocks => '黑名单为空',
};

String _emptyMessage(UserRelationListKind kind) => switch (kind) {
  UserRelationListKind.following => '关注后，对方会出现在这里。',
  UserRelationListKind.followers => '有人关注后，会出现在这里。',
  UserRelationListKind.blocks => '被你拉黑的用户会出现在这里。',
};

IconData _emptyIcon(UserRelationListKind kind) => switch (kind) {
  UserRelationListKind.following => Icons.person_add_alt_1_outlined,
  UserRelationListKind.followers => Icons.people_outline_rounded,
  UserRelationListKind.blocks => Icons.block_outlined,
};
