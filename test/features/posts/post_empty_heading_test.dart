import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/foundation_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  for (final level in [2, 3]) {
    testWidgets('回复空正文选 H$level 后可恢复草稿、输入、发布及重新编辑', (tester) async {
      final repository = PostRepliesPageTestFakePostRepository();
      final container = await postRepliesPageTestPostContainer(
        repository,
        userId: 'author-1',
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
      await postRepliesPageTestPumpUi(tester);
      await tester.tap(find.byKey(const Key('post-reply-compose')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('editor-heading')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('H$level'));
      await tester.pumpAndSettle();
      expect(find.textContaining('不能安全保存'), findsNothing);
      expect(_controller(tester).document.toPlainText(), '\n');

      // 空标题仍是空正文，不能因格式标记而发送一条没有文字的回复。
      await tester.tap(find.byKey(const Key('editor-submit')));
      await tester.pumpAndSettle();
      expect(repository.createInputs, isEmpty);
      await postRepliesPageTestDismissPostComposerFromOutside(tester);
      await tester.tap(find.byKey(const Key('post-reply-compose')));
      await tester.pumpAndSettle();
      expect(_controller(tester).document.toPlainText(), '\n');
      expect(
        _controller(tester).getSelectionStyle().attributes['header']?.value,
        level,
      );
      _controller(
        tester,
      ).replaceText(0, 0, '标题', const TextSelection.collapsed(offset: 2));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('editor-submit')));
      await tester.pumpAndSettle();
      expect(repository.createInputs.single.content, '${'#' * level} 标题');
      expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
      expect(find.text('标题'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('post-reply-created')));
      await postRepliesPageTestLongPressPostMetadata(tester, 'created');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('post-card-action-created-edit')));
      await tester.pumpAndSettle();
      expect(_controller(tester).document.toPlainText(), '标题\n');
      expect(
        _controller(tester).getSelectionStyle().attributes['header']?.value,
        level,
      );
      expect(find.textContaining('不能安全保存'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}

QuillController _controller(WidgetTester tester) => tester
    .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
    .widget
    .controller;
