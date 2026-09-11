import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

// 用户视频：一、／（一）／aaa、bbb 有序列表后留空行，再接（二）及另一
// 列表，提交失败。视频不包含原始 Markdown，以下固定可见行与操作语义，
// 不把构造源码当作已取得原帖源码。另覆盖空行后不接第二个列表的情况。
void main() {
  for (final type in ['bullet', 'ordered']) {
    for (final blanks in [1, 2, 3]) {
      for (final suffix in ['结束', '普通正文', '另一列表']) {
        test('$type 列表后 $blanks 个空行接 $suffix 保存与重开保持行数', () {
          final delta = Delta()
            ..insert('一、\n（一）\n')
            ..insert('aaa')
            ..insert('\n', {'list': type})
            ..insert('bbb')
            ..insert('\n', {'list': type})
            ..insert('\n' * blanks);
          if (suffix != '结束') {
            delta.insert('（二）\n');
            delta.insert('ccc');
            delta.insert('\n', suffix == '另一列表' ? {'list': type} : null);
          }
          final expected = _lines(delta);
          final markdown = MarkdownDeltaCodec.encode(delta);
          final reopened = MarkdownDeltaCodec.decode(markdown).delta;
          expect(_lines(reopened), expected);
          // newline v1 的独占 <br /> 是空段块；普通 HTML 解析器会把后续
          // 行吞入 HTML 块，因此先按已发布空段语义分块，再独立读取列表树。
          final nodes = markdown
              .split(RegExp(r'^<br />$', multiLine: true))
              .expand((part) => md.Document().parseLines(part.split('\n')));
          final lists = nodes
              .whereType<md.Element>()
              .where((node) => ['ol', 'ul'].contains(node.tag))
              .toList();
          expect(lists.length, suffix == '另一列表' ? 2 : 1);
          expect(lists.first.children!.length, 2);
          expect(lists.first.children!.map((node) => node.textContent), [
            'aaa',
            'bbb',
          ]);
          expect(RegExp(r'<br />').allMatches(markdown).length, blanks);
          expect(MarkdownDeltaCodec.encode(reopened), markdown);
        });
      }
    }

    testWidgets('$type 列表后实际连续回车退出列表、留空行并续写', (tester) async {
      final marker = type == 'ordered' ? '1.' : '-';
      final session = RichEditorSession(
        initialMarkdown: '$marker aaa\n$marker bbb',
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      final controller = session.controller;
      controller.updateSelection(
        const TextSelection.collapsed(offset: 7),
        ChangeSource.local,
      );
      for (var i = 0; i < 3; i++) {
        final offset = controller.selection.start;
        controller.replaceText(
          offset,
          0,
          '\n',
          TextSelection.collapsed(offset: offset + 1),
        );
        await tester.pump();
        expect(await session.flush(), isTrue, reason: session.codecFailure);
        final before = _lines(controller.document.toDelta());
        final saved = MarkdownDeltaCodec.encode(controller.document.toDelta());
        expect(_lines(MarkdownDeltaCodec.decode(saved).delta), before);
      }
      expect(
        controller.document.toDelta().operations.last.attributes?['list'],
        isNull,
      );
      final offset = controller.selection.start;
      controller.replaceText(
        offset,
        0,
        '（二）',
        TextSelection.collapsed(offset: offset + 3),
      );
      await tester.pump();
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      final saved = MarkdownDeltaCodec.encode(controller.document.toDelta());
      final reopened = RichEditorSession(
        initialMarkdown: saved,
        onMarkdownChanged: (_) {},
      );
      addTearDown(reopened.dispose);
      expect(
        _lines(reopened.controller.document.toDelta()),
        _lines(controller.document.toDelta()),
      );
      expect(await reopened.flush(), isTrue);
    });
  }

  for (final sample in [
    (
      source: '1. 甲\n   1. 乙\n      1. 丙',
      offset: 4,
      length: 1,
      text: '',
      expected: '甲\n乙\n\n',
    ),
    (
      source: '- - 乙\n\n    -',
      offset: 0,
      length: 0,
      text: '甲',
      expected: '甲\n乙\n\n',
    ),
  ]) {
    testWidgets('共享契约真实编辑操作 ${sample.source}', (tester) async {
      final session = RichEditorSession(
        initialMarkdown: sample.source,
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      session.controller.replaceText(
        sample.offset,
        sample.length,
        sample.text,
        TextSelection.collapsed(offset: sample.offset + sample.text.length),
      );
      await tester.pump();
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      final saved = MarkdownDeltaCodec.encode(
        session.controller.document.toDelta(),
      );
      final reopened = MarkdownDeltaCodec.decode(saved).delta;
      expect(reopened.operations.map((op) => op.data).join(), sample.expected);
      expect(_lines(reopened).map((line) => line['indent']), [0, 1, 2]);
    });
  }
}

List<Map<String, Object>> _lines(Delta delta) {
  final lines = <Map<String, Object>>[];
  var text = '';
  for (final op in delta.operations) {
    if (op.data is! String) continue;
    for (final character in (op.data as String).split('')) {
      if (character != '\n') {
        text += character;
        continue;
      }
      if (op.attributes?[MarkdownDeltaCodec.sourceBreakAttribute] == null &&
          op.attributes?['wenyou_source_separator'] == true) {
        text = '';
        continue;
      }
      lines.add({
        'text': text,
        'list': op.attributes?['list'] as String? ?? '',
        'indent': op.attributes?['indent'] as int? ?? 0,
      });
      text = '';
    }
  }
  return lines;
}
