import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/content_image_viewer_page.dart';
import 'package:wenyousite_mobile/features/media/application/reading_gallery_controller.dart';
import 'package:wenyousite_mobile/features/media/presentation/reading_image_gallery_page.dart';

void main() {
  for (final (label, image, expectedLocation) in [
    (
      '主贴正文',
      const ReadingGalleryImage(
        id: 'main-body-image',
        sourceId: 'main-body',
        sourceVersion: 2,
        imageIndex: 0,
        imageCount: 1,
        url: 'https://example.test/main.png',
        threadId: 'thread',
        subthreadId: 'main-subthread',
      ),
      '/threads/thread?subthread=main-subthread',
    ),
    (
      '其他子贴正文',
      const ReadingGalleryImage(
        id: 'side-body-image',
        sourceId: 'side-body',
        sourceVersion: 3,
        imageIndex: 0,
        imageCount: 1,
        url: 'https://example.test/side.png',
        threadId: 'thread',
        subthreadId: 'side-subthread',
      ),
      '/threads/thread?subthread=side-subthread',
    ),
    (
      '普通楼层',
      const ReadingGalleryImage(
        id: 'floor-image',
        sourceId: 'floor',
        sourceVersion: 4,
        imageIndex: 0,
        imageCount: 1,
        url: 'https://example.test/floor.png',
        threadId: 'thread',
        subthreadId: 'main-subthread',
        floorNumber: 12,
      ),
      '/threads/thread?post=floor',
    ),
    (
      '楼中楼回复',
      const ReadingGalleryImage(
        id: 'reply-image',
        sourceId: 'reply',
        sourceVersion: 5,
        imageIndex: 0,
        imageCount: 1,
        url: 'https://example.test/reply.png',
        threadId: 'thread',
        subthreadId: 'main-subthread',
        parentPostId: 'floor',
      ),
      '/threads/thread/posts/floor/replies?post=reply',
    ),
  ]) {
    testWidgets('$label 图片定位使用正确来源坐标与指南针图标', (tester) async {
      final repository = _Repository();
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: TextButton(
                onPressed: () => unawaited(
                  openReadingImageGallery(
                    context,
                    target: ReadingGalleryTarget(
                      scope: image.parentPostId == null
                          ? ReadingGalleryScope.subthread
                          : ReadingGalleryScope.postReplies,
                      scopeId: image.parentPostId ?? image.subthreadId!,
                    ),
                    sourceId: image.sourceId,
                    version: image.sourceVersion,
                    imageIndex: image.imageIndex,
                    url: image.url,
                  ),
                ),
                child: const Text('打开图片'),
              ),
            ),
          ),
          GoRoute(
            path: '/threads/:threadId',
            builder: (context, state) => Scaffold(
              body: Text(state.uri.toString(), key: const Key('destination')),
            ),
          ),
          GoRoute(
            path: '/threads/:threadId/posts/:postId/replies',
            builder: (context, state) => Scaffold(
              body: Text(state.uri.toString(), key: const Key('destination')),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            readingGalleryRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.tap(find.text('打开图片'));
      await tester.pump();
      repository.operations.single.resultCompleter.complete(
        ReadingGalleryPage(items: [image], anchorItemId: image.id),
      );
      await tester.pumpAndSettle();
      final locate = find.byTooltip(
        image.parentPostId != null
            ? '定位到所在回复'
            : image.floorNumber == null
            ? '定位到所在正文'
            : '定位到所在楼层',
      );
      final iconId = tester
          .widget<WenyouIcon>(
            find.descendant(of: locate, matching: find.byType(WenyouIcon)),
          )
          .semanticId;
      await tester.tap(locate);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('destination')), findsOneWidget);
      expect(find.text(expectedLocation), findsOneWidget);
      expect(iconId, WenyouIconIds.navigationExplore);
    });
  }

  testWidgets('慢查询立即显示点击图片，失败重试后主动请求邻页', (tester) async {
    final repository = _Repository();
    await _pump(tester, repository);
    expect(find.byType(ContentImageViewerPage), findsOneWidget);
    expect(repository.operations, hasLength(1));
    repository.operations[0].resultCompleter.completeError(
      const ApiFailure(httpStatus: 503),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('图集加载失败，重试'));
    await tester.pump();
    repository.operations[1].resultCompleter.complete(
      const ReadingGalleryPage(
        items: [_image],
        anchorItemId: 'clicked',
        nextCursor: 'opaque-next',
      ),
    );
    await tester.pump();
    expect(repository.cursors, [null, null, 'opaque-next']);
    repository.operations[2].resultCompleter.complete(
      const ReadingGalleryPage(items: []),
    );
    await tester.pumpAndSettle();
    expect(find.text('第 12 楼 · 2 / 3'), findsOneWidget);
  });

  testWidgets('点击靠后图片后异步补齐图集，首帧画面与点击锚点一致', (tester) async {
    final repository = _Repository();
    await _pump(tester, repository);
    repository.operations.single.resultCompleter.complete(
      const ReadingGalleryPage(
        items: [
          ReadingGalleryImage(
            id: 'earlier',
            sourceId: 'earlier-post',
            sourceVersion: 1,
            imageIndex: 0,
            imageCount: 1,
            url: 'https://example.test/earlier.png',
            threadId: 'thread',
            subthreadId: 'subthread',
            floorNumber: 1,
          ),
          _image,
        ],
        anchorItemId: 'clicked',
      ),
    );
    await tester.idle();
    await tester.pump();
    expect(
      tester
          .widget<ContentImageViewerPage>(find.byType(ContentImageViewerPage))
          .items,
      hasLength(2),
    );
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 1);
    expect(find.text('第 12 楼 · 2 / 3'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 1);
  });

  testWidgets('可见性变化清除本图并取消查询，迟到结果不能恢复遮罩内容', (tester) async {
    final repository = _Repository();
    await _pump(tester, repository);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ReadingImageGalleryPage)),
    );
    container.read(contentVisibilityRevisionProvider.notifier).advance();
    await tester.pump();
    expect(repository.operations.single.cancelled, isTrue);
    expect(find.byType(ContentImageViewerPage), findsNothing);
    expect(find.text('图片暂时不可见'), findsOneWidget);
    repository.operations.single.resultCompleter.complete(
      const ReadingGalleryPage(items: [_image], anchorItemId: 'clicked'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ContentImageViewerPage), findsNothing);
  });

  testWidgets('首次查询权限丢失立即移除已加载的敏感图片', (tester) async {
    final repository = _Repository();
    await _pump(tester, repository);
    repository.operations.single.resultCompleter.completeError(
      const ApiFailure(httpStatus: 404),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ContentImageViewerPage), findsNothing);
    expect(find.text('图片暂时不可见'), findsOneWidget);
  });
}

