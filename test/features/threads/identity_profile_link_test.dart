import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/domain/domain_validation_exception.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_profile.dart';

void main() {
  for (final link in [
    'https://wenyou.site/threads/topic?post=floor',
    'https://www.wenyou.site/threads/topic?post=floor&order=NEWEST&subthread=child',
    '/threads/topic?post=floor',
    'https://wenyou.site/threads/topic/posts/parent/replies?post=floor',
  ]) {
    test('解析已有复制楼层链接 $link', () {
      expect(parseIdentityProfilePostLink(link, threadId: 'topic'), 'floor');
    });
  }
  test('清除由表单表达，解析器拒绝非法链接且不访问外域', () {
    for (final link in [
      '',
      'floor',
      'https://example.com/threads/topic?post=floor',
      'https://wenyou.site@evil.example/threads/topic?post=floor',
      '//wenyou.site/threads/topic?post=floor',
      'javascript:/threads/topic?post=floor',
      '/threads/topic',
      '/threads/topic?post=floor&post=other',
      '/threads/topic?post=../../file',
      '/threads/topic?post=floor#anchor',
      '/threads/topic?post=floor&order=anything',
      '/threads/topic?post=floor&redirect=https://example.com',
      '/users/person?post=floor',
    ]) {
      expect(
        () => parseIdentityProfilePostLink(link, threadId: 'topic'),
        throwsA(isA<DomainValidationException>()),
        reason: link,
      );
    }
  });
  test('不同主题立即拒绝；规范化链接保持稳定帖子ID', () {
    expect(
      () => parseIdentityProfilePostLink(
        '/threads/other?post=floor',
        threadId: 'topic',
      ),
      throwsA(
        isA<DomainValidationException>().having(
          (e) => e.message,
          '提示',
          contains('本主题'),
        ),
      ),
    );
    expect(
      parseIdentityProfilePostLink(
        identityProfilePostLink('topic', 'floor'),
        threadId: 'topic',
      ),
      'floor',
    );
  });
}
