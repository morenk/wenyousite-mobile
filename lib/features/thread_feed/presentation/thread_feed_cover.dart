import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_playback_coordinator.dart';
import 'package:wenyousite_mobile/features/thread_feed/domain/thread_feed_models.dart';
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
    this.hasVerifiedDisplay = false,
    this.animationLoader = loadCoverAnimation,
    this.previewVariants = const [],
    this.posterBuilder,
    this.onFirstFrameDecoded,
    this.onFirstFramePainted,
    super.key,
  });

  final String? posterUrl;
  final String? animationUrl;
  final bool hasVerifiedDisplay;
  final CoverAnimationLoader animationLoader;
  final List<ThreadFeedCoverPreviewVariant> previewVariants;
  final CoverPosterBuilder? posterBuilder;
  final VoidCallback? onFirstFrameDecoded;
  final VoidCallback? onFirstFramePainted;

  @override
  State<ThreadFeedCover> createState() => _ThreadFeedCoverState();
}

class _ThreadFeedCoverState extends State<ThreadFeedCover> {
  final _token = Object();
  final _phase = ValueNotifier(CoverPlaybackPhase.idle);
  final _boundsKey = GlobalKey();
  final _routeAnimations = <Animation<double>>{};
  CoverPlaybackCoordinator? _coordinator;
  bool _enabled = false;
  bool _posterReady = false;
  bool get _canPrepare => widget.hasVerifiedDisplay || _posterReady;
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
    _updateRouteSubscriptions();
    if (!_enabled) _phase.value = CoverPlaybackPhase.idle;
    _registerAfterLayout();
  }

  void _updateRouteSubscriptions() {
    final animations = <Animation<double>>{};
    var routeContext = context;
    final seen = <NavigatorState>{};
    while (true) {
      final route = ModalRoute.of(routeContext);
      final animation = route?.animation;
      final secondary = route?.secondaryAnimation;
      if (animation != null) animations.add(animation);
      if (secondary != null) animations.add(secondary);
      final navigator = Navigator.maybeOf(routeContext);
      if (navigator == null || !seen.add(navigator)) break;
      routeContext = navigator.context;
    }
    for (final animation in _routeAnimations.difference(animations)) {
      animation.removeStatusListener(_routeStatusChanged);
    }
    for (final animation in animations.difference(_routeAnimations)) {
      animation.addStatusListener(_routeStatusChanged);
    }
    _routeAnimations
      ..clear()
      ..addAll(animations);
  }

  void _routeStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      _phase.value = CoverPlaybackPhase.idle;
      _coordinator?.unregister(_token);
    }
    // 包括父 Navigator 的转场；完成后按最终布局重测，无需用户再滚动唤醒。
    _registerAfterLayout();
  }

  @override
  void didUpdateWidget(covariant ThreadFeedCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.posterUrl != widget.posterUrl ||
        oldWidget.animationUrl != widget.animationUrl ||
        oldWidget.hasVerifiedDisplay != widget.hasVerifiedDisplay) {
      _phase.value = CoverPlaybackPhase.idle;
      _posterReady = false;
      _posterGeneration++;
      _coordinator?.unregister(_token);
      _registerAfterLayout();
    }
  }

  void _registerAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_enabled && _canPrepare && widget.animationUrl != null) {
        _coordinator?.register(_token, _measure);
      } else {
        _coordinator?.unregister(_token);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _selectionChanged() {
    _phase.value = !_enabled || !_canPrepare
        ? CoverPlaybackPhase.idle
        : _coordinator?.isActive(_token) == true
        ? CoverPlaybackPhase.playing
        : CoverPlaybackPhase.idle;
  }

  void _posterLoaded(int generation) {
    if (!mounted || generation != _posterGeneration || _posterReady) return;
    _posterReady = true;
    _registerAfterLayout();
  }

  void _posterFailed(int generation) {
    if (!mounted || generation != _posterGeneration) return;
    _posterGeneration++;
    _posterReady = false;
    if (widget.hasVerifiedDisplay) return;
    _phase.value = CoverPlaybackPhase.idle;
    _coordinator?.unregister(_token);
  }

  CoverPlaybackGeometry? _measure() {
    if (!mounted || !_enabled || !_canPrepare) return null;
    // 嵌套 Navigator 的本页可能仍 current，父 Navigator 已被详情/弹窗覆盖。
    var routeContext = context;
    final seen = <NavigatorState>{};
    while (true) {
      final route = ModalRoute.of(routeContext);
      if (route != null &&
          (!route.isCurrent ||
              (route.animation != null &&
                  route.animation!.status != AnimationStatus.completed) ||
              (route.secondaryAnimation != null &&
                  route.secondaryAnimation!.status !=
                      AnimationStatus.dismissed))) {
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
        child:
            widget.animationUrl == null ||
                (!widget.hasVerifiedDisplay && widget.posterUrl == null)
            ? poster
            : LayoutBuilder(
                builder: (context, constraints) {
                  // 局部约束变化也要在布局后重测，不撤销仍可见的邻卡。
                  _coordinator?.remeasure();
                  final ratio = MediaQuery.devicePixelRatioOf(context);
                  final url = selectThreadCoverAnimation(
                    variants: widget.previewVariants,
                    originalUrl: widget.animationUrl,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    devicePixelRatio: ratio,
                  );
                  return ControlledCoverAnimation(
                    enableRetry: widget.hasVerifiedDisplay,
                    url: url!,
                    decodeWidth: (constraints.maxWidth * ratio).round().clamp(
                      1,
                      1080,
                    ),
                    playing: false,
                    phase: _phase,
                    source: _coordinator?.source,
                    poster: poster,
                    loader: widget.animationLoader,
                    onFirstFrameDecoded: widget.onFirstFrameDecoded,
                    onFirstFramePainted: widget.onFirstFramePainted,
                  );
                },
              ),
      ),
    );
  }

  void _detach() {
    _phase.value = CoverPlaybackPhase.idle;
    _coordinator?.removeListener(_selectionChanged);
    _coordinator?.unregister(_token);
  }

  @override
  void dispose() {
    for (final animation in _routeAnimations) {
      animation.removeStatusListener(_routeStatusChanged);
    }
    _detach();
    _phase.dispose();
    super.dispose();
  }
}
