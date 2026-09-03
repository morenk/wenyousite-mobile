import 'dart:convert';
import 'dart:io';

import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

void main() {
  final contract =
      jsonDecode(
            File(
              'contracts/markdown-v5-image-alignment-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final cases = (contract['cases'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  test('消费 Markdown v5 图片块对齐 fixture', () {
    expect(contract['markdownContractVersion'], 5);

    for (final testCase in cases) {
      final markdown = testCase['markdown'] as String;
      final supported = testCase['supported'] as bool;
      final expected = testCase['expectedAlignment'] as String?;
      final analysis = MarkdownAlignmentContract.analyze(
        markdown,
        imageAlignment: true,
      );

      expect(
        analysis.invalidMarkerLines.isEmpty,
        supported,
        reason: testCase['id'] as String,
      );
      if (expected == null || expected == 'left') {
        expect(analysis.blocks, isEmpty, reason: testCase['id'] as String);
      } else {
        expect(
          analysis.blocks.single.alignment.name,
          expected,
          reason: testCase['id'] as String,
        );
      }
    }
  });

  test('独立图片 Delta 可选择对齐并无损往返，文字混排仍拒绝', () {
    final image = Delta()
      ..insert({
        MarkdownDeltaCodec.imageEmbed: const {
          'version': 1,
          'url': 'https://cdn.example.com/image.webp',
          'alt': '图片',
          'title': null,
        },
      })
      ..insert('\n', const {MarkdownDeltaCodec.sourceBreakAttribute: false});
    final patch = MarkdownDeltaAlignment.applySelection(
      image,
      start: 0,
      end: 0,
      alignment: WenyouTextAlignment.center,
      imageEmbed: MarkdownDeltaCodec.imageEmbed,
      horizontalRuleEmbed: MarkdownDeltaCodec.horizontalRuleEmbed,
      imageAlignment: true,
    );
    final aligned = image.compose(patch);
    const markdown =
        '[wenyousite-align-v1-center]: #\n'
        '![图片](https://cdn.example.com/image.webp)';

    expect(MarkdownDeltaCodec.encode(aligned, imageAlignment: true), markdown);
    expect(
      MarkdownDeltaCodec.encode(
        MarkdownDeltaCodec.decode(markdown, imageAlignment: true).delta,
        imageAlignment: true,
      ),
      markdown,
    );

    final mixed = Delta()
      ..insert('正文 ')
      ..insert({
        MarkdownDeltaCodec.imageEmbed: const {
          'version': 1,
          'url': 'https://cdn.example.com/mixed.webp',
          'alt': '图片',
          'title': null,
        },
      })
      ..insert('\n', const {
        MarkdownDeltaCodec.alignmentAttribute: 'center',
        MarkdownDeltaCodec.sourceBreakAttribute: false,
      });
    expect(
      () => MarkdownDeltaCodec.encode(mixed, imageAlignment: true),
      throwsA(isA<MarkdownCodecException>()),
    );
  });

  test('空段前后的居中与居右图片编码为独立 Markdown 块', () {
    for (final alignment in const ['center', 'right']) {
      final delta = Delta()
        ..insert('\n', const {MarkdownDeltaCodec.emptyParagraphAttribute: true})
        ..insert({
          MarkdownDeltaCodec.imageEmbed: const {
            'version': 1,
            'url': 'https://cdn.example.com/image.webp',
            'alt': '图片',
            'title': null,
          },
        })
        ..insert('\n', {MarkdownDeltaCodec.alignmentAttribute: alignment})
        ..insert('\n', const {MarkdownDeltaCodec.emptyParagraphAttribute: true})
        ..insert('后文')
        ..insert('\n', const {MarkdownDeltaCodec.sourceBreakAttribute: false});

      expect(
        MarkdownDeltaCodec.encode(delta, imageAlignment: true),
        '<br />\n\n'
        '[wenyousite-align-v1-$alignment]: #\n'
        '![图片](https://cdn.example.com/image.webp)\n\n'
        '<br />\n'
        '后文',
      );
    }
  });
}
