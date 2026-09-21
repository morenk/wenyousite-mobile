import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/application/own_relation_lists_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';

class OwnRelationListsPage extends ConsumerStatefulWidget {
  const OwnRelationListsPage({required this.initialKind, super.key});

  final UserRelationListKind initialKind;

  @override
  ConsumerState<OwnRelationListsPage> createState() =>
      _OwnRelationListsPageState();
}

class _OwnRelationListsPageState extends ConsumerState<OwnRelationListsPage> {
  late var _selected = widget.initialKind;
  static const _kinds = [
    UserRelationListKind.following,
    UserRelationListKind.followers,
  ];
  final _titleFocus = FocusNode(skipTraversal: true);

  @override
  void dispose() {
    _titleFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ownRelationListsControllerProvider);
    final controller = ref.read(ownRelationListsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Focus(focusNode: _titleFocus, child: const Text('关注与粉丝')),
      ),
      body: Column(
        children: [
          WenyouContentTabs<UserRelationListKind>(
            selected: _selected,
            onSelected: (kind) => setState(() => _selected = kind),
            semanticsLabel: '本人关系列表',
            placement: WenyouTabPlacement.page,
            keyPrefix: 'own-relation-tab',
            options: [
              WenyouFilterOption(
                value: UserRelationListKind.following,
                label: state.following.loaded
                    ? '关注 ${state.following.items.length}'
                    : '关注',
              ),
              WenyouFilterOption(
                value: UserRelationListKind.followers,
                label: state.followers.loaded
                    ? '粉丝 ${state.followers.items.length}'
                    : '粉丝',
              ),
            ],
          ),
          Expanded(
            child: WenyouSwipeTabRegion<UserRelationListKind>(
              values: _kinds,
              selected: _selected,
              onSelected: (kind) => setState(() => _selected = kind),
              child: IndexedStack(
                index: _kinds.indexOf(_selected),
                children: [
                  for (final kind in [
                    UserRelationListKind.following,
                    UserRelationListKind.followers,
                  ])
                    _OwnRelationListView(
                      key: ValueKey(kind),
                      kind: kind,
                      state: state,
                      onRefresh: controller.refreshAll,
                      onOpen: (item) async {
                        await context.pushNamed(
                          'user-profile',
                          pathParameters: {'userId': item.userId},
                        );
                        if (mounted && controller.isActive) {
                          await controller.refreshAll();
                        }
                      },
                      onAct: (item, action) => _act(controller, item, action),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _act(
    OwnRelationListsController controller,
    UserRelationListItem item,
    OwnRelationAction action,
  ) async {
    final scope = ref.read(sessionScopeProvider);
    final succeeded = action == OwnRelationAction.removeFollower
        ? await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    _RemoveFollowerDialog(item: item, controller: controller),
              ) ??
              false
        : await controller.act(item, action);
    if (!mounted || scope != ref.read(sessionScopeProvider) || !succeeded) {
      return;
    }
    if (action == OwnRelationAction.removeFollower ||
        (action == OwnRelationAction.unfollow &&
            _selected == UserRelationListKind.following)) {
      _titleFocus.requestFocus();
    }
    showWenyouSnackBar(context, switch (action) {
      OwnRelationAction.follow => '已回关。',
      OwnRelationAction.unfollow => '已取消关注。',
      OwnRelationAction.removeFollower => '已移除粉丝。',
    }, tone: WenyouSnackBarTone.success);
  }
}

class _OwnRelationListView extends StatefulWidget {
  const _OwnRelationListView({
    required this.kind,
    required this.state,
    required this.onRefresh,
    required this.onOpen,
    required this.onAct,
    super.key,
  });
  final UserRelationListKind kind;
  final OwnRelationListsState state;
  final Future<void> Function() onRefresh;
  final void Function(UserRelationListItem) onOpen;
  final void Function(UserRelationListItem, OwnRelationAction) onAct;

  @override
  State<_OwnRelationListView> createState() => _OwnRelationListViewState();
}

class _OwnRelationListViewState extends State<_OwnRelationListView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tokens = context.wenyouTokens;
    final list = widget.state.list(widget.kind);
    final title = widget.kind == UserRelationListKind.following ? '关注' : '粉丝';
    if (!list.loaded && list.failure == null) {
      return WenyouPageBody(child: WenyouListSkeleton(label: '正在加载$title'));
    }
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        key: PageStorageKey('own-relations-${widget.kind.name}'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          tokens.space16,
          tokens.space16,
          tokens.space16,
          tokens.space32,
        ),
        children: [
          if (list.failure != null)
            WenyouStatusBanner(
              message: '$title列表加载失败，请稍后重试。',
              detail: wenyouFailureDetail(list.failure),
              tone: WenyouStatusTone.error,
              action: TextButton(
                onPressed: widget.onRefresh,
                child: const Text('重新加载'),
              ),
            ),
          if (list.loaded && list.items.isEmpty)
            WenyouEmptyState(
              icon: WenyouIconIds.identityMembers,
              title: widget.kind == UserRelationListKind.following
                  ? '还没有关注任何人'
                  : '还没有粉丝',
            ),
          for (final item in list.items)
            Padding(
              key: ValueKey('own-relation-${item.userId}'),
              padding: EdgeInsets.only(bottom: tokens.space8),
              child: WenyouConstrainedWidth(
                child: _OwnRelationRow(
                  item: item,
                  state: widget.state,
                  kind: widget.kind,
                  onOpen: () => widget.onOpen(item),
                  onAct: (action) => widget.onAct(item, action),
                  onRefresh: widget.onRefresh,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OwnRelationRow extends StatelessWidget {
  const _OwnRelationRow({
    required this.item,
    required this.state,
    required this.kind,
    required this.onOpen,
    required this.onAct,
    required this.onRefresh,
  });
  final UserRelationListItem item;
  final OwnRelationListsState state;
  final UserRelationListKind kind;
  final VoidCallback onOpen;
  final void Function(OwnRelationAction) onAct;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final pending = state.pending[item.userId];
    final failure = state.failures[item.userId];
    final unknown = state.unconfirmed.contains(item.userId);
    Widget action(String label, OwnRelationAction action) => Semantics(
      label: '${item.username}，$label',
      child: WenyouAsyncButton(
        key: ValueKey('${action.name}-${item.userId}'),
        label: label,
        variant: WenyouAsyncButtonVariant.outlined,
        isLoading: pending == action,
        onPressed: pending != null || unknown ? null : () => onAct(action),
      ),
    );
    return WenyouPanel(
      padding: EdgeInsets.all(tokens.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onOpen,
            child: Row(
              children: [
                WenyouAvatar(
                  username: item.username,
                  avatarUrl: item.avatarUrl,
                  size: tokens.minimumTouchTarget,
                ),
                SizedBox(width: tokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.username,
                        style: Theme.of(context).textTheme.wenyouRowTitle,
                      ),
                      SizedBox(height: tokens.space4),
                      Text(
                        [
                          'Lv.${item.level}',
                          if (item.viewerIsFollowing == true &&
                              item.viewerIsFollowedBy == true)
                            '互相关注'
                          else if (item.viewerIsFollowing == true)
                            '已关注',
                        ].join(' · '),
                        style: Theme.of(context).textTheme.wenyouCaption
                            .copyWith(color: tokens.mutedText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.space12),
          if (!item.hasRelationState)
            Text(
              '关系状态暂不可用，请刷新后再试。',
              style: Theme.of(context).textTheme.wenyouCaption,
            )
          else
            Wrap(
              alignment: WrapAlignment.end,
              spacing: tokens.space8,
              runSpacing: tokens.space8,
              children: [
                if (item.viewerIsFollowing == true)
                  action('取消关注', OwnRelationAction.unfollow)
                else if (kind == UserRelationListKind.followers)
                  action('回关', OwnRelationAction.follow),
                if (kind == UserRelationListKind.followers &&
                    item.viewerIsFollowedBy == true)
                  action('移除粉丝', OwnRelationAction.removeFollower),
              ],
            ),
          if (failure != null) ...[
            SizedBox(height: tokens.space8),
            WenyouStatusBanner(
              message: unknown
                  ? '请刷新列表，查看操作是否已生效。'
                  : UserFacingFailure.fromApi(failure).message,
              detail: wenyouFailureDetail(failure, treatAsWrite: true),
              tone: unknown ? WenyouStatusTone.neutral : WenyouStatusTone.error,
              action: unknown
                  ? TextButton(onPressed: onRefresh, child: const Text('刷新列表'))
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _RemoveFollowerDialog extends ConsumerStatefulWidget {
  const _RemoveFollowerDialog({required this.item, required this.controller});
  final UserRelationListItem item;
  final OwnRelationListsController controller;
  @override
  ConsumerState<_RemoveFollowerDialog> createState() =>
      _RemoveFollowerDialogState();
}

class _RemoveFollowerDialogState extends ConsumerState<_RemoveFollowerDialog> {
  bool _pending = false;
  @override
  Widget build(BuildContext context) {
    ref.listen(sessionScopeProvider, (before, after) {
      if (before != after) Navigator.of(context).pop(false);
    });
    final state = ref.watch(ownRelationListsControllerProvider);
    final failure = state.failures[widget.item.userId];
    final unknown = state.unconfirmed.contains(widget.item.userId);
    return WenyouPendingConfirmationDialog(
      title: '移除粉丝「${widget.item.username}」？',
      message: '移除后，对方将不再关注你。不会通知对方，对方仍可重新关注你。',
      pending: _pending || state.pending.containsKey(widget.item.userId),
      confirmKey: const Key('confirm-remove-follower'),
      confirmLabel: unknown ? '刷新列表' : '移除粉丝',
      tone: unknown
          ? WenyouConfirmationTone.normal
          : WenyouConfirmationTone.destructive,
      feedback: failure == null
          ? null
          : WenyouStatusBanner(
              message: unknown
                  ? '请刷新列表，查看操作是否已生效。'
                  : UserFacingFailure.fromApi(failure).message,
              detail: wenyouFailureDetail(failure, treatAsWrite: true),
              tone: unknown ? WenyouStatusTone.neutral : WenyouStatusTone.error,
            ),
      onCancel: () => Navigator.pop(context, false),
      onConfirm: () async {
        if (_pending ||
            ref
                .read(ownRelationListsControllerProvider)
                .pending
                .containsKey(widget.item.userId)) {
          return;
        }
        setState(() => _pending = true);
        bool result;
        if (unknown) {
          await widget.controller.refreshAll();
          if (!mounted || !widget.controller.isActive) return;
          final refreshed = ref.read(ownRelationListsControllerProvider);
          result =
              refreshed.followers.loaded &&
              refreshed.followers.failure == null &&
              !refreshed.followers.items.any(
                (item) => item.userId == widget.item.userId,
              );
        } else {
          result = await widget.controller.act(
            widget.item,
            OwnRelationAction.removeFollower,
          );
        }
        if (!context.mounted) return;
        setState(() => _pending = false);
        if (result) Navigator.pop(context, true);
      },
    );
  }
}
