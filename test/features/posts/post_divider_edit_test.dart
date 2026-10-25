import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/deterministic_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('回复分隔线旁输入后保存草稿、发布和重新编辑保留全部正文', (tester) async {
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
    _controller(
      tester,
    ).replaceText(0, 0, '前文后文', const TextSelection.collapsed(offset: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editor-horizontal-rule')));
    await tester.pumpAndSettle();
    final controller = _controller(tester);
    expect(controller.document.toPlainText(), '前文\n\uFFFC\n后文\n');
    controller.replaceText(4, 0, '新', const TextSelection.collapsed(offset: 5));
    await tester.pumpAndSettle();
    expect(controller.document.toPlainText(), '前文\n\uFFFC\n新\n后文\n');
    expect(find.textContaining('分隔线必须'), findsNothing);

    await postRepliesPageTestDismissPostComposerFromOutside(tester);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await tester.pumpAndSettle();
    expect(
      _controller(tester).document.toPlainText().replaceAll('\n', ''),
      '前文\uFFFC新后文',
    );
    await tester.tap(find.byKey(const Key('editor-submit')));
    await tester.pumpAndSettle();
    expect(repository.createInputs.single.content, '前文\n\n---\n\n新\n后文');
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);

    await tester.ensureVisible(find.byKey(const Key('post-reply-created')));
    await postRepliesPageTestLongPressPostMetadata(tester, 'created');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('post-card-action-created-edit')));
    await tester.pumpAndSettle();
    expect(
      _controller(tester).document.toPlainText(),
      '前文\n\n\uFFFC\n\n新\n后文\n',
    );
    expect(tester.takeException(), isNull);
  });
}

QuillController _controller(WidgetTester tester) => tester
    .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
    .widget
    .controller;
