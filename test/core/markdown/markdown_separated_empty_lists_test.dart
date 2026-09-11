import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_delta_block_validator.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

// #37 楼反馈：两组列表之间有空行，第二组末项为空时报错，填字后恢复。
// 截图不提供源码，因此固定可见内容、空项及操作状态，不猜测原始拼写。
void main() {
  for (final firstType in ['ordered', 'bullet']) {
    for (final secondType in ['ordered', 'bullet']) {
      for (final blanks in [1, 2, 3]) {
        for (var emptyMask = 0; emptyMask < 4; emptyMask++) {
          test('$firstType/$secondType 空行 $blanks 空项组合 $emptyMask', () {
            final texts = [
              '甲',
              emptyMask & 1 == 0 ? '乙' : '',
              '试试',
              emptyMask & 2 == 0 ? '字' : '',
            ];
            final delta = Delta()
              ..insert(texts[0])
              ..insert('\n', {'list': firstType})
              ..insert(texts[1])
              ..insert('\n', {'list': firstType})
              ..insert('\n' * blanks)
              ..insert(texts[2])
              ..insert('\n', {'list': secondType})
              ..insert(texts[3])
              ..insert('\n', {'list': secondType});
            final saved = MarkdownDeltaCodec.encode(delta);
            // 按 newline v1 独占空段分组后，使用独立阅读解析器核对直属项。
            final lists = saved
                .split(RegExp(r'^<br />$', multiLine: true))
                .expand((part) => md.Document().parseLines(part.split('\n')))
                .whereType<md.Element>()
                .where((node) => ['ol', 'ul'].contains(node.tag))
                .toList();
            expect(lists.map((node) => node.tag), [
              firstType == 'ordered' ? 'ol' : 'ul',
              secondType == 'ordered' ? 'ol' : 'ul',
            ]);
            expect(lists.map((list) => list.children!.length), [2, 2]);
            expect(
              lists
                  .expand((list) => list.children!)
                  .map((item) => item.textContent),
              texts,
            );
            expect(RegExp(r'<br />').allMatches(saved).length, blanks);
            final reopened = MarkdownDeltaCodec.decode(saved).delta;
            final listLines = reopened.operations.where(
              (op) => op.attributes?['list'] != null,
            );
            expect(
              listLines.fold<int>(
                0,
                (count, op) =>
                    count + '\n'.allMatches(op.data as String).length,
              ),
              4,
            );
            expect(MarkdownDeltaCodec.encode(reopened), saved);
          });
        }
      }
    }
  }

  final ordered = Delta()
    ..insert('甲')
    ..insert('\n', {'list': 'ordered'})
    ..insert('乙')
    ..insert('\n', {'list': 'ordered'});
  for (final corrupted in ['- 甲\n- 乙', '1. 甲\n   1. 乙', '1. 甲\n\n1.']) {
    test('没有空项也拒绝类型、层级或内容空状态被改写：$corrupted', () {
      expect(
        () =>
            MarkdownDeltaBlockValidator.validateListReading(ordered, corrupted),
        throwsA(isA<MarkdownCodecException>()),
      );
    });
  }
}
