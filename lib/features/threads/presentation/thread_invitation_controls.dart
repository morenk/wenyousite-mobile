import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_invitation_controller.dart';

class ThreadInviteLinkPanel extends ConsumerStatefulWidget {
  const ThreadInviteLinkPanel({
    required this.threadId,
    this.enabled = true,
    super.key,
  });
  final String threadId;
  final bool enabled;
  @override
  ConsumerState<ThreadInviteLinkPanel> createState() =>
      _ThreadInviteLinkPanelState();
}

class _ThreadInviteLinkPanelState extends ConsumerState<ThreadInviteLinkPanel> {
  bool _busy = false;
  bool _resetting = false;
  bool _confirming = false;
  int _actionEpoch = 0;

  @override
  void didUpdateWidget(covariant ThreadInviteLinkPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.threadId != widget.threadId ||
        oldWidget.enabled != widget.enabled) {
      _actionEpoch += 1;
      _busy = false;
      _resetting = false;
      ref.invalidate(threadInviteLinkControllerProvider(oldWidget.threadId));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionScopeProvider, (before, after) {
      if (before == after) return;
      _actionEpoch += 1;
      setState(() => _busy = false);
    });
    final provider = threadInviteLinkControllerProvider(widget.threadId);
    final state = ref.watch(provider);
    final tokens = context.wenyouTokens;
    final locked = !widget.enabled || _busy || state.isLoading;
    final failure = state.failure == null
        ? null
        : UserFacingFailure.fromApi(
            state.failure,
            objectName: '邀请链接',
            message: state.resetUnconfirmed
                ? '暂时无法确认重置是否成功，请先重新获取当前邀请链接。'
                : null,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('私密邀请', style: Theme.of(context).textTheme.wenyouOverlayTitle),
        SizedBox(height: tokens.space8),
        Text(
          '再次分享时直接复制当前链接。只把链接发送给你希望加入这个私密主题的人。',
          style: Theme.of(
            context,
          ).textTheme.wenyouCompactBody.copyWith(color: tokens.mutedText),
        ),
        if (failure != null) ...[
          SizedBox(height: tokens.space12),
          WenyouStatusBanner(
            key: const Key('thread-invite-link-failure'),
            tone: WenyouStatusTone.error,
            message: failure.message,
            detail: failure.problemDetail,
            action: TextButton(
              key: const Key('thread-invite-link-dismiss-failure'),
              onPressed: locked
                  ? null
                  : () => ref.read(provider.notifier).clearFailure(),
              child: const Text('知道了'),
            ),
          ),
        ],
        if (widget.enabled && state.link != null) ...[
          SizedBox(height: tokens.space16),
          Text('当前邀请链接', style: Theme.of(context).textTheme.wenyouLabel),
          SizedBox(height: tokens.space8),
          SelectableText(
            state.link!.url.toString(),
            key: const Key('thread-invite-link-value'),
          ),
        ],
        SizedBox(height: tokens.space16),
        WenyouAsyncButton(
          key: const Key('thread-invite-link-copy'),
          label: '复制邀请链接',
          isLoading: _busy && !_resetting,
          loadingLabel: '正在获取邀请链接',
          onPressed: locked ? null : () => _perform(reset: false),
          icon: WenyouIconIds.actionCopyAll,
        ),
        SizedBox(height: tokens.space8),
        WenyouAsyncButton(
          key: const Key('thread-invite-link-reset'),
          label: '重置邀请链接',
          isLoading: _busy && _resetting && !_confirming,
          loadingLabel: '正在重置邀请链接',
          onPressed: locked ? null : () => _perform(reset: true),
          icon: WenyouIconIds.securityPassword,
          variant: WenyouAsyncButtonVariant.outlined,
        ),
      ],
    );
  }

  Future<void> _perform({required bool reset}) async {
    if (_busy || !widget.enabled) return;
    final epoch = ++_actionEpoch;
    final scope = ref.read(sessionScopeProvider);
    final threadId = widget.threadId;
    bool current() =>
        mounted &&
        widget.enabled &&
        epoch == _actionEpoch &&
        widget.threadId == threadId &&
        ref.read(sessionScopeProvider) == scope;
    setState(() {
      _busy = true;
      _resetting = reset;
      _confirming = reset;
    });
    try {
      if (reset) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => _InviteResetConfirmation(scope: scope),
        );
        if (!current() || confirmed != true) return;
        setState(() => _confirming = false);
      }
      final controller = ref.read(
        threadInviteLinkControllerProvider(threadId).notifier,
      );
      final result = await (reset ? controller.reset() : controller.ensure());
      if (!current() || result == null) return;
      bool copied;
      try {
        await Clipboard.setData(
          ClipboardData(text: result.link.url.toString()),
        );
        copied = true;
      } on Object {
        copied = false;
      }
      if (!current()) return;
      final message = copied
          ? result.resetConfirmed
                ? '邀请链接已重置并复制，旧链接已失效。'
                : result.recoveredAfterReset
                ? '暂时无法确认重置是否成功，当前邀请链接已获取并复制。'
                : '邀请链接已复制。'
          : result.resetConfirmed
          ? '邀请链接已重置，但自动复制失败，请长按上方链接复制。'
          : result.recoveredAfterReset
          ? '暂时无法确认重置是否成功，当前邀请链接已获取，但自动复制失败，请长按上方链接复制。'
          : '当前邀请链接已获取，但自动复制失败，请长按上方链接复制。';
      if (!mounted) return;
      showWenyouSnackBar(
        context,
        message,
        tone: copied ? WenyouSnackBarTone.success : WenyouSnackBarTone.error,
        pacing: WenyouSnackBarPacing.extended,
      );
    } finally {
      if (current()) setState(() => _busy = false);
    }
  }
}

class _InviteResetConfirmation extends ConsumerWidget {
  const _InviteResetConfirmation({required this.scope});
  final SessionScope scope;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(sessionScopeProvider) != scope) {
      final route = ModalRoute.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && route != null && route.isActive) {
          Navigator.of(context).removeRoute(route, false);
        }
      });
      return const SizedBox.shrink();
    }
    return WenyouPendingConfirmationDialog(
      title: '重置邀请链接？',
      message: '旧邀请链接将立即失效，已加入成员的权限不受影响。',
      confirmLabel: '重置并复制',
      confirmKey: const Key('thread-invite-link-reset-confirm'),
      onConfirm: () => Navigator.pop(context, true),
      onCancel: () => Navigator.pop(context, false),
    );
  }
}
