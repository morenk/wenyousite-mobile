import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/media/media_display.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';

@immutable
class WenyouImageViewerItem {
  const WenyouImageViewerItem({
    required this.url,
    required this.semanticLabel,
    this.fallbackUrls = const [],
    this.id,
    this.display,
  });

  final String url;
  final List<String> fallbackUrls;
  final String semanticLabel;
  final Object? id;
  final MediaDisplay? display;

  List<String> get displayUrls => selectFullMediaUrls(
    sourceUrl: url,
    display: display,
    legacyUrls: [url, ...fallbackUrls],
  );
}

class WenyouImageViewerPage extends StatefulWidget {
  const WenyouImageViewerPage({
    required this.items,
    this.initialIndex = 0,
    this.titleBuilder,
    this.actions = const [],
    this.bottomOverlay,
    this.viewerKey,
    this.closeKey,
    this.closeTooltip = '关闭图片预览',
    this.errorLabel = '图片加载失败',
    this.onPageChanged,
    this.imageBuilder,
    super.key,
  }) : assert(items.length > 0),
       assert(initialIndex >= 0 && initialIndex < items.length);

  final List<WenyouImageViewerItem> items;
  final int initialIndex;
  final String Function(int index, int count)? titleBuilder;
  final List<Widget> actions;
  final Widget? bottomOverlay;
  final Key? viewerKey;
  final Key? closeKey;
  final String closeTooltip;
  final String errorLabel;
  final ValueChanged<int>? onPageChanged;
  final Widget? Function(BuildContext context, int index, bool current)?
  imageBuilder;

  @override
  State<WenyouImageViewerPage> createState() => _WenyouImageViewerPageState();
}

class _WenyouImageViewerPageState extends State<WenyouImageViewerPage> {
  late PageController _pageController;
  late int _index;
  var _zoomed = false;
  final _pointers = <int>{};
  Offset? _pointerStart;
  Offset? _pointerEnd;
  var _multiplePointers = false;
  var _startedZoomed = false;
  var _gestureStartIndex = 0;

  void _pointerDown(PointerDownEvent event) {
    if (_pointers.isEmpty) {
      _pointerStart = event.position;
      _pointerEnd = event.position;
      _multiplePointers = false;
      _startedZoomed = _zoomed;
      _gestureStartIndex = _index;
    }
    _pointers.add(event.pointer);
    if (_pointers.length > 1) {
      _multiplePointers = true;
      _pageController.jumpToPage(_gestureStartIndex);
    }
  }

  void _pointerMove(PointerMoveEvent event) {
    _pointerEnd = event.position;
    if (_multiplePointers ||
        _startedZoomed ||
        _zoomed ||
        !_pageController.hasClients) {
      return;
    }
    final delta = event.position - _pointerStart!;
    if (delta.dx.abs() < 10 || delta.dx.abs() < delta.dy.abs()) return;
    final width = _pageController.position.viewportDimension;
    _pageController.jumpTo(
      (_gestureStartIndex * width - delta.dx).clamp(
        ((_gestureStartIndex - 1).clamp(0, widget.items.length - 1)) * width,
        ((_gestureStartIndex + 1).clamp(0, widget.items.length - 1)) * width,
      ),
    );
  }

