import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown_image.dart';

void main() {
  final fixture =
      jsonDecode(
            File('contracts/gallery-image-occurrences.json').readAsStringSync(),
          )
          as Map<String, Object?>;
  for (final entry in fixture['cases']! as List) {
    final row = entry as Map<String, Object?>;
    testWidgets('共享正文图集位置 ${row['id']}', (tester) async {
      final opened = <(int, String)>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: WenyouMarkdown(
                data: row['markdown']! as String,
                onOpenImage: (index, uri, alt) =>
                    opened.add((index, uri.toString())),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      for (final widget in tester.widgetList<WenyouMarkdownImage>(
        find.byType(WenyouMarkdownImage),
      )) {
        widget.onOpen?.call();
      }
      final urls = (row['urls']! as List).cast<String>();
      expect(opened, [
        for (var index = 0; index < urls.length; index++) (index, urls[index]),
      ]);
      expect(tester.takeException(), isNull);
    });
  }
}
