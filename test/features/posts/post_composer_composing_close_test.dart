import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/deterministic_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final systemBack in [false, true]) {
    testWidgets('真实帖子编辑页组合输入后关闭 systemBack=$systemBack', (tester) async {
      final repository = PostRepliesPageTestFakePostRepository(
        onFetchPost: (_) async => postRepliesPageTestRootWithContent('原文'),
      );
      final container = await postRepliesPageTestPostContainer(
        repository,
        userId: 'root-author',
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
      await postRepliesPageTestPumpUi(tester);
      await postRepliesPageTestLongPressPostMetadata(tester, 'root');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('post-card-action-root-edit')));
      await postRepliesPageTestPumpUi(tester);
      final editor = tester.widget<QuillEditor>(
        find.byKey(const Key('post-composer-body')),
      );
      editor.focusNode.requestFocus();
      await tester.pump();
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '原文爱\n',
          selection: TextSelection.collapsed(offset: 3),
          composing: TextRange(start: 2, end: 3),
        ),
      );
      await tester.pump();
      expect(editor.controller.document.toPlainText(), '原文爱\n');
      if (systemBack) {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      } else {
        await postRepliesPageTestDismissPostComposerFromOutside(tester);
      }
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
      expect(repository.updateRequests, isEmpty);
    });
  }
}
