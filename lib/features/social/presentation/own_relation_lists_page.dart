import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/application/own_relation_lists_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/own_relation_actions_sheet.dart';

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
  bool _menuOpen = false;

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
        leading: const BackButton(),
        backgroundColor: context.wenyouTokens.panel,
        titleSpacing: 0,
        toolbarHeight: (MediaQuery.textScalerOf(context).scale(24) + 24).clamp(
          56,
          120,
        ),
        title: Focus(
          focusNode: _titleFocus,
          child: WenyouContentTabs<UserRelationListKind>(
            selected: _selected,
            onSelected: (kind) => setState(() => _selected = kind),
            semanticsLabel: '本人关系列表',
            placement: WenyouTabPlacement.embedded,
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
        ),
      ),
      body: Column(
        children: [
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
                      onMenu: (item) => _showMenu(controller, item),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMenu(
    OwnRelationListsController controller,
    UserRelationListItem item,
  ) async {
    if (_menuOpen) return;
    _menuOpen = true;
    try {
      await showOwnRelationActions(
        context: context,
        ref: ref,
        item: item,
        onAct: (action) => _act(controller, item, action),
      );
    } finally {
      _menuOpen = false;
    }
  }

  Future<void> _act(
    OwnRelationListsController controller,
    UserRelationListItem item,
    OwnRelationAction action,
  ) async {
    final scope = ref.read(sessionScopeProvider);
    final succeeded =
        action == OwnRelationAction.removeFollower ||
            action == OwnRelationAction.block
        ? await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (_) => OwnRelationConfirmationDialog(
                  item: item,
                  controller: controller,
                  action: action,
                  scope: scope,
                ),
              ) ??
              false
        : await controller.act(item, action);
    if (!mounted || scope != ref.read(sessionScopeProvider) || !succeeded) {
      return;
    }
    if (!ref
        .read(ownRelationListsControllerProvider)
        .list(_selected)
        .items
        .any((entry) => entry.userId == item.userId)) {
      _titleFocus.requestFocus();
    }
    showWenyouSnackBar(context, switch (action) {
      OwnRelationAction.follow =>
        item.viewerIsFollowedBy == true ? '已回关。' : '已关注。',
      OwnRelationAction.unfollow => '已取消关注。',
      OwnRelationAction.removeFollower => '已移除粉丝。',
      OwnRelationAction.block => '已拉黑。',
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
    required this.onMenu,
    super.key,
  });
  final UserRelationListKind kind;
  final OwnRelationListsState state;
  final Future<void> Function() onRefresh;
  final void Function(UserRelationListItem) onOpen;
  final void Function(UserRelationListItem, OwnRelationAction) onAct;
  final void Function(UserRelationListItem) onMenu;

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
      return Semantics(
        label: '正在加载$title',
        child: ListView.builder(
          itemCount: 6,
          padding: EdgeInsets.all(tokens.space16),
          itemBuilder: (_, _) => Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.space8),
            child: Row(
              children: [
                WenyouSkeletonBlock(
                  height: tokens.space20 * 2,
                  width: tokens.space20 * 2,
                ),
                SizedBox(width: tokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WenyouSkeletonBlock(
                        height: tokens.space16,
                        width: tokens.space24 * 4,
                      ),
                      SizedBox(height: tokens.space8),
                      WenyouSkeletonBlock(
                        height: tokens.space12,
                        width: tokens.space24 * 2,
                      ),
                    ],
                  ),
                ),
                WenyouSkeletonBlock(
                  height: tokens.minimumTouchTarget,
                  width: tokens.space24 * 4,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        key: PageStorageKey('own-relations-${widget.kind.name}'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          tokens.space12,
          tokens.space4,
          tokens.space12,
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
                child: const Text('重试'),
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
              padding: EdgeInsets.symmetric(vertical: tokens.space4),
              child: WenyouConstrainedWidth(
                child: Column(
                  children: [
                    _OwnRelationRow(
                      item: item,
                      state: widget.state,
                      kind: widget.kind,
                      onOpen: () => widget.onOpen(item),
                      onAct: (action) => widget.onAct(item, action),
                      onRefresh: widget.onRefresh,
                      onMenu: () => widget.onMenu(item),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: tokens.minimumTouchTarget + tokens.space8,
                        top: tokens.space8,
                      ),
                      child: const Divider(height: 1),
                    ),
                  ],
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
    required this.onMenu,
  });
  final UserRelationListItem item;
  final OwnRelationListsState state;
  final UserRelationListKind kind;
  final VoidCallback onOpen;
  final void Function(OwnRelationAction) onAct;
  final VoidCallback onRefresh;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final pending = state.pending[item.userId];
    final failure = state.failures[item.userId];
    final unknown = state.unconfirmed.contains(item.userId);
    final disabled = pending != null || unknown || !item.hasRelationState;
    final following = item.viewerIsFollowing == true;
    final label = !item.hasRelationState
        ? '状态不可用'
        : following
        ? (item.viewerIsFollowedBy == true ? '互相关注' : '已关注')
        : (item.viewerIsFollowedBy == true ? '回关' : '关注');
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(1);
        // 以身份和完整操作文字所需宽度决定换行，不缩小大字或命中区。
        final actionWidth = tokens.space24 * 4 * scale;
        final wrap =
            constraints.maxWidth <
            actionWidth +
                tokens.minimumTouchTarget * 2 +
                tokens.space16 +
                tokens.space20 * 4 * scale;
        final identity = Row(
          children: [
            WenyouAvatarButton(
              username: item.username,
              avatarUrl: item.avatarUrl,
              visualSize: tokens.space20 * 2,
              onTap: onOpen,
            ),
            SizedBox(width: tokens.space8),
            Expanded(
              child: InkWell(
                onTap: onOpen,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: tokens.minimumTouchTarget,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.username,
                        maxLines: wrap ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        semanticsLabel: item.username,
                        style: Theme.of(context).textTheme.wenyouBody.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      WenyouLevelBadge(level: item.level),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: actionWidth.clamp(
                tokens.minimumTouchTarget,
                constraints.maxWidth - tokens.minimumTouchTarget,
              ),
              child: WenyouAsyncButton(
                key: ValueKey(
                  '${following ? 'status' : 'follow'}-${item.userId}',
                ),
                label: label,
                semanticLabel:
                    '${item.username}，$label${following ? '，打开关系操作' : ''}',
                compact: true,
                variant: following
                    ? WenyouAsyncButtonVariant.tonal
                    : WenyouAsyncButtonVariant.filled,
                isLoading: pending != null,
                onPressed: disabled
                    ? null
                    : following
                    ? onMenu
                    : () => onAct(OwnRelationAction.follow),
              ),
            ),
            if (!following)
              IconButton(
                key: ValueKey('more-${item.userId}'),
                tooltip: '${item.username}的更多操作',
                onPressed: disabled ? null : onMenu,
                icon: const WenyouIcon(WenyouIconIds.actionMore),
              ),
          ],
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wrap) ...[
              identity,
              SizedBox(height: tokens.space8),
              Align(alignment: Alignment.centerRight, child: actions),
            ] else
              Row(
                children: [
                  Expanded(child: identity),
                  SizedBox(width: tokens.space8),
                  actions,
                ],
              ),
            if (!item.hasRelationState)
              Text(
                '关系状态暂不可用，请刷新后再试。',
                style: Theme.of(context).textTheme.wenyouCaption,
              ),
            if (failure != null) ...[
              SizedBox(height: tokens.space8),
              WenyouStatusBanner(
                message: unknown
                    ? '请刷新列表，查看操作是否已生效。'
                    : UserFacingFailure.fromApi(failure).message,
                detail: wenyouFailureDetail(failure, treatAsWrite: true),
                tone: unknown
                    ? WenyouStatusTone.neutral
                    : WenyouStatusTone.error,
                action: unknown
                    ? TextButton(
                        onPressed: onRefresh,
                        child: const Text('刷新列表'),
                      )
                    : null,
              ),
            ],
          ],
        );
      },
    );
  }
}
