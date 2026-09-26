import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_anchored_popover.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_page_failure_state.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/media_ui.dart';

class MomentComposeActions extends StatelessWidget {
  const MomentComposeActions({
    required this.editing,
    required this.editable,
    required this.canDelete,
    required this.waiting,
    required this.submitting,
    required this.succeeded,
    required this.awaitingConfirmation,
    required this.onDelete,
    required this.onSubmit,
    super.key,
  });

  final bool editing, editable, canDelete, waiting, submitting, succeeded;
  final bool awaitingConfirmation;
  final VoidCallback onDelete, onSubmit;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (editing && canDelete)
        WenyouAnchoredActionBubble<String>(
          placement: WenyouPopoverPlacement.below,
          alignment: WenyouPopoverAlignment.end,
          semanticLabel: '动态操作',
          actions: const [
            WenyouPopoverAction(
              key: Key('moment-compose-delete'),
              value: 'delete',
              icon: WenyouIconIds.actionDelete,
              label: '删除',
              semanticsLabel: '删除动态',
              tone: WenyouPopoverActionTone.destructive,
            ),
          ],
          onSelected: (_) => onDelete(),
          anchorBuilder: (context, handle) => IconButton(
            key: const Key('moment-compose-more'),
            tooltip: '更多动态操作',
            onPressed: waiting || submitting || succeeded
                ? null
                : handle.toggle,
            icon: const WenyouIcon(WenyouIconIds.actionMore),
          ),
        ),
      if (editable)
        Padding(
          padding: EdgeInsets.only(right: context.wenyouTokens.space8),
          child: WenyouAsyncButton(
            key: const Key('moment-compose-submit'),
            label: succeeded
                ? '完成'
                : awaitingConfirmation
                ? '查看结果'
                : editing
                ? '保存'
                : '发布',
            loadingLabel: editing ? '正在保存…' : '正在发布…',
            compact: true,
            icon: editing ? WenyouIconIds.actionSave : WenyouIconIds.actionSend,
            isLoading: submitting || waiting,
            onPressed: onSubmit,
          ),
        ),
    ],
  );
}

class MomentPublishWaitNotice extends StatelessWidget {
  const MomentPublishWaitNotice({
    required this.pendingCount,
    required this.onCancelWait,
    super.key,
  });
  final int pendingCount;
  final VoidCallback onCancelWait;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: wenyouHorizontalPagePadding(context),
      ),
      child: DelayedPendingNotice(
        waiting: true,
        child: Row(
          children: [
            Expanded(child: Text('还有 $pendingCount 张图片未就绪')),
            TextButton(
              key: const Key('moment-cancel-publish'),
              onPressed: onCancelWait,
              child: const Text('取消发布'),
            ),
          ],
        ),
      ),
    ),
  );
}

class MomentComposeFailure extends StatelessWidget {
  const MomentComposeFailure({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageFailureState(
      title: '动态加载失败',
      failure: failure,
      onRetry: onRetry,
      retryKey: const Key('moment-compose-retry'),
    );
  }
}
