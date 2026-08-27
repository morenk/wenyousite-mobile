import 'dart:math' as math;

import 'package:flutter/foundation.dart' show precisionErrorTolerance;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// Shows a single destination action only when content is visually clipped or
/// when the caller knows additional items were not included in [child].
class WenyouOverflowDestination extends StatefulWidget {
  const WenyouOverflowDestination({
    required this.child,
    required this.action,
    required this.maxHeight,
    required this.forceAction,
    required this.fadeColor,
    this.collapsedKey,
    super.key,
  }) : assert(maxHeight > 0);

  final Widget child;
  final Widget action;
  final double maxHeight;
  final bool forceAction;
  final Color fadeColor;
  final Key? collapsedKey;

  @override
  State<WenyouOverflowDestination> createState() =>
      _WenyouOverflowDestinationState();
}

class _WenyouOverflowDestinationState extends State<WenyouOverflowDestination> {
  var _heightOverflows = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final measured = _WenyouMeasuredHeight(
      triggerHeight: widget.maxHeight,
      visibleHeight: widget.maxHeight,
      clipOverflow: true,
      onOverflowChanged: _handleOverflowChanged,
      child: widget.child,
    );

    if (_heightOverflows) {
      return Stack(
        key: widget.collapsedKey,
        children: [
          measured,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 96,
            child: _WenyouBottomFade(color: widget.fadeColor),
          ),
          Positioned(
            left: tokens.space8,
            right: tokens.space8,
            bottom: tokens.space12,
            child: Align(alignment: Alignment.center, child: widget.action),
          ),
        ],
      );
    }
    if (widget.forceAction) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          measured,
          SizedBox(height: tokens.space8),
          Align(alignment: Alignment.center, child: widget.action),
        ],
      );
    }
    return measured;
  }

  void _handleOverflowChanged(bool value) {
    if (!mounted || _heightOverflows == value) return;
    setState(() => _heightOverflows = value);
  }
}

class WenyouOverflowAction extends StatelessWidget {
  const WenyouOverflowAction({
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    this.icon,
    this.expanded,
    this.focusNode,
    this.appearance = WenyouOverflowActionAppearance.outlined,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final String? icon;
  final bool? expanded;
  final FocusNode? focusNode;
  final WenyouOverflowActionAppearance appearance;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final outlinedStyle = OutlinedButton.styleFrom(
      minimumSize: Size(0, tokens.minimumTouchTarget),
      foregroundColor: tokens.mutedText,
      backgroundColor: backgroundColor,
      side: BorderSide(color: tokens.border),
      padding: EdgeInsets.symmetric(horizontal: tokens.space16),
      shape: const StadiumBorder(),
    );
    final textStyle = TextButton.styleFrom(
      minimumSize: Size(0, tokens.minimumTouchTarget),
      foregroundColor: tokens.mutedText,
      textStyle: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
      padding: EdgeInsets.symmetric(horizontal: tokens.space8),
    );
    final button = switch ((appearance, icon)) {
      (WenyouOverflowActionAppearance.outlined, null) => OutlinedButton(
        focusNode: focusNode,
        onPressed: onPressed,
        style: outlinedStyle,
        child: Text(label),
      ),
      (WenyouOverflowActionAppearance.outlined, final icon?) =>
        OutlinedButton.icon(
          focusNode: focusNode,
          onPressed: onPressed,
          style: outlinedStyle,
          icon: WenyouIcon(icon, size: 16),
          label: Text(label),
        ),
      (WenyouOverflowActionAppearance.quiet, null) => TextButton(
        focusNode: focusNode,
        onPressed: onPressed,
        style: textStyle,
        child: Text(label),
      ),
      (WenyouOverflowActionAppearance.quiet, final icon?) => TextButton.icon(
        focusNode: focusNode,
        onPressed: onPressed,
        style: textStyle,
        icon: WenyouIcon(icon, size: 16),
        label: Text(label),
      ),
    };
    return Semantics(expanded: expanded, child: button);
  }
}

enum WenyouOverflowActionAppearance { outlined, quiet }

class _WenyouBottomFade extends StatelessWidget {
  const _WenyouBottomFade({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0), color],
          ),
        ),
      ),
    );
  }
}

class _WenyouMeasuredHeight extends SingleChildRenderObjectWidget {
  const _WenyouMeasuredHeight({
    required this.triggerHeight,
    required this.visibleHeight,
    required this.clipOverflow,
    required this.onOverflowChanged,
    required super.child,
  });

  final double triggerHeight;
  final double visibleHeight;
  final bool clipOverflow;
  final ValueChanged<bool> onOverflowChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderWenyouMeasuredHeight(
      triggerHeight: triggerHeight,
      visibleHeight: visibleHeight,
      clipOverflow: clipOverflow,
      onOverflowChanged: onOverflowChanged,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderWenyouMeasuredHeight renderObject,
  ) {
    renderObject
      ..triggerHeight = triggerHeight
      ..visibleHeight = visibleHeight
      ..clipOverflow = clipOverflow
      ..onOverflowChanged = onOverflowChanged;
  }
}

class _RenderWenyouMeasuredHeight extends RenderProxyBox {
  _RenderWenyouMeasuredHeight({
    required this._triggerHeight,
    required this._visibleHeight,
    required this._clipOverflow,
    required this._onOverflowChanged,
  });

  double _triggerHeight;
  double get triggerHeight => _triggerHeight;
  set triggerHeight(double value) {
    if (_triggerHeight == value) return;
    _triggerHeight = value;
    markNeedsLayout();
  }

  double _visibleHeight;
  double get visibleHeight => _visibleHeight;
  set visibleHeight(double value) {
    if (_visibleHeight == value) return;
    _visibleHeight = value;
    markNeedsLayout();
  }

  bool _clipOverflow;
  bool get clipOverflow => _clipOverflow;
  set clipOverflow(bool value) {
    if (_clipOverflow == value) return;
    _clipOverflow = value;
    markNeedsLayout();
  }

  ValueChanged<bool> _onOverflowChanged;
  set onOverflowChanged(ValueChanged<bool> value) {
    _onOverflowChanged = value;
  }

  bool? _lastReportedOverflow;
  var _hasVisualOverflow = false;

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      _hasVisualOverflow = false;
      _reportOverflow(false);
      return;
    }
    child.layout(
      BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      parentUsesSize: true,
    );
    final overflows =
        child.size.height > triggerHeight + precisionErrorTolerance;
    final targetHeight = clipOverflow && overflows
        ? math.min(child.size.height, visibleHeight)
        : child.size.height;
    size = constraints.constrain(Size(child.size.width, targetHeight));
    _hasVisualOverflow =
        child.size.width > size.width + precisionErrorTolerance ||
        child.size.height > size.height + precisionErrorTolerance;
    _reportOverflow(overflows);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_hasVisualOverflow) {
      super.paint(context, offset);
      return;
    }
    context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      super.paint,
      clipBehavior: Clip.hardEdge,
    );
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) {
    return _hasVisualOverflow ? Offset.zero & size : null;
  }

  void _reportOverflow(bool value) {
    if (_lastReportedOverflow == value) return;
    _lastReportedOverflow = value;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (attached && _lastReportedOverflow == value) {
        _onOverflowChanged(value);
      }
    });
  }
}
