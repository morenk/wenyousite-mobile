import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_animation_byte_cache.dart';

void main() {
  test('编码缓存限制总字节、最近使用优先、超大文件不缓存', () {
    final cache = CoverAnimationByteCache(maximumBytes: 8);
    cache.put('a', Uint8List(4));
    cache.put('b', Uint8List(4));
    expect(cache.get('a'), isNotNull);
    cache.put('c', Uint8List(4));
    expect(cache.get('b'), isNull);
    expect(cache.size, 8);
    cache.put('large', Uint8List(9));
    expect(cache.get('large'), isNull);
    cache.clear();
    expect(cache.size, 0);
    expect(cache.get('a'), isNull);
  });
}
