import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_color.dart';
import '../../support/text_color_assertions.dart';

void main() {
  test('真机复现：如何呢整段预设色与居中同时保存并重开', () {
    final delta = Delta()
      ..insert('如何呢', {
        MarkdownDeltaCodec.literalTextAttribute: true,
        'color': '#D14343',
      })
      ..insert('\n', {'align': 'center'});
    final saved = MarkdownDeltaCodec.encode(delta);
    expect(saved, contains('[wenyousite-align-v1-center]: #\n'));
    final blocks = MarkdownAlignmentContract.renderSegments(saved);
    expect(blocks.single.alignment, WenyouTextAlignment.center);
    final reopened = MarkdownDeltaCodec.decode(saved).delta;
    expect(reopened.operations.first.data, '如何呢');
    expect(reopened.operations.first.attributes?['color'], '#D14343');
    expect(reopened.operations.last.attributes?['align'], 'center');
  });

  for (final header in [null, 2, 3]) {
    for (final alignment in WenyouTextAlignment.values) {
      test('颜色与32种样式组合在 header=$header / $alignment 保留块归属', () {
        for (var mask = 0; mask < 32; mask++) {
          final marks = textColorMarks(mask);
          final delta = Delta()
            ..insert('如何呢😀', {
              ...marks,
              MarkdownDeltaCodec.literalTextAttribute: true,
            })
            ..insert('\n', {'header': ?header, 'align': alignment.name});
          final saved = MarkdownDeltaCodec.encode(delta);
          final segments = MarkdownAlignmentContract.renderSegments(saved);
          expect(segments.single.alignment, alignment);
          final nodes = colorReaderNodes(segments.single.markdown);
          expect(
            (nodes.single as md.Element).tag,
            header == null ? 'p' : 'h$header',
          );
          final expected = colorExpectedUnits([('如何呢😀', marks)]);
          expect(colorReaderUnits(nodes), expected, reason: saved);
          final reopened = MarkdownDeltaCodec.decode(saved).delta;
          expect(colorDeltaUnits(reopened), expected);
          expect(reopened.operations.last.attributes?['header'], header);
          expect(
            reopened.operations.last.attributes?['align'],
            alignment == WenyouTextAlignment.left ? null : alignment.name,
          );
        }
      });
    }
  }

  test('对齐中的混色软换行与段间空白保持各自范围和块边界', () {
    const red = '<span data-wenyou-color-v1="#D14343">如何</span>';
    const blue = '<span data-wenyou-color-v1="#2563EB">呢😀</span>';
    const source =
        '[wenyousite-align-v1-center]: #\n$red\n$blue\n\n'
        '<br />\n\n[wenyousite-align-v1-right]: #\n## $red$blue';
    final delta = MarkdownDeltaCodec.decode(source).delta;
    final saved = MarkdownDeltaCodec.encode(delta);
    final segments = MarkdownAlignmentContract.renderSegments(saved);
    final aligned = segments.where((segment) => segment.isAligned).toList();
    expect(aligned.map((s) => s.alignment), [
      WenyouTextAlignment.center,
      WenyouTextAlignment.right,
    ]);
    expect(aligned.first.markdown.split('\n').length, 2);
    expect(
      colorReaderUnits(colorReaderNodes(aligned.first.markdown)),
      colorExpectedUnits([
        ('如何', {'color': '#D14343'}),
        ('\n', {}),
        ('呢😀', {'color': '#2563EB'}),
      ]),
    );
    expect(saved, contains('<br />'));
    final reopened = MarkdownDeltaCodec.decode(saved).delta;
    expect(
      reopened.operations
          .where(
            (op) =>
                op.attributes?[MarkdownDeltaCodec.emptyParagraphAttribute] ==
                true,
          )
          .length,
      1,
    );
    expect(
      colorDeltaUnits(reopened),
      colorExpectedUnits([
        ('如何', {'color': '#D14343'}),
        ('呢😀', {'color': '#2563EB'}),
        ('如何', {'color': '#D14343'}),
        ('呢😀', {'color': '#2563EB'}),
      ]),
    );
  });

  for (final block in [
    {'blockquote': true},
    for (final list in ['bullet', 'ordered'])
      for (final depth in [0, 1, 2]) {'list': list, 'indent': depth},
  ]) {
    test('颜色与32种行内组合在引用及三级列表保留阅读层级 $block', () {
      for (var mask = 0; mask < 32; mask++) {
        final delta = Delta();
        final depth = block['indent'] as int? ?? 0;
        final segments = <ColorSegment>[];
        for (var level = 0; level < depth; level++) {
          delta
            ..insert('父$level')
            ..insert('\n', {
              'list': block['list'],
              if (level != 0) 'indent': level,
            });
          segments.add(('父$level', {}));
        }
        final marks = textColorMarks(mask);
        delta
          ..insert('如何呢', marks)
          ..insert('\n', block);
        segments.add(('如何呢', marks));
        final saved = MarkdownDeltaCodec.encode(delta);
        final nodes = colorReaderNodes(saved);
        expect(
          (nodes.single as md.Element).tag,
          block.containsKey('blockquote')
              ? 'blockquote'
              : block['list'] == 'bullet'
              ? 'ul'
              : 'ol',
        );
        expect(
          colorReaderUnits(nodes),
          colorExpectedUnits(segments),
          reason: saved,
        );
        final reopened = MarkdownDeltaCodec.decode(saved).delta;
        expect(colorDeltaUnits(reopened), colorExpectedUnits(segments));
        final attrs = reopened.operations.last.attributes!;
        for (final entry in block.entries) {
          if (entry.key == 'indent' && entry.value == 0) continue;
          expect(attrs[entry.key], entry.value);
        }
        expect(_listDepth(nodes), block.containsKey('list') ? depth + 1 : 0);
      }
    });
  }

  test('受控标签掩码保留 UTF16 索引，后续 HTML 转义判断没有偏移', () {
    const prefix = '<span data-wenyou-color-v1="#D14343">👩🏽‍💻文字</span>';
    for (final suffix in ['<script>x</script>', r'\<i>文字\</i>']) {
      final source = '$prefix$suffix';
      final masked = MarkdownTextColor.maskValidTags(source);
      expect(masked.length, source.length);
      expect(masked.substring(prefix.length), suffix);
      final analysis = MarkdownAlignmentContract.analyze(
        '[wenyousite-align-v1-center]: #\n$source',
      );
      expect(analysis.blocks.isNotEmpty, suffix.startsWith(r'\'));
    }
  });

  test('受控颜色不能放宽任意HTML、损坏颜色、硬换行及列表对齐边界', () {
    for (final target in [
      '<span style="color:red">文字</span>',
      '<span data-wenyou-color-v1="#D14343" onclick="x">文字</span>',
      '<span data-wenyou-color-v1="#D14343">文字',
      '<span data-wenyou-color-v1="#D14343"><b>文字</b></span>',
      '<span data-wenyou-color-v1="#D14343">文字</span><script>x</script>',
      '<span data-wenyou-color-v1="#D14343">文字</span>  \n下一行',
      '- <span data-wenyou-color-v1="#D14343">文字</span>',
      '> <span data-wenyou-color-v1="#D14343">文字</span>',
    ]) {
      final analysis = MarkdownAlignmentContract.analyze(
        '[wenyousite-align-v1-center]: #\n$target',
      );
      expect(analysis.blocks, isEmpty, reason: target);
      expect(analysis.invalidMarkerLines, contains(0));
    }
  });

  test('整段颜色后的普通图片仍被识别，不误接纳段内图片对齐', () {
    const source =
        '<span data-wenyou-color-v1="#D14343">文字</span> ![图](https://example.com/image.png)';
    expect(MarkdownAlignmentContract.containsRegularImage(source), isTrue);
    for (final imageAlignment in [false, true]) {
      expect(
        MarkdownAlignmentContract.analyze(
          '[wenyousite-align-v1-center]: #\n$source',
          imageAlignment: imageAlignment,
        ).blocks,
        isEmpty,
      );
    }
  });
}

int _listDepth(List<md.Node> nodes) {
  var maximum = 0;
  for (final node in nodes.whereType<md.Element>()) {
    final depth =
        _listDepth(node.children ?? []) +
        (node.tag == 'ul' || node.tag == 'ol' ? 1 : 0);
    if (depth > maximum) maximum = depth;
  }
  return maximum;
}
