import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 只有当前路由、前台且与所有祖先滚动视口相交的内容可以播放。
class WenyouVisiblePlayback extends StatefulWidget {
  const WenyouVisiblePlayback({
    required this.enabled,
    required this.builder,
    super.key,
  });

  final bool enabled;
  final Widget Function(BuildContext context, bool playing) builder;

  @override
  State<WenyouVisiblePlayback> createState() => _WenyouVisiblePlaybackState();
}

class _WenyouVisiblePlaybackState extends State<WenyouVisiblePlayback>
    with WidgetsBindingObserver {
  final _positions = <ScrollPosition>{};
  bool _visible = false;
  bool _scheduled = false;
  late bool _foreground;

  @override
  void initState() {
    super.initState();
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final position in _positions) {
      position.removeListener(_schedule);
    }
    _positions.clear();
    context.visitAncestorElements((element) {
      if (element is StatefulElement && element.state is ScrollableState) {
        _positions.add((element.state as ScrollableState).position);
      }
      return true;
    });
    for (final position in _positions) {
      position.addListener(_schedule);
    }
    _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _foreground = state == AppLifecycleState.resumed);
    _schedule();
  }

  @override
  void didChangeMetrics() => _schedule();

  void _schedule() {
    if (_scheduled || !mounted) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      final render = context.findRenderObject();
      var visible = false;
      if (render is RenderBox && render.attached && render.hasSize) {
        var rect = MatrixUtils.transformRect(
          render.getTransformTo(null),
          render.paintBounds,
        );
        rect = rect.intersect(Offset.zero & MediaQuery.sizeOf(context));
        RenderObject? ancestor = render.parent;
        while (ancestor != null) {
          if (ancestor is RenderAbstractViewport) {
            rect = rect.intersect(
              MatrixUtils.transformRect(
                ancestor.getTransformTo(null),
                ancestor.paintBounds,
              ),
            );
          }
          ancestor = ancestor.parent;
        }
        visible = !rect.isEmpty;
      }
      if (_visible != visible) setState(() => _visible = visible);
    });
  }

  @override
  void dispose() {
    for (final position in _positions) {
      position.removeListener(_schedule);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = ModalRoute.isCurrentOf(context) ?? true;
    final active = TickerMode.valuesOf(context).enabled;
    return _PlaybackGeometry(
      onPaint: _schedule,
      child: widget.builder(
        context,
        widget.enabled && current && active && _foreground && _visible,
      ),
    );
  }
}

class _PlaybackGeometry extends SingleChildRenderObjectWidget {
  const _PlaybackGeometry({required this.onPaint, required super.child});
  final VoidCallback onPaint;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _PlaybackGeometryBox(onPaint);

  @override
  void updateRenderObject(
    BuildContext context,
    _PlaybackGeometryBox renderObject,
  ) {
    renderObject.onPaint = onPaint;
  }
}

class _PlaybackGeometryBox extends RenderProxyBox {
  _PlaybackGeometryBox(this.onPaint);
  VoidCallback onPaint;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    onPaint();
  }
}
