import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';

@immutable
class WenyouImageViewerItem {
  const WenyouImageViewerItem({
    required this.url,
    required this.semanticLabel,
    this.fallbackUrls = const [],
    this.id,
  });

  final String url;
  final List<String> fallbackUrls;
  final String semanticLabel;
  final Object? id;
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
    this.errorLabel = '原图加载失败，请检查网络后返回重试',
    this.onPageChanged,
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

  @override
  State<WenyouImageViewerPage> createState() => _WenyouImageViewerPageState();
}

class _WenyouImageViewerPageState extends State<WenyouImageViewerPage> {
  late final PageController _pageController;
  late int _index;
  var _dragDistance = 0.0;
  var _zoomed = false;

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
            child: GestureDetector(
              onVerticalDragUpdate: _zoomed
                  ? null
                  : (details) => _dragDistance += details.delta.dy,
              onVerticalDragEnd: _zoomed
                  ? null
                  : (_) {
                      if (_dragDistance > 80) Navigator.maybePop(context);
                      _dragDistance = 0;
                    },
              child: PageView.builder(
                controller: _pageController,
                physics: _zoomed ? const NeverScrollableScrollPhysics() : null,
                onPageChanged: (index) {
                  setState(() {
                    _index = index;
                    _zoomed = false;
                  });
                  widget.onPageChanged?.call(index);
                },
                itemCount: widget.items.length,
                itemBuilder: (context, index) => _ZoomableViewerImage(
                  key: ValueKey(widget.items[index].id ?? index),
                  item: widget.items[index],
                  errorLabel: widget.errorLabel,
                  onZoomChanged: (zoomed) {
                    if (mounted && _zoomed != zoomed) {
                      setState(() => _zoomed = zoomed);
                    }
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
    super.key,
  });

  final WenyouImageViewerItem item;
  final String errorLabel;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_ZoomableViewerImage> createState() => _ZoomableViewerImageState();
}

class _ZoomableViewerImageState extends State<_ZoomableViewerImage> {
  final _transformationController = TransformationController();

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
        : Matrix4.diagonal3Values(2, 2, 1);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return GestureDetector(
      onDoubleTap: _toggleZoom,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1,
        maxScale: 5,
        child: Center(
          child: Semantics(
            image: true,
            label: widget.item.semanticLabel,
            child: WenyouCachedImage(
              imageUrl: widget.item.url,
              fallbackImageUrls: widget.item.fallbackUrls,
              fit: BoxFit.contain,
              placeholder: (_, _) => Center(
                child: WenyouIcon(
                  WenyouIconIds.actionImage,
                  color: tokens.onImageViewerBackground.withValues(alpha: 0.7),
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
                      style: TextStyle(color: tokens.onImageViewerBackground),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
