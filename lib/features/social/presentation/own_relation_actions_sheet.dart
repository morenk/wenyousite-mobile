import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_sheet.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/reports.dart';
import 'package:wenyousite_mobile/features/social/application/own_relation_lists_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/user_relation_actions.dart';

enum _MenuAction { message, unfollow, removeFollower, block, report }

Future<void> showOwnRelationActions({
  required BuildContext context,
  required WidgetRef ref,
  required UserRelationListItem item,
  required Future<void> Function(OwnRelationAction) onAct,
}) async {
  final scope = ref.read(sessionScopeProvider);
  final action = await showWenyouSheet<_MenuAction>(
    context: context,
    builder: (_) => _RelationActionsSheet(item: item, scope: scope),
  );
  if (!context.mounted ||
      scope != ref.read(sessionScopeProvider) ||
      action == null) {
    return;
  }
  final state = ref.read(ownRelationListsControllerProvider);
  if (!_contains(state, item.userId) ||
      state.pending.containsKey(item.userId) ||
      state.unconfirmed.contains(item.userId)) {
    return;
  }
  // sheet 已退出后，才创建下一个路由或确认框。
  switch (action) {
    case _MenuAction.message:
      if (ref.read(appCapabilitiesProvider).directMessages) {
        await context.pushNamed(
          'direct-message-new',
          pathParameters: {'userId': item.userId},
        );
      }
    case _MenuAction.report:
      await showWenyouReportFlow(
        context: context,
        ref: ref,
        target: ReportTarget.user(item.userId),
        targetLabel: '这个用户',
        returnTo: '/users/${item.userId}',
      );
    case _MenuAction.unfollow:
      await onAct(OwnRelationAction.unfollow);
    case _MenuAction.removeFollower:
      await onAct(OwnRelationAction.removeFollower);
    case _MenuAction.block:
      await onAct(OwnRelationAction.block);
  }
}

bool _contains(OwnRelationListsState state, String id) => [
  ...state.following.items,
  ...state.followers.items,
].any((item) => item.userId == id);

/// 只撤下本组件所属路由，避免会话切换时误关上层的其他页面。
void _dismissOwnedRoute(BuildContext context) {
  final route = ModalRoute.of(context);
  if (route != null && route.isActive) Navigator.of(context).removeRoute(route);
}

class _RelationActionsSheet extends ConsumerStatefulWidget {
  const _RelationActionsSheet({required this.item, required this.scope});
  final UserRelationListItem item;
  final SessionScope scope;

  @override
  ConsumerState<_RelationActionsSheet> createState() =>
      _RelationActionsSheetState();
}

class _RelationActionsSheetState extends ConsumerState<_RelationActionsSheet> {
  bool _closing = false;
  UserRelationListItem get item => widget.item;

  void _invalidate() {
    if (_closing) return;
    _closing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _dismissOwnedRoute(context);
    });
  }

  void _close([_MenuAction? action]) {
    if (!mounted || _closing) return;
    _closing = true;
    final route = ModalRoute.of(context);
    if (route != null && route.isActive) {
      if (route.isCurrent) {
        Navigator.pop(context, action);
      } else {
        Navigator.of(context).removeRoute(route, action);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionScopeProvider, (before, after) {
      if (before != after) _invalidate();
    });
    if (widget.scope != ref.watch(sessionScopeProvider)) {
      _invalidate();
      return const SizedBox.shrink();
    }
    ref.listen(ownRelationListsControllerProvider, (_, after) {
      if (!_contains(after, item.userId)) _close();
    });
    final state = ref.watch(ownRelationListsControllerProvider);
    if (!_contains(state, item.userId)) {
      _invalidate();
      return const SizedBox.shrink();
    }
    final current =
        [
          ...state.following.items,
          ...state.followers.items,
        ].where((entry) => entry.userId == item.userId).firstOrNull ??
        item;
    final disabled =
        state.pending.containsKey(item.userId) ||
        state.unconfirmed.contains(item.userId);
    final tokens = context.wenyouTokens;
    Widget option(
      _MenuAction action,
      String label,
      String icon, {
      bool enabled = true,
    }) => ListTile(
      key: ValueKey('${action.name}-${item.userId}'),
      minTileHeight: tokens.minimumTouchTarget,
      leading: WenyouIcon(icon),
      title: Text(label),
      enabled: !disabled && enabled,
      onTap: disabled || !enabled ? null : () => _close(action),
    );
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space16,
                0,
                tokens.space8,
                tokens.space12,
              ),
              child: Row(
                children: [
                  WenyouAvatar(
                    username: item.username,
                    avatarUrl: item.avatarUrl,
                    size: tokens.space20 * 2,
                  ),
                  SizedBox(width: tokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.username,
                          style: Theme.of(context).textTheme.wenyouBody
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Lv.${item.level}',
                          style: Theme.of(context).textTheme.wenyouCaption
                              .copyWith(color: tokens.mutedText),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('relation-sheet-close'),
                    tooltip: '关闭',
                    onPressed: _close,
                    icon: const WenyouIcon(WenyouIconIds.actionClose),
                  ),
                ],
              ),
            ),
            if (ref.watch(appCapabilitiesProvider).directMessages)
              option(_MenuAction.message, '私聊', WenyouIconIds.contentThread),
            if (current.viewerIsFollowing == true)
              option(
                _MenuAction.unfollow,
                '取消关注',
                WenyouIconIds.actionUnfollow,
              ),
            if (current.viewerIsFollowedBy == true)
              option(
                _MenuAction.removeFollower,
                '移除粉丝',
                WenyouIconIds.identityMembers,
              ),
            option(
              _MenuAction.block,
              state.blocked.contains(item.userId) ? '已拉黑' : '拉黑',
              WenyouIconIds.actionBlock,
              enabled: !state.blocked.contains(item.userId),
            ),
            option(_MenuAction.report, '举报', WenyouIconIds.actionReport),
            SizedBox(height: tokens.space8),
          ],
        ),
      ),
    );
  }
}

