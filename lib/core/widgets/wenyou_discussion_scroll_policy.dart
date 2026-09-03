import 'package:flutter/rendering.dart'
    show RenderAbstractViewport, RenderObject, RenderSliver, ScrollCacheExtent;
import 'package:flutter/widgets.dart';

/// Prepares the visible discussion plus two viewports on either side.
/// Materialized rows are then retained by [DiscussionKeepAlive].
const discussionScrollCacheExtent = ScrollCacheExtent.viewport(2.0);

/// Retains a discussion row after its first layout so returning to already-read
/// content never reparses and relays out its Markdown subtree.
class DiscussionKeepAlive extends StatefulWidget {
  const DiscussionKeepAlive({required this.child, super.key});

  final Widget child;

  @override
  State<DiscussionKeepAlive> createState() => _DiscussionKeepAliveState();
}

class _DiscussionKeepAliveState extends State<DiscussionKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Starts one discussion text prefetch task after the current frame is
/// delivered, without scheduling duplicates during intervening rebuilds.
class DiscussionPrefetchScheduler {
  var _scheduled = false;

  void schedule({
    required bool shouldPrefetch,
    required bool Function() isMounted,
    required VoidCallback prefetch,
  }) {
    if (_scheduled || !shouldPrefetch) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (isMounted()) prefetch();
    });
  }
}

/// Reveals a discussion target that may not have been materialized by its
/// lazy sliver yet. The target owns automatic movement until the first user
/// drag, and can be reset when route or filter context changes.
class DiscussionTargetRevealCoordinator {
  static const maxEstimatedAttempts = 6;

  String? _lastContentSignature;
  String? _scopeSignature;
  String? _attemptTargetId;
  var _attempts = 0;
  var _scheduled = false;
  var _releasedByUser = false;

  void reset() {
    _lastContentSignature = null;
    _scopeSignature = null;
    _attemptTargetId = null;
    _attempts = 0;
    _scheduled = false;
    _releasedByUser = false;
  }

  void schedule({
    required String targetId,
    required String scopeSignature,
    required String contentSignature,
    required int targetIndex,
    required int itemCount,
    required bool ready,
    required GlobalKey targetKey,
    required ScrollController scrollController,
    required bool Function() isMounted,
    required VoidCallback requestRebuild,
  }) {
    if (_scopeSignature != scopeSignature) {
      reset();
      _scopeSignature = scopeSignature;
    }
    if (!ready ||
        targetIndex < 0 ||
        _releasedByUser ||
        _scheduled ||
        _lastContentSignature == contentSignature) {
      return;
    }
    if (_attemptTargetId != targetId) {
      _attemptTargetId = targetId;
      _attempts = 0;
    }
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!isMounted() ||
          _releasedByUser ||
          _scopeSignature != scopeSignature) {
        return;
      }
      final targetContext = targetKey.currentContext;
      if (targetContext != null && _canReveal(targetContext)) {
        Scrollable.ensureVisible(
          targetContext,
          duration: Duration.zero,
          alignment: 0.12,
        );
        _lastContentSignature = contentSignature;
        _attemptTargetId = null;
        _attempts = 0;
        return;
      }
      if (!scrollController.hasClients || _attempts >= maxEstimatedAttempts) {
        return;
      }
      _attempts += 1;
      final position = scrollController.position;
      final fraction = (targetIndex + 1) / (itemCount + 1);
      final estimated = position.maxScrollExtent * fraction;
      scrollController.jumpTo(
        estimated.clamp(position.minScrollExtent, position.maxScrollExtent),
      );
      if (isMounted()) requestRebuild();
    });
  }

  static bool _canReveal(BuildContext context) {
    // Kept-alive sliver children retain context after losing layout geometry.
    final target = context.findRenderObject();
    if (target == null || !target.attached) return false;
    RenderObject child = target;
    while (child.parent != null) {
      final parent = child.parent!;
      if (parent is RenderSliver && parent.childScrollOffset(child) == null) {
        return false;
      }
      if (parent is RenderAbstractViewport) return true;
      child = parent;
    }
    return false;
  }

  bool handleLayoutChange({
    required bool Function() isMounted,
    required VoidCallback requestRebuild,
  }) {
    if (_scopeSignature == null ||
        _lastContentSignature == null ||
        _releasedByUser) {
      return false;
    }
    _lastContentSignature = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isMounted()) requestRebuild();
    });
    return false;
  }

  bool handleUserScroll(ScrollNotification notification) {
    final startsUserScroll =
        notification.depth == 0 &&
        notification.metrics.axis == Axis.vertical &&
        notification is ScrollStartNotification &&
        notification.dragDetails != null &&
        _scopeSignature != null;
    if (startsUserScroll) _releasedByUser = true;
    return false;
  }
}
