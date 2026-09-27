import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/animation/wenyou_motion.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_target_visibility.dart';

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
  String? _activeTarget;
  var _visible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activateVisibleTarget();
  }

  @override
  void didUpdateWidget(covariant WenyouTransientTargetFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetId != widget.targetId) _activateVisibleTarget();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _activateVisibleTarget() {
    final targetId =
        (DiscussionTargetVisibility.maybeOf(context)?.visible ?? true)
        ? widget.targetId
        : null;
    if (_activeTarget == targetId) return;
    _activeTarget = targetId;
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
    final reduceMotion = wenyouAnimationsDisabled(context);
    final hasCoverAnnouncement =
        DiscussionTargetVisibility.maybeOf(context) != null;
    return Semantics(
      container: true,
      liveRegion: !hasCoverAnnouncement,
      label: _visible && !hasCoverAnnouncement ? widget.announcement : null,
      child: AnimatedContainer(
        key: ValueKey('target-frame-${widget.targetId ?? 'none'}'),
        duration: reduceMotion ? Duration.zero : WenyouFoundationMotion.slow,
        curve: wenyouStandardMotionCurve,
        decoration: BoxDecoration(
          border: Border.all(
            color: _visible ? tokens.brandSurface : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(tokens.radiusCompact),
        ),
        child: widget.child,
      ),
    );
  }
}
