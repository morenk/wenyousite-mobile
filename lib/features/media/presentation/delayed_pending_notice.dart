import 'dart:async';

import 'package:flutter/widgets.dart';

/// 短暂的图片等待只留在发布按钮中，较久才展开辅助操作。
class DelayedPendingNotice extends StatefulWidget {
  const DelayedPendingNotice({
    required this.waiting,
    required this.child,
    this.delay = const Duration(seconds: 3),
    super.key,
  });

  final bool waiting;
  final Widget child;
  final Duration delay;

  @override
  State<DelayedPendingNotice> createState() => _DelayedPendingNoticeState();
}

class _DelayedPendingNoticeState extends State<DelayedPendingNotice> {
  Timer? _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant DelayedPendingNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.waiting != widget.waiting) _sync();
  }

  void _sync() {
    _timer?.cancel();
    _visible = false;
    if (!widget.waiting) return;
    _timer = Timer(widget.delay, () {
      if (mounted && widget.waiting) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _visible && widget.waiting ? widget.child : const SizedBox.shrink();
}
