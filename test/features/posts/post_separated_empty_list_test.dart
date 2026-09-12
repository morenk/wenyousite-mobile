import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

import '../../support/deterministic_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final marker in ['1.', '-']) {
    testWidgets('#37 反馈 $marker 第二组末项空白、填字、删空、保存重开', (tester) async {
      final repository = PostRepliesPageTestFakePostRepository(
        initialReplies: [
          postRepliesPageTestReply(
            'reply-own',
            '$marker 甲\n$marker 乙\n\n<br />\n$marker 试试',
            postRepliesPageTestAuthor,
          ),
        ],
      );
      final container = await postRepliesPageTestPostContainer(
        repository,
        userId: 'author-1',
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
      await postRepliesPageTestPumpUi(tester);
      await _edit(tester);
      final controller = _controller(tester);
      final offset = controller.document.length - 1;
      controller.replaceText(
        offset,
        0,
        '\n',
        TextSelection.collapsed(offset: offset + 1),
      );
      await _settle(tester);
      expect(find.textContaining('不能安全保存'), findsNothing);
      expect(
        controller.document.toDelta().operations.last.attributes?['list'],
        marker == '1.' ? 'ordered' : 'bullet',
      );
      final emptyText = controller.document.toPlainText();
      expect(emptyText, '甲\n乙\n\n试试\n\n');
      final emptyMarkdown = MarkdownDeltaCodec.encode(
        controller.document.toDelta(),
      );

      final tail = controller.document.length - 1;
      controller.replaceText(
        tail,
        0,
        '字',
        TextSelection.collapsed(offset: tail + 1),
      );
      await _settle(tester);
      expect(find.textContaining('不能安全保存'), findsNothing);
      expect(
        MarkdownDeltaCodec.encode(controller.document.toDelta()),
        contains('字'),
      );
      controller.replaceText(
        tail,
        1,
        '',
        TextSelection.collapsed(offset: tail),
      );
      await _settle(tester);
      expect(find.textContaining('不能安全保存'), findsNothing);
      expect(
        MarkdownDeltaCodec.encode(controller.document.toDelta()),
        emptyMarkdown,
      );

      await tester.tap(find.byKey(const Key('editor-submit')));
      await tester.pumpAndSettle();
      expect(repository.updateRequests, hasLength(1));
      expect(repository.updateRequests.single.content, emptyMarkdown);
      await _edit(tester);
      expect(_controller(tester).document.toPlainText(), emptyText);
      expect(
        MarkdownDeltaCodec.encode(_controller(tester).document.toDelta()),
        emptyMarkdown,
      );
      expect(find.textContaining('不能安全保存'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}

QuillController _controller(WidgetTester tester) => tester
    .widget<QuillEditor>(find.byKey(const Key('post-composer-body')))
    .controller;

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
}

Future<void> _edit(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('post-reply-reply-own')));
  await postRepliesPageTestLongPressPostMetadata(tester, 'reply-own');
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('post-card-action-reply-own-edit')));
  await tester.pumpAndSettle();
}
