import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_boundary.dart';

void main() {
  test('Web 标点邻接样例规范为无可见空格的安全强调', () {
    const cases = <String, String>{
      '选择你的DeerSeek模型：**【注意注意！并不是真的AI！DeerSeek就是我！】**DeerSeek v4 pro':
          '选择你的DeerSeek模型：**【注意注意！并不是真的AI！DeerSeek就是我！】**&#x44;eerSeek v4 pro',
      '前*（斜体）*后': '&#x524D;*（斜体）*&#x540E;',
      '前***【粗斜体】***后': '&#x524D;***【粗斜体】***&#x540E;',
      '前~~【删除】~~后': '&#x524D;~~【删除】~~&#x540E;',
      '前_（斜体）_后': '&#x524D;*（斜体）*&#x540E;',
      '前__【粗体】__后': '&#x524D;**【粗体】**&#x540E;',
      '前___【粗斜体】___后': '&#x524D;***【粗斜体】***&#x540E;',
      '前**🚨注意🚨**后': '&#x524D;**🚨注意🚨**&#x540E;',
    };

    for (final MapEntry(:key, :value) in cases.entries) {
      expect(MarkdownInlineBoundary.canonicalize(key), value, reason: key);
      expect(MarkdownInlineBoundary.canonicalize(value), value, reason: value);
    }
  });

  test('转义、空白、长定界符、代码、链接和图片保持字面边界', () {
    const cases = [
      r'前\**【字面】**后',
      '前**【未闭合】后',
      '前** 【空白】**后',
      '前**【空白】 **后',
      'foo_bar_baz',
      'x****【四星】****y',
      '`前**【代码】**后`',
      '[前**【链接】**后](https://example.com)',
      '![前**【图片】**后](https://example.com/image.png)',
      '<span data-value="**【属性】**">',
    ];

    for (final source in cases) {
      expect(
        MarkdownInlineBoundary.canonicalize(source),
        source,
        reason: source,
      );
    }
  });

  test('文档规范化不进入围栏、缩进代码、定义和引用链接', () {
    const source = '''```md
前**【围栏】**后
```
    前**【缩进】**后
[前**【引用链接】**后][guide]

[guide]: https://example.com/**literal**''';

    expect(MarkdownInlineBoundary.canonicalizeDocument(source), source);
  });

  test('同一行跳过受保护片段后继续恢复后续独立格式', () {
    const source = r'\**【字面】** x**【恢复】**y';
    const multiple = 'A**【粗】**B / C_（斜）_D / E~~【删】~~F';

    expect(
      MarkdownInlineBoundary.canonicalize(source),
      r'\**【字面】** &#x78;**【恢复】**&#x79;',
    );
    expect(
      MarkdownInlineBoundary.canonicalize(multiple),
      '&#x41;**【粗】**&#x42; / &#x43;*（斜）*&#x44; / '
      '&#x45;~~【删】~~&#x46;',
    );
  });

  test('CRLF 围栏结束后继续恢复普通正文', () {
    const source = '```md\r\n前**【围栏】**后\r\n```\r\n前**【恢复】**后';

    expect(
      MarkdownInlineBoundary.canonicalizeDocument(source),
      '```md\r\n前**【围栏】**后\r\n```\r\n&#x524D;**【恢复】**&#x540E;',
    );
  });

  test('粗体尾随的单个分隔空格移到闭合定界符外', () {
    const malformed = '**粗体 **`代码`';
    const canonical = '**粗体** `代码`';

    expect(MarkdownInlineBoundary.canonicalize(malformed), canonical);
    expect(MarkdownInlineBoundary.canonicalize(canonical), canonical);
    for (final source in const ['**粗体  **`代码`', '**粗体 **`未闭合', '*斜体 *`代码`']) {
      expect(MarkdownInlineBoundary.canonicalize(source), source);
    }

    final authored = Delta()
      ..insert('粗体 ', {'bold': true})
      ..insert('代码', {'code': true})
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false});
    expect(MarkdownDeltaCodec.encode(authored), canonical);

    final document = MarkdownDeltaCodec.decode(malformed);
    expect(
      document.delta.operations.where((operation) => operation.data != '\n'),
      containsAllInOrder([
        isA<Operation>()
            .having((operation) => operation.data, 'text', '粗体')
            .having(
              (operation) => operation.attributes,
              'attributes',
              containsPair('bold', true),
            ),
        isA<Operation>()
            .having((operation) => operation.data, 'text', ' ')
            .having((operation) => operation.attributes, 'attributes', isNull),
        isA<Operation>()
            .having((operation) => operation.data, 'text', '代码')
            .having(
              (operation) => operation.attributes,
              'attributes',
              containsPair('code', true),
            ),
      ]),
    );
    expect(MarkdownDeltaCodec.encode(document.delta), canonical);
  });

  test('编辑器恢复链接但不把链接标签中的定界符提升为强调', () {
    const source = '[前**【链接】**后](https://example.com)';

    final document = MarkdownDeltaCodec.decode(source);
    final textOperations = document.delta.operations.where(
      (operation) => operation.data is String && operation.data != '\n',
    );

    expect(
      textOperations,
      contains(
        isA<Operation>()
            .having((operation) => operation.data, 'text', '前**【链接】**后')
            .having(
              (operation) => operation.attributes,
              'attributes',
              allOf(
                containsPair('link', 'https://example.com'),
                isNot(contains('bold')),
                isNot(contains('italic')),
              ),
            ),
      ),
    );
    expect(MarkdownDeltaCodec.encode(document.delta), source);
  });
}
