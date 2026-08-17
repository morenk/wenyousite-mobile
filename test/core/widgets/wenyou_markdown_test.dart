import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';
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

  testWidgets('混排和换行后的骰子与正文共享行高与文字基线', (tester) async {
    const secondNodeId = '550e8400-e29b-41d4-a716-446655440001';
    const secondDiceNode = '[[dice:v1:$secondNodeId:2d6+3]]';
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 240);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: RepaintBoundary(
            key: Key('markdown-inline-dice-visual'),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: WenyouMarkdown(
                data: '第一行文字 $diceNode 继续叙述\n第二行文字 $secondDiceNode 仍然同行',
                diceLabels: {nodeId: '1d20 = 16', secondNodeId: '2d6+3 = 11'},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final firstDice = find.byKey(const ValueKey('wenyou-dice-$nodeId'));
    final secondDice = find.byKey(const ValueKey('wenyou-dice-$secondNodeId'));
    expect(firstDice, findsOneWidget);
    expect(secondDice, findsOneWidget);
    expect(tester.getSize(firstDice).height, lessThanOrEqualTo(31));
    expect(tester.getSize(secondDice).height, lessThanOrEqualTo(31));
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byKey(const Key('markdown-inline-dice-visual')),
      matchesGoldenFile('goldens/markdown_inline_dice_360.png'),
    );
  });

  testWidgets('骰子结果异步到达后更新内联标签', (tester) async {
    Widget app(Map<String, String> labels) => MaterialApp(
      home: Scaffold(
        body: WenyouMarkdown(data: diceNode, diceLabels: labels),
      ),
    );

    await tester.pumpWidget(app(const {}));
    expect(find.text('1d20 = ?'), findsOneWidget);
    await tester.pumpWidget(app(const {nodeId: '1d20 = 16'}));
    await tester.pump();

    expect(find.text('1d20 = ?'), findsNothing);
    expect(find.text('1d20 = 16'), findsOneWidget);
  });

  testWidgets('Markdown v3 不支持的表格按可读原文展示', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WenyouMarkdown(data: '| 名称 | 数量 |\n| --- | --- |\n| 骰子 | 2 |'),
        ),
      ),
    );

    expect(find.byType(Table), findsNothing);
    expect(
      find.textContaining('| 名称 | 数量 |', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('| 骰子 | 2 |', findRichText: true),
      findsOneWidget,
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

  testWidgets('Markdown 站内坐标使用 Foundation 传送门且交给内部导航', (tester) async {
    Uri? opened;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 180,
            child: WenyouMarkdown(
              data:
                  '参见 [很长但不能被截断的设定入口](/threads/cmsewdo0h000x7qv6aa77ll1v)，`[代码](/threads/cmsewdo0h000x7qv6aa77ll1v)`。',
              onInternalLink: (location) => opened = location,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final portal = find.byKey(const ValueKey('markdown-internal-reference-0'));
    expect(portal, findsOneWidget);
    expect(find.byType(WenyouInternalReferenceChip), findsOneWidget);
    expect(tester.getSize(portal).width, lessThanOrEqualTo(180));
    expect(tester.getSize(portal).height, greaterThanOrEqualTo(48));
    final icon = tester.widget<WenyouIcon>(
      find.descendant(of: portal, matching: find.byType(WenyouIcon)),
    );
    expect(icon.semanticId, WenyouIconIds.contentInternalReference);
    expect(find.textContaining('代码', findRichText: true), findsOneWidget);
    expect(
      find.textContaining(
        '/threads/cmsewdo0h000x7qv6aa77ll1v',
        findRichText: true,
      ),
      findsOneWidget,
    );

    await tester.tap(portal);
    expect(opened, Uri.parse('/threads/cmsewdo0h000x7qv6aa77ll1v'));
    expect(tester.takeException(), isNull);
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

  testWidgets('正文图片保持纯净并从原图页按需收藏表情', (tester) async {
    const url = 'https://cdn.example.com/story.png';
    var saveCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouMarkdown(
            data: '![雾港地图]($url)',
            onSaveImage: (uri) async {
              expect(uri.toString(), url);
              saveCalls += 1;
              return '已添加到表情收藏。';
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final image = find.byKey(const ValueKey('markdown-image-$url'));
    expect(image, findsOneWidget);
    expect(find.byTooltip('添加到表情收藏'), findsNothing);
    expect(find.byKey(const Key('content-image-actions')), findsNothing);
    expect(
      find.ancestor(of: image, matching: find.byType(Stack)),
      findsNothing,
    );

    await tester.tap(image);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('content-image-viewer')), findsOneWidget);
    expect(find.text('雾港地图'), findsOneWidget);
    expect(find.byKey(const Key('content-image-actions')), findsOneWidget);
    await tester.tap(find.byKey(const Key('content-image-actions')));
    await tester.pumpAndSettle();
    expect(find.text('添加到表情收藏'), findsOneWidget);

    await tester.tap(find.text('添加到表情收藏'));
    await tester.pumpAndSettle();

    expect(saveCalls, 1);
    expect(find.text('已添加到表情收藏。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('纯文本点击回调不吞图片自身交互', (tester) async {
    const url = 'https://cdn.example.com/story.png';
    var textTapCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouMarkdown(
            data: '点击正文\n\n![雾港地图]($url)',
            onTapText: () => textTapCalls += 1,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.textContaining('点击正文', findRichText: true));
    await tester.pump();
    expect(textTapCalls, 1);

    await tester.tap(find.byKey(const ValueKey('markdown-image-$url')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('content-image-viewer')), findsOneWidget);
    expect(textTapCalls, 1);
  });

  testWidgets('纯文本点击回调不吞链接自身交互', (tester) async {
    var textTapCalls = 0;
    Uri? openedInternalLink;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouMarkdown(
            data: '[打开主题](/threads/thread-2)',
            onTapText: () => textTapCalls += 1,
            onInternalLink: (uri) => openedInternalLink = uri,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.textContaining('打开主题', findRichText: true));
    await tester.pump();
    expect(openedInternalLink?.toString(), '/threads/thread-2');
    expect(textTapCalls, 0);
  });

  testWidgets('游客正文图片仍可查看原图且没有收藏入口', (tester) async {
    const url = 'https://cdn.example.com/story.png';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: WenyouMarkdown(data: '![雾港地图]($url)')),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('markdown-image-$url')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('content-image-viewer')), findsOneWidget);
    expect(find.byKey(const Key('content-image-actions')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('正文图片语义只暴露查看原图且 320 至 600dp 无常驻操作', (tester) async {
    final semantics = tester.ensureSemantics();
    for (final width in const [320.0, 360.0, 400.0, 600.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 640);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: WenyouMarkdown(
              data: '![雾港地图](https://cdn.example.com/story-$width.png)',
              onSaveImage: (_) async => '已添加到表情收藏。',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.bySemanticsLabel('查看正文图片原图：雾港地图'), findsOneWidget);
      expect(find.byTooltip('添加到表情收藏'), findsNothing);
      expect(find.byTooltip('图片操作'), findsNothing);
      expect(tester.takeException(), isNull);
    }
    semantics.dispose();
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  testWidgets('正文内的收藏表情保持原子展示且不伪装成普通插图', (tester) async {
    const url = 'https://cdn.example.com/sticker.gif';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouMarkdown(
            data: '![挥手]($url "wenyousite-sticker:asset-1")',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('markdown-image-$url')), findsNothing);
    expect(find.byKey(const Key('content-image-viewer')), findsNothing);
    expect(find.bySemanticsLabel('挥手'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
