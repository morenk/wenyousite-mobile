import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';

/// 仅指定正文片段参与动态字体加载，UI 字体仍由应用主题决定。
class TextFontScope extends ConsumerStatefulWidget {
  const TextFontScope({required this.texts, required this.builder, super.key});
  final Map<String, String> texts;
  final Widget Function(BuildContext, TextFontRuntime?) builder;
  @override
  ConsumerState<TextFontScope> createState() => _TextFontScopeState();
}

class _TextFontScopeState extends ConsumerState<TextFontScope> {
  TextFontRuntime? _runtime;
  TextFontService? _service;
  final _scrolls = <ScrollPosition>{};
  bool _visible = false;
  bool _scheduled = false;
  int _generation = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final scroll in _scrolls) {
      scroll.removeListener(_scheduleVisibility);
    }
    _scrolls.clear();
    context.visitAncestorElements((element) {
      if (element is StatefulElement && element.state is ScrollableState) {
        _scrolls.add((element.state as ScrollableState).position);
      }
      return true;
    });
    for (final scroll in _scrolls) {
      scroll.addListener(_scheduleVisibility);
    }
    _service = ref.read(textFontServiceProvider);
    _scheduleVisibility();
  }

  @override
  void didUpdateWidget(covariant TextFontScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapEquals(oldWidget.texts, widget.texts)) {
      _generation++;
      if (_visible) unawaited(_load());
    }
    _scheduleVisibility();
  }

  void _scheduleVisibility() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      final box = context.findRenderObject();
      var visible =
          TickerMode.valuesOf(context).enabled &&
          (ModalRoute.of(context)?.isCurrent ?? true);
      if (box is RenderBox && box.hasSize) {
        var bounds = box.localToGlobal(Offset.zero) & box.size;
        final screen = Offset.zero & MediaQuery.sizeOf(context);
        bounds = bounds.intersect(screen);
        RenderObject ancestor = box;
        while (ancestor.parent != null) {
          ancestor = ancestor.parent!;
          if (ancestor is RenderAbstractViewport) {
            bounds = bounds.intersect(
              MatrixUtils.transformRect(
                ancestor.getTransformTo(null),
                ancestor.paintBounds,
              ),
            );
          }
        }
        visible = visible && bounds.width > 0 && bounds.height > 0;
      } else {
        visible = false;
      }
      if (_visible == visible) return;
      _visible = visible;
      _generation++;
      if (visible) {
        unawaited(_load());
      } else {
        _service?.release(this);
        _runtime?.release(this);
      }
    });
  }

  Future<void> _load() async {
    if (widget.texts.isEmpty) {
      _service?.release(this);
      _runtime?.release(this);
      return;
    }
    final generation = ++_generation;
    try {
      final runtime = await _service!.retain(this, widget.texts);
      if (!mounted || !_visible || generation != _generation) return;
      if (_runtime != runtime) {
        _runtime?.removeListener(_changed);
        _runtime = runtime..addListener(_changed);
        _changed();
      }
      runtime.setDemand(this, widget.texts);
    } on Object {
      // 平台目录不可用时同样只回退正文，不阻断编辑。
    }
  }

  void _changed() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _runtime?.removeListener(_changed);
    _runtime?.release(this);
    _service?.release(this);
    for (final scroll in _scrolls) {
      scroll.removeListener(_scheduleVisibility);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _runtime);
}
