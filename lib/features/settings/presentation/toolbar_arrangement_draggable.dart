import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';

class ToolbarArrangementDraggable extends Draggable<EditorTool> {
  const ToolbarArrangementDraggable({
    required super.data,
    required super.feedback,
    required super.child,
    required super.maxSimultaneousDrags,
    required super.onDragStarted,
    required super.onDragUpdate,
    required super.onDragEnd,
    super.key,
  });

  @override
  MultiDragGestureRecognizer createRecognizer(
    GestureMultiDragStartCallback onStart,
  ) => _ToolbarDragRecognizer(debugOwner: this)..onStart = onStart;
}

class _ToolbarDragRecognizer extends DelayedMultiDragGestureRecognizer {
  _ToolbarDragRecognizer({required super.debugOwner});

  @override
  MultiDragPointerState createNewPointerState(PointerDownEvent event) =>
      event.kind == PointerDeviceKind.mouse
      ? _MouseDragPointerState(event.position, event.kind, gestureSettings)
      : super.createNewPointerState(event);
}

class _MouseDragPointerState extends MultiDragPointerState {
  _MouseDragPointerState(
    super.initialPosition,
    super.kind,
    super.gestureSettings,
  );

  @override
  void checkForResolutionAfterMove() {
    if (pendingDelta!.distance > computeHitSlop(kind, gestureSettings)) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) =>
      starter(initialPosition);
}
