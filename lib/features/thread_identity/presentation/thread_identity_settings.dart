import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_feedback.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_row.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';

class ThreadIdentitySettings extends ConsumerStatefulWidget {
  const ThreadIdentitySettings({
    required this.threadId,
    required this.initialEnabled,
    super.key,
  });
  final String threadId;
  final bool initialEnabled;
  @override
  ConsumerState<ThreadIdentitySettings> createState() =>
      _ThreadIdentitySettingsState();
}

class _ThreadIdentitySettingsState
    extends ConsumerState<ThreadIdentitySettings> {
  late bool _enabled = widget.initialEnabled;
  bool _busy = false;
  String? _error;
  @override
  void didUpdateWidget(ThreadIdentitySettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_busy && oldWidget.initialEnabled != widget.initialEnabled) {
      _enabled = widget.initialEnabled;
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      WenyouSettingsToggle(
        title: '帖内身份',
        icon: WenyouIconIds.contentRoleplay,
        value: _enabled,
        onChanged: _busy ? null : _change,
      ),
      if (_error != null)
        WenyouStatusBanner(message: _error!, tone: WenyouStatusTone.error),
    ],
  );
  Future<void> _change(bool enabled) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (!enabled) {
        final confirmed = await showWenyouConfirmationDialog(
          context: context,
          title: '关闭帖内身份？',
          message: '所有发言将显示站内资料。帖内资料和历史身份会保留，重新开启后恢复。',
          confirmLabel: '关闭帖内身份',
          cancelLabel: '保持开启',
          confirmKey: const Key('thread-identity-disable-confirm'),
        );
        if (!confirmed || !mounted) return;
      }
      await ref
          .read(threadIdentityRepositoryProvider)
          .setEnabled(widget.threadId, enabled: enabled);
      if (!mounted) return;
      setState(() => _enabled = enabled);
      ref.read(visibilityCacheInvalidatorProvider)();
    } on Object catch (error) {
      if (mounted) {
        setState(
          () => _error = wenyouFailureMessage(
            mapApplicationFailure(error, '帖内身份设置失败，请重试。'),
            treatAsWrite: true,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
