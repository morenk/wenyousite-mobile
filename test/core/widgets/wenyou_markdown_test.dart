import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  const nodeId = '550e8400-e29b-41d4-a716-446655440000';
  const diceNode = '[[dice:v1:$nodeId:1d20]]';

  testWidgets('骰子节点渲染为内联结果且不泄漏节点标签', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WenyouMarkdown(
            data: '结果 $diceNode',
            diceLabels: {nodeId: '1d20 = 16'},
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('wenyou-dice-$nodeId')), findsOneWidget);
    expect(find.text('1d20 = 16'), findsOneWidget);
    expect(
      find.textContaining('<wenyou-dice', findRichText: true),
      findsNothing,
    );
    expect(find.textContaining('[[dice:', findRichText: true), findsNothing);
    expect(find.textContaining('🎲', findRichText: true), findsNothing);
  });

  testWidgets('骰子结果异步到达后更新内联标签', (tester) async {
    Widget app(Map<String, String> labels) => MaterialApp(
      home: Scaffold(
        body: WenyouMarkdown(data: diceNode, diceLabels: labels),
      ),
    );

    await tester.pumpWidget(app(const {}));
    expect(find.text('1d20 = ?'), findsOneWidget);
    final markdownElement = tester.element(find.byType(MarkdownBody));

    await tester.pumpWidget(app(const {nodeId: '1d20 = 16'}));
    await tester.pump();

    expect(find.text('1d20 = ?'), findsNothing);
    expect(find.text('1d20 = 16'), findsOneWidget);
    expect(
      identical(markdownElement, tester.element(find.byType(MarkdownBody))),
      isTrue,
    );
  });

  testWidgets('代码与转义内容中的骰子表达式保持原文', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WenyouMarkdown(
            data:
                '''
$diceNode
`$diceNode`
\\$diceNode
```md
$diceNode
```
''',
            diceLabels: {nodeId: '1d20 = 16'},
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('wenyou-dice-$nodeId')), findsOneWidget);
    expect(find.text('1d20 = 16'), findsOneWidget);
  });

  testWidgets('360dp 长文保持正文、标题、引用和分隔线的克制阅读层级', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: RepaintBoundary(
            key: Key('markdown-reading-visual'),
            child: ColoredBox(
              color: Color(0xFFFFFFFF),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(12),
                child: WenyouMarkdown(
                  data: '''
## 第一章 · 雨停以前

城门外的雨下了整整三天。她把最后一页信纸折好，沿着旧地图上褪色的河流继续向北。

文字应该让人安静地读下去，而不是被四周的按钮和装饰不断打断。

> “如果下一位旅人读到这里，请替我写完没有抵达的春天。”

### 接力提示

- 保留上一段留下的人物动机
- 从黎明前的钟声继续

---

远处终于传来第一声鸟鸣，故事仍在等待下一位作者。
''',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    final style = markdown.styleSheet!;
    expect(style.p?.fontSize, 17);
    expect(style.p?.height, 1.8);
    expect(style.p?.letterSpacing, closeTo(0.136, 0.001));
    expect(style.h2?.fontSize, closeTo(22.95, 0.001));
    expect(style.h3?.fontSize, closeTo(19.04, 0.001));
    expect(style.blockquote?.height, 1.8);
    final rule = style.horizontalRuleDecoration! as BoxDecoration;
    expect((rule.border! as Border).top.width, 1);
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byKey(const Key('markdown-reading-visual')),
      matchesGoldenFile('goldens/markdown_reading_360.png'),
    );
  });
}