  void _pointerUp(PointerUpEvent event) {
    _pointers.remove(event.pointer);
    if (_pointers.isNotEmpty) return;
    final delta =
        (_pointerEnd ?? event.position) - (_pointerStart ?? event.position);
    if (_multiplePointers || _startedZoomed || _zoomed) return;
    // 翻页和关闭共用一次完整触摸序列；捏合松开一指不能变成导航。
    if (delta.dx.abs() > 60 && delta.dx.abs() > delta.dy.abs()) {
      final next = (_gestureStartIndex + (delta.dx < 0 ? 1 : -1)).clamp(
        0,
        widget.items.length - 1,
      );
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
      _pageChanged(next);
    } else if (delta.dy > 80 && delta.dy > delta.dx.abs()) {
      Navigator.maybePop(context);
    } else {
      _pageController.animateToPage(
        _gestureStartIndex,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }
  }

  void _pageChanged(int index) {
    if (_index == index) return;
    setState(() {
      _index = index;
      _zoomed = false;
    });
    widget.onPageChanged?.call(index);
    _prefetchNeighbors();
  }

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WenyouImageViewerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final id = oldWidget.items[_index].id;
    final next = id == null
        ? _index.clamp(0, widget.items.length - 1)
        : widget.items.indexWhere((item) => item.id == id);
    final target = next >= 0 ? next : widget.initialIndex;
    if (target != _index) {
      final oldController = _pageController;
      _pageController = PageController(initialPage: target);
      _index = target;
      if (_pointers.isNotEmpty) {
        _multiplePointers = true;
        _gestureStartIndex = target;
      }
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => oldController.dispose(),
      );
    }
    _prefetchNeighbors();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefetchNeighbors();
  }

  void _prefetchNeighbors() {
    for (final index in [_index - 1, _index + 1]) {
      if (index >= 0 && index < widget.items.length) {
        precacheImage(
          CachedNetworkImageProvider(widget.items[index].displayUrls.first),
          context,
          onError: (Object error, StackTrace? stack) {},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final title =
        widget.titleBuilder?.call(_index, widget.items.length) ??
        '${_index + 1} / ${widget.items.length}';
    return Scaffold(
      key: widget.viewerKey,
      backgroundColor: tokens.imageViewerBackground,
      appBar: AppBar(
        backgroundColor: tokens.imageViewerBackground,
        foregroundColor: tokens.onImageViewerBackground,
        title: Text(title),
        leading: IconButton(
          key: widget.closeKey,
          onPressed: () => Navigator.maybePop(context),
          tooltip: widget.closeTooltip,
          icon: const WenyouIcon(WenyouIconIds.actionClose),
        ),
        actions: widget.actions,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Listener(
              onPointerDown: _pointerDown,
              onPointerMove: _pointerMove,
              onPointerUp: _pointerUp,
              onPointerCancel: (event) {
                _pointers.remove(event.pointer);
                _multiplePointers = true;
                _pageController.jumpToPage(_index);
              },
              child: PageView.custom(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  if (_pointers.isEmpty) _pageChanged(index);
                },
                childrenDelegate: SliverChildBuilderDelegate(
                  (context, index) => _ZoomableViewerImage(
                    key: ValueKey(widget.items[index].id ?? index),
                    item: widget.items[index],
                    current: index == _index,
                    image: widget.imageBuilder?.call(
                      context,
                      index,
                      index == _index,
                    ),
                    errorLabel: widget.errorLabel,
                    onZoomChanged: (zoomed) {
                      if (mounted && index == _index && _zoomed != zoomed) {
                        setState(() => _zoomed = zoomed);
                      }
                    },
                  ),
                  childCount: widget.items.length,
                  findChildIndexCallback: (key) {
                    if (key is! ValueKey) return null;
                    final index = widget.items.indexWhere(
                      (item) => item.id == key.value,
                    );
                    return index < 0 ? null : index;
                  },
                ),
              ),
            ),
          ),
          if (widget.bottomOverlay case final overlay?)
            Positioned(
              right: tokens.space16,
              bottom: tokens.space16,
              left: tokens.space16,
              child: SafeArea(top: false, child: overlay),
            ),
        ],
      ),
    );
  }
}

class _ZoomableViewerImage extends StatefulWidget {
  const _ZoomableViewerImage({
    required this.item,
    required this.errorLabel,
    required this.onZoomChanged,
    required this.current,
    this.image,
    super.key,
  });

  final WenyouImageViewerItem item;
  final Widget? image;
  final String errorLabel;
  final ValueChanged<bool> onZoomChanged;
  final bool current;

  @override
  State<_ZoomableViewerImage> createState() => _ZoomableViewerImageState();
}

class _ZoomableViewerImageState extends State<_ZoomableViewerImage> {
  final _transformationController = TransformationController();
  Offset _doubleTapPosition = Offset.zero;

  @override
  void didUpdateWidget(covariant _ZoomableViewerImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current) {
      _transformationController.value = Matrix4.identity();
    }
  }

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_reportZoom);
  }

  @override
  void dispose() {
    _transformationController
      ..removeListener(_reportZoom)
      ..dispose();
    super.dispose();
  }

  void _reportZoom() {
    widget.onZoomChanged(
      _transformationController.value.getMaxScaleOnAxis() > 1.01,
    );
  }

  void _toggleZoom() {
    final zoomed = _transformationController.value.getMaxScaleOnAxis() > 1.01;
    _transformationController.value = zoomed
        ? Matrix4.identity()
        : (Matrix4.identity()
            ..setEntry(0, 0, 2)
            ..setEntry(1, 1, 2)
            ..setEntry(0, 3, -_doubleTapPosition.dx)
            ..setEntry(1, 3, -_doubleTapPosition.dy));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return GestureDetector(
      onDoubleTap: _toggleZoom,
      onDoubleTapDown: (details) => _doubleTapPosition = details.localPosition,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1,
        maxScale: 5,
        child: TickerMode(
          enabled: widget.current,
          child: Center(
            child: Semantics(
              image: true,
              label: widget.item.semanticLabel,
              child:
                  widget.image ??
                  WenyouCachedImage(
                    enableRetry: true,
                    imageUrl: widget.item.displayUrls.first,
                    fallbackImageUrls: widget.item.displayUrls
                        .skip(1)
                        .toList(growable: false),
                    fit: BoxFit.contain,
                    placeholder: (_, _) => Center(
                      child: WenyouIcon(
                        WenyouIconIds.actionImage,
                        color: tokens.onImageViewerBackground.withValues(
                          alpha: 0.7,
                        ),
                        size: 40,
                      ),
                    ),
                    errorWidget: (_, _, _) => Padding(
                      padding: EdgeInsets.all(tokens.space24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          WenyouIcon(
                            WenyouIconIds.statusImageUnavailable,
                            color: tokens.onImageViewerBackground.withValues(
                              alpha: 0.7,
                            ),
                            size: 48,
                          ),
                          SizedBox(height: tokens.space8),
                          Text(
                            widget.errorLabel,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.wenyouBody
                                .copyWith(
                                  color: tokens.onImageViewerBackground,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
