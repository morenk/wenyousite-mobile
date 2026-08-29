import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

void main() {
  group('Delta 对齐编码出口', () {
    final eligibleCases =
        <
          ({String label, int? header, String alignment, String expectedPrefix})
        >[
          (
            label: '正文居中',
            header: null,
            alignment: 'center',
            expectedPrefix: '',
          ),
          (label: '正文居右', header: null, alignment: 'right', expectedPrefix: ''),
          (
            label: 'H2 居中',
            header: 2,
            alignment: 'center',
            expectedPrefix: '## ',
          ),
          (
            label: 'H2 居右',
            header: 2,
            alignment: 'right',
            expectedPrefix: '## ',
          ),
          (
            label: 'H3 居中',
            header: 3,
            alignment: 'center',
            expectedPrefix: '### ',
          ),
          (
            label: 'H3 居右',
            header: 3,
            alignment: 'right',
            expectedPrefix: '### ',
          ),
        ];

    for (final testCase in eligibleCases) {
      test('${testCase.label}生成唯一 marker 并可重开', () {
        final attributes = <String, dynamic>{
          if (testCase.header != null) 'header': testCase.header,
          'align': testCase.alignment,
          MarkdownDeltaCodec.sourceBreakAttribute: false,
        };
        final delta = Delta()
          ..insert('正文')
          ..insert('\n', attributes);
        final marker = '[wenyousite-align-v1-${testCase.alignment}]: #\n';
        final expected = '$marker${testCase.expectedPrefix}正文';

        expect(MarkdownDeltaCodec.encode(delta), expected);
        expect(
          MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(expected).delta),
          expected,
        );
      });
    }

    test('缺省与显式 left 都归一为无属性、无 marker', () {
      for (final value in [null, 'left']) {
        final delta = Delta()
          ..insert('正文')
          ..insert('\n', {
            'align': ?value,
            MarkdownDeltaCodec.sourceBreakAttribute: false,
          });

        expect(MarkdownDeltaCodec.encode(delta), '正文');
        final patch = MarkdownDeltaAlignment.sanitize(
          delta,
          imageEmbed: MarkdownDeltaCodec.imageEmbed,
          horizontalRuleEmbed: MarkdownDeltaCodec.horizontalRuleEmbed,
        );
        final sanitized = delta.compose(patch);
        expect(_newlineAttributes(sanitized).single, isNot(contains('align')));
      }
    });

    for (final value in ['justify', 'CENTER', true, 1]) {
      test('未知 align 值 $value 在编码出口被拒绝', () {
        final delta = Delta()
          ..insert('正文')
          ..insert('\n', {
            'align': value,
            MarkdownDeltaCodec.sourceBreakAttribute: false,
          });

        expect(
          () => MarkdownDeltaCodec.encode(delta),
          throwsA(isA<MarkdownCodecException>()),
        );
      });
    }

    test('同一 Markdown 段落的多个物理行只写一个 marker', () {
      final delta = Delta()
        ..insert('第一行')
        ..insert('\n', const {'align': 'center'})
        ..insert('第二行')
        ..insert('\n', const {
          'align': 'center',
          MarkdownDeltaCodec.sourceBreakAttribute: false,
        });

      expect(
        MarkdownDeltaCodec.encode(delta),
        '[wenyousite-align-v1-center]: #\n第一行\n第二行',
      );
    });

    test('同一 Markdown 段落混合 left/center/right 时拒绝直接编码', () {
      final deltas = [
        Delta()
          ..insert('第一行')
          ..insert('\n', const {'align': 'center'})
          ..insert('第二行')
          ..insert('\n', const {
            'align': 'right',
            MarkdownDeltaCodec.sourceBreakAttribute: false,
          }),
        Delta()
          ..insert('第一行')
          ..insert('\n', const {'align': 'right'})
          ..insert('第二行')
          ..insert('\n', const {
            MarkdownDeltaCodec.sourceBreakAttribute: false,
          }),
      ];

      for (final delta in deltas) {
        expect(
          () => MarkdownDeltaCodec.encode(delta),
          throwsA(isA<MarkdownCodecException>()),
        );
      }
    });
  });

  group('Delta 选择边界与循环', () {
    const source =
        '左段\n\n'
        '[wenyousite-align-v1-center]: #\n中段\n\n'
        '[wenyousite-align-v1-right]: #\n右段';

    test('折叠光标在文字、终止换行和空白分隔处只命中预期块', () {
      final delta = MarkdownDeltaCodec.decode(source).delta;
      final plainText = Document.fromDelta(delta).toPlainText();
      final left = plainText.indexOf('左段');
      final center = plainText.indexOf('中段');
      final right = plainText.indexOf('右段');
      final separator = plainText.indexOf('\n\n') + 1;

      expect(_selectionAlignment(delta, left, left), WenyouTextAlignment.left);
      expect(
        _selectionAlignment(delta, center, center),
        WenyouTextAlignment.center,
      );
      expect(
        _selectionAlignment(delta, right, right),
        WenyouTextAlignment.right,
      );
      expect(
        _selectionAlignment(delta, plainText.length - 1, plainText.length - 1),
        WenyouTextAlignment.right,
      );
      expect(
        _selectionAlignment(delta, separator, separator),
        WenyouTextAlignment.left,
      );
      expect(_cycle(delta, separator, separator), isEmpty);
    });

    test('跨越混合方向的选区按 left 状态一次统一为 center', () {
      final delta = MarkdownDeltaCodec.decode(source).delta;
      final changed = delta.compose(
        _cycle(delta, 0, _documentLength(delta) - 1),
      );

      expect(
        MarkdownDeltaCodec.encode(changed),
        '[wenyousite-align-v1-center]: #\n左段\n\n'
        '[wenyousite-align-v1-center]: #\n中段\n\n'
        '[wenyousite-align-v1-center]: #\n右段',
      );
    });

    test('合法段落与列表混选时只修改合法块，列表保持原样', () {
      final delta = MarkdownDeltaCodec.decode('前段\n\n- 列表\n\n后段').delta;
      final changed = delta.compose(
        _cycle(delta, 0, _documentLength(delta) - 1),
      );

      expect(
        MarkdownDeltaCodec.encode(changed),
        '[wenyousite-align-v1-center]: #\n前段\n\n- 列表\n\n'
        '[wenyousite-align-v1-center]: #\n后段',
      );
    });

    test('光标落在第二物理行时循环整个 Markdown 段落', () {
      final delta = MarkdownDeltaCodec.decode('第一行\n第二行').delta;
      final secondLine = Document.fromDelta(delta).toPlainText().indexOf('第二行');
      final changed = delta.compose(_cycle(delta, secondLine, secondLine));

      expect(
        MarkdownDeltaCodec.encode(changed),
        '[wenyousite-align-v1-center]: #\n第一行\n第二行',
      );
      expect(
        _newlineAttributes(changed).map((attributes) => attributes['align']),
        ['center', 'center'],
      );
    });

    test('列表、引用、图片、分隔线、空段、兼容行和 H1/H4 不响应循环', () {
      final excluded = <Delta>[
        _textLine('列表', {'list': 'bullet'}),
        _textLine('引用', {'blockquote': true}),
        _textLine('一级标题', {'header': 1}),
        _textLine('四级标题', {'header': 4}),
        _textLine('兼容', {MarkdownDeltaCodec.literalLineAttribute: true}),
        Delta()..insert('\n', const {
          MarkdownDeltaCodec.emptyParagraphAttribute: true,
          MarkdownDeltaCodec.sourceBreakAttribute: false,
        }),
        Delta()
          ..insert({
            MarkdownDeltaCodec.imageEmbed: const {
              'version': 1,
              'url': 'https://cdn.example.com/a.png',
              'alt': '图片',
              'title': null,
            },
          })
          ..insert('\n', const {
            MarkdownDeltaCodec.sourceBreakAttribute: false,
          }),
        Delta()
          ..insert({
            MarkdownDeltaCodec.horizontalRuleEmbed: const {'version': 1},
          })
          ..insert('\n', const {
            MarkdownDeltaCodec.sourceBreakAttribute: false,
          }),
      ];

      for (final delta in excluded) {
        expect(_cycle(delta, 0, _documentLength(delta) - 1), isEmpty);
      }
    });
  });

  group('Delta 非法对齐清洗', () {
    test('所有排除块都会移除继承或注入的 align', () {
      final excluded = <Delta>[
        _textLine('列表', {'list': 'ordered', 'align': 'center'}),
        _textLine('引用', {'blockquote': true, 'align': 'right'}),
        _textLine('缩进', {'indent': 1, 'align': 'center'}),
        _textLine('H1', {'header': 1, 'align': 'right'}),
        _textLine('H4', {'header': 4, 'align': 'center'}),
        _textLine('兼容', {
          MarkdownDeltaCodec.literalLineAttribute: true,
          'align': 'right',
        }),
        Delta()..insert('\n', const {
          MarkdownDeltaCodec.emptyParagraphAttribute: true,
          'align': 'center',
          MarkdownDeltaCodec.sourceBreakAttribute: false,
        }),
        Delta()
          ..insert({
            MarkdownDeltaCodec.imageEmbed: const {
              'version': 1,
              'url': 'https://cdn.example.com/a.png',
              'alt': '图片',
              'title': null,
            },
          })
          ..insert('\n', const {
            'align': 'right',
            MarkdownDeltaCodec.sourceBreakAttribute: false,
          }),
        Delta()
          ..insert({
            MarkdownDeltaCodec.horizontalRuleEmbed: const {'version': 1},
          })
          ..insert('\n', const {
            'align': 'center',
            MarkdownDeltaCodec.sourceBreakAttribute: false,
          }),
      ];

      for (final delta in excluded) {
        final sanitized = delta.compose(_sanitize(delta));
        expect(
          _newlineAttributes(
            sanitized,
          ).every((attributes) => !attributes.containsKey('align')),
          isTrue,
        );
      }
    });

    test('未知值和同段混合值统一清回 left，合法 H2/H3 保持', () {
      final malformed = Delta()
        ..insert('第一行')
        ..insert('\n', const {'align': 'center'})
        ..insert('第二行')
        ..insert('\n', const {
          'align': 'unexpected',
          MarkdownDeltaCodec.sourceBreakAttribute: false,
        });
      final sanitized = malformed.compose(_sanitize(malformed));
      expect(
        _newlineAttributes(
          sanitized,
        ).every((attributes) => !attributes.containsKey('align')),
        isTrue,
      );

      for (final delta in [
        _textLine('二级标题', {'header': 2, 'align': 'center'}),
        _textLine('三级标题', {'header': 3, 'align': 'right'}),
      ]) {
        expect(_sanitize(delta), isEmpty);
      }
    });
  });
}

