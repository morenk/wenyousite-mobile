import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown_inline_builder.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('所有自定义行内元素必须注册统一排版入口', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: WenyouMarkdown(data: '`code`')),
      ),
    );
    final renderer = tester.widget<MarkdownBody>(
      find.bySubtype<MarkdownBody>(),
    );
    final inlineBuilders = renderer.builders.entries.where(
      (entry) => !entry.value.isBlockElement(),
    );
    expect(inlineBuilders, isNotEmpty);
    for (final entry in inlineBuilders) {
      expect(
        entry.value,
        isA<WenyouMarkdownInlineBuilder>(),
        reason: entry.key,
      );
    }
  });

  const samples = {
    '粗体': '**样式**',
    '斜体': '*样式*',
    '删除线': '~~样式~~',
    '普通链接': '[样式](https://wenyou.site/help)',
    '行内代码': '`code`',
    '用户提及': '[@张三](/users/user-zhang)',
    '全体提及': '@全体玩家',
    '站内传送门': '[入口](/threads/cmsewdo0h000x7qv6aa77ll1v)',
    '骰子': '[[dice:v1:550e8400-e29b-41d4-a716-446655440000:1d20]]',
    '收藏表情':
        '![挥手](https://wenyou.site/test-sticker.png "wenyousite-sticker:asset-1")',
  };

  for (final sample in samples.entries) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('${sample.key} 前后换行保持文字行首 scale=$scale', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(360, 800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: WenyouMarkdown(data: '甲\n${sample.value}\n乙'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final before = _characterRect(tester, '甲');
        final after = _characterRect(tester, '乙');
        expect(after.left, closeTo(before.left, 0.5));
        expect(after.top, greaterThan(before.bottom));
        for (final richText in find.byType(RichText).evaluate()) {
          final paragraph = richText.renderObject! as RenderParagraph;
          paragraph.visitChildren((child) {
            if (child is! RenderBox) return;
            final rect = child.localToGlobal(Offset.zero) & child.size;
            // 原子表情、提及点击区及长代码都必须占据真实的行高。
            expect(after.top, greaterThanOrEqualTo(rect.bottom - 0.5));
          });
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}

Rect _characterRect(WidgetTester tester, String character) {
  final finder = find.byWidgetPredicate(
    (widget) =>
        widget is RichText && widget.text.toPlainText().contains(character),
  );
  expect(finder, findsOneWidget);
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  final offset = paragraph.text.toPlainText().indexOf(character);
  return paragraph
      .getBoxesForSelection(
        TextSelection(baseOffset: offset, extentOffset: offset + 1),
      )
      .single
      .toRect()
      .shift(paragraph.localToGlobal(Offset.zero));
}
