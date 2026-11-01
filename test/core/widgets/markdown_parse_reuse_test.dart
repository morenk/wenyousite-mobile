import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown_body.dart';

class _CountingSyntax extends md.BlockSyntax {
  _CountingSyntax(this.onParse);
  final VoidCallback onParse;
  @override
  RegExp get pattern => RegExp(r'^count:');
  @override
  md.Node parse(md.BlockParser parser) {
    onParse();
    final line = parser.current.content;
    parser.advance();
    return md.Element.text('p', line);
  }
}

void main() {
  testWidgets('同正文只解析一次，字号更新复用，正文或语义变化重新解析', (tester) async {
    var parses = 0;
    final syntax = _CountingSyntax(() => parses++);
    Future<void> render(String data, double size, md.BlockSyntax rule) =>
        tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WenyouMarkdownBody(
                data: data,
                blockSyntaxes: [rule],
                styleSheet: MarkdownStyleSheet(p: TextStyle(fontSize: size)),
              ),
            ),
          ),
        );
    await render('count:原正文', 14, syntax);
    expect(parses, 1);
    expect(find.text('count:原正文'), findsOneWidget);
    await render('count:原正文', 20, syntax);
    expect(parses, 1);
    expect(
      tester.widget<Text>(find.text('count:原正文')).textSpan?.style?.fontSize,
      20,
    );
    await render('count:新正文', 20, syntax);
    expect(parses, 2);
    expect(find.text('count:新正文'), findsOneWidget);
    await render('count:新正文', 20, _CountingSyntax(() => parses++));
    expect(parses, 3);
    expect(tester.takeException(), isNull);
  });
}
