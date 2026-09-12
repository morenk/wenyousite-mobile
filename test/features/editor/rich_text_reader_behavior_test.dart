import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown_body.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/rich_text_behavior_projection.dart';
import '../../support/rich_text_behavior_report.dart';
import '../../support/rich_text_reader_projection.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  final report = RichTextBehaviorReport('reader');
  final fixture =
      jsonDecode(
            File(
              'contracts/rich-text-behavior-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as BehaviorJson;
  for (final item in (fixture['cases'] as List).cast<BehaviorJson>()) {
    testWidgets('实际阅读组件共享行为 ${item['id']}', (tester) async {
      final points = <String, BehaviorJson>{
        'initial': item['initial'] as BehaviorJson,
        for (final step in (item['steps'] as List).cast<BehaviorJson>())
          step['id'] as String: step['expected'] as BehaviorJson,
      };
      for (final point in points.entries) {
        final canonical = point.value['canonical'] as String?;
        if (canonical == null) {
          report.unavailable(
            item['id'] as String,
            point.key,
            'reader',
            'not-applicable',
          );
          continue;
        }
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: WenyouMarkdown(
                  data: canonical,
                  enablePlainTextFastPath: false,
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final summary = projectReader(
          tester.widgetList<WenyouMarkdownBody>(
            find.byType(WenyouMarkdownBody),
          ),
        );
        expect(
          summary,
          point.value['summary'],
          reason: '${item['id']}/${point.key}/reader',
        );
        report.observe(item['id'] as String, point.key, 'reader', {
          'canonical': canonical,
          'summary': summary,
        });
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
