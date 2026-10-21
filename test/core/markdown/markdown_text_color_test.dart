import 'dart:convert';
import 'dart:io';

import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_semantics.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_rich_line_decoder.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_color.dart';

void main() {
  test('阅读解析也排除提及及音频/表情链接，不排除普通title', () {
    for (final inner in [
      '[@用户](/users/c111111111111111111111111)',
      '[音频](https://example.com/a "wenyousite-audio:v1:x")',
      '[表情](https://example.com/a "wenyousite-sticker:v1:x")',
    ]) {
      expect(MarkdownTextColor.parseInner(inner), isNull);
    }
    expect(
      MarkdownTextColor.parseInner('[普通](https://example.com "标题")'),
      isNotNull,
    );
  });
  final fixtures =
      jsonDecode(
            File(
              'contracts/markdown-text-color-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  for (final fixture in fixtures['validCases'] as List) {
    test('Backend color v1 ${fixture['id']} 编辑语义往返', () {
      final source = fixture['source'] as String;
      final decoded = MarkdownDeltaCodec.decode(source);
      final output = MarkdownDeltaCodec.encode(decoded.delta);
      expect(
        MarkdownDeltaSemantics.equivalent(
          decoded.delta,
          MarkdownDeltaCodec.decode(output).delta,
        ),
        isTrue,
      );
      if (![
        'plain',
        'code-literal',
        'escaped-literal',
      ].contains(fixture['id'])) {
        expect(
          decoded.delta.operations.any((op) => op.attributes?['color'] != null),
          isTrue,
          reason: '$source => ${decoded.delta}',
        );
        expect(output, contains('data-wenyou-color-v1='));
        expect(
          decoded.delta.operations
              .where((op) => op.data is String)
              .map((op) => op.data)
              .join(),
          isNot(contains('<span')),
        );
      }
    });
  }
  for (final source in fixtures['invalidSources'] as List) {
    test('损坏颜色保留源码且不着色 $source', () {
      final delta = MarkdownDeltaCodec.decode(source as String).delta;
      expect(
        delta.operations.every((op) => op.attributes?['color'] == null),
        isTrue,
      );
    });
  }
  test('有色中文、emoji、空格和组合格式独立可读', () {
    final delta = Delta()
      ..insert(' 中文😀 ', {'color': '#112233', 'bold': true})
      ..insert('\n');
    final source = MarkdownDeltaCodec.encode(delta);
    final reader = MarkdownRichLineDecoder.decode(source)!;
    expect(reader.spans.map((s) => s.text).join(), ' 中文😀 ');
    expect(
      reader.spans.every((s) => s.attributes?['color'] == '#112233'),
      isTrue,
    );
    expect(
      reader.spans
          .where((s) => s.text.contains('中文'))
          .single
          .attributes?['bold'],
      isTrue,
    );
  });
  test('转义原子语法是普通字面，颜色和可见文字保留', () {
    for (final pair in [
      (r'\@全体玩家', '@全体玩家'),
      (r'\[\[dice:v1:x:1d6\]\]', '[[dice:v1:x:1d6]]'),
      (
        r'\/threads/c111111111111111111111111',
        '/threads/c111111111111111111111111',
      ),
      ('`@全体玩家`', '@全体玩家'),
      ('`</span>`', '</span>'),
      ('`` `</span>` ``', '`</span>`'),
    ]) {
      final source = '<span data-wenyou-color-v1="#123456">${pair.$1}</span>';
      final line = MarkdownRichLineDecoder.decodeInline(source)!;
      expect(line.spans.map((s) => s.text).join(), pair.$2);
      expect(
        line.spans.every((s) => s.attributes?['color'] == '#123456'),
        isTrue,
      );
      final decoded = MarkdownDeltaCodec.decode(source);
      expect(decoded.delta.operations.first.attributes?['color'], '#123456');
      expect(
        MarkdownDeltaCodec.encode(decoded.delta),
        contains('data-wenyou-color-v1'),
      );
    }
  });
  test('语义门禁识别颜色丢失和颜色改变', () {
    final original = Delta()
      ..insert('文字', {'color': '#112233'})
      ..insert('\n');
    expect(
      MarkdownDeltaSemantics.equivalent(original, Delta()..insert('文字\n')),
      isFalse,
    );
    expect(
      MarkdownDeltaSemantics.equivalent(
        original,
        Delta()
          ..insert('文字', {'color': '#332211'})
          ..insert('\n'),
      ),
      isFalse,
    );
  });
  test('颜色和32种行内组合无损往返，保留独立阅读语义', () {
    for (var mask = 0; mask < 32; mask++) {
      final marks = <String, dynamic>{
        'color': '#123456',
        if (mask & 1 != 0) 'bold': true,
        if (mask & 2 != 0) 'italic': true,
        if (mask & 4 != 0) 'strike': true,
        if (mask & 8 != 0) 'code': true,
        if (mask & 16 != 0) 'link': 'https://example.com',
      };
      final delta = Delta()
        ..insert('组合文字😀', marks)
        ..insert('\n');
      final encoded = MarkdownDeltaCodec.encode(delta);
      final read = MarkdownRichLineDecoder.decode(encoded)!;
      expect(
        read.spans.map((span) => span.text).join(),
        '组合文字😀',
        reason: '$mask',
      );
      for (final entry in marks.entries) {
        expect(
          read.spans.single.attributes?[entry.key],
          entry.value,
          reason: '$mask ${entry.key}',
        );
      }
      expect(
        MarkdownDeltaSemantics.equivalent(
          delta,
          MarkdownDeltaCodec.decode(encoded).delta,
        ),
        isTrue,
        reason: '$mask',
      );
    }
  });
}
