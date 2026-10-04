import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('主题详情与独立讨论仅预渲染两屏并按稳定 ID 回收正文', () {
    for (final entry in const [
      (
        path: 'lib/features/threads/presentation/thread_detail_page.dart',
        content:
            'lib/features/threads/presentation/thread_detail_reading_content.dart',
      ),
      (
        path: 'lib/features/posts/presentation/post_replies_page.dart',
        content: 'lib/features/posts/presentation/post_replies_content.dart',
      ),
    ]) {
      final path = entry.path;
      final source =
          File(path).readAsStringSync() +
          File(entry.content).readAsStringSync();

      expect(source, contains('CustomScrollView('), reason: path);
      expect(source, contains('DiscussionSliverList'), reason: path);
      expect(
        source,
        contains('scrollCacheExtent: discussionScrollCacheExtent'),
        reason: path,
      );
      expect(source, isNot(contains('ScrollCacheExtent.pixels(4000)')));
      expect(source, contains('DiscussionWindowPrefetch'), reason: path);
      expect(source, isNot(contains('DiscussionKeepAlive')), reason: path);
      expect(source, contains('findChildIndexCallback'), reason: path);
    }

    final policy = File(
      'lib/core/widgets/wenyou_discussion_scroll_policy.dart',
    ).readAsStringSync();
    expect(policy, contains('ScrollCacheExtent.viewport(2.0)'));
    expect(policy, isNot(contains('AutomaticKeepAliveClientMixin')));
    expect(policy, contains('addPostFrameCallback'));
  });
}
