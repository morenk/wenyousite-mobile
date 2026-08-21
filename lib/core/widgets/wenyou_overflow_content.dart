import 'dart:math' as math;

import 'package:flutter/foundation.dart' show precisionErrorTolerance;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// Collapses content from its real laid-out height without briefly painting the
/// full child first.
class WenyouCollapsibleContent extends StatefulWidget {
  const WenyouCollapsibleContent({
    required this.child,
    required this.contentIdentity,
    required this.triggerHeight,
    required this.collapsedHeight,
    required this.fadeColor,
    this.expandLabel = '展开全文',
    this.collapseLabel = '收起',
    this.actionKey,
    this.collapsedKey,
    super.key,
  }) : assert(triggerHeight > 0),
       assert(collapsedHeight > 0),
       assert(collapsedHeight <= triggerHeight);

  final Widget child;
  final Object contentIdentity;
  final double triggerHeight;
  final double collapsedHeight;
  final Color fadeColor;
  final String expandLabel;
  final String collapseLabel;
  final Key? actionKey;
  final Key? collapsedKey;

  @override
  State<WenyouCollapsibleContent> createState() =>
      _WenyouCollapsibleContentState();
}

class _WenyouCollapsibleContentState extends State<WenyouCollapsibleContent> {
  final _anchorKey = GlobalKey();
  final _actionFocusNode = FocusNode();
  var _overflows = false;
  var _expanded = false;

  @override
  void didUpdateWidget(covariant WenyouCollapsibleContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contentIdentity != widget.contentIdentity) {
      _overflows = false;
      _expanded = false;
    }
  }

  @override
  void dispose() {
    _actionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final measured = _WenyouMeasuredHeight(
      key: ValueKey(widget.contentIdentity),
      triggerHeight: widget.triggerHeight,
      visibleHeight: widget.collapsedHeight,
      clipOverflow: !_expanded,
      onOverflowChanged: _handleOverflowChanged,
      child: widget.child,
    );

    Widget content;
    if (!_overflows) {
      content = measured;
    } else if (_expanded) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          measured,
          SizedBox(height: tokens.space12),
          Align(
            alignment: Alignment.center,
            child: WenyouOverflowAction(
              key: widget.actionKey,
              label: widget.collapseLabel,
              expanded: true,
              focusNode: _actionFocusNode,
              backgroundColor: widget.fadeColor,
              onPressed: _toggle,
            ),
          ),
        ],
      );
    } else {
      content = Stack(
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
            child: Align(
              alignment: Alignment.center,
              child: WenyouOverflowAction(
                key: widget.actionKey,
                label: widget.expandLabel,
                expanded: false,
                focusNode: _actionFocusNode,
                backgroundColor: widget.fadeColor,
                onPressed: _toggle,
              ),
            ),
          ),
        ],
      );
    }

    return KeyedSubtree(key: _anchorKey, child: content);
  }

  void _handleOverflowChanged(bool value) {
    if (!mounted || _overflows == value) return;
    setState(() {
      _overflows = value;
      if (!value) _expanded = false;
    });
  }

  void _toggle() {
    if (_expanded) {
      setState(() => _expanded = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final anchorContext = _anchorKey.currentContext;
        if (anchorContext != null) {
          Scrollable.ensureVisible(
            anchorContext,
            alignment: 0,
            duration: Duration.zero,
          );
        }
        _actionFocusNode.requestFocus();
      });
      return;
    }
    setState(() => _expanded = true);
  }
}

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
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final String? icon;
  final bool? expanded;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final style = OutlinedButton.styleFrom(
      minimumSize: Size(0, tokens.minimumTouchTarget),
      foregroundColor: tokens.mutedText,
      backgroundColor: backgroundColor,
      side: BorderSide(color: tokens.border),
      padding: EdgeInsets.symmetric(horizontal: tokens.space16),
      shape: const StadiumBorder(),
    );
    final button = icon == null
        ? OutlinedButton(
            focusNode: focusNode,
            onPressed: onPressed,
            style: style,
            child: Text(label),
          )
        : OutlinedButton.icon(
            focusNode: focusNode,
            onPressed: onPressed,
            style: style,
            icon: WenyouIcon(icon!, size: 16),
            label: Text(label),
          );
    return Semantics(expanded: expanded, child: button);
  }
}

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
    super.key,
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
