import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
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
        help: '允许楼主、协作者和已标记玩家设置本帖头像、昵称。关闭后统一显示站内资料，重新开启会恢复历史身份。',
        value: _enabled,
        onChanged: _busy ? null : _change,
      ),
      if (_error != null)
        Text(
          _error!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
    ],
  );
  Future<void> _change(bool enabled) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
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
