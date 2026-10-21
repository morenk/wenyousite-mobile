import 'dart:convert';
import 'dart:io';

import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_semantics.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';

import '../../support/text_color_assertions.dart';

void main() {
  final fixtures =
      jsonDecode(
            File(
              'contracts/markdown-text-font-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  test('可解码 ID 等于 Backend 现役目录与退役档案，历史身份不重新开放', () {
    final catalog =
        jsonDecode(
              File('contracts/thread-font-catalog-v1.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
    final retired =
        jsonDecode(
              File(
                'contracts/archive/thread-font-xiaocheng-lafeng-v1.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final currentIds = (catalog['fonts'] as List)
        .map((e) => (e as Map)['id'])
        .toSet();
    final retiredId = (retired['font'] as Map)['id'];
    expect(currentIds, hasLength(28));
    expect(currentIds, isNot(contains(retiredId)));
    expect(MarkdownTextFont.ids, {...currentIds, retiredId});
  });
  for (final entry in fixtures['validCases'] as List) {
    final row = entry as Map<String, dynamic>;
    test('正式样例 ${row['id']}：可编辑文字、样式与重开保持', () {
      final source = row['source'] as String;
      final canonical = row['canonical'] as String;
      final decoded = MarkdownDeltaCodec.decode(source).delta;
      expect(
        decoded.operations.where((op) => op.attributes?['font'] != null),
        isNotEmpty,
      );
      expect(decoded.operations.every((op) => op.data is String), isTrue);
      final saved = MarkdownDeltaCodec.encode(decoded);
      expect(
        colorReaderUnits(colorReaderNodes(saved)),
        colorReaderUnits(colorReaderNodes(canonical)),
      );
      expect(
        MarkdownDeltaSemantics.equivalent(
          decoded,
          MarkdownDeltaCodec.decode(saved).delta,
        ),
        isTrue,
      );
    });
  }
  test('字体与 32 种行内格式、颜色组合独立核对阅读与重开', () {
    for (var mask = 0; mask < 32; mask++) {
      for (final color in [null, '#D14343']) {
        verifyColorSegments([
          ('甲', {...textColorMarks(mask, color), 'font': 'wenkai'}),
          ('何呢', {...textColorMarks(mask ^ 31, color), 'font': 'zhuque'}),
        ]);
      }
    }
  });
  test('移除最后字体保留危险开头字面与段落边界', () {
    for (final value in [
      '# 标题',
      '> 引用',
      '* 列表',
      '    缩进',
      '[链接](https://example.com)',
    ]) {
      final delta = Delta()
        ..insert(value, {MarkdownDeltaCodec.literalTextAttribute: true})
        ..insert('\n');
      final saved = MarkdownDeltaCodec.encode(delta);
      expect(
        colorReaderUnits(colorReaderNodes(saved)),
        colorExpectedUnits([(value, <String, Object>{})]),
      );
    }
  });
  test('未知字体保留兼容源码，不冒认成可编辑字体', () {
    const source = '<span data-wenyou-font-v1="future-font">未来字体</span>';
    final decoded = MarkdownDeltaCodec.decode(source).delta;
    expect(
      decoded.operations.where((op) => op.attributes?['font'] != null),
      isEmpty,
    );
    expect(MarkdownDeltaCodec.encode(decoded), source);
  });
}
