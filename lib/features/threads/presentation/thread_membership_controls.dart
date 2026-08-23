import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_member_management_controller.dart';

class ThreadMembershipControls extends ConsumerWidget {
  const ThreadMembershipControls({
    required this.threadId,
    required this.canExitPlayer,
    required this.onExited,
    super.key,
  });

  final String threadId;
  final bool canExitPlayer;
  final Future<void> Function() onExited;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!canExitPlayer) return const SizedBox.shrink();
    final provider = threadPlayerExitControllerProvider(threadId);
    final state = ref.watch(provider);
    final tokens = context.wenyouTokens;
    return Padding(
      padding: EdgeInsets.only(top: tokens.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            key: const Key('thread-player-exit'),
            onPressed: state.isSubmitting
                ? null
                : () => _confirmAndExit(context, ref),
            icon: state.isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const WenyouIcon(WenyouIconIds.actionLogout),
            label: Text(state.isSubmitting ? '正在退出' : '退出玩家身份'),
          ),
          if (state.failure != null) ...[
            SizedBox(height: tokens.space12),
            WenyouStatusBanner(
              key: const Key('thread-player-exit-failure'),
              tone: WenyouStatusTone.error,
              message: state.failure!.userMessage,
              detail: state.failure!.requestId == null
                  ? null
                  : '问题编号：${state.failure!.requestId}',
              action: TextButton(
                key: const Key('thread-player-exit-retry'),
                onPressed: state.isSubmitting
                    ? null
                    : () => _exit(context, ref),
                child: const Text('重试退出'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmAndExit(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('退出玩家身份？'),
        content: const Text('退出后会从“我参与的”主题中移除，并取消其他用户对你在本帖发言的订阅。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('thread-player-exit-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认退出'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) await _exit(context, ref);
  }

  Future<void> _exit(BuildContext context, WidgetRef ref) async {
    final succeeded = await ref
        .read(threadPlayerExitControllerProvider(threadId).notifier)
        .exit();
    if (!context.mounted || !succeeded) return;
    showWenyouSnackBar(context, '已退出玩家身份。');
    await onExited();
  }
}
