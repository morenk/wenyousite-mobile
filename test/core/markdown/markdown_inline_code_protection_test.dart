import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

void main() {
  test('已闭合行内代码的 HTML 字面量保留代码样式和外部转义文字', () {
    const source = r'\> 引用源码 `> <br />`';
    expect(MarkdownContent.unsupportedLineIndexes(source), isEmpty);
    final delta = MarkdownDeltaCodec.decode(source).delta;
    final code = delta.operations.where((op) => op.attributes?['code'] == true);
    expect(code.single.data, '> <br />');
    expect(delta.operations.map((op) => op.data).join(), '> 引用源码 > <br />\n');
    expect(MarkdownDeltaCodec.encode(delta), source);
  });

  for (final source in [
    '正文 `<span>` <span>正文</span>',
    '正文 `<span>``',
    '正文 ``<span>`',
    r'正文 \`<span>\`',
  ]) {
    test('未闭合或代码区外 HTML 仍不放行：$source', () {
      expect(MarkdownContent.unsupportedLineIndexes(source), {0});
    });
  }
  for (final source in [
    '正文 ``<span>`字符``',
    '正文 `<span>``字符`',
    r'正文 `<span>\`',
  ]) {
    test('完整反引号串界定代码保护范围：$source', () {
      expect(MarkdownContent.unsupportedLineIndexes(source), isEmpty);
    });
  }
  test('未知协议仍只能在完整代码区内作为字面文字', () {
    expect(
      MarkdownContent.unsupportedLineIndexes('正文 `[[widget:v9:future]]`'),
      isEmpty,
    );
    expect(
      MarkdownContent.unsupportedLineIndexes('正文 `[[widget:v9:future]]``'),
      {0},
    );
  });
}
