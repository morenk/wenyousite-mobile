import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_bookmark_folder_picker.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_interaction_toggle.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/application/thread_interaction_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_interaction_models.dart';

class ThreadInteractionActions extends ConsumerWidget {
  const ThreadInteractionActions({
    required this.target,
    required this.onRequireAuthentication,
    this.compact = false,
    super.key,
  });

  final ThreadInteractionTarget target;
  final VoidCallback onRequireAuthentication;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticated = ref.watch(
      sessionControllerProvider.select((session) => session.isAuthenticated),
    );
    final provider = threadInteractionControllerProvider(target);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final bookmarkCatalog = ref.read(
      bookmarkFolderCatalogProvider(BookmarkFolderContentKind.thread),
    );
    final tokens = context.wenyouTokens;
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          WenyouInteractionToggle(
            key: const Key('thread-interaction-like'),
            kind: WenyouInteractionKind.like,
            selected: state.isLiked,
            pending: state.pendingAction == ThreadInteractionAction.like,
            onPressed: state.isPending
                ? null
                : authenticated
                ? () => _toggleLike(context, notifier, compact: true)
                : onRequireAuthentication,
            semanticLabel: state.isLiked
                ? '取消喜欢，当前 ${state.likeCount} 个喜欢'
                : '喜欢，当前 ${state.likeCount} 个喜欢',
            padding: EdgeInsets.symmetric(horizontal: tokens.space4),
            supporting: Text(
              formatWenyouCompactCount(state.likeCount),
              style: Theme.of(context).textTheme.wenyouUtilityCaption,
            ),
          ),
          if (authenticated)
            WenyouInteractionToggle(
              key: const Key('thread-interaction-bookmark'),
              kind: WenyouInteractionKind.bookmark,
              selected: state.isBookmarked,
              pending: state.pendingAction == ThreadInteractionAction.bookmark,
              onPressed: state.isPending
                  ? null
                  : () => _toggleBookmark(
                      context,
                      notifier,
                      wasBookmarked: state.isBookmarked,
                      bookmarkCatalog: bookmarkCatalog,
                      compact: true,
                    ),
              semanticLabel: state.isBookmarked ? '取消收藏' : '收藏主题',
              padding: EdgeInsets.symmetric(horizontal: tokens.space4),
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: tokens.space8,
          runSpacing: tokens.space8,
          children: [
            WenyouInteractionToggle(
              key: const Key('thread-interaction-like'),
              kind: WenyouInteractionKind.like,
              selected: state.isLiked,
              pending: state.pendingAction == ThreadInteractionAction.like,
              onPressed: state.isPending
                  ? null
                  : authenticated
                  ? () => _toggleLike(context, notifier)
                  : onRequireAuthentication,
              semanticLabel: state.isLiked ? '取消喜欢' : '喜欢',
              supporting: Text(
                state.isLiked
                    ? '已喜欢 ${state.likeCount}'
                    : '喜欢 ${state.likeCount}',
              ),
            ),
            if (authenticated)
              WenyouInteractionToggle(
                key: const Key('thread-interaction-bookmark'),
                kind: WenyouInteractionKind.bookmark,
                selected: state.isBookmarked,
                pending:
                    state.pendingAction == ThreadInteractionAction.bookmark,
                onPressed: state.isPending
                    ? null
                    : () => _toggleBookmark(
                        context,
                        notifier,
                        wasBookmarked: state.isBookmarked,
                        bookmarkCatalog: bookmarkCatalog,
                      ),
                semanticLabel: state.isBookmarked ? '取消收藏' : '收藏主题',
                supporting: Text(state.isBookmarked ? '已收藏' : '收藏'),
              ),
          ],
        ),
        if (state.failure != null) ...[
          SizedBox(height: tokens.space12),
          WenyouStatusBanner(
            tone: WenyouStatusTone.error,
            message: state.failure!.userMessage,
            detail: wenyouFailureDetail(state.failure, treatAsWrite: true),
          ),
        ],
        if (state.outcomeStatus != null) ...[
          SizedBox(height: tokens.space12),
          WenyouWriteOutcomeBanner(
            key: const Key('thread-interaction-write-outcome'),
            status: state.outcomeStatus!,
            confirmingMessage: '正在确认主题互动状态…',
            indeterminateMessage: '现在无法继续互动。请先刷新主题查看是否已生效；应用不会自动重复提交。',
            failure: state.outcomeFailure,
            requestId: state.outcomeRequestId,
            onRefresh: notifier.refresh,
            refreshKey: const Key('thread-interaction-refresh-result'),
          ),
        ],
      ],
    );
  }

  Future<void> _toggleLike(
    BuildContext context,
    ThreadInteractionController notifier, {
    bool compact = false,
  }) async {
    final succeeded = await notifier.toggleLike();
    if (!context.mounted) return;
    if (!succeeded) {
      if (compact) _showFailure(context, notifier);
      return;
    }
    _showSuccess(context, notifier);
  }

  Future<void> _toggleBookmark(
    BuildContext context,
    ThreadInteractionController notifier, {
    required bool wasBookmarked,
    required BookmarkFolderCatalog bookmarkCatalog,
    bool compact = false,
  }) async {
    if (wasBookmarked) {
      final succeeded = await notifier.toggleBookmark();
      if (!context.mounted) return;
      if (!succeeded) {
        if (compact) _showFailure(context, notifier);
        return;
      }
      _showSuccess(context, notifier);
      return;
    }
    final folder = await showBookmarkFolderPicker(
      context: context,
      catalog: bookmarkCatalog,
      onConfirm: (folderId) async {
        final succeeded = await notifier.toggleBookmark(folderId: folderId);
        if (succeeded) return;
        throw notifier.takeFailure() ??
            ApiFailure(
              userMessage: notifier.takeIndeterminateNotice() ?? '收藏失败，请稍后重试。',
            );
      },
    );
    if (!context.mounted || folder == null) return;
    notifier.takeSuccessMessage();
    showWenyouSnackBar(context, '已收藏到“${folder.name}”。');
  }

  void _showFailure(
    BuildContext context,
    ThreadInteractionController notifier,
  ) {
    final failure = notifier.takeFailure();
    if (failure == null) {
      final message = notifier.takeIndeterminateNotice();
      if (message != null) {
        showWenyouSnackBar(
          context,
          message,
          pacing: WenyouSnackBarPacing.extended,
        );
      }
      return;
    }
    final message = wenyouFailureMessage(
      failure,
      treatAsWrite: true,
      objectName: '主题',
      operationName: '互动',
    );
    if (message != null) {
      showWenyouSnackBar(
        context,
        message,
        pacing: WenyouSnackBarPacing.extended,
      );
    }
  }

  void _showSuccess(
    BuildContext context,
    ThreadInteractionController notifier,
  ) {
    final message = notifier.takeSuccessMessage();
    if (message == null) return;
    showWenyouSnackBar(context, message);
  }
}
