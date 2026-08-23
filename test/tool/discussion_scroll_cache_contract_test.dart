import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('主题详情与独立讨论固定预渲染前后各两个视口', () {
    for (final entry in const [
      (
        path: 'lib/features/threads/presentation/thread_detail_page.dart',
        prefetch: 'prefetchRemainingFloors()',
      ),
      (
        path: 'lib/features/posts/presentation/post_replies_page.dart',
        prefetch: 'prefetchRemainingReplies()',
      ),
    ]) {
      final path = entry.path;
      final source = File(path).readAsStringSync();

      expect(source, contains('CustomScrollView('), reason: path);
      expect(source, contains('SliverList'), reason: path);
      expect(
        source,
        contains('scrollCacheExtent: discussionScrollCacheExtent'),
        reason: path,
      );
      expect(source, isNot(contains('ScrollCacheExtent.pixels(4000)')));
      expect(source, contains('DiscussionPrefetchScheduler'), reason: path);
      expect(source, contains(entry.prefetch), reason: path);
      expect(source, contains('findChildIndexCallback'), reason: path);
    }

    final policy = File(
      'lib/core/widgets/wenyou_discussion_scroll_policy.dart',
    ).readAsStringSync();
    expect(policy, contains('ScrollCacheExtent.viewport(2.0)'));
    expect(policy, contains('addPostFrameCallback'));
  });
}
