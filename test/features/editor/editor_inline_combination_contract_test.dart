import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_boundary.dart';
import 'package:wenyousite_mobile/features/editor/presentation/literal_text_quill_controller.dart';

import '../../support/inline_combination_assertions.dart';

typedef _Segments = List<(String, Map<String, Object>)>;

void main() {
  final fixture =
      jsonDecode(
            File(
              'contracts/markdown-inline-combinations-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final sets = (fixture['markSets'] as List).cast<Map<String, dynamic>>();
  final matrix = fixture['adjacencyMatrix'] as Map<String, dynamic>;
  final exports = <Map<String, Object?>>[];
  const export = bool.fromEnvironment('INLINE_COMBINATION_EXPORT');

  void verify(String id, _Segments segments) {
    final markdown = verifyInlineCombination(segments);
    if (export && (id.startsWith('adjacency-') || id.startsWith('text-'))) {
      exports.add({
        'id': id,
        'markdown': markdown,
        'expectedSegments': [
          for (final (text, marks) in segments) {'text': text, 'marks': marks},
        ],
      });
    }
  }

  test('中央语料版本和矩阵数量不漂移', () {
    expect(fixture['revision'], 2);
    expect(sets, hasLength(32));
    expect(matrix['expectedCaseCount'], 9216);
    expect(fixture['cases'], hasLength(15));
  });

  for (final distinct in [false, true]) {
    test(
      '完整中央邻接矩阵 distinctLink=$distinct',
      () {
        var count = 0;
        final failures = <String>[];
        for (final left in sets) {
          for (final right in sets) {
            final leftMarks = Map<String, Object>.from(left['marks'] as Map);
            final rightMarks = Map<String, Object>.from(right['marks'] as Map);
            if (distinct) {
              if (!leftMarks.containsKey('link') ||
                  !rightMarks.containsKey('link')) {
                continue;
              }
              final targets = matrix['distinctLinkTargets'] as Map;
              leftMarks['link'] = targets['left'] as String;
              rightMarks['link'] = targets['right'] as String;
            }
            for (final separator
                in (matrix['separators'] as List).cast<String>()) {
              for (final context in (matrix['contexts'] as List).cast<Map>()) {
                final id =
                    'adjacency-$distinct-${left['id']}-${right['id']}-${separator.length}-${context['prefix']}';
                count++;
                try {
                  verify(id, [
                    (context['prefix'] as String, {}),
                    (matrix['leftText'] as String, leftMarks),
                    (separator, {}),
                    (matrix['rightText'] as String, rightMarks),
                    (context['suffix'] as String, {}),
                  ]);
                } on Object catch (error) {
                  failures.add('$id: $error');
                }
              }
            }
          }
        }
        expect(count, distinct ? 2304 : 9216);
        expect(failures.take(10), isEmpty, reason: '${failures.length} 个失败组合');
      },
      timeout: const Timeout(Duration(minutes: 8)),
    );
  }

  test('完整中央文本矩阵及明确空白规则', () {
    var count = 0;
    final failures = <String>[];
    final textMatrix = fixture['textMatrix'] as Map;
    expect(
      (textMatrix['whitespacePolicy'] as Map)['withCode'],
      'preserve-all-text-and-marks',
    );
    for (final set in sets) {
      for (final text in (textMatrix['texts'] as List).cast<String>()) {
        final marks = Map<String, Object>.from(set['marks'] as Map);
        final segments = marks['code'] == true
            ? [(text, marks)]
            : _edgeWhitespace(text, marks);
        try {
          verify('text-${set['id']}-$count', segments);
        } on Object catch (error) {
          failures.add('${set['id']}/$text: $error');
        }
        count++;
      }
    }
    expect(count, textMatrix['expectedCaseCount']);
    expect(failures.take(10), isEmpty, reason: '${failures.length} 个失败组合');
  });

  for (final item in (fixture['cases'] as List).cast<Map>()) {
    test('中央命名场景 ${item['id']}', () {
      final segments = _segments(item['segments'] as List);
      if (item['kind'] == 'operation') {
        final delta = Delta();
        for (final (text, marks) in segments) {
          delta.insert(text, marks);
        }
        delta.insert('\n');
        final selection = item['selection'] as Map;
        final controller = LiteralTextQuillController(
          document: Document.fromDelta(delta),
          selection: TextSelection(
            baseOffset: selection['anchor'] as int,
            extentOffset: selection['focus'] as int,
          ),
          config: const QuillControllerConfig(),
        );
        addTearDown(controller.dispose);
        final before = controller.document.toDelta().toJson();
        final selected = controller.selection;
        final operation = item['operation'] as Map;
        controller.formatSelection(
          Attribute.fromKeyValue(
            operation['mark'] as String,
            operation['value'] == true ? true : null,
          ),
        );
        final expected = _segments(item['expectedSegments'] as List);
        final canonical = verifyInlineCombination(expected);
        expect(
          MarkdownDeltaCodec.encode(controller.document.toDelta()),
          canonical,
        );
        expect(controller.selection, selected);
        controller.undo();
        expect(controller.document.toDelta().toJson(), before);
        expect(controller.selection, selected);
        controller.redo();
        expect(
          MarkdownDeltaCodec.encode(controller.document.toDelta()),
          canonical,
        );
      } else {
        verify(item['id'] as String, segments);
        final source = item['canonical'] ?? item['markdown'];
        if (source is String) {
          final expected = _units(
            _segments((item['readingSegments'] ?? item['segments']) as List),
          );
          final prepared = item['kind'] == 'legacy-ambiguous'
              ? MarkdownInlineBoundary.canonicalize(source)
              : source;
          expect(
            inlineReadingUnits(
              md.Document(
                extensionSet: md.ExtensionSet.gitHubFlavored,
                encodeHtml: false,
              ).parseInline(prepared),
            ),
            expected,
          );
          final decoded = MarkdownDeltaCodec.decode(source).delta;
          expect(
            MarkdownDeltaCodec.encode(decoded),
            verifyInlineCombination(segments),
          );
        }
      }
    });
  }

  tearDownAll(() {
    if (export) {
      expect(exports, hasLength(11904));
      expect(
        const String.fromEnvironment('CANDIDATE_SHA'),
        matches(r'^[0-9a-f]{40}$'),
      );
      final file = File('build/inline-combinations-mobile.json');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(
        jsonEncode({
          'contract': 'wenyousite-inline-cross-client-result',
          'version': 1,
          'producer': 'mobile',
          'producerCommit': const String.fromEnvironment('CANDIDATE_SHA'),
          'fixtureRevision': fixture['revision'],
          'fixtureSha256': sha256
              .convert(
                File(
                  'contracts/markdown-inline-combinations-v1-fixtures.json',
                ).readAsBytesSync(),
              )
              .toString(),
          'fixtureCommit': 'f3cad6799d7fdd6b484d7341b3b918970767a190',
          'samples': exports,
        }),
      );
    }
  });
}

_Segments _segments(List values) => [
  for (final value in values.cast<Map>())
    (value['text'] as String, Map<String, Object>.from(value['marks'] as Map)),
];
List<Object> _units(_Segments segments) => [
  for (final (text, marks) in segments)
    for (final rune in text.runes)
      {'text': String.fromCharCode(rune), 'marks': marks},
];
_Segments _edgeWhitespace(String text, Map<String, Object> marks) {
  final core = text.trim();
  if (core.isEmpty) return [(text, {})];
  final leading = text.length - text.trimLeft().length;
  return [
    (text.substring(0, leading), {}),
    (core, marks),
    (text.substring(leading + core.length), {}),
  ];
}
