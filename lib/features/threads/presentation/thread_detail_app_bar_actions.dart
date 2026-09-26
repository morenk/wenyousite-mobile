import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_actions.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_anchored_popover.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

enum ThreadDetailAppBarAction { editBody, manage, tip, report, exitPlayer }

List<Widget> buildThreadDetailAppBarActions({
  required String threadId,
  required ThreadDetailState state,
  required VoidCallback onSearch,
  required ValueChanged<ThreadLatestPostModel> onLatestTarget,
  required ValueChanged<ThreadDetailAppBarAction> onSelected,
}) {
  final detail = state.detail;
  return [
    IconButton(
      key: const Key('thread-detail-search'),
      tooltip: '搜索主题内容',
      onPressed: onSearch,
      icon: const WenyouIcon(WenyouIconIds.actionSearch),
    ),
    ThreadLatestPostAction(
      threadId: threadId,
      detail: detail,
      available: (detail?.postCount ?? 0) > 0 || state.floors.isNotEmpty,
      onTarget: onLatestTarget,
    ),
    if (detail != null &&
        (!detail.isCurrentUserOwner || detail.canManageThread))
      WenyouAnchoredActionBubble<ThreadDetailAppBarAction>(
        actions: [
          if (detail.canManageThread)
            WenyouPopoverAction(
              value: ThreadDetailAppBarAction.editBody,
              icon: state.selectedSubthread?.body == null
                  ? WenyouIconIds.contentDraft
                  : WenyouIconIds.actionEdit,
              label: state.selectedSubthread?.body == null ? '添加正文' : '编辑正文',
              semanticsLabel: state.selectedSubthread?.body == null
                  ? '添加当前子贴正文'
                  : '编辑当前子贴正文',
              enabled: state.selectedSubthread != null,
              key: const Key('thread-detail-edit-body'),
            ),
          if (detail.canManageThread)
            const WenyouPopoverAction(
              value: ThreadDetailAppBarAction.manage,
              icon: WenyouIconIds.actionFilter,
              label: '管理',
              semanticsLabel: '管理主题',
              key: Key('thread-detail-manage'),
            ),
          if (!detail.isCurrentUserOwner)
            const WenyouPopoverAction(
              value: ThreadDetailAppBarAction.tip,
              icon: WenyouIconIds.actionTip,
              label: '加油',
              semanticsLabel: '为创作者加油',
              key: Key('thread-detail-tip'),
            ),
          if (!detail.isPrivate && !detail.isCurrentUserOwner)
            const WenyouPopoverAction(
              value: ThreadDetailAppBarAction.report,
              icon: WenyouIconIds.actionReport,
              label: '举报',
              semanticsLabel: '举报主题',
              tone: WenyouPopoverActionTone.destructive,
              key: Key('thread-detail-report'),
            ),
          if (detail.isCurrentUserPlayer && !detail.isCurrentUserOwner)
            const WenyouPopoverAction(
              value: ThreadDetailAppBarAction.exitPlayer,
              icon: WenyouIconIds.actionLogout,
              label: '退出玩家身份',
              semanticsLabel: '退出当前主题的玩家身份',
              tone: WenyouPopoverActionTone.destructive,
              key: Key('thread-detail-exit-player'),
            ),
        ],
        placement: WenyouPopoverPlacement.below,
        alignment: WenyouPopoverAlignment.end,
        semanticLabel: '主题操作',
        onSelected: onSelected,
        anchorBuilder: (context, handle) => IconButton(
          key: const Key('thread-detail-more'),
          tooltip: '更多主题操作',
          onPressed: handle.toggle,
          icon: const WenyouIcon(WenyouIconIds.actionMore),
        ),
      ),
  ];
}

class ThreadLatestPostAction extends ConsumerStatefulWidget {
  const ThreadLatestPostAction({
    required this.threadId,
    required this.detail,
    required this.available,
    required this.onTarget,
    super.key,
  });

  final String threadId;
  final ThreadDetailModel? detail;
  final bool available;
  final ValueChanged<ThreadLatestPostModel> onTarget;

  @override
  ConsumerState<ThreadLatestPostAction> createState() =>
      _ThreadLatestPostActionState();
}

class _ThreadLatestPostActionState
    extends ConsumerState<ThreadLatestPostAction> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return WenyouAsyncIconButton(
      key: const Key('thread-detail-latest'),
      icon: WenyouIconIds.navigationExplore,
      label: '跳到最新发言',
      isLoading: _isLoading,
      onPressed: widget.available ? _locate : null,
    );
  }

  Future<void> _locate() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final target = await ref
          .read(threadDetailRepositoryProvider)
          .fetchLatestPost(widget.threadId);
      if (!mounted) return;
      if (widget.detail?.subthreadById(target.subthreadId) == null) {
        throw ApiFailure.contractViolation(
          userMessage: '最新发言已经发生变化，请刷新主题后重试。',
          diagnosticCode: 'THREAD_LATEST_SUBTHREAD_MISSING',
        );
      }
      widget.onTarget(target);
    } catch (error) {
      if (!mounted) return;
      final failure = mapApplicationFailure(error, '最新发言加载失败，请稍后重试。');
      final presentation = UserFacingFailure.fromApi(
        failure,
        objectName: '最新发言',
        operationName: '定位',
        placement: FailurePresentationPlacement.transient,
        message: failure.businessCode == 40403 ? '当前主题还没有楼层或回复。' : null,
      );
      showWenyouSnackBar(
        context,
        presentation.problemDetail == null
            ? presentation.message
            : '${presentation.message}\n${presentation.problemDetail}',
        pacing: WenyouSnackBarPacing.extended,
        tone: WenyouSnackBarTone.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
