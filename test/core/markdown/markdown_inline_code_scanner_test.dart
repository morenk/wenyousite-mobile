import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_boundary.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_code_scanner.dart';

void main() {
  test('转义的反引号之后仍可开始完整代码区，三个消费者保持保护', () {
    for (final source in [r'\``<b>`', r'\```<b>``']) {
      expect(
        MarkdownInlineCodeScanner.mask(source),
        r'\`' + ' ' * (source.length - 2),
      );
      expect(MarkdownContent.unsupportedLineIndexes(source), isEmpty);
      expect(MarkdownInlineBoundary.canonicalize(source), source);
      final aligned = MarkdownAlignmentContract.analyze(
        '[wenyousite-align-v1-center]: #\n$source',
      );
      expect(aligned.invalidMarkerLines, isEmpty);
      expect(aligned.alignmentForLine(1), WenyouTextAlignment.center);
    }
  });
  test('较长闭合串不让包含HTML的未闭合代码伪装成可对齐正文', () {
    final aligned = MarkdownAlignmentContract.analyze(
      '[wenyousite-align-v1-center]: #\n`x<b>``',
    );
    expect(aligned.invalidMarkerLines, {0});
  });

  test('闭合反引号必须整串等长，未闭合与转义开头不保护', () {
    for (final source in ['`x``', '``x```', r'\`x`']) {
      expect(MarkdownInlineCodeScanner.mask(source), source);
    }
    expect(MarkdownInlineCodeScanner.mask('``a`b```c``!'), '${' ' * 11}!');
    expect(MarkdownInlineCodeScanner.endAt('``x```', 1), isNull);
    expect(
      MarkdownInlineCodeScanner.mask(r'\\`x`'),
      r'\\'
      '   ',
    );
    expect(MarkdownInlineCodeScanner.mask(r'`x\`'), ' ' * 4);
  });

  test('保留外部可见字符、换行及UTF16位置，不解析代码内容', () {
    const source = '前😀`<b>\r\n骰子`后';
    final masked = MarkdownInlineCodeScanner.mask(source);
    expect(masked, '前😀${' ' * 9}后');
    expect(masked.length, source.length);
    expect(MarkdownInlineCodeScanner.endAt(source, 3), 12);
    expect(MarkdownInlineCodeScanner.mask('`a` + `b`'), '    +    ');
  });
}
