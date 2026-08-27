import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Lets selectable text keep long press while forwarding surrounding blank
/// space to the owning content action menu.
class WenyouSelectableActionRegion extends StatefulWidget {
  const WenyouSelectableActionRegion({
    required this.selectionAreaKey,
    required this.onLongPressBlank,
    required this.child,
    super.key,
  });

  final GlobalKey<SelectionAreaState> selectionAreaKey;
  final VoidCallback? onLongPressBlank;
  final Widget child;

  @override
  State<WenyouSelectableActionRegion> createState() =>
      _WenyouSelectableActionRegionState();
}

class _WenyouSelectableActionRegionState
    extends State<WenyouSelectableActionRegion> {
  static const _blankActionDelay = Duration(milliseconds: 50);

  Timer? _longPressTimer;
  int? _pointer;
  Offset? _pointerOrigin;

  @override
  void didUpdateWidget(covariant WenyouSelectableActionRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onLongPressBlank == null) _cancelPendingLongPress();
  }

  @override
  void dispose() {
    _cancelPendingLongPress();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onLongPressBlank == null) return widget.child;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerEnd,
      onPointerCancel: _handlePointerEnd,
      child: widget.child,
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_pointer != null || _pointerHitsText(event.position)) return;
    _pointer = event.pointer;
    _pointerOrigin = event.position;
    _longPressTimer = Timer(kLongPressTimeout + _blankActionDelay, () {
      _longPressTimer = null;
      widget.onLongPressBlank?.call();
    });
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer || _pointerOrigin == null) return;
    if ((event.position - _pointerOrigin!).distance > kTouchSlop) {
      _cancelPendingLongPress();
    }
  }

  void _handlePointerEnd(PointerEvent event) {
    if (event.pointer == _pointer) _cancelPendingLongPress();
  }

  void _cancelPendingLongPress() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _pointer = null;
    _pointerOrigin = null;
  }

  bool _pointerHitsText(Offset globalPosition) {
    final root = widget.selectionAreaKey.currentContext?.findRenderObject();
    if (root is! RenderBox || !root.attached) return false;
    final rootPosition = root.globalToLocal(globalPosition);
    if (!root.paintBounds.contains(rootPosition)) return false;

    var hitText = false;
    void inspect(RenderObject renderObject) {
      if (hitText || !renderObject.attached) return;
      if (renderObject case RenderParagraph paragraph) {
        final localPosition = paragraph.globalToLocal(globalPosition);
        if (paragraph.paintBounds.contains(localPosition) &&
            _paragraphHasGlyphAt(paragraph, localPosition)) {
          hitText = true;
          return;
        }
      }
      renderObject.visitChildren(inspect);
    }

    inspect(root);
    return hitText;
  }

  bool _paragraphHasGlyphAt(RenderParagraph paragraph, Offset localPosition) {
    final textLength = paragraph.text.toPlainText().length;
    if (textLength == 0) return false;
    final offset = paragraph
        .getPositionForOffset(localPosition)
        .offset
        .clamp(0, textLength);
    final selections = <TextSelection>[
      if (offset < textLength)
        TextSelection(baseOffset: offset, extentOffset: offset + 1),
      if (offset > 0)
        TextSelection(baseOffset: offset - 1, extentOffset: offset),
    ];
    return selections.any(
      (selection) => paragraph
          .getBoxesForSelection(selection)
          .any((box) => box.toRect().inflate(2).contains(localPosition)),
    );
  }
}
