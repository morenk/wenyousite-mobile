import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/animation/wenyou_motion.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_target_loading.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_target_visibility.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_scroll_policy.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

/// Keeps the real paged list laid out behind an opaque reading surface until
/// the requested row has reached its final visible position.
class DiscussionTargetCover extends StatefulWidget {
  const DiscussionTargetCover({
    required this.scope,
    required this.targetId,
    required this.loadingLabel,
    required this.revealedLabel,
    required this.child,
    required this.targetKey,
    required this.itemListKey,
    required this.scrollController,
    required this.targetIndex,
    required this.itemCount,
    required this.canLocate,
    required this.isLoadingPage,
    required this.hasMore,
    required this.onLoadMore,
    required this.onRetry,
    required this.onBack,
    this.navigationRevision = 0,
    this.issue,
    this.onRevealed,
    this.onCovered,
    super.key,
  });

  final Object scope;
  final String targetId;
  final String loadingLabel;
  final String revealedLabel;
  final Widget child;
  final GlobalKey targetKey;
  final GlobalKey itemListKey;
  final ScrollController scrollController;
  final int targetIndex;
  final int itemCount;
  final bool canLocate;
  final bool isLoadingPage;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final int navigationRevision;
  final Widget? issue;
  final VoidCallback? onRevealed;
  final VoidCallback? onCovered;

  @override
  State<DiscussionTargetCover> createState() => _DiscussionTargetCoverState();
}

