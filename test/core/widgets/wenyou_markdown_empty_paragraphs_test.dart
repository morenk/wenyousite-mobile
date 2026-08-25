import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_overflow_content.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('连续协议标记逐段渲染且不暴露 HTML 文本', (tester) async {
    await tester.pumpWidget(
      _testApp(const WenyouMarkdown(data: '<br>\n<br/>\n<br >\n<br />')),
    );
    await tester.pump();

    expect(_emptyParagraphs(), findsNWidgets(4));
    for (var index = 0; index < 4; index++) {
      expect(
        tester
            .getSize(
              find.byKey(ValueKey('wenyou-markdown-empty-paragraph-$index')),
            )
            .height,
        closeTo(30.6, 0.01),
      );
    }
    expect(find.textContaining('<br', findRichText: true), findsNothing);
  });

  testWidgets('首部、中部与尾部历史空行恢复为对应空段', (tester) async {
    await tester.pumpWidget(
      _testApp(const WenyouMarkdown(data: '\n正文一\n\n\n正文二\n\n\n')),
    );
    await tester.pump();

    expect(_emptyParagraphs(), findsNWidgets(4));
    expect(find.textContaining('正文一', findRichText: true), findsOneWidget);
    expect(find.textContaining('正文二', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('空段高度参与长正文折叠并在展开后完整保留', (tester) async {
    await tester.pumpWidget(
      _testApp(
        Builder(
          builder: (context) => WenyouCollapsibleContent(
            contentIdentity: 'blank-paragraphs',
            triggerHeight: 180,
            collapsedHeight: 120,
            fadeColor: Theme.of(context).colorScheme.surface,
            actionKey: const Key('blank-paragraphs-action'),
            collapsedKey: const Key('blank-paragraphs-collapsed'),
            child: const WenyouMarkdown(
              data: '开头\n<br />\n<br />\n<br />\n<br />\n<br />\n<br />\n结尾',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_emptyParagraphs(), findsNWidgets(6));
    expect(find.byKey(const Key('blank-paragraphs-collapsed')), findsOneWidget);
    expect(find.text('展开全文'), findsOneWidget);

    await tester.tap(find.byKey(const Key('blank-paragraphs-action')));
    await tester.pumpAndSettle();

    expect(_emptyParagraphs(), findsNWidgets(6));
    expect(find.byKey(const Key('blank-paragraphs-collapsed')), findsNothing);
    expect(find.text('收起'), findsOneWidget);
  });

  testWidgets('360dp 空段落阅读基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 340);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: RepaintBoundary(
            key: Key('markdown-blank-paragraphs-visual'),
            child: ColoredBox(
              color: Color(0xFFFFFFFF),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: WenyouMarkdown(
                  data: '序章\n\n\n\n第一节\n<br />\n<br />\n尾声',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_emptyParagraphs(), findsNWidgets(4));
    await expectLater(
      find.byKey(const Key('markdown-blank-paragraphs-visual')),
      matchesGoldenFile('goldens/markdown_blank_paragraphs_360.png'),
    );
  });
}

Finder _emptyParagraphs() => find.byWidgetPredicate((widget) {
  final key = widget.key;
  return key is ValueKey<String> &&
      key.value.startsWith('wenyou-markdown-empty-paragraph-');
});

Widget _testApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 360, child: child),
      ),
    ),
  );
}
