import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import '../../support/block_boundary_fixtures.dart';
import '../../support/deterministic_test_fonts.dart';
import '../posts/post_replies_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  final source =
      (loadBlockBoundaryFixture()['cases'] as List)
              .cast<Map<String, dynamic>>()
              .singleWhere((item) => item['id'] == 'unsafe-target')['markdown']
          as String;

  testWidgets('危险链接目标在真实会话 flush 时被阻断', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: source,
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    expect(await session.flush(), isFalse);
    expect(emitted, isEmpty);
    expect(
      session.controller.document.toPlainText(),
      contains('ftp://example.com'),
    );
  });

  testWidgets('危险链接目标在真实楼层保存入口不发送写请求', (tester) async {
    final repository = PostRepliesPageTestFakePostRepository(
      initialReplies: [
        postRepliesPageTestReply(
          'reply-own',
          source,
          postRepliesPageTestAuthor,
        ),
      ],
    );
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'author-1',
      markdownAlignment: true,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);
    await tester.ensureVisible(find.byKey(const Key('post-reply-reply-own')));
    await postRepliesPageTestLongPressPostMetadata(tester, 'reply-own');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('post-card-action-reply-own-edit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editor-submit')));
    await tester.pumpAndSettle();
    expect(repository.updateRequests, isEmpty);
    expect(find.byKey(const Key('post-composer-sheet')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
