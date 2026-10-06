import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/editor_link_toolbar.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('真实回复页面输入站内楼层链接，保存后阅读和重开编辑均保留传送门', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = PostRepliesPageTestFakePostRepository();
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'author-1',
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);
    Future<void> openEditor() async {
      await postRepliesPageTestLongPressPostMetadata(tester, 'reply-own');
      await postRepliesPageTestPumpUi(tester);
      await tester.tap(
        find.byKey(const Key('post-card-action-reply-own-edit')),
      );
      await postRepliesPageTestPumpUi(tester);
    }

    await openEditor();
    await postRepliesPageTestReplaceComposerText(tester, '你好');
    final controller = tester
        .widget<QuillEditor>(find.byKey(const Key('post-composer-body')))
        .controller;
    controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 2),
      ChangeSource.local,
    );
    const target =
        '/threads/cmsewdo0h000x7qv6aa77ll1v?post=cmsewdqcr001a7qv6cy0y38bd';
    await insertToolbarLink(tester, '你好', 'https://wenyou.site$target');
    expect(find.byKey(const Key('editor-internal-reference')), findsOneWidget);
    expect(find.textContaining('正文无法安全保存'), findsNothing);
    await tester.tap(find.byKey(const Key('editor-submit')));
    await postRepliesPageTestPumpUi(tester);
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    expect(
      repository.replies.singleWhere((post) => post.id == 'reply-own').content,
      '[你好]($target)',
    );
    expect(find.byType(WenyouInternalReferenceSurface), findsOneWidget);
    expect(find.text('你好'), findsOneWidget);
    await openEditor();
    final reopened = tester
        .widget<QuillEditor>(find.byKey(const Key('post-composer-body')))
        .controller;
    expect(reopened.document.toPlainText(), '\uFFFC\n');
    expect(reopened.document.root.children, hasLength(1));
    expect(
      MarkdownDeltaCodec.encode(reopened.document.toDelta()),
      '[你好]($target)',
    );
    expect(find.byKey(const Key('editor-internal-reference')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
