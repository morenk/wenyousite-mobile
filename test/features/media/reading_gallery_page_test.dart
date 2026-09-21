import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/content_image_viewer_page.dart';
import 'package:wenyousite_mobile/features/media/application/reading_gallery_controller.dart';
import 'package:wenyousite_mobile/features/media/presentation/reading_image_gallery_page.dart';

void main() {
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
