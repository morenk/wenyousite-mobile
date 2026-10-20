import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/deterministic_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('讨论主楼层和回复真实菜单共用链接复制端口', (tester) async {
    final root = postRepliesPageTestRootWithContent('原楼层');
    final reply = postRepliesPageTestReply(
      'reply-link',
      '回复',
      postRepliesPageTestOtherAuthor,
    );
    final repository = PostRepliesPageTestFakePostRepository(
      onFetchPost: (_) async => root,
      initialReplies: [reply],
    );
    final links = <String>[];
    final container = await postRepliesPageTestPostContainer(
      repository,
      linkWriter: (text) async => links.add(text),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);
    for (final id in ['root', 'reply-link']) {
      await postRepliesPageTestLongPressPostMetadata(tester, id);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('post-card-action-$id-link')));
      await tester.pumpAndSettle();
    }
    expect(links, [
      'https://wenyou.site/threads/thread?post=root',
      'https://wenyou.site/threads/thread/posts/root/replies?post=reply-link',
    ]);
  });
}
