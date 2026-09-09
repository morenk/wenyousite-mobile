import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import '../../support/foundation_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadFoundationTestFonts);
  for (final alignment in ['center', 'right']) {
    testWidgets('回复输入法回车后独立左对齐，发布和重新编辑保持一行间隔 $alignment', (tester) async {
      final repository = PostRepliesPageTestFakePostRepository();
      final container = await postRepliesPageTestPostContainer(
        repository,
        userId: 'author-1',
        markdownAlignment: true,
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
      await postRepliesPageTestPumpUi(tester);
      await tester.tap(find.byKey(const Key('post-reply-compose')));
      await tester.pumpAndSettle();
      await postRepliesPageTestReplaceComposerText(tester, '甲乙');
      await tester.tap(find.byKey(const Key('editor-more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('editor-align-$alignment')));
      await tester.pumpAndSettle();
      final editor = tester.widget<QuillEditor>(
        find.byKey(const Key('post-composer-body')),
      );
      editor.controller.updateSelection(
        const TextSelection.collapsed(offset: 1),
        ChangeSource.local,
      );
      editor.focusNode.requestFocus();
      await tester.pump();
      // 模拟 Android 输入连接提交单个 LF，经过真实 Quill 输入差异处理。
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '甲\n乙\n',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );
      await tester.pumpAndSettle();
      expect(editor.controller.document.toPlainText(), '甲\n乙\n');
      expect(
        editor.controller.selection,
        const TextSelection.collapsed(offset: 2),
      );
      expect(
        MarkdownDeltaCodec.encode(editor.controller.document.toDelta()),
        '[wenyousite-align-v1-$alignment]: #\n甲\n\n乙',
      );
      expect(find.textContaining('不能安全保存'), findsNothing);
      await tester.tap(find.byKey(const Key('editor-submit')));
      await tester.pumpAndSettle();
      expect(
        repository.createInputs.single.content,
        '[wenyousite-align-v1-$alignment]: #\n甲\n\n乙',
      );
      expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
      expect(find.text('甲'), findsOneWidget);
      expect(find.text('乙'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('post-reply-created')));
      await postRepliesPageTestLongPressPostMetadata(tester, 'created');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('post-card-action-created-edit')));
      await tester.pumpAndSettle();
      final reopened = tester
          .widget<QuillEditor>(find.byKey(const Key('post-composer-body')))
          .controller;
      expect(reopened.document.toPlainText(), '甲\n乙\n');
      final attrs = reopened.document
          .toDelta()
          .operations
          .where((op) => op.data == '\n')
          .map((op) => op.attributes?['align'])
          .toList();
      expect(attrs, [alignment, null]);
      expect(find.textContaining('不能安全保存'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
