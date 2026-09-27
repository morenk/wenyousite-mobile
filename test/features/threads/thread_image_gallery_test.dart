import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown_image.dart';
import 'package:wenyousite_mobile/features/media/application/reading_gallery_controller.dart';
import 'package:wenyousite_mobile/features/media/presentation/reading_image_gallery_page.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

import '../../support/reading_gallery_test_repository.dart';
import 'thread_detail_page_test_support.dart';

void main() {
  for (final reply in [false, true]) {
    testWidgets(reply ? '真实主题页内嵌楼中楼只请求该楼层回复图集' : '真实主题页当前子贴图集传递倒序作者筛选及重复位置', (
      tester,
    ) async {
      final floor = ThreadFloorModel(
        id: 'floor-images',
        floorNumber: 12,
        author: threadDetailPageTestAuthor,
        body: const ThreadBodyModel(
          markdown:
              '![一](https://example.test/image.png)\n\n![二](https://example.test/image.png)',
        ),
        createdAt: DateTime.utc(2026, 9, 20),
        isDeleted: false,
        version: 7,
        replyCount: reply ? 1 : 0,
        replies: [
          if (reply)
            ThreadReplyModel(
              id: 'reply-image',
              author: threadDetailPageTestAuthor,
              body: const ThreadBodyModel(
                markdown: '![回复图](https://example.test/reply.png)',
              ),
              createdAt: DateTime.utc(2026, 9, 20),
              isDeleted: false,
              version: 3,
            ),
        ],
      );
      final repository = ThreadDetailPageTestFakeThreadDetailRepository(
        mainFloor: floor,
      );
      final gallery = ReadingGalleryTestRepository(
        (request) => [
          ReadingGalleryImage(
            id: 'clicked',
            sourceId: request.anchorId,
            sourceVersion: request.anchorVersion,
            imageIndex: request.anchorIndex,
            imageCount: reply ? 1 : 2,
            url: reply
                ? 'https://example.test/reply.png'
                : 'https://example.test/image.png',
            threadId: 'thread-1',
            subthreadId: 'subthread-1',
            parentPostId: reply ? floor.id : null,
            floorNumber: 12,
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            readingGalleryRepositoryProvider.overrideWithValue(gallery),
          ],
          child: threadDetailPageTestDetailRouterApp(repository),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('thread-floors-order')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('thread-floors-author')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(threadDetailPageTestAuthor.username).last);
      await tester.pumpAndSettle();
      final key = ValueKey(
        'markdown-image-https://example.test/${reply ? 'reply' : 'image'}.png',
      );
      final target = reply ? find.byKey(key) : find.byKey(key).last;
      await tester.scrollUntilVisible(
        target,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      final scroll = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .pixels;
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(find.byType(ReadingImageGalleryPage), findsOneWidget);
      final request = gallery.requests.single;
      expect(
        request.scope,
        reply ? ReadingGalleryScope.postReplies : ReadingGalleryScope.subthread,
      );
      expect(request.scopeId, reply ? floor.id : 'subthread-1');
      expect(request.anchorId, reply ? 'reply-image' : floor.id);
      expect(request.anchorIndex, reply ? 0 : 1);
      expect(request.anchorVersion, reply ? 3 : 7);
      if (!reply) {
        expect(request.order, ReadingGalleryOrder.newest);
        expect(request.authorId, threadDetailPageTestAuthor.id);
      }
      await tester.tap(find.byTooltip('关闭原图'));
      await tester.pumpAndSettle();
      expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels,
        closeTo(scroll, 1),
      );
      expect(find.byType(WenyouMarkdownImage), findsWidgets);
    });
  }
}
