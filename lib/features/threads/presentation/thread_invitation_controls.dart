import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_invitation_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_invitation_models.dart';

class ThreadInviteLinkPanel extends ConsumerWidget {
  const ThreadInviteLinkPanel({
    required this.threadId,
    this.enabled = true,
    super.key,
  });

  final String threadId;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = threadInviteLinkControllerProvider(threadId);
    final state = ref.watch(provider);
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WenyouSectionHeader(
            title: '私密邀请',
            subtitle: '每次生成都会让旧邀请立即失效。只把链接发送给你希望加入这个私密主题的人。',
          ),
          if (state.failure != null) ...[
            SizedBox(height: tokens.space12),
            WenyouStatusBanner(
              key: const Key('thread-invite-link-failure'),
              tone: WenyouStatusTone.error,
              message: state.failure!.userMessage,
              detail: state.failure!.requestId == null
                  ? null
                  : '请求 ID：${state.failure!.requestId}',
              action: state.failure!.businessCode == 40107
                  ? TextButton(
                      key: const Key('thread-invite-link-verify-email'),
                      onPressed: state.isGenerating
                          ? null
                          : () => _openVerification(context, ref),
                      child: const Text('先验证邮箱'),
                    )
                  : TextButton(
                      key: const Key('thread-invite-link-dismiss-failure'),
                      onPressed: state.isGenerating
                          ? null
                          : () => ref.read(provider.notifier).clearFailure(),
                      child: const Text('知道了'),
                    ),
            ),
          ],
          if (state.link != null) ...[
            SizedBox(height: tokens.space12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.softPanel,
                borderRadius: BorderRadius.circular(tokens.radius12),
                border: Border.all(color: tokens.border),
              ),
              child: Padding(
                padding: EdgeInsets.all(tokens.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '当前新邀请',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    SizedBox(height: tokens.space8),
                    SelectableText(
                      state.link!.url.toString(),
                      key: const Key('thread-invite-link-value'),
                    ),
                    SizedBox(height: tokens.space8),
                    OutlinedButton.icon(
                      key: const Key('thread-invite-link-copy'),
                      onPressed: enabled && !state.isGenerating
                          ? () => _copyLink(context, state.link!)
                          : null,
                      icon: const Icon(Icons.copy_all_outlined),
                      label: const Text('再次复制'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: tokens.space16),
          OutlinedButton.icon(
            key: const Key('thread-invite-link-generate'),
            onPressed: enabled && !state.isGenerating
                ? () => _confirmAndGenerate(context, ref)
                : null,
            icon: state.isGenerating
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.key_outlined),
            label: Text(state.isGenerating ? '正在生成新邀请' : '生成新邀请链接'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndGenerate(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('生成新的邀请链接？'),
        content: const Text('如果这个主题已经有邀请链接，生成后旧链接会立即失效。确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('thread-invite-link-generate-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('生成并复制'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final link = await ref
        .read(threadInviteLinkControllerProvider(threadId).notifier)
        .generate();
    if (link == null || !context.mounted) return;
    await _copyLink(context, link, generated: true);
  }

  Future<void> _copyLink(
    BuildContext context,
    ThreadInvitationLink link, {
    bool generated = false,
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: link.url.toString()));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(generated ? '新邀请已生成并复制，旧链接已失效。' : '邀请链接已复制。')),
      );
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('邀请已生成，但自动复制失败，请长按上方链接复制。')));
    }
  }

  Future<void> _openVerification(BuildContext context, WidgetRef ref) async {
    final returnTo = '/threads/$threadId/manage';
    final verified = await context.push<bool>(
      Uri(
        path: '/me/security/verify-email',
        queryParameters: {'returnTo': returnTo},
      ).toString(),
    );
    if (verified == true && context.mounted) {
      ref
          .read(threadInviteLinkControllerProvider(threadId).notifier)
          .clearFailure();
    }
  }
}
