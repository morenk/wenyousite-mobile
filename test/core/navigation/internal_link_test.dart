import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/navigation/internal_link.dart';

void main() {
  test('相对路径和站内绝对链接识别为移动端路由', () {
    expect(
      isInternalWenyouUri(Uri.parse('/threads/thread-1?post=reply-1')),
      isTrue,
    );
    expect(
      isInternalWenyouUri(
        Uri.parse('https://wenyou.site/threads/thread-1?post=reply-1'),
      ),
      isTrue,
    );
    expect(
      isInternalWenyouUri(Uri.parse('https://www.wenyou.site/users/user-1')),
      isTrue,
    );
  });

  test('外部链接仍保留浏览器打开语义', () {
    expect(
      isInternalWenyouUri(Uri.parse('https://example.com/threads/1')),
      isFalse,
    );
    expect(internalWenyouLocation(Uri.parse('mailto:a@example.com')), isNull);
  });

  test('站内绝对链接转换为路由路径并保留查询参数', () {
    expect(
      internalWenyouLocation(
        Uri.parse('https://wenyou.site/threads/thread-1?post=reply-1'),
      ).toString(),
      '/threads/thread-1?post=reply-1',
    );
  });
}
