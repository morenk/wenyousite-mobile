import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/editor_test_paste.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('楼中楼真实复制菜单粘贴发布重开只呈现阅读文字', (tester) async {
    const source =
        '1. 项目\n'
        r'\(一\) **内容**';
    const visible = '1. 项目\n(一) 内容';
    final repository = PostRepliesPageTestFakePostRepository(
      initialReplies: [
        postRepliesPageTestReply(
          'reply-other',
          source,
          postRepliesPageTestOtherAuthor,
        ),
      ],
    );
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'author-1',
    );
    addTearDown(container.dispose);
    wenyouEditorClipboardStore.clear();
    addTearDown(wenyouEditorClipboardStore.clear);
    String? clipboardText;
    final platform = tester.binding.defaultBinaryMessenger;
    platform.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboardText = (call.arguments as Map)['text'] as String;
      }
      if (call.method == 'Clipboard.getData') return {'text': clipboardText};
      return null;
    });
    addTearDown(
      () => platform.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);
    final readingText = tester
        .widgetList<RichText>(find.byType(RichText))
        .map((widget) => widget.text.toPlainText())
        .join('\n');
    expect(readingText, contains('(一) 内容'));
    expect(readingText, isNot(contains(r'\(')));
    await postRepliesPageTestLongPressPostMetadata(tester, 'reply-other');
    await postRepliesPageTestPumpUi(tester);
    await tester.tap(find.text('复制内容'));
    await postRepliesPageTestPumpUi(tester);
    expect(clipboardText, visible);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await postRepliesPageTestPumpUi(tester);
    final editor = tester.widget<QuillEditor>(
      find.byKey(const Key('post-composer-body')),
    );
    expect(await pasteEditorClipboard(editor.controller), isTrue);
    await tester.pump();
    expect(editor.controller.document.toPlainText(), '$visible\n');
    editor.controller.replaceText(
      editor.controller.document.length - 1,
      0,
      '补充',
      null,
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('editor-submit')));
    await postRepliesPageTestPumpUi(tester);
    expect(repository.createInputs, hasLength(1));
    await postRepliesPageTestLongPressPostMetadata(tester, 'created');
    await postRepliesPageTestPumpUi(tester);
    await tester.tap(find.byKey(const Key('post-card-action-created-edit')));
    await postRepliesPageTestPumpUi(tester);
    final reopened = tester.widget<QuillEditor>(
      find.byKey(const Key('post-composer-body')),
    );
    expect(reopened.controller.document.toPlainText(), '$visible补充\n');
    expect(tester.takeException(), isNull);
  });
}