class _DiscussionTargetCoverState extends State<DiscussionTargetCover>
    with SingleTickerProviderStateMixin {
  static const _settleDuration = Duration(milliseconds: 180);
  static const _slowDuration = Duration(seconds: 5);

  final _reveal = DiscussionTargetRevealCoordinator();
  final _pageScheduler = DiscussionPrefetchScheduler();
  late final _transition = AnimationController(
    vsync: this,
    duration: WenyouFoundationMotion.standard,
  );
  late final _coverOpacity = _transition
      .drive(CurveTween(curve: wenyouStandardMotionCurve))
      .drive(Tween<double>(begin: 1, end: 0));
  Timer? _settleTimer;
  Timer? _slowTimer;
  Rect? _alignedRect;
  var _revealed = false;
  var _revealing = false;
  var _transitionAttempt = 0;
  var _slow = false;

  @override
  void initState() {
    super.initState();
    _startSlowTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_revealing && wenyouAnimationsDisabled(context)) {
      _transition.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant DiscussionTargetCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changedTarget =
        oldWidget.scope != widget.scope ||
        oldWidget.targetId != widget.targetId;
    if (changedTarget ||
        (oldWidget.canLocate && !widget.canLocate) ||
        (oldWidget.targetIndex >= 0 && widget.targetIndex < 0) ||
        (oldWidget.issue == null && widget.issue != null)) {
      _conceal(restartSlowTimer: changedTarget);
    }
    if (oldWidget.navigationRevision != widget.navigationRevision) {
      _reveal.releaseForUserNavigation();
    }
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    _slowTimer?.cancel();
    _transition.dispose();
    super.dispose();
  }

  void _cancelTransition() {
    _transitionAttempt++;
    _revealing = false;
    _transition.reset();
  }

  void _conceal({required bool restartSlowTimer}) {
    final wasRevealed = _revealed;
    _revealed = false;
    _cancelTransition();
    _alignedRect = null;
    _reveal.reset();
    _settleTimer?.cancel();
    if (restartSlowTimer) {
      _slow = false;
      _startSlowTimer();
    }
    if (wasRevealed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onCovered?.call();
      });
    }
  }

  void _startSlowTimer() {
    _slowTimer?.cancel();
    _slowTimer = Timer(_slowDuration, () {
      if (mounted && !_revealed) setState(() => _slow = true);
    });
  }

  Rect? _targetRect() {
    final render = widget.targetKey.currentContext?.findRenderObject();
    if (render is! RenderBox || !render.attached || !render.hasSize) {
      return null;
    }
    return render.localToGlobal(Offset.zero) & render.size;
  }

  void _onAligned() {
    if (!mounted || !widget.canLocate || widget.issue != null) return;
    // 揭开途中几何再次变化时，立即恢复不透明遮罩并重新等待稳定。
    if (_revealing) setState(_cancelTransition);
    _alignedRect = _targetRect();
    _settleTimer?.cancel();
    _settleTimer = Timer(_settleDuration, _finishIfStable);
  }

  void _finishIfStable() {
    if (!mounted || !widget.canLocate || widget.issue != null) return;
    final previous = _alignedRect;
    final current = _targetRect();
    if (previous == null ||
        current == null ||
        (previous.top - current.top).abs() > 1 ||
        (previous.left - current.left).abs() > 1 ||
        (previous.width - current.width).abs() > 1 ||
        (previous.height - current.height).abs() > 1) {
      final targetContext = widget.targetKey.currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          duration: Duration.zero,
          alignment: 0,
        );
      } else {
        _reveal.handleLayoutChange(
          isMounted: () => mounted,
          requestRebuild: () => setState(() {}),
        );
      }
      _alignedRect = _targetRect();
      _settleTimer = Timer(_settleDuration, _finishIfStable);
      return;
    }
    if (_revealed || _revealing) return;
    final attempt = ++_transitionAttempt;
    if (wenyouAnimationsDisabled(context)) {
      _completeReveal(attempt);
      return;
    }
    setState(() => _revealing = true);
    _transition
        .forward(from: 0)
        .whenCompleteOrCancel(() => _completeReveal(attempt));
  }

  void _completeReveal(int attempt) {
    if (!mounted || attempt != _transitionAttempt || _revealed) return;
    _slowTimer?.cancel();
    _revealing = false;
    setState(() => _revealed = true);
    widget.onRevealed?.call();
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        widget.revealedLabel,
        Directionality.of(context),
      ),
    );
  }

  bool _onScroll(ScrollNotification notification) {
    _reveal.handleUserScroll(notification);
    return false;
  }

  bool _onMetrics(ScrollMetricsNotification notification) {
    _reveal.handleLayoutChange(
      isMounted: () => mounted,
      requestRebuild: () => setState(() {}),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final canSeek = widget.canLocate && widget.issue == null;
    if (canSeek && widget.targetIndex >= 0) {
      _reveal.schedule(
        targetId: widget.targetId,
        scopeSignature: widget.scope.toString(),
        contentSignature:
            '${widget.scope}:${widget.targetIndex}:${widget.itemCount}',
        targetIndex: widget.targetIndex,
        itemCount: widget.itemCount,
        ready: true,
        targetKey: widget.targetKey,
        itemListKey: widget.itemListKey,
        scrollController: widget.scrollController,
        isMounted: () => mounted,
        requestRebuild: () => setState(() {}),
        onAligned: _onAligned,
      );
    } else {
      _pageScheduler.schedule(
        shouldPrefetch:
            canSeek &&
            widget.targetIndex < 0 &&
            widget.hasMore &&
            !widget.isLoadingPage,
        isMounted: () => mounted,
        prefetch: widget.onLoadMore,
      );
    }
    final exhausted =
        canSeek &&
        widget.targetIndex < 0 &&
        !widget.hasMore &&
        !widget.isLoadingPage;
    final tokens = context.wenyouTokens;
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          excluding: !_revealed,
          child: ExcludeFocus(
            excluding: !_revealed,
            child: IgnorePointer(
              ignoring: !_revealed,
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: NotificationListener<ScrollMetricsNotification>(
                  onNotification: _onMetrics,
                  child: DiscussionTargetVisibility(
                    visible: _revealed,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!_revealed)
          Positioned.fill(
            child: FadeTransition(
              key: const Key('discussion-target-transition'),
              opacity: _coverOpacity,
              child: AbsorbPointer(
                absorbing: _revealing,
                child: ColoredBox(
                  key: const Key('discussion-target-cover'),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: WenyouContentFrame(
                        top: tokens.space16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.issue case final issue?)
                              issue
                            else if (exhausted)
                              WenyouStatusBanner(
                                message: '目标内容已不可见',
                                action: TextButton(
                                  key: const Key('discussion-target-retry'),
                                  onPressed: widget.onRetry,
                                  child: const Text('重新确认'),
                                ),
                              )
                            else
                              DiscussionTargetLoading(
                                label: widget.loadingLabel,
                                slow: _slow,
                              ),
                            if (_slow || widget.issue != null || exhausted) ...[
                              SizedBox(height: tokens.space16),
                              TextButton(
                                key: const Key('discussion-target-return'),
                                onPressed: widget.onBack,
                                child: const Text('返回'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
