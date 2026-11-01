import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/features/editor/presentation/editor_format_policy.dart';

import '../../support/deterministic_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('楼层退出引用后输入、保存、阅读及再次编辑保持三行归属', (tester) async {
    const portal = '[传送门](/threads/cmsewdo0h000x7qv6aa77ll1v)';
    final repository = PostRepliesPageTestFakePostRepository(
      initialReplies: [
        postRepliesPageTestReply(
          'reply-own',
          '> 如何呢$portal\n> 哈哈哈\n> 如何呢$portal',
          postRepliesPageTestAuthor,
        ),
      ],
    );
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'author-1',
      markdownAlignment: true,
      markdownImageAlignment: true,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);

    Future<QuillEditor> open() async {
      await tester.ensureVisible(find.byKey(const Key('post-reply-reply-own')));
      await postRepliesPageTestLongPressPostMetadata(tester, 'reply-own');
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('post-card-action-reply-own-edit')),
      );
      await tester.pumpAndSettle();
      return tester.widget<QuillEditor>(
        find.byKey(const Key('post-composer-body')),
      );
    }

    final editor = await open();
    final controller = editor.controller;
    final before = controller.document.toPlainText();
    final offset = before.lastIndexOf('如何呢') + 3;
    controller.updateSelection(
      TextSelection.collapsed(offset: offset),
      ChangeSource.local,
    );
    WenyouEditorFormatPolicy.toggle(controller, Attribute.blockQuote);
    editor.focusNode.requestFocus();
    await tester.pump();
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: before.replaceRange(offset, offset, '呀'),
        selection: TextSelection.collapsed(offset: offset + 1),
      ),
    );
    await tester.pumpAndSettle();
    expect(controller.document.root.children, hasLength(2));
    expect((controller.document.root.children.first as Block).childCount, 2);
    expect(controller.document.root.children.last, isA<Line>());
    await tester.tap(find.byKey(const Key('editor-submit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('post-composer-body')), findsNothing);
    final saved = repository.updateRequests.single.content;
    expect(saved, '> 如何呢$portal\n> 哈哈哈\n\n如何呢呀$portal');
    final blocks = md.Document()
        .parseLines(saved.split('\n'))
        .cast<md.Element>();
    expect(blocks.map((block) => block.tag), ['blockquote', 'p']);
    expect(blocks.first.textContent, '如何呢传送门\n哈哈哈');
    expect(blocks.last.textContent, '如何呢呀传送门');
    final quoteText = find.byWidgetPredicate(
      (widget) =>
          widget is RichText && widget.text.toPlainText().contains('哈哈哈'),
    );
    final outsideText = find.byWidgetPredicate(
      (widget) =>
          widget is RichText && widget.text.toPlainText().startsWith('如何呢呀'),
    );
    expect(quoteText, findsOneWidget);
    expect(outsideText, findsOneWidget);
    expect(
      tester.getTopLeft(outsideText).dx,
      lessThan(tester.getTopLeft(quoteText).dx),
    );
    final reopened = (await open()).controller.document;
    expect(reopened.toPlainText(), before.replaceRange(offset, offset, '呀'));
    expect(reopened.root.children, hasLength(2));
    expect((reopened.root.children.first as Block).childCount, 2);
    expect(reopened.root.children.last, isA<Line>());
    expect(tester.takeException(), isNull);
    await postRepliesPageTestDismissPostComposerFromOutside(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
