import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/animation/wenyou_motion.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_reorder_feedback.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

/// 固定格点负责命中，稳定的收藏 Key 负责让位；命中不跟随动画中的图片。
class StickerReorderGrid extends StatefulWidget {
  const StickerReorderGrid({
    required this.items,
    required this.scrollController,
    required this.viewportKey,
    required this.addButton,
    required this.onReorder,
    required this.onRemove,
    required this.onDragChanged,
    this.enabled = true,
    this.managing = false,
    this.canRemove = true,
    this.resetSignal,
    super.key,
  });

  final List<UserSticker> items;
  final ScrollController scrollController;
  final GlobalKey viewportKey;
  final Widget addButton;
  final ValueChanged<List<UserSticker>> onReorder;
  final ValueChanged<UserSticker> onRemove;
  final ValueChanged<bool> onDragChanged;
  final bool enabled;
  final bool managing;
  final bool canRemove;
  final Object? resetSignal;

  @override
  State<StickerReorderGrid> createState() => _StickerReorderGridState();
}

class _StickerReorderGridState extends State<StickerReorderGrid>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _gridKey = GlobalKey();
  final _images = <String, StickerGridImage>{};
  late final Ticker _scrollTicker;
  late List<UserSticker> _order = [...widget.items];
  String? _dragging;
  String? _settling;
  Offset _pointer = Offset.zero;
  Offset _grab = Offset.zero;
  Offset _dragPosition = Offset.zero;
  Duration _lastTick = Duration.zero;
  double _size = 0;
  double _gap = 0;
  int _columns = 4;
  bool _rtl = false;

  @override
  void initState() {
    super.initState();
    _scrollTicker = createTicker(_autoScroll);
    WidgetsBinding.instance.addObserver(this);
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(StickerReorderGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ids = widget.items.map((item) => item.id).toSet();
    _images.removeWhere((id, _) => !ids.contains(id));
    final sameMembers = setEquals(
      widget.items.map((item) => item.id).toSet(),
      _order.map((item) => item.id).toSet(),
    );
    if (!sameMembers ||
        !widget.enabled ||
        oldWidget.resetSignal != widget.resetSignal) {
      final wasDragging = _dragging != null;
      _stop();
      _order = [...widget.items];
      if (wasDragging) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onDragChanged(false);
        });
      }
    } else if (_dragging == null) {
      _order = [...widget.items];
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _cancel();
  }

  @override
  void didChangeMetrics() => _cancel();

  RenderBox? get _grid =>
      _gridKey.currentContext?.findRenderObject() as RenderBox?;
  RenderBox? get _viewport =>
      widget.viewportKey.currentContext?.findRenderObject() as RenderBox?;

  Offset _slot(int index) {
    final column = index % _columns;
    return Offset(
      (_rtl ? _columns - column - 1 : column) * (_size + _gap),
      (index ~/ _columns) * (_size + _gap),
    );
  }

  void _start(UserSticker sticker, LongPressStartDetails details) {
    if (!widget.enabled || _dragging != null || _grid == null) return;
    final index = _order.indexWhere((item) => item.id == sticker.id);
    _pointer = details.globalPosition;
    _dragPosition = _slot(index + 1);
    _grab = _grid!.globalToLocal(_pointer) - _dragPosition;
    setState(() {
      _dragging = sticker.id;
      _settling = null;
    });
    HapticFeedback.selectionClick();
    widget.onDragChanged(true);
    _syncAutoScroll();
  }

  void _move(Offset pointer) {
    if (!mounted || _dragging == null || _grid == null) return;
    _pointer = pointer;
    setState(() {
      _dragPosition = _grid!.globalToLocal(pointer) - _grab;
      final center = _dragPosition + Offset(_size / 2, _size / 2);
      var column = (center.dx / (_size + _gap)).floor().clamp(0, _columns - 1);
      if (_rtl) column = _columns - column - 1;
      final row = (center.dy / (_size + _gap)).floor();
      final slot = row * _columns + column;
      if (slot < 1) return; // 添加入口固定，不参与排序。
      final target = (slot - 1).clamp(0, _order.length - 1);
      final current = _order.indexWhere((item) => item.id == _dragging);
      if (current != target) _order.insert(target, _order.removeAt(current));
    });
    _syncAutoScroll();
  }

  void _syncAutoScroll() {
    final viewport = _viewport;
    if (_dragging == null ||
        viewport == null ||
        !widget.scrollController.hasClients) {
      return;
    }
    final position = widget.scrollController.position;
    final y = viewport.globalToLocal(_pointer).dy;
    final edge = context.wenyouTokens.minimumTouchTarget;
    final shouldScroll =
        (y < edge && position.pixels > position.minScrollExtent) ||
        (y > viewport.size.height - edge &&
            position.pixels < position.maxScrollExtent);
    // 中间停住或已到尽头时不空转帧；手指再次触达可滚动边缘才启动。
    if (shouldScroll && !_scrollTicker.isActive) {
      _lastTick = Duration.zero;
      _scrollTicker.start();
    } else if (!shouldScroll && _scrollTicker.isActive) {
      _scrollTicker.stop();
    }
  }

  void _finish() {
    if (_dragging == null) return;
    final viewport = _viewport;
    if (viewport != null &&
        !(Offset.zero & viewport.size).contains(
          viewport.globalToLocal(_pointer),
        )) {
      _cancel();
      return;
    }
    final ordered = List<UserSticker>.unmodifiable(_order);
    setState(_stop);
    widget.onDragChanged(false);
    if (!listEquals(
      ordered.map((item) => item.id).toList(),
      widget.items.map((item) => item.id).toList(),
    )) {
      widget.onReorder(ordered);
    }
  }

  void _stop() {
    _settling = _dragging ?? _settling;
    _dragging = null;
    _scrollTicker.stop();
  }

  void _cancel() {
    if (!mounted || _dragging == null) return;
    setState(() {
      _stop();
      _order = [...widget.items];
    });
    widget.onDragChanged(false);
  }

  void _onScroll() {
    if (_dragging != null) {
      _move(_pointer);
    } else {
      setState(() {}); // 只在视口附近挂载图片，离屏图片释放。
    }
  }

  void _autoScroll(Duration elapsed) {
    final dt =
        (elapsed - _lastTick).inMicroseconds / Duration.microsecondsPerSecond;
    _lastTick = elapsed;
    if (_dragging == null || !widget.scrollController.hasClients) return;
    final viewport = _viewport;
    if (viewport == null) return;
    final local = viewport.globalToLocal(_pointer);
    final edge = context.wenyouTokens.minimumTouchTarget;
    final double strength;
    if (local.dy < edge) {
      strength = -((edge - local.dy) / edge).clamp(0.0, 1.0);
    } else if (local.dy > viewport.size.height - edge) {
      strength = ((local.dy - viewport.size.height + edge) / edge).clamp(
        0.0,
        1.0,
      );
    } else {
      return;
    }
    final position = widget.scrollController.position;
    final next = (position.pixels + strength * _size * 6 * dt.clamp(0, 0.05))
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if (next != position.pixels) widget.scrollController.jumpTo(next);
  }

  void _moveAccessible(int index, int target) {
    if (!widget.enabled || _dragging != null) return;
    final ordered = [..._order];
    ordered.insert(target, ordered.removeAt(index));
    widget.onReorder(ordered);
  }

  Widget _image(UserSticker sticker) {
    final previous = _images[sticker.id];
    if (previous != null &&
        previous.size == _size &&
        previous.sticker.asset.thumbnailUrl == sticker.asset.thumbnailUrl) {
      return previous;
    }
    // 手势帧只更新坐标；沿用图片 Widget，避免整片图片子树随手指重建。
    return _images[sticker.id] = StickerGridImage(
      sticker: sticker,
      size: _size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final reduced = wenyouAnimationsDisabled(context);
    final duration = reduced ? Duration.zero : WenyouFoundationMotion.standard;
    return LayoutBuilder(
      builder: (context, constraints) {
        _gap = tokens.space8;
        _columns =
            (constraints.maxWidth /
                    (tokens.minimumTouchTarget + tokens.space16))
                .floor()
                .clamp(3, 8);
        _size = (constraints.maxWidth - (_columns - 1) * _gap) / _columns;
        _rtl = Directionality.of(context) == TextDirection.rtl;
        final rows = ((_order.length + 1) / _columns).ceil();
        final height = rows * (_size + _gap) - _gap;
        final scrollOffset = widget.scrollController.hasClients
            ? widget.scrollController.offset
            : 0.0;
        final screenHeight = MediaQuery.sizeOf(context).height;
        // 预留一屏缓冲，拖动中的图片始终保留在最上层。
        final minY = scrollOffset - screenHeight;
        final maxY = scrollOffset + screenHeight + _size * 2;
        final active = _dragging ?? _settling;
        final entries = [
          ..._order.indexed.where((entry) => entry.$2.id != active),
          ..._order.indexed.where((entry) => entry.$2.id == active),
        ];
        return Listener(
          onPointerCancel: (_) => _cancel(),
          child: SizedBox(
            height: height,
            child: Stack(
              key: _gridKey,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: _slot(0).dx,
                  top: 0,
                  width: _size,
                  height: _size,
                  child: widget.addButton,
                ),
                if (_dragging != null)
                  Positioned(
                    left: _slot(
                      _order.indexWhere((item) => item.id == _dragging) + 1,
                    ).dx,
                    top: _slot(
                      _order.indexWhere((item) => item.id == _dragging) + 1,
                    ).dy,
                    width: _size,
                    height: _size,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: tokens.softPanel,
                        borderRadius: BorderRadius.circular(tokens.radius12),
                        border: Border.all(color: tokens.border),
                      ),
                    ),
                  ),
                for (final (index, sticker) in entries)
                  if (sticker.id == active ||
                      (_slot(index + 1).dy >= minY &&
                          _slot(index + 1).dy <= maxY))
                    AnimatedPositioned(
                      key: ValueKey('sticker-position-${sticker.id}'),
                      duration: sticker.id == _dragging
                          ? Duration.zero
                          : duration,
                      curve: wenyouStandardMotionCurve,
                      left: sticker.id == _dragging
                          ? _dragPosition.dx
                          : _slot(index + 1).dx,
                      top: sticker.id == _dragging
                          ? _dragPosition.dy
                          : _slot(index + 1).dy,
                      width: _size,
                      height: _size,
                      child: Semantics(
                        sortKey: OrdinalSortKey(index.toDouble()),
                        label: '表情 ${index + 1}',
                        hint: '长按拖动排序',
                        customSemanticsActions: widget.enabled
                            ? {
                                if (index > 0)
                                  const CustomSemanticsAction(
                                    label: '向前移动',
                                  ): () =>
                                      _moveAccessible(index, index - 1),
                                if (index + 1 < _order.length)
                                  const CustomSemanticsAction(
                                    label: '向后移动',
                                  ): () =>
                                      _moveAccessible(index, index + 1),
                                if (widget.canRemove)
                                  const CustomSemanticsAction(
                                    label: '移除表情',
                                  ): () =>
                                      widget.onRemove(sticker),
                              }
                            : null,
                        child: GestureDetector(
                          key: ValueKey('sticker-drag-${sticker.id}'),
                          behavior: HitTestBehavior.opaque,
                          onLongPressStart: widget.enabled
                              ? (details) => _start(sticker, details)
                              : null,
                          onLongPressMoveUpdate: (details) =>
                              _move(details.globalPosition),
                          onLongPressEnd: (_) => _finish(),
                          child: WenyouReorderFeedback(
                            lifted: sticker.id == _dragging,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(tokens.space4),
                                  child: _image(sticker),
                                ),
                                if (widget.managing && _dragging == null)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      key: ValueKey(
                                        'sticker-remove-${sticker.id}',
                                      ),
                                      tooltip: '移除表情',
                                      onPressed:
                                          widget.enabled && widget.canRemove
                                          ? () => widget.onRemove(sticker)
                                          : null,
                                      icon: WenyouIcon(
                                        WenyouIconIds.actionDelete,
                                        color: tokens.destructive,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.scrollController.removeListener(_onScroll);
    _scrollTicker.dispose();
    super.dispose();
  }
}

class StickerGridImage extends StatelessWidget {
  const StickerGridImage({
    required this.sticker,
    required this.size,
    super.key,
  });

  final UserSticker sticker;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fallback = Center(
      child: WenyouIcon(WenyouIconIds.actionImage, color: tokens.mutedText),
    );
    return WenyouCachedImage(
      imageUrl: sticker.asset.thumbnailUrl,
      fit: BoxFit.contain,
      cacheWidth: size.ceil(),
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}

class StickerGridSkeleton extends StatelessWidget {
  const StickerGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      label: '正在加载表情收藏',
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                (constraints.maxWidth /
                        (tokens.minimumTouchTarget + tokens.space16))
                    .floor()
                    .clamp(3, 8);
            final size =
                (constraints.maxWidth - (columns - 1) * tokens.space8) /
                columns;
            return Wrap(
              spacing: tokens.space8,
              runSpacing: tokens.space8,
              children: [
                for (var i = 0; i < columns * 3; i++)
                  WenyouSkeletonBlock(
                    width: size,
                    height: size,
                    radius: tokens.radius12,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
