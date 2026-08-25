import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_empty_paragraphs.dart';

void main() {
  group('recoverLegacy', () {
    test('保留普通段落边界，只恢复内部多余空行', () {
      expect(MarkdownEmptyParagraphs.recoverLegacy('第一段\n\n第二段'), '第一段\n\n第二段');
      expect(
        MarkdownEmptyParagraphs.recoverLegacy('第一段\n\n\n第二段'),
        '第一段\n\n<br />\n\n第二段',
      );
      expect(
        MarkdownEmptyParagraphs.recoverLegacy('第一段\n\n\n\n第二段'),
        '第一段\n\n<br />\n\n<br />\n\n第二段',
      );
    });

    test('逐个恢复首部空行，尾部只忽略一个格式化换行', () {
      expect(
        MarkdownEmptyParagraphs.recoverLegacy('\n\n正文'),
        '<br />\n\n<br />\n\n正文',
      );
      expect(MarkdownEmptyParagraphs.recoverLegacy('正文\n'), '正文\n');
      expect(
        MarkdownEmptyParagraphs.recoverLegacy('正文\n\n\n'),
        '正文\n\n<br />\n\n<br />',
      );
    });

    test('显式协议标记幂等且统一跨平台换行', () {
      const canonical = '第一段\n\n<br />\n<br />\n\n第二段';
      expect(MarkdownEmptyParagraphs.recoverLegacy(canonical), canonical);
      expect(
        MarkdownEmptyParagraphs.recoverLegacy('第一段\r\n\r\n\r\n第二段'),
        '第一段\n\n<br />\n\n第二段',
      );
      expect(MarkdownEmptyParagraphs.recoverLegacy(' \r\n\r\n\t'), ' \n\n\t');
    });

    test('围栏、缩进代码和原始 HTML 中的空行保持字面内容', () {
      const fenced = '```text\n第一行\n\n\n第二行\n```';
      const indented = '    第一行\n\n\n    第二行';
      const html = '<script>\n第一行\n\n\n第二行\n</script>';

      expect(MarkdownEmptyParagraphs.recoverLegacy(fenced), fenced);
      expect(MarkdownEmptyParagraphs.recoverLegacy(indented), indented);
      expect(MarkdownEmptyParagraphs.recoverLegacy(html), html);
    });
  });

  group('prepareForLineEditor', () {
    test('移除协议标记周围的结构分隔，不增加 Quill 空段', () {
      expect(
        MarkdownEmptyParagraphs.prepareForLineEditor(
          '第一段\n\n<br />\n<br>\n<br/>\n\n第二段',
        ),
        '第一段\n<br />\n<br />\n<br />\n第二段',
      );
    });

    test('历史原始空行进入编辑器前转换为逐个协议空段', () {
      expect(
        MarkdownEmptyParagraphs.prepareForLineEditor('第一段\n\n\n\n第二段'),
        '第一段\n<br />\n<br />\n第二段',
      );
      expect(
        MarkdownEmptyParagraphs.prepareForLineEditor('第一段\n\n第二段'),
        '第一段\n\n第二段',
      );
    });
  });
}
