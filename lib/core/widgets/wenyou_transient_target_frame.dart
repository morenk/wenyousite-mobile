import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

class WenyouTransientTargetFrame extends StatefulWidget {
  const WenyouTransientTargetFrame({
    required this.targetId,
    required this.child,
    this.announcement = '已定位到目标内容',
    super.key,
  });

  final String? targetId;
  final Widget child;
  final String announcement;

  @override
  State<WenyouTransientTargetFrame> createState() =>
      _WenyouTransientTargetFrameState();
}

class _WenyouTransientTargetFrameState
    extends State<WenyouTransientTargetFrame> {
  static const _holdDuration = Duration(milliseconds: 1200);

  Timer? _timer;
  var _visible = false;

  @override
  void initState() {
    super.initState();
    _activate(widget.targetId);
  }

  @override
  void didUpdateWidget(covariant WenyouTransientTargetFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetId != widget.targetId) _activate(widget.targetId);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _activate(String? targetId) {
    _timer?.cancel();
    _visible = targetId != null;
    if (!_visible) return;
    _timer = Timer(_holdDuration, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.targetId == null) return widget.child;
    final tokens = context.wenyouTokens;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Semantics(
      container: true,
      liveRegion: true,
      label: _visible ? widget.announcement : null,
      child: AnimatedContainer(
        key: ValueKey('target-frame-${widget.targetId ?? 'none'}'),
        duration: reduceMotion ? Duration.zero : WenyouFoundationMotion.slow,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          border: Border.all(
            color: _visible ? tokens.brandSurface : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(tokens.radius12),
        ),
        child: widget.child,
      ),
    );
  }
}
