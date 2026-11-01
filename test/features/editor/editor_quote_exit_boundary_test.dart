import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_format_policy.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

const portal = '[传送门](/threads/cmsewdo0h000x7qv6aa77ll1v)';

void main() {
  for (final suffix in ['', portal]) {
    testWidgets('退出引用后的正文保存与阅读保持在框外 $suffix', (tester) async {
      // 根据截图重建可见三行；私帖原始 Markdown 和具体点击顺序未知。
      final session = RichEditorSession(
        initialMarkdown: '> 如何呢$suffix\n> 哈哈哈\n> 如何呢$suffix',
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      final controller = session.controller;
      final lastLine = controller.document.toPlainText().lastIndexOf('如何呢');
      controller.updateSelection(
        TextSelection.collapsed(offset: lastLine),
        ChangeSource.local,
      );
      WenyouEditorFormatPolicy.toggle(controller, Attribute.blockQuote);
      final before = controller.document.toPlainText();
      expect(controller.document.root.children, hasLength(2));
      expect((controller.document.root.children.first as Block).childCount, 2);
      expect(controller.document.root.children.last, isA<Line>());
      expect(await session.flush(), isTrue);
      final saved = MarkdownDeltaCodec.encode(controller.document.toDelta());
      // 独立 CommonMark 阅读解析必须是引用 + 普通段落，不能只验 Codec 往返。
      final blocks = md.Document()
          .parseLines(saved.split('\n'))
          .cast<md.Element>();
      expect(blocks.map((block) => block.tag), ['blockquote', 'p']);
      expect(blocks.first.textContent, contains('哈哈哈'));
      expect(blocks.first.textContent.split('如何呢'), hasLength(2));
      expect(blocks.last.textContent, '如何呢${suffix.isEmpty ? '' : '传送门'}');
      expect(saved, '> 如何呢$suffix\n> 哈哈哈\n\n如何呢$suffix');
      final reopened = Document.fromDelta(
        MarkdownDeltaCodec.decode(saved).delta,
      );
      addTearDown(reopened.close);
      expect(reopened.toPlainText(), before);
      expect(reopened.root.children, hasLength(2));
      expect((reopened.root.children.first as Block).childCount, 2);
      expect(reopened.root.children.last, isA<Line>());
      expect(MarkdownDeltaCodec.encode(reopened.toDelta()), saved);
    });
  }
}