const _image = ReadingGalleryImage(
  id: 'clicked',
  sourceId: 'post',
  sourceVersion: 7,
  imageIndex: 1,
  imageCount: 3,
  url: 'https://example.test/image.png',
  threadId: 'thread',
  subthreadId: 'subthread',
  floorNumber: 12,
);

Future<void> _pump(WidgetTester tester, _Repository repository) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        readingGalleryRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const ReadingImageGalleryPage(
          request: ReadingGalleryRequest(
            scope: ReadingGalleryScope.subthread,
            scopeId: 'subthread',
            anchorId: 'post',
            anchorVersion: 7,
            anchorIndex: 1,
          ),
          initialImage: _image,
        ),
      ),
    ),
  );
  await tester.pump();
}

class _Repository implements ReadingGalleryRepository {
  final operations = <_Operation>[];
  final cursors = <String?>[];
  @override
  ReadingGalleryOperation load(
    ReadingGalleryRequest request, {
    String? cursor,
  }) {
    cursors.add(cursor);
    final operation = _Operation();
    operations.add(operation);
    return operation;
  }
}

class _Operation implements ReadingGalleryOperation {
  final resultCompleter = Completer<ReadingGalleryPage>();
  bool cancelled = false;
  @override
  Future<ReadingGalleryPage> get result => resultCompleter.future;
  @override
  void cancel() => cancelled = true;
}
