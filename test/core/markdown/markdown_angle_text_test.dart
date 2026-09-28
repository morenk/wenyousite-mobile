import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

void main() {
  const marker = '[wenyousite-align-v1-center]: #';
  // 实际楼层第 87、88 行；预期来自原始输入及独立阅读语义。
  const original = r'*<\<Y/N \>\>*';
  const readable = <String, String>{
    original: '<<Y/N >>',
    '*1 < 2 > 0*': '1 < 2 > 0',
    '*<中文>*': '<中文>',
    '*<Y/N >*': '<Y/N >',
    r'*\<tag\>*': '<tag>',
    r'*&lt;\<Y/N \>\>*': '<<Y/N >>',
    '*&#60;&#60;Y/N &#62;&#62;*': '<<Y/N >>',
    '*&lt;tag&gt;*': '<tag>',
  };
  for (final entry in readable.entries) {
    test('普通尖括号保持阅读文字、斜体、居中及保存重开：${entry.key}', () {
      expect(
        md.Document(
          encodeHtml: false,
        ).parseInline(entry.key).single.textContent,
        entry.value,
      );
      final source = '$marker\n${entry.key}';
      expect(MarkdownContent.unsupportedLineIndexes(source), isEmpty);
      expect(MarkdownAlignmentContract.analyze(source).validMarkerLines, {0});
      void check(Document document) {
        expect(document.toPlainText(), '${entry.value}\n');
        expect(document.root.children, hasLength(1));
        final block = document.root.children.single as Block;
        expect(block.style.attributes['align']?.value, 'center');
        expect(block.childCount, 1);
        final line = block.children.single as Line;
        for (final leaf in line.children) {
          expect(leaf.style.attributes['italic']?.value, isTrue);
        }
      }

      final decoded = MarkdownDeltaCodec.decode(source);
      check(Document.fromDelta(decoded.delta));
      final saved = MarkdownDeltaCodec.encode(decoded.delta);
      expect(MarkdownContent.unsupportedLineIndexes(saved), isEmpty);
      check(Document.fromDelta(MarkdownDeltaCodec.decode(saved).delta));
    });
  }

  for (final source in [
    '<3 > 0',
    '<中文>',
    r'\<tag\>',
    '`<tag>`',
    '<user@example.com>',
    '<mailto:user@example.com>',
    '<https://example.com/[[custom:v1:x]]>',
    'https://example.com/[[custom:v1:x]]',
    '[链接](https://example.com/[[custom:v1:x]])',
    '[链接](https://example.com "<tag> [[custom:v1:x]]")',
    '[链接](https://example.com "[wenyousite-align-v2-center]: #")',
    '## `` `<tag>` ``',
    '## `[wenyousite-align-v2-center]: #`',
    '前 `跨行\n<tag>\n[wenyousite-align-v2-center]: #\n后`',
  ]) {
    test('按真实解析范围排除 HTML 和协议误判：$source', () {
      expect(MarkdownContent.unsupportedLineIndexes(source), isEmpty);
    });
  }

  for (final source in [
    '<tag>',
    '<tag data-x="a">正文</tag>',
    '前 <!-- comment --> 后',
    '前 <?instruction?> 后',
    '前 <![CDATA[hidden]]> 后',
    '前 <span\nclass="x"> 后',
    '## ``未闭合 <tag> `',
    r'\\<tag>',
  ]) {
    test('实际 HTML 仍保持只读保护：$source', () {
      expect(MarkdownContent.unsupportedLineIndexes(source), isNotEmpty);
      expect(
        MarkdownAlignmentContract.analyze('$marker\n$source').blocks,
        isEmpty,
      );
    });
  }

  test('普通尖括号不是空正文，预览不丢失文字', () {
    expect(MarkdownContent.hasVisibleContent('<中文>'), isTrue);
    expect(MarkdownContent.hasVisibleContent('`<tag>`'), isTrue);
    expect(
      MarkdownContent.toPlainTextPreview('$marker\n$original'),
      '<<Y/N >>',
    );
  });

  test('实体解码出的标签文字写回后不能升级成 HTML', () {
    for (final source in ['&lt;tag&gt;', '&lt;!--注释--&gt;', '&#60;br /&#62;']) {
      final expected = md.Document(
        encodeHtml: false,
      ).parseInline(source).single.textContent;
      final decoded = MarkdownDeltaCodec.decode(source);
      expect(Document.fromDelta(decoded.delta).toPlainText(), '$expected\n');
      final saved = MarkdownDeltaCodec.encode(decoded.delta);
      expect(MarkdownContent.unsupportedLineIndexes(saved), isEmpty);
      expect(
        Document.fromDelta(
          MarkdownDeltaCodec.decode(saved).delta,
        ).toPlainText(),
        '$expected\n',
      );
    }
  });

  for (final prefix in ['', '## ', '### ', '> ', '- ']) {
    test('实体标签保留块归属：$prefix', () {
      final source = '$prefix&lt;tag&gt;';
      final decoded = MarkdownDeltaCodec.decode(source);
      expect(Document.fromDelta(decoded.delta).toPlainText(), '<tag>\n');
      final saved = MarkdownDeltaCodec.encode(decoded.delta);
      expect(MarkdownContent.unsupportedLineIndexes(saved), isEmpty);
      final reopened = Document.fromDelta(
        MarkdownDeltaCodec.decode(saved).delta,
      );
      expect(reopened.toPlainText(), '<tag>\n');
      final attributes = reopened.collectStyle(0, 5).attributes;
      if (prefix.startsWith('#')) {
        expect(attributes['header']?.value, prefix.trim().length);
      }
      if (prefix == '> ') expect(attributes['blockquote']?.value, isTrue);
      if (prefix == '- ') expect(attributes['list']?.value, 'bullet');
    });
  }

  for (final body in [
    original,
    '## $original',
    '### $original',
    '$original\n---',
    '&lt;tag&gt;',
  ]) {
    for (final newline in ['\n', '\r\n']) {
      test('有效对齐标记在段落和标题、不同换行中保持隐藏：$body / ${newline.length}', () {
        final source = '$marker\n$body'.replaceAll('\n', newline);
        expect(MarkdownContent.unsupportedLineIndexes(source), isEmpty);
        final decoded = MarkdownDeltaCodec.decode(source);
        final plain = Document.fromDelta(decoded.delta).toPlainText();
        expect(plain, isNot(contains('wenyousite')));
        expect(plain, body == '&lt;tag&gt;' ? '<tag>\n' : '<<Y/N >>\n');
        final saved = MarkdownDeltaCodec.encode(decoded.delta);
        expect(MarkdownAlignmentContract.analyze(saved).blocks, hasLength(1));
      });
    }
  }

  test('代码、转义和损坏标记不能被预览静默删除', () {
    expect(MarkdownContent.hasVisibleContent('`\n$marker\n`'), isTrue);
    for (final source in [
      '`\n$marker\n`',
      '\\$marker',
      '[wenyousite-align-v2-center]: #\n正文',
      marker,
    ]) {
      expect(
        MarkdownContent.toPlainTextPreview(source),
        contains('wenyousite-align'),
      );
    }
    expect(MarkdownContent.toPlainTextPreview('$marker\n正文'), '正文');
  });
}
