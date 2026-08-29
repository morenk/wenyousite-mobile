import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

void main() {
  group('Markdown v4 对齐 marker', () {
    test('左对齐不落 marker，居中和居右只生成固定 v1 marker', () {
      expect(MarkdownAlignmentContract.markerFor(WenyouTextAlignment.left), '');
      expect(
        MarkdownAlignmentContract.markerFor(WenyouTextAlignment.center),
        '[wenyousite-align-v1-center]: #',
      );
      expect(
        MarkdownAlignmentContract.markerFor(WenyouTextAlignment.right),
        '[wenyousite-align-v1-right]: #',
      );
    });

    final validCases =
        <
          ({
            String label,
            String source,
            WenyouTextAlignment alignment,
            MarkdownAlignedBlockKind kind,
            int endLine,
          })
        >[
          (
            label: '单行正文居中',
            source: '[wenyousite-align-v1-center]: #\n正文',
            alignment: WenyouTextAlignment.center,
            kind: MarkdownAlignedBlockKind.paragraph,
            endLine: 1,
          ),
          (
            label: '多物理行正文居右',
            source: '[wenyousite-align-v1-right]: #\n第一行\n第二行',
            alignment: WenyouTextAlignment.right,
            kind: MarkdownAlignedBlockKind.paragraph,
            endLine: 2,
          ),
          (
            label: 'ATX H2 居中',
            source: '[wenyousite-align-v1-center]: #\n## 二级标题',
            alignment: WenyouTextAlignment.center,
            kind: MarkdownAlignedBlockKind.heading2,
            endLine: 1,
          ),
          (
            label: 'ATX H3 居右',
            source: '[wenyousite-align-v1-right]: #\n### 三级标题',
            alignment: WenyouTextAlignment.right,
            kind: MarkdownAlignedBlockKind.heading3,
            endLine: 1,
          ),
          (
            label: '历史 Setext H2 居中',
            source: '[wenyousite-align-v1-center]: #\n二级标题\n---',
            alignment: WenyouTextAlignment.center,
            kind: MarkdownAlignedBlockKind.heading2,
            endLine: 2,
          ),
        ];

    for (final testCase in validCases) {
      test('${testCase.label}只消费紧邻目标块', () {
        final analysis = MarkdownAlignmentContract.analyze(testCase.source);

        expect(analysis.invalidMarkerLines, isEmpty);
        expect(analysis.validMarkerLines, {0});
        expect(analysis.blocks, hasLength(1));
        final block = analysis.blocks.single;
        expect(block.markerLine, 0);
        expect(block.startLine, 1);
        expect(block.endLine, testCase.endLine);
        expect(block.kind, testCase.kind);
        expect(block.alignment, testCase.alignment);
        for (var line = block.startLine; line <= block.endLine; line++) {
          expect(analysis.alignmentForLine(line), testCase.alignment);
        }
      });
    }

    test('左中右交错时对齐域按块终止且阅读分段保持顺序', () {
      const source =
          '左一\n\n'
          '[wenyousite-align-v1-center]: #\n中一\n中二\n\n'
          '[wenyousite-align-v1-right]: #\n### 右标题\n\n'
          '左二';

      final analysis = MarkdownAlignmentContract.analyze(source);
      expect(analysis.blocks.map((block) => block.alignment), [
        WenyouTextAlignment.center,
        WenyouTextAlignment.right,
      ]);
      expect(analysis.alignmentForLine(0), WenyouTextAlignment.left);
      expect(analysis.alignmentForLine(3), WenyouTextAlignment.center);
      expect(analysis.alignmentForLine(4), WenyouTextAlignment.center);
      expect(analysis.alignmentForLine(7), WenyouTextAlignment.right);
      expect(analysis.alignmentForLine(9), WenyouTextAlignment.left);

      final segments = MarkdownAlignmentContract.renderSegments(source);
      expect(segments.map((segment) => segment.alignment), [
        WenyouTextAlignment.left,
        WenyouTextAlignment.center,
        WenyouTextAlignment.right,
        WenyouTextAlignment.left,
      ]);
      expect(segments.map((segment) => segment.markdown), [
        '左一',
        '中一\n中二',
        '### 右标题',
        '左二',
      ]);
    });

    final malformedMarkers = <String, String>{
      '孤立 marker': '[wenyousite-align-v1-center]: #',
      'marker 与目标间有空行': '[wenyousite-align-v1-center]: #\n\n正文',
      '前置空格': ' [wenyousite-align-v1-center]: #\n正文',
      '尾随空格': '[wenyousite-align-v1-center]: # \n正文',
      '尾随 Tab': '[wenyousite-align-v1-center]: #\t\n正文',
      '大小写变体': '[WENYOUSITE-ALIGN-V1-CENTER]: #\n正文',
      '显式 left': '[wenyousite-align-v1-left]: #\n正文',
      '未知方式': '[wenyousite-align-v1-justify]: #\n正文',
      '未来版本': '[wenyousite-align-v2-center]: #\n正文',
      '带数字的保留方式': '[wenyousite-align-v1-center2]: #\n正文',
      '带下划线的保留方式': '[wenyousite-align-v1-center_alt]: #\n正文',
      '缺少井号': '[wenyousite-align-v1-center]:\n正文',
      '行内出现': '前文 [wenyousite-align-v1-center]: #\n正文',
      '引用内出现': '> [wenyousite-align-v1-center]: #\n正文',
    };

    for (final entry in malformedMarkers.entries) {
      test('${entry.key}不会被当成可隐藏协议', () {
        final analysis = MarkdownAlignmentContract.analyze(entry.value);

        expect(analysis.blocks, isEmpty);
        expect(analysis.invalidMarkerLines, contains(0));
        expect(
          MarkdownContent.unsupportedLineIndexes(entry.value),
          contains(0),
        );
      });
    }

    test('连续 marker 只允许最靠近目标的一个生效', () {
      const source =
          '[wenyousite-align-v1-center]: #\n'
          '[wenyousite-align-v1-right]: #\n正文';
      final analysis = MarkdownAlignmentContract.analyze(source);

      expect(analysis.invalidMarkerLines, {0});
      expect(analysis.validMarkerLines, {1});
      expect(analysis.blocks.single.alignment, WenyouTextAlignment.right);
    });

    test('转义、行内代码、围栏代码和缩进代码内的 marker 始终是正文', () {
      const marker = '[wenyousite-align-v1-center]: #';
      final sources = <String>[
        r'\[wenyousite-align-v1-center]: #',
        '`$marker`',
        '```text\n$marker\n正文\n```',
        '~~~\n$marker\n正文\n~~~',
        '```text\n$marker\n正文',
        '    $marker',
        '\t$marker',
      ];

      for (final source in sources) {
        final analysis = MarkdownAlignmentContract.analyze(source);
        expect(analysis.blocks, isEmpty, reason: source);
        expect(analysis.invalidMarkerLines, isEmpty, reason: source);
      }

      final fenced = MarkdownDeltaCodec.decode(sources[2]).delta;
      expect(
        fenced.operations.any(
          (operation) =>
              operation.data is String &&
              (operation.data as String).contains(marker),
        ),
        isTrue,
      );
      expect(
        MarkdownDeltaCodec.encode(fenced),
        contains('wenyousite\\-align\\-v1\\-center'),
      );
    });

    test('CRLF 输入经公共规范化后仍恢复精确对齐并只保存 LF', () {
      const source =
          '[wenyousite-align-v1-center]: #\r\n## 标题\r\n\r\n'
          '[wenyousite-align-v1-right]: #\r\n正文';
      const expected =
          '[wenyousite-align-v1-center]: #\n## 标题\n\n'
          '[wenyousite-align-v1-right]: #\n正文';

      expect(MarkdownContent.normalize(source), expected);
      expect(
        MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(source).delta),
        expected,
      );
    });

    test('大量左中右与三类合法块交错时仍线性解析并幂等往返', () {
      final blocks = <String>[];
      for (var index = 0; index < 180; index++) {
        final alignment = WenyouTextAlignment.values[index % 3];
        final marker = MarkdownAlignmentContract.markerFor(alignment);
        final content = switch (index % 3) {
          1 => '## 标题 $index 中文 🎲',
          2 => '### Heading $index العربية',
          _ => '正文 $index e\u0301',
        };
        blocks.add(marker.isEmpty ? content : '$marker\n$content');
      }
      final source = blocks.join('\n\n');
      final analysis = MarkdownAlignmentContract.analyze(source);

      expect(analysis.invalidMarkerLines, isEmpty);
      expect(analysis.blocks, hasLength(120));
      expect(
        MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(source).delta),
        source,
      );
    });
  });

  group('Markdown v4 对齐目标白名单', () {
    final excludedTargets = <String, String>{
      '空段': '',
      '空白段': '   ',
      '空 H2': '##',
      '空 H3': '### ',
      'H1': '# 一级标题',
      'H4': '#### 四级标题',
      '无序列表': '- 项目',
      '星号列表': '* 项目',
      '加号列表': '+ 项目',
      '有序列表': '1. 项目',
      '右括号有序列表': '1) 项目',
      '引用': '> 引用',
      '分隔线': '---',
      '星号分隔线': '* * *',
      '下划线分隔线': '_ _ _',
      '协议空段': '<br />',
      '围栏代码': '```dart\ncode\n```',
      '缩进代码': '    code',
      '表格': '| A | B |\n| --- | --- |\n| 1 | 2 |',
      '原始 HTML': '<div>正文</div>',
      '硬换行': '第一行  \n第二行',
      '未知协议': '[[custom:v1:payload]]',
      '损坏骰子': '[[dice:v1:not-a-uuid:1d20]]',
      '普通图片': '![图片](https://cdn.example.com/a.png)',
      '正文混普通图片': '正文 ![图片](https://cdn.example.com/a.png)',
      '后续软行普通图片': '正文\n![图片](https://cdn.example.com/a.png)',
      '损坏收藏表情':
          '![表情](https://cdn.example.com/stickers/a.webp '
          '"wenyousite-sticker:v1:bad")',
      '未知收藏表情协议':
          '![表情](https://cdn.example.com/stickers/a.webp '
          '"wenyousite-sticker:v2:cm1234567890123456789012")',
    };

    for (final alignment in const ['center', 'right']) {
      for (final entry in excludedTargets.entries) {
        test('$alignment 不得用于${entry.key}', () {
          final source = '[wenyousite-align-v1-$alignment]: #\n${entry.value}';
          final analysis = MarkdownAlignmentContract.analyze(source);

          expect(analysis.blocks, isEmpty);
          expect(analysis.invalidMarkerLines, {0});
          expect(MarkdownContent.unsupportedLineIndexes(source), contains(0));
          expect(
            MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(source).delta),
            contains('wenyousite\\-align\\-v1\\-$alignment'),
          );
        });
      }
    }

    final inlineAtoms = <String, String>{
      '用户提及': '[@张三](/users/user-zhang)',
      '全体玩家': '@全体玩家',
      '骰子': '[[dice:v1:550e8400-e29b-41d4-a716-446655440000:1d20]]',
      '收藏表情':
          '![表情](https://cdn.example.com/stickers/a.webp '
          '"wenyousite-sticker:v1:cm1234567890123456789012")',
      '混排原子':
          '前 [@张三](/users/user-zhang) @全体玩家 '
          '[[dice:v1:550e8400-e29b-41d4-a716-446655440000:1d20]] '
          '![表情](https://cdn.example.com/stickers/a.webp '
          '"wenyousite-sticker:v1:cm1234567890123456789012") 后',
    };

    for (final alignment in const ['center', 'right']) {
      for (final entry in inlineAtoms.entries) {
        test('$alignment 正文允许${entry.key}继承父段落', () {
          final source = '[wenyousite-align-v1-$alignment]: #\n${entry.value}';
          final analysis = MarkdownAlignmentContract.analyze(source);

          expect(analysis.invalidMarkerLines, isEmpty);
          expect(analysis.blocks, hasLength(1));
          expect(
            MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(source).delta),
            source,
          );
        });
      }
    }
  });
}
