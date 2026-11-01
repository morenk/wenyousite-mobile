import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/animation/wenyou_motion.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_progress_indicator.dart';

/// 原生下拉手势和请求生命周期保持；减少动画只替换忙碌外观，不暂停手势控制器。
class WenyouRefreshIndicator extends StatefulWidget {
  const WenyouRefreshIndicator({
    required this.onRefresh,
    required this.child,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    super.key,
  });
  final RefreshCallback onRefresh;
  final Widget child;
  final ScrollNotificationPredicate notificationPredicate;
  final String? semanticsLabel;

  @override
  State<WenyouRefreshIndicator> createState() => _WenyouRefreshIndicatorState();
}

class _WenyouRefreshIndicatorState extends State<WenyouRefreshIndicator> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduced = wenyouAnimationsDisabled(context);
    final child = Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        if (reduced && _refreshing)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Semantics(
                label: '正在刷新',
                liveRegion: true,
                child: const WenyouLinearProgressIndicator(),
              ),
            ),
          ),
      ],
    );
    if (!reduced) {
      return RefreshIndicator(
        semanticsLabel: widget.semanticsLabel,
        onRefresh: _refresh,
        notificationPredicate: widget.notificationPredicate,
        child: child,
      );
    }
    return RefreshIndicator.noSpinner(
      semanticsLabel: widget.semanticsLabel,
      onRefresh: _refresh,
      notificationPredicate: widget.notificationPredicate,
      child: child,
    );
  }
}
