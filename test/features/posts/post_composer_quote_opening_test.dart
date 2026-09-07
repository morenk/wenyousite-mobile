import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

import '../../support/foundation_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('反馈楼层原文经最新版读取及真实编辑入口保持单个引用块', (tester) async {
    // The reported post's exact Markdown, obtained by a targeted read-only
    // query. IDs and account details are replaced by local test fixtures.
    const source = '> 阿三大苏打\n>\n> 阿三大苏打\n\n<br />';
    var fetches = 0;
    final repository = PostRepliesPageTestFakePostRepository(
      onFetchPost: (id) async {
        expect(id, 'root');
        fetches += 1;
        return postRepliesPageTestRootWithContent(
          fetches == 1 ? '列表中的旧正文' : source,
        );
      },
    );
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'root-author',
      markdownAlignment: true,
      markdownImageAlignment: true,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);
    expect(fetches, 1);

    Future<void> openAndCheck() async {
      await postRepliesPageTestLongPressPostMetadata(tester, 'root');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('post-card-action-root-edit')));
      await postRepliesPageTestPumpUi(tester);
      final controller = tester
          .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
          .widget
          .controller;
      final document = controller.document;
      expect(document.toPlainText(), '阿三大苏打\n阿三大苏打\n\n');
      expect(document.root.children, hasLength(2));
      final quote = document.root.children.first as Block;
      expect(quote.style.attributes['blockquote']?.value, isTrue);
      expect(quote.childCount, 2);
      expect(document.root.children.last, isA<Line>());
      expect(
        MarkdownDeltaCodec.encode(document.toDelta(), imageAlignment: true),
        '> 阿三大苏打\n>\n> 阿三大苏打\n<br />',
      );
      expect(tester.takeException(), isNull);
    }

    await openAndCheck();
    expect(fetches, 2);
    await postRepliesPageTestDismissPostComposerFromOutside(tester);
    await openAndCheck();
    expect(fetches, 3);
    expect(repository.updateRequests, isEmpty);
    await postRepliesPageTestDismissPostComposerFromOutside(tester);
  });
}
