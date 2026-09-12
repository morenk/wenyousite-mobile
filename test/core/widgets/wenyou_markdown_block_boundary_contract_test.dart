import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import '../../support/block_boundary_fixtures.dart';
import '../../support/deterministic_test_fonts.dart';
import '../../support/markdown_rendered_text.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  final fixture = loadBlockBoundaryFixture();
  for (final item in (fixture['cases'] as List).cast<Map<String, dynamic>>()) {
    if (item['supported'] != true) continue;
    testWidgets('真实阅读共享块 ${item['id']} 保存前后一致', (tester) async {
      final source = item['markdown'] as String;
      final saved = MarkdownDeltaCodec.encode(
        MarkdownDeltaCodec.decode(source, imageAlignment: true).delta,
        imageAlignment: true,
      );
      for (final value in [source, saved]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(child: WenyouMarkdown(data: value)),
            ),
          ),
        );
        await tester.pump();
        final rendered = markdownRenderedText(
          tester.element(find.byType(WenyouMarkdown)),
        );
        final expected = (item['blocks'] as List)
            .cast<Map<String, dynamic>>()
            .where((block) => block['alignment'] != 'left')
            .toList();
        final aligned = tester
            .widgetList<MarkdownBody>(find.bySubtype<MarkdownBody>())
            .where((body) => body.styleSheet!.textAlign != WrapAlignment.start)
            .toList();
        expect(aligned.length, expected.length);
        for (var i = 0; i < expected.length; i++) {
          final body = aligned[i];
          final block = expected[i];
          final direction = block['alignment'] == 'center'
              ? WrapAlignment.center
              : WrapAlignment.end;
          expect(body.styleSheet!.textAlign, direction);
          expect(body.styleSheet!.h2Align, direction);
          expect(body.styleSheet!.h3Align, direction);
          for (final line in (block['lines'] as List).cast<String>()) {
            if (line == '[图片]') {
              expect(body.data, contains('!['));
            } else if (line.isNotEmpty) {
              expect(rendered, contains(line));
            }
          }
        }
        if (!(item['visibleText'] as String).contains('wenyousite-align')) {
          expect(
            find.textContaining('wenyousite-align', findRichText: true),
            findsNothing,
          );
        }
        for (final line in (item['lines'] as List).cast<String>()) {
          if (line.isNotEmpty && line != '[图片]') {
            expect(rendered, contains(line));
          }
        }
        expect(tester.takeException(), isNull);
      }
    });
  }
  final original =
      jsonDecode(
            File(
              'test/fixtures/markdown-block-boundary-original-space.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  testWidgets('原始三列空格在阅读文字树中逐字符保留', (tester) async {
    final source = original['markdown'] as String;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(child: WenyouMarkdown(data: source)),
        ),
      ),
    );
    await tester.pump();
    for (final line in source.split('\n').where((line) => line.isNotEmpty)) {
      expect(
        find.textContaining(
          line.replaceFirst(RegExp(r'^ {1,3}(?=\u2060)'), ''),
          findRichText: true,
        ),
        findsWidgets,
      );
    }
    expect(tester.takeException(), isNull);
  });
}
