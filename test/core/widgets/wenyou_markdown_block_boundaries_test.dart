import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

void main() {
  for (final alignment in ['center', 'right']) {
    for (final heading in ['', '## ', '### ']) {
      final source = '经历：\n[wenyousite-align-v1-$alignment]: #\n$heading目标正文';
      testWidgets(
        '前置正文无空行接 $alignment ${heading.isEmpty ? 'P' : heading} 保持块边界',
        (tester) async {
          final analysis = MarkdownAlignmentContract.analyze(source);
          expect(analysis.validMarkerLines, {1});
          expect(analysis.invalidMarkerLines, isEmpty);
          expect(analysis.blocks.single.startLine, 2);
          expect(analysis.blocks.single.endLine, 2);
          final decoded = MarkdownDeltaCodec.decode(source);
          expect(decoded.issues, isEmpty);
          expect(
            decoded.delta.toJson().last['attributes'],
            containsPair('align', alignment),
          );
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(body: WenyouMarkdown(data: source)),
            ),
          );
          await tester.pump();
          final segment = find.byKey(
            ValueKey('wenyou-markdown-segment-1-$alignment'),
          );
          final body = tester.widget<MarkdownBody>(
            find.descendant(
              of: segment,
              matching: find.bySubtype<MarkdownBody>(),
            ),
          );
          final expected = alignment == 'center'
              ? WrapAlignment.center
              : WrapAlignment.end;
          expect(switch (heading) {
            '## ' => body.styleSheet!.h2Align,
            '### ' => body.styleSheet!.h3Align,
            _ => body.styleSheet!.textAlign,
          }, expected);
          expect(find.text('经历：', findRichText: true), findsOneWidget);
          expect(find.text('目标正文', findRichText: true), findsOneWidget);
          expect(
            find.textContaining('wenyousite-align', findRichText: true),
            findsNothing,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
