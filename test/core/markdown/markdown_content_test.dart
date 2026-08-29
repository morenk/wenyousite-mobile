import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';

void main() {
  final contract =
      jsonDecode(File('contracts/markdown-v4-fixtures.json').readAsStringSync())
          as Map<String, dynamic>;
  final cases = (contract['cases'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  test('加载的是 Markdown v4 黄金语料', () {
    expect(contract['version'], 4);
    expect(cases, isNotEmpty);
  });

  for (final fixture in cases) {
    final id = fixture['id'] as String;
    final input = fixture['input'] as String;
    final canonical = fixture['canonical'] as String;
    final visible = fixture['visible'] as bool;

    test('$id 规范化与发布可见性一致', () {
      expect(MarkdownContent.normalize(input), canonical);
      expect(MarkdownContent.hasVisibleContent(canonical), visible);
      expect(MarkdownContent.normalize(canonical), canonical);
    });
  }

  test('链接和图片仅允许明确的安全 scheme', () {
    expect(
      MarkdownContent.isSafeLink(Uri.parse('https://wenyou.site')),
      isTrue,
    );
    expect(
      MarkdownContent.isSafeLink(Uri.parse('javascript:alert(1)')),
      isFalse,
    );
    expect(
      MarkdownContent.isSafeImage(Uri.parse('data:image/png;base64,YQ==')),
      isFalse,
    );
  });

  test('阅读态只替换正文中的骰子节点并保留代码与转义内容', () {
    const nodeId = '550e8400-e29b-41d4-a716-446655440000';
    const markdown =
        '''
结果 [[dice:v1:$nodeId:1d20]]
`[[dice:v1:$nodeId:2d6]]`
\\[[dice:v1:$nodeId:3d6]]
```md
[[dice:v1:$nodeId:4d6]]
```
''';

    final rendered = MarkdownContent.renderDiceForDisplay(markdown, const {
      nodeId: '1d20 = 16',
    });

    expect(rendered, contains('结果 1d20 = 16'));
    expect(rendered, contains('`[[dice:v1:$nodeId:2d6]]`'));
    expect(rendered, contains('\\[[dice:v1:$nodeId:3d6]]'));
    expect(rendered, contains('[[dice:v1:$nodeId:4d6]]'));
  });

  test('阅读态未知骰子结果使用可理解的降级文本', () {
    const nodeId = '550e8400-e29b-41d4-a716-446655440000';
    expect(
      MarkdownContent.renderDiceForDisplay(
        '[[dice:v1:$nodeId:2d6+3]]',
        const {},
      ),
      '2d6+3 = ?',
    );
  });

  test('发布可见性排除真实骰子，但保留代码和转义中的骰子文字', () {
    const nodeId = '550e8400-e29b-41d4-a716-446655440000';
    const dice = '[[dice:v1:$nodeId:1d20]]';

    expect(MarkdownContent.hasVisibleNonDiceContent(dice), isFalse);
    expect(MarkdownContent.hasVisibleNonDiceContent('正文 $dice'), isTrue);
    expect(MarkdownContent.hasVisibleNonDiceContent('`$dice`'), isTrue);
    expect(MarkdownContent.hasVisibleNonDiceContent('\\$dice'), isTrue);
    expect(
      MarkdownContent.hasVisibleNonDiceContent('```md\n$dice\n```'),
      isTrue,
    );
  });

  test('骰子数量按单份正文统计，并忽略代码与转义中的标记', () {
    const first = '550e8400-e29b-41d4-a716-446655440000';
    const second = '550e8400-e29b-41d4-a716-446655440001';
    const markdown =
        '''
[[dice:v1:$first:1d20]] [[dice:v1:$second:2d6]]
`[[dice:v1:$first:3d6]]`
\\[[dice:v1:$first:4d6]]
```md
[[dice:v1:$first:5d6]]
```
''';

    expect(MarkdownDiceContract.countMarkdownNodes(markdown), 2);
  });

  test('搜索预览移除 Markdown 语法并保留图片与骰子语义', () {
    const nodeId = '550e8400-e29b-41d4-a716-446655440000';
    expect(
      MarkdownContent.toPlainTextPreview(
        '**星海正文** ![航图](https://cdn.example.com/map.jpg) '
        '[[dice:v1:$nodeId:2d6+1]]',
      ),
      '星海正文 [图片] [2d6+1]',
    );
  });

  test('搜索预览按 Unicode 字符截断且使用省略号', () {
    expect(MarkdownContent.toPlainTextPreview('一二三四五', maxLength: 4), '一二三…');
    expect(MarkdownContent.toPlainTextPreview('正文', maxLength: 0), isEmpty);
  });

  test('紧凑预览继续折叠历史空行与协议空段', () {
    expect(
      MarkdownContent.toPlainTextPreview('第一段\n\n\n\n第二段\n<br />\n<br />\n第三段'),
      '第一段 第二段 第三段',
    );
  });

  test('对齐协议只在精确 marker 位置生效，代码与转义保持字面文本', () {
    expect(
      MarkdownContent.unsupportedLineIndexes(
        '前文 [wenyousite-align-v1-center]: 非法后缀',
      ),
      {0},
    );
    expect(
      MarkdownContent.unsupportedLineIndexes(
        '`[wenyousite-align-v2-center]: #`',
      ),
      isEmpty,
    );
    expect(
      MarkdownContent.unsupportedLineIndexes(
        r'\[wenyousite-align-v1-center]: #',
      ),
      isEmpty,
    );
  });
}
