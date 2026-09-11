import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import '../../support/block_boundary_fixtures.dart';

void main() {
  for (final source in [
    '> `甲\n> [wenyousite-align-v1-center]: #\n> 乙`',
    '- `甲\n  [wenyousite-align-v1-center]: #\n  乙`',
  ]) {
    test('显式容器内 code 保留字面 marker 与块属性 $source', () {
      final analysis = MarkdownAlignmentContract.analyze(source);
      expect(analysis.validMarkerLines, isEmpty);
      expect(analysis.invalidMarkerLines, isEmpty);
      final delta = MarkdownDeltaCodec.decode(source).delta;
      final rows = boundaryRows(delta);
      expect(rows.single['text'], '甲 [wenyousite-align-v1-center]: # 乙');
      expect(
        rows.single['type'],
        source.startsWith('>') ? 'blockquote' : 'bullet-list',
      );
      expect(delta.operations.first.attributes?['code'], isTrue);
      final saved = MarkdownDeltaCodec.encode(delta);
      expect(boundaryRows(MarkdownDeltaCodec.decode(saved).delta), rows);
      expect(
        MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(saved).delta),
        saved,
      );
    });
  }
  for (final source in [
    '> ```\n> [wenyousite-align-v1-center]: #\n> ```',
    '- 列表\n  ```\n  [wenyousite-align-v1-center]: #\n  ```',
    '- 列表\n\n      [wenyousite-align-v1-center]: #\n      正文',
  ]) {
    test('嵌套代码块内 marker 不被当作对齐协议 $source', () {
      final analysis = MarkdownAlignmentContract.analyze(source);
      expect(analysis.validMarkerLines, isEmpty);
      expect(analysis.invalidMarkerLines, isEmpty);
      final delta = MarkdownDeltaCodec.decode(source).delta;
      expect(
        delta.operations
            .where((op) => op.data is String)
            .map((op) => op.data)
            .join(),
        contains('[wenyousite-align-v1-center]: #'),
      );
      expect(
        delta.operations.any((op) => op.attributes?['align'] != null),
        isFalse,
      );
      final saved = MarkdownDeltaCodec.encode(delta);
      expect(
        MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(saved).delta),
        saved,
      );
    });
  }
}
