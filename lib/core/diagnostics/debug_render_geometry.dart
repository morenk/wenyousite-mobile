import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Builds a privacy-safe snapshot of actual render-tree geometry.
///
/// Target names are fixed by the caller. Widget content, route identifiers and
/// semantic labels are deliberately excluded from the snapshot.
Map<String, Object?> buildDebugRenderGeometrySnapshot({
  required BuildContext context,
  required Map<String, GlobalKey> targets,
  ScrollController? scrollController,
}) {
  if (!kDebugMode) return const {};
  final screenRect = Offset.zero & MediaQuery.sizeOf(context);
  return {
    'screenRect': _rect(screenRect),
    'targets': {
      for (final entry in targets.entries)
        entry.key: _renderTargetSnapshot(entry.value, screenRect),
    },
    if (scrollController != null) 'scroll': _scrollSnapshot(scrollController),
  };
}

Map<String, Object?> _renderTargetSnapshot(GlobalKey key, Rect screenRect) {
  final renderObject = key.currentContext?.findRenderObject();
  if (renderObject == null) return const {'present': false};
  final parents = <String>[];
  RenderObject? ancestor = renderObject.parent;
  while (ancestor != null && parents.length < 8) {
    parents.add(ancestor.runtimeType.toString());
    ancestor = ancestor.parent;
  }
  final base = <String, Object?>{
    'present': true,
    'attached': renderObject.attached,
    'renderType': renderObject.runtimeType.toString(),
    'parentRenderTypes': parents,
  };
  if (!renderObject.attached) return {...base, 'hasSize': false};
  if (renderObject is! RenderBox || !renderObject.hasSize) {
    return {...base, 'hasSize': false};
  }

  final transform = renderObject.getTransformTo(null);
  final localRect = Offset.zero & renderObject.size;
  final globalRect = MatrixUtils.transformRect(transform, localRect);
  final globalPaintBounds = MatrixUtils.transformRect(
    transform,
    renderObject.paintBounds,
  );
  final visibleRect = globalRect.overlaps(screenRect)
      ? globalRect.intersect(screenRect)
      : Rect.zero;
  final area = globalRect.width * globalRect.height;
  final visibleArea = visibleRect.width * visibleRect.height;
  final constraints = renderObject.constraints;
  return {
    ...base,
    'hasSize': true,
    'size': _size(renderObject.size),
    'constraints': {
      'minWidth': _number(constraints.minWidth),
      'maxWidth': _number(constraints.maxWidth),
      'minHeight': _number(constraints.minHeight),
      'maxHeight': _number(constraints.maxHeight),
    },
    'globalRect': _rect(globalRect),
    'localPaintBounds': _rect(renderObject.paintBounds),
    'globalPaintBounds': _rect(globalPaintBounds),
    'visibleRect': _rect(visibleRect),
    'visibleFraction': _number(area <= 0 ? 0 : visibleArea / area),
    'transform': [for (final value in transform.storage) _number(value)],
  };
}

Map<String, Object?> _scrollSnapshot(ScrollController controller) {
  if (!controller.hasClients) return const {'attached': false};
  final position = controller.position;
  return {
    'attached': true,
    'positionType': position.runtimeType.toString(),
    'pixels': _number(position.pixels),
    'minScrollExtent': _number(position.minScrollExtent),
    'maxScrollExtent': _number(position.maxScrollExtent),
    'viewportDimension': _number(position.viewportDimension),
    'axisDirection': position.axisDirection.name,
    'outOfRange': position.outOfRange,
    'hasContentDimensions': position.hasContentDimensions,
  };
}

Map<String, Object> _size(Size value) => {
  'width': _number(value.width),
  'height': _number(value.height),
};

Map<String, Object> _rect(Rect value) => {
  'left': _number(value.left),
  'top': _number(value.top),
  'right': _number(value.right),
  'bottom': _number(value.bottom),
  'width': _number(value.width),
  'height': _number(value.height),
};

Object _number(double value) {
  if (value.isNaN) return 'nan';
  if (value == double.infinity) return 'infinity';
  if (value == double.negativeInfinity) return '-infinity';
  return (value * 1000).roundToDouble() / 1000;
}
