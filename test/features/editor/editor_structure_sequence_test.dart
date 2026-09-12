import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_format_policy.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

enum _Format { body, h2, h3, quote, bullet, ordered }

void main() {
  const surroundings = [
    ('前文', '后文'),
    ('> 前文', '1. 后文'),
    ('1. 前文', '> 后文'),
    ('## 前文', '- 后文'),
  ];
  for (final around in surroundings) {
    for (final blanks in [1, 2]) {
      for (final initial in _Format.values) {
        for (final target in _Format.values) {
          testWidgets('上下文 $around 空行 $blanks $initial→$target 连续编辑', (
            tester,
          ) async {
            final gap = List.filled(blanks, '<br />').join('\n\n');
            final session = RichEditorSession(
              initialMarkdown:
                  '${around.$1}\n\n$gap\n\n${_source(initial, '甲')}\n\n$gap\n\n${around.$2}',
              onMarkdownChanged: (_) {},
            );
            addTearDown(session.dispose);
            final controller = session.controller;
            final prefix = '前文\n${'\n' * blanks}';
            final suffix = '\n${'\n' * blanks}后文\n';
            final row = 1 + blanks;
            final offset = prefix.length;
            await _check(tester, session, '$prefix甲$suffix', row, initial);

            _replace(controller, offset, 1, '');
            await _check(tester, session, '$prefix$suffix', row, initial);
            _apply(controller, target);
            final togglesOff =
                initial == target &&
                [
                  _Format.quote,
                  _Format.bullet,
                  _Format.ordered,
                ].contains(target);
            final selected = togglesOff ? _Format.body : target;
            await _check(tester, session, '$prefix$suffix', row, selected);

            _replace(controller, offset, 0, '乙');
            await _check(tester, session, '$prefix乙$suffix', row, selected);
            _replace(controller, offset + 1, 0, '\n');
            final next = [_Format.h2, _Format.h3].contains(selected)
                ? _Format.body
                : selected;
            await _check(tester, session, '$prefix乙\n$suffix', row + 1, next);
            _replace(controller, offset + 2, 0, '丙');
            await _check(tester, session, '$prefix乙\n丙$suffix', row + 1, next);
            _replace(controller, offset + 2, 1, '');
            await _check(tester, session, '$prefix乙\n$suffix', row + 1, next);

            final saved = MarkdownDeltaCodec.encode(
              controller.document.toDelta(),
            );
            final reopened = RichEditorSession(
              initialMarkdown: saved,
              onMarkdownChanged: (_) {},
            );
            try {
              await _check(
                tester,
                reopened,
                '$prefix乙\n$suffix',
                row + 1,
                next,
              );
            } finally {
              reopened.dispose();
            }
          });
        }
      }
    }
  }
}

String _source(_Format format, String text) => switch (format) {
  _Format.body => text,
  _Format.h2 => '## $text',
  _Format.h3 => '### $text',
  _Format.quote => '> $text',
  _Format.bullet => '- $text',
  _Format.ordered => '1. $text',
};

void _replace(
  QuillController controller,
  int offset,
  int length,
  String text,
) => controller.replaceText(
  offset,
  length,
  text,
  TextSelection.collapsed(offset: offset + text.length),
);

void _apply(QuillController controller, _Format format) {
  switch (format) {
    case _Format.body:
      WenyouEditorFormatPolicy.applyHeading(controller, 0);
    case _Format.h2:
      WenyouEditorFormatPolicy.applyHeading(controller, 2);
    case _Format.h3:
      WenyouEditorFormatPolicy.applyHeading(controller, 3);
    case _Format.quote:
      WenyouEditorFormatPolicy.toggle(controller, Attribute.blockQuote);
    case _Format.bullet:
      WenyouEditorFormatPolicy.toggle(controller, Attribute.ul);
    case _Format.ordered:
      WenyouEditorFormatPolicy.toggle(controller, Attribute.ol);
  }
}

Future<void> _check(
  WidgetTester tester,
  RichEditorSession session,
  String text,
  int row,
  _Format format,
) async {
  await tester.pump();
  expect(session.controller.document.toPlainText(), text);
  expect(await session.flush(), isTrue, reason: session.codecFailure);
  final source = MarkdownDeltaCodec.encode(
    session.controller.document.toDelta(),
  );
  final decoded = MarkdownDeltaCodec.decode(source).delta;
  final lines = <Map<String, dynamic>>[];
  for (final operation in decoded.operations) {
    if (operation.data case final String value) {
      for (var i = 0; i < '\n'.allMatches(value).length; i++) {
        lines.add(operation.attributes ?? {});
      }
    }
  }
  expect(Document.fromDelta(decoded).toPlainText(), text);
  final attributes = lines[row];
  expect(attributes['header'], switch (format) {
    _Format.h2 => 2,
    _Format.h3 => 3,
    _ => null,
  });
  expect(attributes['list'], switch (format) {
    _Format.bullet => 'bullet',
    _Format.ordered => 'ordered',
    _ => null,
  });
  expect(attributes['blockquote'] == true, format == _Format.quote);
}
