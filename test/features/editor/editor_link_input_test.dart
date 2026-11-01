import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_link_input.dart';

void main() {
  for (final (source, expected) in [
    (
      'https://v.douyin.com/QIwpF-JdM4A/ :6pm mDu:/ H@V.Yz 08/08',
      'https://v.douyin.com/QIwpF-JdM4A/',
    ),
    (
      '分享给你 https://example.com/a?x=1&y=2 查看内容',
      'https://example.com/a?x=1&y=2',
    ),
    (
      '  https://example.com/a%20b?q=%29#part  ',
      'https://example.com/a%20b?q=%29#part',
    ),
    (
      'mailto:hello@example.com?subject=hello%20world',
      'mailto:hello@example.com?subject=hello%20world',
    ),
  ]) {
    test('解析后的唯一链接可被既有 Codec 无损保存：$source', () {
      final link = resolveEditorLinkInput(source);
      expect(link.error, isNull);
      expect(link.url, expected);
      final markdown = MarkdownDeltaCodec.encode(
        Delta()
          ..insert('希尔薇', {'link': link.url})
          ..insert('\n'),
      );
      expect(markdown, '[希尔薇]($expected)');
      expect(
        MarkdownDeltaCodec.decode(
          markdown,
        ).delta.operations.first.attributes?['link'],
        expected,
      );
    });
  }
  for (final input in [
    '',
    'https://',
    'mailto:',
    'javascript:alert(1)',
    'https://example.com/a(b)',
    'https://example.com/<bad>',
    'https://one.example https://two.example',
    'https://one.example mailto:two@example.com',
    'mailto:test@example.com?subject=hello world',
  ]) {
    test('不把不完整、多网址或不支持的输入写入正文：$input', () {
      expect(resolveEditorLinkInput(input).url, isNull);
      expect(resolveEditorLinkInput(input).error, isNotNull);
    });
  }
}
