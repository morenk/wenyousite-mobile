import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_color_selection.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/text_color_assertions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const image = '![图](https://example.com/a.png)';
  const red = '#D14343';
  final cases = [
    ('RGB', red, true, <Attribute>[]),
    ('默认色', null, true, <Attribute>[]),
    ('能力关闭', null, false, <Attribute>[]),
    ('RGB粗斜体', red, true, [Attribute.bold, Attribute.italic]),
    ('默认色粗体', null, true, [Attribute.bold]),
  ];
  for (final withImage in [false, true]) {
    for (final (label, color, enabled, marks) in cases) {
      test('含LF多字符String逐文字着色：$label 图片$withImage', () async {
        final session = RichEditorSession(
          initialMarkdown: withImage ? '$image\n\n甲' : '甲',
          onMarkdownChanged: (_) {},
        );
        addTearDown(session.dispose);
        expect(session.isSourceProtected, isFalse);
        final controller = session.controller;
        final at = controller.document.length - 1;
        controller.updateSelection(
          TextSelection.collapsed(offset: at),
          ChangeSource.local,
        );
        controller.textColorInputEnabled = enabled;
        for (final mark in marks) {
          controller.formatSelection(mark);
        }
        if (enabled) {
          expect(
            EditorTextColorPolicy.apply(
              controller,
              controller.selection,
              color,
            ),
            isTrue,
          );
        }
        final before = controller.document.toDelta();
        const inserted = '\n乙\n😀';
        controller.replaceText(
          at,
          0,
          inserted,
          TextSelection.collapsed(offset: at + inserted.length),
        );
        final delta = controller.document.toDelta();
        final expected = colorExpectedUnits([
          ('甲', {}),
          (
            '乙😀',
            {
              'color': ?color,
              for (final mark in marks) mark.key: mark.value as Object,
            },
          ),
        ]);
        expect(controller.document.toPlainText(), endsWith('甲\n乙\n😀\n'));
        expect(colorDeltaUnits(delta), expected);
        for (final operation in delta.operations) {
          final data = operation.data;
          if (data is Map || (data is String && data.contains('\n'))) {
            for (final key in textColorMarkKeys) {
              expect(operation.attributes?[key], isNull, reason: '$operation');
            }
          }
        }
        expect(await session.flush(), isTrue, reason: session.codecFailure);
        final saved = session.localMarkdown;
        if (withImage) expect(image.allMatches(saved), hasLength(1));
        expect(
          colorReaderUnits(
            colorReaderNodes(saved),
          ).where((unit) => (unit as Map)['text'] != '\n'),
          expected,
        );
        expect(
          colorDeltaUnits(MarkdownDeltaCodec.decode(saved).delta),
          expected,
        );
        controller.undo();
        expect(controller.document.toDelta(), before);
        controller.redo();
        expect(controller.document.toDelta(), delta);
      });
    }
  }

  for (final (label, source, original, inserted) in [
    ('继承粗体', '**甲乙**', {'bold': true}, {'bold': true}),
    (
      '继承粗斜体',
      '**_甲乙_**',
      {'bold': true, 'italic': true},
      {'bold': true, 'italic': true},
    ),
    ('显式关闭粗体', '**甲乙**', {'bold': true}, <String, bool>{}),
  ]) {
    test('含LF多字符String保留当前位置样式并尊重显式覆盖：$label', () async {
      final session = RichEditorSession(
        initialMarkdown: '<span data-wenyou-color-v1="$red">$source</span>',
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      final controller = session.controller;
      controller.updateSelection(
        const TextSelection.collapsed(offset: 1),
        ChangeSource.local,
      );
      if (inserted.isEmpty) {
        controller.formatSelection(Attribute.clone(Attribute.bold, null));
      }
      controller.replaceText(
        1,
        0,
        '丙\n丁',
        const TextSelection.collapsed(offset: 4),
      );
      final expected = colorExpectedUnits([
        ('甲', {...original, 'color': red}),
        ('丙丁', {...inserted, 'color': red}),
        ('乙', {...original, 'color': red}),
      ]);
      expect(controller.document.toPlainText(), '甲丙\n丁乙\n');
      expect(colorDeltaUnits(controller.document.toDelta()), expected);
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      expect(
        colorReaderUnits(
          colorReaderNodes(session.localMarkdown),
        ).where((unit) => (unit as Map)['text'] != '\n'),
        expected,
      );
      expect(
        colorDeltaUnits(MarkdownDeltaCodec.decode(session.localMarkdown).delta),
        expected,
      );
    });
  }
}
