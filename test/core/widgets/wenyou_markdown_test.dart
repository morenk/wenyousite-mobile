import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

void main() {
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

    await tester.pumpWidget(app(const {nodeId: '1d20 = 16'}));
    await tester.pump();

    expect(find.text('1d20 = ?'), findsNothing);
    expect(find.text('1d20 = 16'), findsOneWidget);
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
}
