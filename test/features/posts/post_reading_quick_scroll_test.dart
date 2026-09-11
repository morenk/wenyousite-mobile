import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';

import '../../support/foundation_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('独立讨论快翻不盖住正文和发表，回复无虚构楼层号', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = PostRepliesPageTestFakePostRepository(
      initialReplies: [
        for (var i = 0; i < 60; i++)
          postRepliesPageTestReply(
            'reply-$i',
            List.filled(3, '回复 $i 的阅读正文').join('\n\n'),
            postRepliesPageTestAuthor,
          ),
      ],
    );
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'author-1',
    );
    addTearDown(container.dispose);
    const visualKey = Key('quick-scroll-replies-visual');
    await tester.pumpWidget(
      RepaintBoundary(
        key: visualKey,
        child: postRepliesPageTestPostRepliesApp(container),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reading-quick-scroll-toggle')));
    await tester.pumpAndSettle();
    final bar = tester.getRect(
      find.byKey(const Key('reading-quick-scroll-bar')),
    );
    final compose = tester.getRect(find.byKey(const Key('post-reply-compose')));
    expect(compose.bottom, lessThanOrEqualTo(bar.top));
    await expectLater(
      find.byKey(visualKey),
      matchesGoldenFile('goldens/post_quick_scroll_360.png'),
    );
    final quick = tester
        .widget<ReadingQuickScrollAction>(find.byType(ReadingQuickScrollAction))
        .controller;
    await tester.tap(find.byKey(const Key('reading-quick-scroll-end')));
    await tester.pumpAndSettle();
    expect(quick.scrollController.position.extentAfter, lessThanOrEqualTo(1));
    expect(quick.edgeFailed, isFalse);
    expect(quick.location, contains('回复附近'));
    expect(quick.location, isNot(contains('第 60')));
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reading-quick-scroll-bar')), findsNothing);
    expect(find.byKey(const Key('post-composer-sheet')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
