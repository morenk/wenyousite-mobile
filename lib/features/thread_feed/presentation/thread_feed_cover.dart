import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_playback_coordinator.dart';
import 'package:wenyousite_mobile/features/thread_feed/presentation/controlled_cover_animation.dart';
import 'package:wenyousite_mobile/features/thread_feed/presentation/cover_playback_scope.dart';

typedef CoverPosterBuilder =
    Widget Function(
      BuildContext context,
      String url,
      VoidCallback onReady,
      VoidCallback onError,
    );

class ThreadFeedCover extends StatefulWidget {
  const ThreadFeedCover({
    this.posterUrl,
    this.animationUrl,
    this.animationLoader = loadCoverAnimation,
    this.posterBuilder,
    super.key,
  });

  final String? posterUrl;
  final String? animationUrl;
  final CoverAnimationLoader animationLoader;
  final CoverPosterBuilder? posterBuilder;

  @override
  State<ThreadFeedCover> createState() => _ThreadFeedCoverState();
}

class _ThreadFeedCoverState extends State<ThreadFeedCover> {
  final _token = Object();
  final _lease = ValueNotifier(false);
  final _boundsKey = GlobalKey();
  CoverPlaybackCoordinator? _coordinator;
  bool _enabled = false;
  bool _posterReady = false;
  int _posterGeneration = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final coordinator = CoverPlaybackScope.maybeOf(context);
    if (coordinator != _coordinator) {
      _detach();
      _coordinator = coordinator;
      _coordinator?.addListener(_selectionChanged);
    }
    // 订阅路由和 IndexedStack 的可见性；TickerMode 只提供资格，不用于停止解码。
    _enabled =
        TickerMode.valuesOf(context).enabled &&
        ModalRoute.isCurrentOf(context) != false &&
        !MediaQuery.disableAnimationsOf(context);
    if (!_enabled) _lease.value = false;
    _registerAfterLayout();
  }

  @override
  void didUpdateWidget(covariant ThreadFeedCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.posterUrl != widget.posterUrl ||
        oldWidget.animationUrl != widget.animationUrl) {
      _lease.value = false;
      _posterReady = false;
      _posterGeneration++;
      _coordinator?.unregister(_token);
      _registerAfterLayout();
    }
  }

  void _registerAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_enabled &&
          _posterReady &&
          widget.posterUrl != null &&
          widget.animationUrl != null) {
        _coordinator?.register(_token, _measure);
      } else {
        _coordinator?.unregister(_token);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _selectionChanged() => _lease.value =
      _enabled && _posterReady && _coordinator?.selected == _token;

  void _posterLoaded(int generation) {
    if (!mounted || generation != _posterGeneration || _posterReady) return;
    _posterReady = true;
    _registerAfterLayout();
  }

  void _posterFailed(int generation) {
    if (!mounted || generation != _posterGeneration) return;
    _posterGeneration++;
    _posterReady = false;
    _lease.value = false;
    _coordinator?.unregister(_token);
  }

  CoverPlaybackGeometry? _measure() {
    if (!mounted || !_enabled || !_posterReady) return null;
    // 嵌套 Navigator 的本页可能仍 current，父 Navigator 已被详情/弹窗覆盖。
    var routeContext = context;
    final seen = <NavigatorState>{};
    while (true) {
      final route = ModalRoute.of(routeContext);
      if (route != null &&
          (!route.isCurrent ||
              (route.animation != null &&
                  route.animation!.status != AnimationStatus.completed))) {
        return null;
      }
      final navigator = Navigator.maybeOf(routeContext);
      if (navigator == null || !seen.add(navigator)) break;
      routeContext = navigator.context;
    }
    final box = _boundsKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    final media = MediaQuery.of(context);
    var viewport = Rect.fromLTRB(
      media.padding.left,
      media.padding.top,
      media.size.width - media.padding.right,
      media.size.height - media.padding.bottom - media.viewInsets.bottom,
    );
    var visibleBounds = viewport;
    RenderObject child = box;
    RenderObject? ancestor = box.parent;
    while (ancestor != null) {
      if (ancestor is RenderOffstage && ancestor.offstage) return null;
      if (ancestor is RenderAbstractViewport && ancestor is RenderBox) {
        final viewportBox = ancestor as RenderBox;
        viewport = viewport.intersect(
          viewportBox.localToGlobal(Offset.zero) & viewportBox.size,
        );
      }
      final clip = ancestor.describeApproximatePaintClip(child);
      if (clip != null) {
        visibleBounds = visibleBounds.intersect(
          MatrixUtils.transformRect(ancestor.getTransformTo(null), clip),
        );
      }
      child = ancestor;
      ancestor = ancestor.parent;
    }
    return CoverPlaybackGeometry(
      cover: box.localToGlobal(Offset.zero) & box.size,
      viewport: viewport,
      visibleBounds: visibleBounds.intersect(viewport),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final posterGeneration = _posterGeneration;
    final placeholder = ColoredBox(
      color: tokens.softPanel,
      child: Center(
        child: WenyouIcon(WenyouIconIds.actionImage, color: tokens.mutedText),
      ),
    );
    final poster = widget.posterUrl == null
        ? placeholder
        : widget.posterBuilder?.call(
                context,
                widget.posterUrl!,
                () => _posterLoaded(posterGeneration),
                () => _posterFailed(posterGeneration),
              ) ??
              WenyouCachedImage(
                key: ValueKey('${widget.posterUrl}|${widget.animationUrl}'),
                imageUrl: widget.posterUrl!,
                fit: BoxFit.cover,
                cacheWidth: 540,
                placeholder: (_, _) => placeholder,
                onImageReady: () => _posterLoaded(posterGeneration),
                errorWidget: (_, _, _) {
                  _posterFailed(posterGeneration);
                  return placeholder;
                },
              );
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius12),
      child: AspectRatio(
        key: _boundsKey,
        aspectRatio: 16 / 9,
        child: widget.animationUrl == null || widget.posterUrl == null
            ? poster
            : ControlledCoverAnimation(
                url: widget.animationUrl!,
                playing: false,
                lease: _lease,
                byteCache: _coordinator?.byteCache,
                poster: poster,
                loader: widget.animationLoader,
              ),
      ),
    );
  }

  void _detach() {
    _lease.value = false;
    _coordinator?.removeListener(_selectionChanged);
    _coordinator?.unregister(_token);
  }

  @override
  void dispose() {
    _detach();
    _lease.dispose();
    super.dispose();
  }
}