class OwnRelationConfirmationDialog extends ConsumerStatefulWidget {
  const OwnRelationConfirmationDialog({
    required this.item,
    required this.controller,
    required this.action,
    required this.scope,
    super.key,
  });
  final UserRelationListItem item;
  final OwnRelationListsController controller;
  final OwnRelationAction action;
  final SessionScope scope;
  @override
  ConsumerState<OwnRelationConfirmationDialog> createState() =>
      _OwnRelationConfirmationDialogState();
}

class _OwnRelationConfirmationDialogState
    extends ConsumerState<OwnRelationConfirmationDialog> {
  bool _pending = false;
  bool _invalidated = false;

  void _invalidate() {
    if (_invalidated) return;
    _invalidated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _dismissOwnedRoute(context);
    });
  }

  void _close(bool result) {
    if (!mounted || _invalidated) return;
    _invalidated = true;
    final route = ModalRoute.of(context);
    if (route != null && route.isActive) {
      if (route.isCurrent) {
        Navigator.pop(context, result);
      } else {
        Navigator.of(context).removeRoute(route, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionScopeProvider, (before, after) {
      if (before != after) _invalidate();
    });
    if (widget.scope != ref.watch(sessionScopeProvider)) {
      _invalidate();
      return const SizedBox.shrink();
    }
    ref.listen(ownRelationListsControllerProvider, (_, after) {
      if (!_pending &&
          !after.pending.containsKey(widget.item.userId) &&
          !_contains(after, widget.item.userId)) {
        _invalidated = true;
        _dismissOwnedRoute(context);
      }
    });
    final state = ref.watch(ownRelationListsControllerProvider);
    if (!_pending &&
        !state.pending.containsKey(widget.item.userId) &&
        !_contains(state, widget.item.userId)) {
      _invalidate();
      return const SizedBox.shrink();
    }
    final failure = state.failures[widget.item.userId];
    final unknown = state.unconfirmed.contains(widget.item.userId);
    final block = widget.action == OwnRelationAction.block;
    return WenyouPendingConfirmationDialog(
      title: block ? '拉黑用户？' : '移除粉丝「${widget.item.username}」？',
      message: block
          ? wenyouUserBlockConfirmationMessage(widget.item.username)
          : '移除后，对方将不再关注你。不会通知对方，对方仍可重新关注你。',
      pending: _pending || state.pending.containsKey(widget.item.userId),
      confirmKey: Key(
        block ? 'user-relation-block-confirm' : 'confirm-remove-follower',
      ),
      confirmLabel: unknown
          ? '刷新列表'
          : block
          ? '确认拉黑'
          : '移除粉丝',
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
      onCancel: () {
        if (!_pending &&
            !ref
                .read(ownRelationListsControllerProvider)
                .pending
                .containsKey(widget.item.userId)) {
          _close(false);
        }
      },
      onConfirm: () async {
        if (!mounted ||
            _pending ||
            _invalidated ||
            widget.scope != ref.read(sessionScopeProvider) ||
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
          if (!mounted || _invalidated || !widget.controller.isActive) return;
          final refreshed = ref.read(ownRelationListsControllerProvider);
          result = block
              ? refreshed.blocked.contains(widget.item.userId)
              : refreshed.followers.loaded &&
                    refreshed.followers.failure == null &&
                    !refreshed.followers.items.any(
                      (item) => item.userId == widget.item.userId,
                    );
        } else {
          result = await widget.controller.act(widget.item, widget.action);
        }
        if (!context.mounted ||
            _invalidated ||
            widget.scope != ref.read(sessionScopeProvider)) {
          return;
        }
        setState(() => _pending = false);
        if (result) _close(true);
      },
    );
  }
}
