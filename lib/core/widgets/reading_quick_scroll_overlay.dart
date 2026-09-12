import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll_card.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll_controller.dart';

class ReadingQuickScrollOverlay extends StatefulWidget {
  const ReadingQuickScrollOverlay({
    required this.controller,
    required this.child,
    required this.hasMore,
    required this.loading,
    required this.loadFailed,
    this.onRetry,
    this.bottomObstructionKey,
    super.key,
  });
  final ReadingQuickScrollController controller;
  final Widget child;
  final bool hasMore;
  final bool loading;
  final bool loadFailed;
  final VoidCallback? onRetry;
  final GlobalKey? bottomObstructionKey;
  @override
  State<ReadingQuickScrollOverlay> createState() =>
      _ReadingQuickScrollOverlayState();
}

class _ReadingQuickScrollOverlayState extends State<ReadingQuickScrollOverlay> {
  final _viewportKey = GlobalKey();
  final _tapGroup = Object();
  final _focus = FocusNode(debugLabel: '阅读快翻');
  bool _cardOpen = false;
  bool _dragActive = false;
  double _downY = 0;
  double _downFraction = 0;
  double _travel = 0;
  double _dragRailTop = 0;
  double _dragRailLength = 0;
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
      _cardOpen = false;
      _dragActive = false;
    }
    if (!_controller.isOpen) {
      _cardOpen = false;
      _dragActive = false;
    }
  }

  void _changed() {
    if (!mounted) return;
    setState(() {
      if (!_controller.isOpen) {
        _cardOpen = false;
        _dragActive = false;
      }
    });
  }

  void _dismissCard() {
    if (_cardOpen && mounted) setState(() => _cardOpen = false);
  }

  void _toggleCard() {
    _focus.requestFocus();
    setState(() => _cardOpen = !_cardOpen);
  }

  String? get _status {
    if (!widget.hasMore) return null;
    if (widget.loadFailed) return '更多内容加载失败，当前可快翻已加载内容';
    if (widget.loading) return '正在加载更多，当前可快翻已加载内容';
    return _controller.isFollowingEnd ? '按住末端继续快翻，松手即可停下' : '当前可快翻已加载内容';
  }

  Rect? _rect(GlobalKey? key) {
    final box = key?.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  void _updateDrag(double globalY) {
    if (!_dragActive || _travel <= 0) return;
    _controller.updateDrag(
      (_downFraction + (globalY - _downY) / _travel).clamp(0, 1),
    );
  }

  void _cancelDrag() {
    if (!_dragActive) return;
    _dragActive = false;
    _controller.cancelDrag();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowRight) {
      _dismissCard();
      _controller.stepByViewport(1);
    } else if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowLeft) {
      _dismissCard();
      _controller.stepByViewport(-1);
    } else if (key == LogicalKeyboardKey.home ||
        key == LogicalKeyboardKey.end) {
      _dismissCard();
      _controller.seekEdge(key == LogicalKeyboardKey.end);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      _toggleCard();
    } else if (key == LogicalKeyboardKey.escape) {
      _cardOpen ? _dismissCard() : _controller.close();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Stack(
      key: _viewportKey,
      fit: StackFit.expand,
      children: [
        NotificationListener<ScrollStartNotification>(
          onNotification: (notification) {
            if (notification.depth == 0 &&
                notification.dragDetails != null &&
                _cardOpen) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _dismissCard(),
              );
            }
            return false;
          },
          child: widget.child,
        ),
        if (_controller.isOpen) ..._controls(context, constraints.biggest),
      ],
    ),
  );

  List<Widget> _controls(BuildContext context, Size size) {
    if (_dragActive && _dragViewportSize != size) _cancelDrag();
    final tokens = context.wenyouTokens;
    const target = WenyouReadingQuickScrollContract.minimumTarget;
    const gap = WenyouReadingQuickScrollContract.edgeGap;
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
      if (header != null) {
        // 标题吸顶前后保留相同高度，避免拖动时轨道突然改变位置。
        top = math.max(top, header.height + gap);
      }
      if (compose != null && compose.overlaps(viewport)) {
        bottom = math.min(bottom, compose.top - viewport.top - gap);
      }
    }
    final height = bottom - top;
    if (height < target || size.width < right + target + gap) return [];
    final availableLength = math.min(
      WenyouReadingQuickScrollContract.railMaxLength,
      height,
    );
    // 吸顶标题可能切换密度；本次抓取沿固定轨道移动，松手后再更新几何。
    final length = _dragActive ? _dragRailLength : availableLength;
    final railTop = _dragActive ? _dragRailTop : top + (height - length) / 2;
    final travel = length - target;
    final thumbTop = railTop + travel * _controller.fraction;
    final corner = BorderRadius.circular(tokens.radiusPill);
    final leftSpace =
        size.width -
        right -
        target -
        WenyouReadingQuickScrollContract.labelGap -
        gap;
    final panel = _cardOpen
        ? ReadingQuickScrollCard(
            controller: _controller,
            status: _status,
            hasMore: widget.hasMore,
            loadFailed: widget.loadFailed,
            onRetry: widget.onRetry,
            onDismiss: _dismissCard,
          )
        : _controller.isDragging
        ? Material(
            key: const Key('reading-quick-scroll-location'),
            color: tokens.panel,
            borderRadius: BorderRadius.circular(tokens.radius12),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(tokens.space8),
              child: Text(
                [_controller.location, ?_status].join('\n'),
                style: Theme.of(context).textTheme.wenyouCaption,
              ),
            ),
          )
        : widget.hasMore
        ? Material(
            color: tokens.panel,
            borderRadius: BorderRadius.circular(tokens.radius12),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(tokens.space4),
              child: Text(
                widget.loadFailed ? '加载失败 · 已加载范围' : '已加载范围',
                style: Theme.of(context).textTheme.wenyouCaption,
              ),
            ),
          )
        : null;
    return [
      Positioned(
        right: right,
        top: railTop,
        width: target,
        height: length,
        child: IgnorePointer(
          child: ExcludeSemantics(
            child: SizedBox(
              key: const Key('reading-quick-scroll-rail'),
              child: Center(
                child: Container(
                  width: WenyouReadingQuickScrollContract.railThickness,
                  height: travel,
                  decoration: BoxDecoration(
                    borderRadius: corner,
                    color: tokens.brandForeground.withValues(
                      alpha: WenyouReadingQuickScrollContract.railOpacity,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        right: right,
        top: thumbTop,
        width: target,
        height: target,
        child: TapRegion(
          groupId: _tapGroup,
          onTapOutside: (_) => _dismissCard(),
          child: Focus(
            focusNode: _focus,
            onKeyEvent: _onKey,
            onFocusChange: (_) {
              if (mounted) setState(() {});
            },
            child: Semantics(
              key: const Key('reading-quick-scroll-slider'),
              label: '快翻阅读位置',
              value: _controller.location,
              hint: '上下调整位置，点按展开首尾操作',
              slider: true,
              enabled: _controller.canScroll,
              increasedValue: _controller.location,
              decreasedValue: _controller.location,
              onIncrease: _controller.canScroll
                  ? () => _controller.stepByViewport(1)
                  : null,
              onDecrease: _controller.canScroll
                  ? () => _controller.stepByViewport(-1)
                  : null,
              onTap: _toggleCard,
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleCard,
                onVerticalDragDown: _controller.canScroll && travel > 0
                    ? (details) {
                        _downY = details.globalPosition.dy;
                        _downFraction = _controller.fraction;
                        _travel = travel;
                        _dragRailTop = railTop;
                        _dragRailLength = length;
                        _dragViewportSize = size;
                      }
                    : null,
                onVerticalDragStart: _controller.canScroll && travel > 0
                    ? (details) {
                        _focus.requestFocus();
                        _cardOpen = false;
                        _dragActive = true;
                        _controller.beginDrag(_downFraction);
                        _updateDrag(details.globalPosition.dy);
                      }
                    : null,
                onVerticalDragUpdate: _controller.canScroll && travel > 0
                    ? (details) => _updateDrag(details.globalPosition.dy)
                    : null,
                onVerticalDragEnd: _controller.canScroll && travel > 0
                    ? (_) {
                        _dragActive = false;
                        _controller.endDrag(_controller.fraction);
                      }
                    : null,
                onVerticalDragCancel: _cancelDrag,
                // 已获胜的纵向手势可能把 PointerCancel 当作 end；先取消排队输入。
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerCancel: (_) => _cancelDrag(),
                  child: Center(
                    child: Container(
                      width: WenyouReadingQuickScrollContract.backingWidth,
                      height: WenyouReadingQuickScrollContract.backingHeight,
                      decoration: BoxDecoration(
                        color: tokens.panel.withValues(
                          alpha:
                              WenyouReadingQuickScrollContract.backingOpacity,
                        ),
                        borderRadius: corner,
                        border: _focus.hasFocus
                            ? Border.all(color: tokens.focus)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: WenyouReadingQuickScrollContract.thumbWidth,
                        height: WenyouReadingQuickScrollContract.thumbHeight,
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
      if (panel != null && leftSpace > 0)
        Positioned(
          top: top,
          bottom: size.height - bottom,
          left: gap,
          right: right + target + WenyouReadingQuickScrollContract.labelGap,
          child: CustomSingleChildLayout(
            delegate: _QuickScrollPanelLayout(thumbTop + target / 2 - top),
            child: _cardOpen
                ? TapRegion(
                    groupId: _tapGroup,
                    onTapOutside: (_) => _dismissCard(),
                    child: panel,
                  )
                : IgnorePointer(child: panel),
          ),
        ),
    ];
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    _focus.dispose();
    super.dispose();
  }
}

/// 先测量卡片，再贴近手指并限制在正文内；空白部分不参与命中。
class _QuickScrollPanelLayout extends SingleChildLayoutDelegate {
  const _QuickScrollPanelLayout(this.anchorY);
  final double anchorY;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen().copyWith(
        maxWidth: math.min(
          constraints.maxWidth,
          WenyouReadingQuickScrollContract.cardMaxWidth,
        ),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) => Offset(
    size.width - childSize.width,
    (anchorY - childSize.height / 2).clamp(
      0,
      math.max(0, size.height - childSize.height),
    ),
  );

  @override
  bool shouldRelayout(covariant _QuickScrollPanelLayout oldDelegate) =>
      anchorY != oldDelegate.anchorY;
}
