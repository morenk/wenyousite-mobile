import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll_controller.dart';

class ReadingQuickScrollOverlay extends StatefulWidget {
  const ReadingQuickScrollOverlay({
    required this.controller,
    required this.child,
    required this.hasMore,
    required this.loading,
    required this.loadFailed,
    this.bottomObstructionKey,
    super.key,
  });
  final ReadingQuickScrollController controller;
  final Widget child;
  final bool hasMore;
  final bool loading;
  final bool loadFailed;
  final GlobalKey? bottomObstructionKey;

  @override
  State<ReadingQuickScrollOverlay> createState() =>
      _ReadingQuickScrollOverlayState();
}

class _ReadingQuickScrollOverlayState extends State<ReadingQuickScrollOverlay>
    with TickerProviderStateMixin {
  final _viewportKey = GlobalKey();
  final _focus = FocusNode(debugLabel: '阅读位置');
  late final _shape = AnimationController(vsync: this);
  late final _opacity = AnimationController(vsync: this);
  int _resetRevision = -1;
  bool? _expandedTarget;
  bool? _visibleTarget;
  bool _reducedMotion = false;
  int? _pointer;
  double _downY = 0;
  double _downFraction = 0;
  double _travel = 0;
  Rect? _frozenTrack;
  Size? _dragViewportSize;
  ReadingQuickScrollController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(covariant ReadingQuickScrollOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != _controller) {
      oldWidget.controller.removeListener(_changed);
      _controller.addListener(_changed);
      _resetRevision = -1;
      _pointer = null;
      _frozenTrack = null;
    }
  }

  void _changed() {
    if (!mounted) return;
    if (!_controller.isDragging) {
      _pointer = null;
      _frozenTrack = null;
    }
    setState(() {});
  }

  void _syncAnimations() {
    final reset = _resetRevision != _controller.resetRevision;
    _resetRevision = _controller.resetRevision;
    final expanded = _controller.isOpen;
    final visible = _controller.isVisible;
    if (reset || _reducedMotion) {
      _shape.value = expanded ? 1 : 0;
      _opacity.value = visible ? 1 : 0;
    } else {
      if (_expandedTarget != expanded) {
        _shape.animateTo(
          expanded ? 1 : 0,
          duration: Duration(
            milliseconds: expanded
                ? WenyouAdaptiveReadingScrollContract.expandDurationMs
                : WenyouAdaptiveReadingScrollContract.collapseDurationMs,
          ),
          curve: expanded ? Curves.easeOutCubic : Curves.easeInOutCubic,
        );
      }
      if (_visibleTarget != visible) {
        if (visible) {
          _opacity.value = 1;
        } else {
          _opacity.animateTo(
            0,
            duration: const Duration(
              milliseconds: WenyouAdaptiveReadingScrollContract.fadeDurationMs,
            ),
          );
        }
      }
    }
    _expandedTarget = expanded;
    _visibleTarget = visible;
  }

  Rect? _rect(GlobalKey? key) {
    final box = key?.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  void _cancelDrag() {
    _pointer = null;
    _frozenTrack = null;
    _controller.cancelDrag();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowRight) {
      _controller.stepByViewport(1);
    } else if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowLeft) {
      _controller.stepByViewport(-1);
    } else if (key == LogicalKeyboardKey.home ||
        key == LogicalKeyboardKey.end) {
      _controller.seekEdge(key == LogicalKeyboardKey.end);
    } else if (key == LogicalKeyboardKey.escape) {
      _focus.unfocus();
      _controller.close();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    _reducedMotion = media.disableAnimations;
    _controller.configurePresentation(
      active:
          (ModalRoute.isCurrentOf(context) ?? true) &&
          media.viewInsets.bottom == 0,
      accessible: media.accessibleNavigation,
    );
    _syncAnimations();
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        key: _viewportKey,
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_controller.enabled && _controller.canScroll)
            ..._controls(context, constraints.biggest),
        ],
      ),
    );
  }

  List<Widget> _controls(BuildContext context, Size size) {
    if (_pointer != null && _dragViewportSize != size) _cancelDrag();
    final tokens = context.wenyouTokens;
    const width = WenyouAdaptiveReadingScrollContract.minimumTargetWidth;
    const height = WenyouAdaptiveReadingScrollContract.minimumTargetHeight;
    const gap = WenyouAdaptiveReadingScrollContract.edgeGap;
    final media = MediaQuery.of(context);
    final right =
        math.max(media.systemGestureInsets.right, media.padding.right) + gap;
    var top = math.max(media.padding.top, media.systemGestureInsets.top) + gap;
    var bottom =
        size.height -
        math.max(media.padding.bottom, media.systemGestureInsets.bottom) -
        gap;
    final viewport = _rect(_viewportKey);
    final header = _rect(_controller.pinnedHeaderKey);
    final compose = _rect(widget.bottomObstructionKey);
    if (viewport != null) {
      if (header != null && header.overlaps(viewport)) {
        top = math.max(top, header.bottom - viewport.top + gap);
      }
      if (compose != null && compose.overlaps(viewport)) {
        bottom = math.min(bottom, compose.top - viewport.top - gap);
      }
    }
    if (bottom - top < height || size.width < right + width + gap) return [];
    final track =
        _frozenTrack ??
        Rect.fromLTWH(size.width - right - width, top, width, bottom - top);
    final travel = track.height - height;
    final thumbTop = track.top + travel * _controller.fraction;
    final interactive = _controller.isOpen;
    final corner = BorderRadius.circular(tokens.radiusPill);
    return [
      // 单一完整路径仅供布局和测量，不绘制轨道也不接受点按。
      Positioned.fromRect(
        rect: track,
        child: const IgnorePointer(
          child: SizedBox(key: Key('reading-quick-scroll-rail')),
        ),
      ),
      Positioned(
        left: track.left,
        top: thumbTop,
        width: width,
        height: height,
        child: Focus(
          focusNode: _focus,
          onKeyEvent: _onKey,
          onFocusChange: _controller.setKeyboardFocus,
          child: Semantics(
            key: const Key('reading-quick-scroll-slider'),
            label: '快翻阅读位置',
            value: _controller.location,
            hint: '上下调整阅读位置',
            slider: true,
            excludeSemantics: true,
            enabled: interactive,
            increasedValue: _controller.location,
            decreasedValue: _controller.location,
            onIncrease: interactive
                ? () => _controller.stepByViewport(1)
                : null,
            onDecrease: interactive
                ? () => _controller.stepByViewport(-1)
                : null,
            child: IgnorePointer(
              ignoring: !interactive,
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) {
                  if (_pointer != null || travel <= 0 || !_controller.isOpen) {
                    return;
                  }
                  _pointer = event.pointer;
                  _frozenTrack = track;
                  _dragViewportSize = size;
                  _downY = event.position.dy;
                  _travel = travel;
                  _downFraction = _controller.grab();
                },
                onPointerMove: (event) {
                  if (event.pointer != _pointer) return;
                  _controller.updateDrag(
                    (_downFraction + (event.position.dy - _downY) / _travel)
                        .clamp(0, 1),
                  );
                },
                onPointerUp: (event) {
                  if (event.pointer != _pointer) return;
                  _pointer = null;
                  _frozenTrack = null;
                  _controller.endDrag(_controller.fraction);
                },
                onPointerCancel: (event) {
                  if (event.pointer == _pointer) _cancelDrag();
                },
                child: AnimatedBuilder(
                  animation: Listenable.merge([_shape, _opacity]),
                  builder: (context, _) => Opacity(
                    opacity: _opacity.value,
                    child: Center(
                      child: Container(
                        width: WenyouAdaptiveReadingScrollContract
                            .expandedBackingWidth,
                        height: WenyouAdaptiveReadingScrollContract
                            .expandedBackingHeight,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: corner,
                          color: tokens.panel.withValues(
                            alpha:
                                WenyouAdaptiveReadingScrollContract
                                    .expandedBackingOpacity *
                                _shape.value,
                          ),
                          border: _focus.hasFocus
                              ? Border.all(color: tokens.focus)
                              : null,
                        ),
                        child: Container(
                          key: const Key('reading-progress-indicator'),
                          width: lerpDouble(
                            WenyouAdaptiveReadingScrollContract.collapsedWidth,
                            WenyouAdaptiveReadingScrollContract.expandedWidth,
                            _shape.value,
                          ),
                          height: lerpDouble(
                            WenyouAdaptiveReadingScrollContract.collapsedHeight,
                            WenyouAdaptiveReadingScrollContract.expandedHeight,
                            _shape.value,
                          ),
                          decoration: BoxDecoration(
                            color: tokens.brandForeground,
                            borderRadius: corner,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      if (_controller.isDragging)
        Positioned(
          top: top,
          bottom: size.height - bottom,
          left: gap,
          right:
              size.width -
              track.left +
              WenyouAdaptiveReadingScrollContract.labelGap,
          child: IgnorePointer(
            child: CustomSingleChildLayout(
              delegate: _LocationLayout(thumbTop + height / 2 - top),
              child: Material(
                key: const Key('reading-quick-scroll-location'),
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.radiusCompact),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(tokens.space8),
                  child: Text(
                    [
                      _controller.location,
                      if (widget.hasMore)
                        widget.loadFailed
                            ? '加载失败 · 已加载范围'
                            : widget.loading
                            ? '正在加载 · 已加载范围'
                            : '已加载范围',
                    ].join('\n'),
                    style: Theme.of(context).textTheme.wenyouCaption,
                  ),
                ),
              ),
            ),
          ),
        ),
    ];
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    _shape.dispose();
    _opacity.dispose();
    _focus.dispose();
    super.dispose();
  }
}

class _LocationLayout extends SingleChildLayoutDelegate {
  const _LocationLayout(this.anchorY);
  final double anchorY;
  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();
  @override
  Offset getPositionForChild(Size size, Size childSize) => Offset(
    size.width - childSize.width,
    (anchorY - childSize.height / 2).clamp(
      0,
      math.max(0, size.height - childSize.height),
    ),
  );
  @override
  bool shouldRelayout(covariant _LocationLayout oldDelegate) =>
      anchorY != oldDelegate.anchorY;
}