WenyouTextAlignment _selectionAlignment(Delta delta, int start, int end) =>
    MarkdownDeltaAlignment.selectionAlignment(
      delta,
      start: start,
      end: end,
      imageEmbed: MarkdownDeltaCodec.imageEmbed,
      horizontalRuleEmbed: MarkdownDeltaCodec.horizontalRuleEmbed,
    );

Delta _cycle(Delta delta, int start, int end) =>
    MarkdownDeltaAlignment.cycleSelection(
      delta,
      start: start,
      end: end,
      imageEmbed: MarkdownDeltaCodec.imageEmbed,
      horizontalRuleEmbed: MarkdownDeltaCodec.horizontalRuleEmbed,
    );

Delta _sanitize(Delta delta) => MarkdownDeltaAlignment.sanitize(
  delta,
  imageEmbed: MarkdownDeltaCodec.imageEmbed,
  horizontalRuleEmbed: MarkdownDeltaCodec.horizontalRuleEmbed,
);

Delta _textLine(String text, Map<String, dynamic> attributes) => Delta()
  ..insert(text)
  ..insert('\n', {
    ...attributes,
    MarkdownDeltaCodec.sourceBreakAttribute: false,
  });

int _documentLength(Delta delta) => delta.operations.fold(
  0,
  (length, operation) => length + (operation.length ?? 0),
);

List<Map<String, dynamic>> _newlineAttributes(Delta delta) {
  final output = <Map<String, dynamic>>[];
  for (final operation in delta.operations) {
    final data = operation.data;
    if (data is! String) continue;
    for (var index = 0; index < data.length; index++) {
      if (data[index] == '\n') {
        output.add(Map<String, dynamic>.from(operation.attributes ?? const {}));
      }
    }
  }
  return output;
}
