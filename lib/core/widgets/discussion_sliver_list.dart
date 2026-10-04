import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// 双向窗口保留相同条目的布局坐标，前插不把旧屏幕索引当成新位置。
/// 只复用仍在渲染邻域里的行；离屏正文由 Sliver 正常释放。
class DiscussionSliverList extends SliverMultiBoxAdaptorWidget {
  const DiscussionSliverList({
    required this.scope,
    required super.delegate,
    super.key,
  });

  final Object scope;

  @override
  SliverMultiBoxAdaptorElement createElement() =>
      _DiscussionSliverElement(this);

  @override
  RenderSliverList createRenderObject(BuildContext context) =>
      RenderSliverList(childManager: context as SliverMultiBoxAdaptorElement);
}

class _DiscussionSliverElement extends SliverMultiBoxAdaptorElement {
  _DiscussionSliverElement(DiscussionSliverList super.widget);

  var _preserve = true;

  @override
  void update(covariant DiscussionSliverList newWidget) {
    _preserve = (widget as DiscussionSliverList).scope == newWidget.scope;
    super.update(newWidget);
    _preserve = true;
  }

  @override
  void performRebuild() {
    final offsets = <RenderBox, double>{};
    if (_preserve) {
      for (
        var child = renderObject.firstChild;
        child != null;
        child = renderObject.childAfter(child)
      ) {
        final offset = renderObject.childScrollOffset(child);
        if (offset != null) offsets[child] = offset;
      }
    }
    super.performRebuild();
    for (
      var child = renderObject.firstChild;
      child != null;
      child = renderObject.childAfter(child)
    ) {
      final offset = offsets[child];
      if (offset != null) {
        (child.parentData! as SliverMultiBoxAdaptorParentData).layoutOffset =
            offset;
      }
    }
  }
}
