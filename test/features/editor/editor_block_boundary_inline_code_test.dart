import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  final actualSaves = <Map<String, dynamic>>[];
  tearDownAll(() {
    Directory('build').createSync(recursive: true);
    File('build/mobile-block-boundary-code-saves.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(actualSaves),
    );
  });
  for (final (prefix, block) in [
    ('', <String, dynamic>{}),
    ('- ', <String, dynamic>{'list': 'bullet'}),
    ('> ', <String, dynamic>{'blockquote': true}),
  ]) {
    testWidgets('跨行代码在真实 Quill 中保留容器并可输入保存 $prefix', (tester) async {
      final source = '$prefix😀 `代码\n[wenyousite-align-v1-center]: #\n正文`';
      String? emitted;
      final session = RichEditorSession(
        initialMarkdown: source,
        onMarkdownChanged: (value) => emitted = value,
      );
      addTearDown(session.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates:
              FlutterQuillLocalizations.localizationsDelegates,
          home: Scaffold(
            body: QuillEditor(
              controller: session.controller,
              focusNode: session.focusNode,
              scrollController: session.scrollController,
              config: const QuillEditorConfig(scrollable: false),
            ),
          ),
        ),
      );
      const text = '😀 代码 [wenyousite-align-v1-center]: # 正文\n';
      expect(session.controller.document.toPlainText(), text);
      expect(
        MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
        source,
      );
      final offset = text.indexOf('正文') + 1;
      session.controller.updateSelection(
        TextSelection.collapsed(offset: offset),
        ChangeSource.local,
      );
      session.focusNode.requestFocus();
      await tester.pump();
      tester.testTextInput.updateEditingValue(
        TextEditingValue(
          text: text.replaceRange(offset, offset, '续'),
          selection: TextSelection.collapsed(offset: offset + 1),
        ),
      );
      await tester.pumpAndSettle();
      final saved = MarkdownDeltaCodec.encode(
        session.controller.document.toDelta(),
      );
      expect(await session.flush(), isTrue);
      expect(emitted, saved);
      actualSaves.add({
        'id': 'inline-code-${block.keys.firstOrNull ?? 'paragraph'}',
        'markdown': emitted,
        'producer': 'RichEditorSession-IME-flush',
        'expectedBackendAccepted': true,
      });
      expect(
        MarkdownAlignmentContract.analyze(saved).validMarkerLines,
        isEmpty,
      );
      final reopened = RichEditorSession(
        initialMarkdown: saved,
        onMarkdownChanged: (_) {},
      );
      addTearDown(reopened.dispose);
      expect(
        reopened.controller.document.toPlainText(),
        text.replaceFirst('正文', '正续文'),
      );
      expect(
        reopened.controller.document
            .collectStyle(offset, 1)
            .attributes['code']
            ?.value,
        isTrue,
      );
      for (final entry in block.entries) {
        expect(
          reopened.controller.document
              .toDelta()
              .operations
              .last
              .attributes?[entry.key],
          entry.value,
        );
      }
      expect(
        MarkdownDeltaCodec.encode(reopened.controller.document.toDelta()),
        saved,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
