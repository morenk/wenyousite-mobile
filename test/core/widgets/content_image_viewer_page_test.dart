import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/image_gallery.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_page_transitions.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/content_image_viewer_page.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_image_viewer_page.dart';

void main() {
  testWidgets('原图页支持双击缩放、再次双击复位和下滑关闭', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => pushWenyouFullscreenPage<void>(
                  context: context,
                  builder: (_) => ContentImageViewerPage.single(
                    url: 'https://cdn.example.com/story.png',
                    alt: '雾港地图',
                  ),
                ),
                child: const Text('查看图片'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('查看图片'));
    await tester.pumpAndSettle();

    final viewer = find.byType(InteractiveViewer);
    expect(viewer, findsOneWidget);
    final controller = tester
        .widget<InteractiveViewer>(viewer)
        .transformationController!;
    await _doubleTap(tester, viewer);
    await tester.pump();
    expect(controller.value.getMaxScaleOnAxis(), closeTo(2, 0.01));

    await _doubleTap(tester, viewer);
    await tester.pump();
    expect(controller.value.getMaxScaleOnAxis(), closeTo(1, 0.01));

    await tester.dragFrom(const Offset(180, 180), const Offset(0, 140));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('content-image-viewer')), findsNothing);
    expect(find.text('查看图片'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('原图页收藏进行中锁定菜单并只提交一次', (tester) async {
    final completer = Completer<String>();
    var calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: ContentImageViewerPage.single(
            url: 'https://cdn.example.com/story.png',
            alt: '雾港地图',
            onAddToStickers: (_) {
              calls += 1;
              return completer.future;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('content-image-actions')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加到表情收藏'));
    await tester.pump();

    expect(calls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<PopupMenuButton<dynamic>>(
            find.byKey(const Key('content-image-actions')),
          )
          .enabled,
      isFalse,
    );

    completer.complete('图片处理中…');
    await tester.pumpAndSettle();
    expect(find.text('图片处理中…'), findsOneWidget);
    expect(calls, 1);
  });

  testWidgets('收藏失败留在原图任务内并可原位重试', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: ContentImageViewerPage.single(
            url: 'https://cdn.example.com/story.png',
            alt: '雾港地图',
            onAddToStickers: (_) async {
              calls += 1;
              if (calls == 1) {
                throw const ApiFailure(
                  userMessage: '收藏表情失败，请稍后重试。',
                  requestId: 'save-image-request',
                );
              }
              return '已添加到表情收藏。';
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('content-image-actions')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加到表情收藏'));
    await tester.pumpAndSettle();

    expect(find.text('收藏表情失败，请稍后重试。'), findsOneWidget);
    expect(find.textContaining('问题编号：save-image-request'), findsOneWidget);
    expect(find.byKey(const Key('content-image-action-retry')), findsOneWidget);

    await tester.tap(find.byKey(const Key('content-image-action-retry')));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('收藏表情失败，请稍后重试。'), findsNothing);
    expect(find.text('已添加到表情收藏。'), findsOneWidget);
  });

  testWidgets('保存图片使用当前页原图和回退地址', (tester) async {
    final gallery = _FakeImageGalleryService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [imageGalleryServiceProvider.overrideWithValue(gallery)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: ContentImageViewerPage(
            items: const [
              WenyouImageViewerItem(
                id: 'first',
                url: 'https://cdn.example.com/first.png',
                semanticLabel: '第一张',
              ),
              WenyouImageViewerItem(
                id: 'second',
                url: 'https://cdn.example.com/second.png',
                fallbackUrls: ['https://cdn.example.com/second-fallback.png'],
                semanticLabel: '第二张',
              ),
            ],
          ),
        ),
      ),
    );

    tester.widget<PageView>(find.byType(PageView)).controller!.jumpToPage(1);
    await tester.pump();
    await tester.tap(find.byKey(const Key('content-image-actions')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存图片'));
    await tester.pumpAndSettle();

    expect(gallery.sources.single.url, 'https://cdn.example.com/second.png');
    expect(gallery.sources.single.fallbackUrls, [
      'https://cdn.example.com/second-fallback.png',
    ]);
    expect(find.text('图片已保存到系统相册。'), findsOneWidget);
  });

  testWidgets('照片权限需设置时提供设置入口', (tester) async {
    final gallery = _FakeImageGalleryService(
      failure: const ImageGalleryException(
        userMessage: '请在系统设置中允许温油站添加照片。',
        settingsRequired: true,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [imageGalleryServiceProvider.overrideWithValue(gallery)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: ContentImageViewerPage.single(
            url: 'https://cdn.example.com/story.png',
            alt: '雾港地图',
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('content-image-actions')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存图片'));
    await tester.pumpAndSettle();
    expect(find.text('请在系统设置中允许温油站添加照片。'), findsOneWidget);
    expect(find.text('前往设置'), findsOneWidget);

    await tester.tap(find.text('前往设置'));
    await tester.pump();
    expect(gallery.settingsCalls, 1);
  });
}

Future<void> _doubleTap(WidgetTester tester, Finder finder) async {
  final center = tester.getCenter(finder);
  await tester.tapAt(center);
  await tester.pump(const Duration(milliseconds: 80));
  await tester.tapAt(center);
}

class _FakeImageGalleryService implements ImageGalleryService {
  _FakeImageGalleryService({this.failure});

  final ImageGalleryException? failure;
  final List<ImageGallerySource> sources = [];
  var settingsCalls = 0;

  @override
  bool get isSupported => true;

  @override
  Future<void> openSettings() async {
    settingsCalls += 1;
  }

  @override
  ImageGallerySaveOperation startSave(ImageGallerySource source) {
    sources.add(source);
    return ImageGallerySaveOperation(
      result: failure == null ? Future.value() : Future.error(failure!),
      cancel: () {},
    );
  }
}
