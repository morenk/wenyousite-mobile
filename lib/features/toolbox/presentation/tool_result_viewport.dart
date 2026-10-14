import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// 结果独立滚动，复制操作留在外部；内容不足时不撑高面板。
class ToolResultViewport extends StatefulWidget {
  const ToolResultViewport({
    required this.child,
    required this.resetToken,
    this.horizontal = false,
    this.fromRight = false,
    super.key,
  });

  final Widget child;
  final Object resetToken;
  final bool horizontal;
  final bool fromRight;

  @override
  State<ToolResultViewport> createState() => _ToolResultViewportState();
}

class _ToolResultViewportState extends State<ToolResultViewport>
    with WidgetsBindingObserver {
  final _vertical = ScrollController(keepScrollOffset: false);
  final _horizontal = ScrollController(keepScrollOffset: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(ToolResultViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetToken != widget.resetToken ||
        oldWidget.fromRight != widget.fromRight) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        for (final controller in [_vertical, _horizontal]) {
          if (controller.hasClients) controller.jumpTo(0);
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _vertical.dispose();
    _horizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    // Scaffold 正文会移除键盘 inset，窗口值用于限制实际可用高度。
    final media = MediaQueryData.fromView(View.of(context));
    final availableHeight =
        media.size.height - media.padding.vertical - media.viewInsets.bottom;
    final maximumHeight = math.max(
      tokens.minimumTouchTarget,
      math.min(400.0, availableHeight * .45),
    );
    Widget content = Scrollbar(
      key: const Key('tool-result-vertical-bar'),
      controller: _vertical,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      notificationPredicate: (notification) =>
          notification.depth == 0 && notification.metrics.axis == Axis.vertical,
      child: SingleChildScrollView(
        key: const Key('tool-result-vertical-scroll'),
        controller: _vertical,
        primary: false,
        padding: EdgeInsets.only(
          right: tokens.space12,
          bottom: widget.horizontal ? tokens.space12 : 0,
        ),
        child: widget.horizontal
            ? SingleChildScrollView(
                key: const Key('tool-result-horizontal-scroll'),
                controller: _horizontal,
                primary: false,
                scrollDirection: Axis.horizontal,
                reverse: widget.fromRight,
                child: widget.child,
              )
            : widget.child,
      ),
    );
    if (widget.horizontal) {
      content = Scrollbar(
        key: const Key('tool-result-horizontal-bar'),
        controller: _horizontal,
        thumbVisibility: true,
        trackVisibility: true,
        interactive: true,
        scrollbarOrientation: ScrollbarOrientation.bottom,
        notificationPredicate: (notification) =>
            notification.metrics.axis == Axis.horizontal,
        child: content,
      );
    }
    return ScrollbarTheme(
      data: ScrollbarTheme.of(context).copyWith(
        thumbColor: WidgetStatePropertyAll(tokens.mutedText),
        trackColor: WidgetStatePropertyAll(tokens.border),
        thickness: WidgetStatePropertyAll(tokens.space4),
        radius: Radius.circular(tokens.radiusControl),
      ),
      child: ConstrainedBox(
        key: const Key('tool-result-viewport'),
        constraints: BoxConstraints(maxHeight: maximumHeight),
        child: content,
      ),
    );
  }
}
