import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter/widgets.dart' show WidgetsBinding;

/// Keeps the visible discussion plus two viewports on either side laid out.
///
/// This stays viewport-relative across phone sizes without retaining every
/// Markdown subtree in a long discussion.
const discussionScrollCacheExtent = ScrollCacheExtent.viewport(2.0);

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
