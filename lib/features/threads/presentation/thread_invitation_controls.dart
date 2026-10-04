import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/navigation/navigation_link_writer.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_invitation_controller.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_management_action_row.dart';

class ThreadInviteLinkCopyRow extends ConsumerStatefulWidget {
  const ThreadInviteLinkCopyRow({
    required this.threadId,
    required this.beforeCopy,
    this.enabled = true,
    super.key,
  });

  final String threadId;
  final Future<bool> Function() beforeCopy;
  final bool enabled;

  @override
  ConsumerState<ThreadInviteLinkCopyRow> createState() =>
      _ThreadInviteLinkCopyRowState();
}

class _ThreadInviteLinkCopyRowState
    extends ConsumerState<ThreadInviteLinkCopyRow> {
  bool _busy = false;
  int _actionEpoch = 0;
  String? _manualLink;
  bool _routeActive = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active = ModalRoute.of(context)?.isCurrent ?? true;
    if (_routeActive && !active) {
      _actionEpoch += 1;
      _busy = false;
      _manualLink = null;
    }
    _routeActive = active;
  }

  @override
  void didUpdateWidget(covariant ThreadInviteLinkCopyRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.threadId != widget.threadId ||
        oldWidget.enabled != widget.enabled) {
      _actionEpoch += 1;
      _busy = false;
      _manualLink = null;
      ref.invalidate(threadInviteLinkControllerProvider(oldWidget.threadId));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionScopeProvider, (before, after) {
      if (before == after) return;
      _actionEpoch += 1;
      setState(() {
        _busy = false;
        _manualLink = null;
      });
    });
    final state = ref.watch(
      threadInviteLinkControllerProvider(widget.threadId),
    );
    final tokens = context.wenyouTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ThreadManagementActionRow(
          key: const Key('thread-invite-link-copy'),
          title: '复制邀请链接',
          icon: WenyouIconIds.actionCopyAll,
          busy: _busy,
          onTap: !widget.enabled || _busy || state.isLoading ? null : _copy,
        ),
        if (widget.enabled && _manualLink != null) ...[
          Text(
            '自动复制失败，请长按下方链接复制。',
            style: Theme.of(context).textTheme.wenyouCaption.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(height: tokens.space8),
          SelectableText(
            _manualLink!,
            key: const Key('thread-invite-link-value'),
          ),
          SizedBox(height: tokens.space8),
        ],
      ],
    );
  }

  Future<void> _copy() async {
    if (_busy || !widget.enabled) return;
    final epoch = ++_actionEpoch;
    final scope = ref.read(sessionScopeProvider);
    final threadId = widget.threadId;
    bool current() =>
        mounted &&
        widget.enabled &&
        epoch == _actionEpoch &&
        widget.threadId == threadId &&
        ref.read(sessionScopeProvider) == scope &&
        (ModalRoute.of(context)?.isCurrent ?? true);
    setState(() {
      _busy = true;
      _manualLink = null;
    });
    try {
      // 聚合保存结束后，调用者再按已保存的主题权限复核。
      final ready = await widget.beforeCopy();
      if (!mounted || !current()) return;
      if (!ready) {
        showWenyouSnackBar(
          context,
          '暂时无法复制，请确认设置已保存且仍可邀请。',
          tone: WenyouSnackBarTone.error,
        );
        return;
      }
      final provider = threadInviteLinkControllerProvider(threadId);
      final link = await ref.read(provider.notifier).ensure();
      if (!mounted || !current()) return;
      if (link == null) {
        final failure = UserFacingFailure.fromApi(
          ref.read(provider).failure,
          objectName: '邀请链接',
          message: '邀请链接获取失败，请重试。',
        );
        showWenyouSnackBar(
          context,
          [
            failure.message,
            if (failure.problemDetail != null) failure.problemDetail!,
          ].join('\n'),
          tone: WenyouSnackBarTone.error,
        );
        return;
      }
      try {
        await ref.read(navigationLinkWriterProvider)(link.url.toString());
      } on Object {
        if (current()) setState(() => _manualLink = link.url.toString());
        return;
      }
      if (mounted && current()) {
        showWenyouSnackBar(
          context,
          '邀请链接已复制。',
          tone: WenyouSnackBarTone.success,
        );
      }
    } finally {
      if (mounted && epoch == _actionEpoch) setState(() => _busy = false);
    }
  }
}
