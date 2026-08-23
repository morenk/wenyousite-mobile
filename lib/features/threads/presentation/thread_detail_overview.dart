import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_subthread_navigator.dart';

class ThreadDetailOverview extends StatelessWidget {
  const ThreadDetailOverview({required this.detail, super.key});

  final ThreadDetailModel detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('thread-detail-overview'),
      padding: EdgeInsets.symmetric(horizontal: context.wenyouTokens.space4),
      child: Semantics(
        header: true,
        child: Text(
          detail.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.wenyouDetailTitle,
        ),
      ),
    );
  }
}

class ThreadDetailSubthreadHeaderSliver extends StatelessWidget {
  const ThreadDetailSubthreadHeaderSliver({
    required this.subthreads,
    required this.selectedSubthreadId,
    required this.onSelected,
    required this.scrollCoordinator,
    super.key,
  });

  final List<ThreadSubthreadModel> subthreads;
  final String? selectedSubthreadId;
  final Future<void> Function(String) onSelected;
  final ThreadDetailSubthreadScrollCoordinator scrollCoordinator;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    if (subthreads.isEmpty || selectedSubthreadId == null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: tokens.space12),
          child: Divider(height: 1, color: tokens.border),
        ),
      );
    }

    final navigatorExtent = _navigatorExtent(context, tokens);
    final pinned = subthreads.length > 1;
    final maxExtent = navigatorExtent + tokens.space12 * 2 + _dividerExtent;
    final minExtent = pinned
        ? navigatorExtent + tokens.space4 * 2 + _dividerExtent
        : maxExtent;
    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _ThreadSubthreadHeaderDelegate(
        minExtent: minExtent,
        maxExtent: maxExtent,
        maxPadding: tokens.space12,
        minPadding: pinned ? tokens.space4 : tokens.space12,
        background: tokens.background,
        border: tokens.border,
        headerKey: scrollCoordinator.headerKey,
        child: Semantics(
          container: true,
          label: '子贴切换',
          child: ThreadSubthreadNavigator(
            subthreads: subthreads,
            selectedSubthreadId: selectedSubthreadId!,
            onSelected: (id) =>
                scrollCoordinator.selectSubthread(() => onSelected(id)),
          ),
        ),
      ),
    );
  }

  double _navigatorExtent(BuildContext context, WenyouThemeTokens tokens) {
    final painter = TextPainter(
      text: TextSpan(
        text: '子贴\n子贴',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      maxLines: 2,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return math.max(tokens.minimumTouchTarget, painter.height);
  }
}

class ThreadDetailSubthreadScrollCoordinator {
  final controller = ScrollController();
  final headerKey = GlobalKey();
  final bodyKey = GlobalKey();
  var _disposed = false;

  void selectSubthread(Future<void> Function() select) {
    final revealBody = _isHeaderPinned();
    unawaited(select());
    if (revealBody) _scheduleBodyReveal();
  }

  void dispose() {
    _disposed = true;
    controller.dispose();
  }

  bool _isHeaderPinned() {
    if (!controller.hasClients) return false;
    final headerBox = headerKey.currentContext?.findRenderObject();
    final scrollBox = controller.position.context.notificationContext
        ?.findRenderObject();
    if (headerBox is! RenderBox || scrollBox is! RenderBox) return false;
    final headerTop = headerBox.localToGlobal(Offset.zero).dy;
    final scrollTop = scrollBox.localToGlobal(Offset.zero).dy;
    return controller.offset > 0 && (headerTop - scrollTop).abs() <= 1;
  }

  void _scheduleBodyReveal([int attempt = 0]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed || !controller.hasClients) return;
      final body = bodyKey.currentContext?.findRenderObject();
      final header = headerKey.currentContext?.findRenderObject();
      final viewport = RenderAbstractViewport.maybeOf(body);
      if (body == null || header is! RenderBox || viewport == null) {
        if (attempt < 2) _scheduleBodyReveal(attempt + 1);
        return;
      }
      final position = controller.position;
      final bodyOffset = viewport.getOffsetToReveal(body, 0).offset;
      controller.jumpTo(
        (bodyOffset - header.size.height).clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        ),
      );
    });
  }
}

class _ThreadSubthreadHeaderDelegate extends SliverPersistentHeaderDelegate {
  _ThreadSubthreadHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.minPadding,
    required this.maxPadding,
    required this.background,
    required this.border,
    required this.headerKey,
    required this.child,
  });

  @override
  final double minExtent;

  @override
  final double maxExtent;

  final double minPadding;
  final double maxPadding;
  final Color background;
  final Color border;
  final GlobalKey headerKey;
  final Widget child;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final progress = range == 0 ? 1.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    final padding = maxPadding + (minPadding - maxPadding) * progress;
    return KeyedSubtree(
      key: headerKey,
      child: ColoredBox(
        key: const Key('thread-subthread-sticky-header'),
        color: background,
        child: Column(
          children: [
            Expanded(
              child: WenyouContentFrame(
                top: padding,
                bottom: padding,
                child: child,
              ),
            ),
            WenyouContentFrame(
              child: Divider(height: _dividerExtent, color: border),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_ThreadSubthreadHeaderDelegate oldDelegate) {
    return minExtent != oldDelegate.minExtent ||
        maxExtent != oldDelegate.maxExtent ||
        minPadding != oldDelegate.minPadding ||
        maxPadding != oldDelegate.maxPadding ||
        background != oldDelegate.background ||
        border != oldDelegate.border ||
        headerKey != oldDelegate.headerKey ||
        child != oldDelegate.child;
  }
}

const _dividerExtent = 1.0;
