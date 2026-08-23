import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('主题详情与独立讨论使用框架默认视口缓存邻域', () {
    for (final path in const [
      'lib/features/threads/presentation/thread_detail_page.dart',
      'lib/features/posts/presentation/post_replies_page.dart',
    ]) {
      final source = File(path).readAsStringSync();

      expect(source, contains('CustomScrollView('), reason: path);
      expect(source, contains('SliverList'), reason: path);
      expect(source, isNot(contains('scrollCacheExtent:')), reason: path);
      expect(source, isNot(contains('ScrollCacheExtent')), reason: path);
      expect(source, isNot(contains('_contentCacheExtent')), reason: path);
    }
  });
}
