import 'package:flutter/rendering.dart' show ScrollCacheExtent;
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
