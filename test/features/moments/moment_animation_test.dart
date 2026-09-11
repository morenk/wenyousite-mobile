import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_comment_body.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_playback_image.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_widgets.dart';
import 'moment_animation_fixture.dart';

void main() {
  test('GIF 以元数据识别，列表所有类型仅使用派生图', () {
    expect(_media.isAnimated, true);
    expect(_media.staticFeedUrls, [_media.thumbnailUrl]);
    expect(_media.playbackPreviewUrls, [_media.thumbnailUrl]);
    expect(
      const MomentMedia(
        id: 'old',
        url: 'https://cdn.example/raw',
      ).staticFeedUrls,
      isEmpty,
    );
    expect(
      const MomentMedia(
        id: 'alias',
        url: 'https://cdn.example/raw',
        thumbnailUrl: 'https://cdn.example/raw',
        animated: true,
      ).staticFeedUrls,
      isEmpty,
    );
    const still = MomentMedia(
      id: 'still',
      url: 'https://cdn.example/raw',
      feedUrl: 'https://cdn.example/feed',
      thumbnailUrl: 'https://cdn.example/thumb',
      mediumUrl: 'https://cdn.example/medium',
    );
    expect(still.staticFeedUrls, [
      still.feedUrl,
      still.thumbnailUrl,
      still.mediumUrl,
    ]);
  });

  testWidgets('真实双帧 GIF：列表静帧无原图请求，详情画面变化，暂停释放帧', (tester) async {
    await MomentAnimationFixture.run(tester, (fixture) async {
      await tester.pumpWidget(
        _app(
          const SizedBox.square(
            dimension: 100,
            child: MomentCoverImage(media: _media),
          ),
        ),
      );
      await _decode(tester);
      expect(fixture.requests, [_media.thumbnailUrl]);
      final still = await _pixel(tester);
      await tester.pump(const Duration(milliseconds: 150));
      expect(await _pixel(tester), still);
      await tester.pumpWidget(
        _app(
          MomentPlaybackImage(
            previewUrls: [_media.thumbnailUrl!],
            animationUrl: _media.url,
            allowPlayback: true,
            width: 100,
            height: 100,
          ),
        ),
      );
      await _decode(tester);
      expect(fixture.requests, contains(_media.url));
      final first = await _pixel(tester);
      await tester.pump(const Duration(milliseconds: 110));
      await tester.pump();
      expect(await _pixel(tester), isNot(first));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await _decode(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      expect(_animationUrls(tester), isEmpty);
      final stopped = await _pixel(tester);
      await tester.pump(const Duration(milliseconds: 350));
      expect(await _pixel(tester), stopped);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });
  });

  testWidgets('列表缩略图失败或缺失不请求原图', (tester) async {
    await MomentAnimationFixture.run(tester, (fixture) async {
      fixture.failures.add(_media.thumbnailUrl!);
      await tester.pumpWidget(
        _app(
          const SizedBox.square(
            dimension: 100,
            child: MomentCoverImage(media: _media),
          ),
        ),
      );
      await _decode(tester);
      expect(fixture.requests, [_media.thumbnailUrl]);
      await tester.pumpWidget(
        _app(
          const SizedBox.square(
            dimension: 100,
            child: MomentCoverImage(
              media: MomentMedia(
                id: 'missing',
                url: 'https://cdn.example/raw',
                animated: true,
              ),
            ),
          ),
        ),
      );
      await _settle(tester);
      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(fixture.requests, [_media.thumbnailUrl]);
    });
  });

  testWidgets('详情和全屏仅当前轮播图播放，底层暂停并在返回恢复', (tester) async {
    await MomentAnimationFixture.run(tester, (fixture) async {
      await tester.pumpWidget(
        _app(const MomentGallery(momentId: 'm', images: [_media, _second])),
      );
      await _decode(tester);
      expect(_animationUrls(tester), [_media.url]);
      expect(fixture.requests, isNot(contains(_second.url)));
      tester.widget<PageView>(find.byType(PageView)).controller!.jumpToPage(1);
      await _decode(tester);
      expect(_animationUrls(tester), [_second.url]);
      await _openGallery(tester);
      expect(_animationUrls(tester), [_second.url]);
      tester
          .widget<PageView>(find.byType(PageView).last)
          .controller!
          .jumpToPage(0);
      await _settle(tester);
      expect(_animationUrls(tester), [_media.url]);
      await _closeGallery(tester);
      expect(_animationUrls(tester), [_second.url]);
    });
  });

  testWidgets('可见主评论和楼中楼动态表情都播放，离屏和前后台停止', (tester) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await MomentAnimationFixture.run(tester, (fixture) async {
      await tester.pumpWidget(
        _app(
          SingleChildScrollView(
            controller: scroll,
            child: Column(
              children: [
                MomentCommentBody(
                  comment: _comment(media: _media),
                  busy: false,
                ),
                MomentCommentBody(
                  comment: _comment(sticker: true),
                  busy: false,
                  compact: true,
                ),
                const SizedBox(height: 1500),
              ],
            ),
          ),
        ),
      );
      await _decode(tester);
      expect(_animationUrls(tester), containsAll([_media.url, _second.url]));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await _settle(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      expect(_animationUrls(tester), isEmpty);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await _settle(tester);
      expect(_animationUrls(tester), containsAll([_media.url, _second.url]));
      scroll.jumpTo(1200);
      await _settle(tester);
      expect(_animationUrls(tester), isEmpty);
      scroll.jumpTo(0);
      await _settle(tester);
      expect(_animationUrls(tester), containsAll([_media.url, _second.url]));
    });
  });

  testWidgets('普通100x50静态图片与表情保留原始显示尺寸', (tester) async {
    await MomentAnimationFixture.run(tester, (fixture) async {
      final picture = MomentCommentBody(
        comment: _comment(
          media: const MomentMedia(
            id: 'still',
            url: 'https://cdn.example/still',
            mediumUrl: 'https://cdn.example/still-medium',
            contentType: 'image/png',
            width: 100,
            height: 50,
          ),
        ),
        busy: false,
      );
      final sticker = MomentCommentBody(
        comment: MomentComment(
          id: 'still-sticker',
          momentId: 'm',
          author: const MomentAuthor(id: 'u', username: '用户', level: 1),
          deleted: false,
          canDelete: false,
          createdAt: DateTime.utc(2026),
          sticker: const MomentSticker(
            id: 'still',
            url: 'https://cdn.example/still',
            thumbnailUrl: 'https://cdn.example/still-thumb',
            mediumUrl: 'https://cdn.example/still-medium',
            animated: false,
            frameCount: 1,
            durationMs: 0,
            width: 100,
            height: 50,
          ),
        ),
        busy: false,
      );
      await tester.pumpWidget(_app(Column(children: [picture, sticker])));
      await _decode(tester);
      for (final element in find.byType(MomentCommentBody).evaluate()) {
        final raw = find
            .descendant(
              of: find.byWidget(element.widget),
              matching: find.byType(RawImage),
            )
            .first;
        expect(tester.getSize(raw), const Size(100, 50));
      }
      expect(find.byType(MomentPlaybackImage), findsNothing);
    });
  });

  testWidgets('嵌套滚动任意祖先视口离屏都会停止动画', (tester) async {
    final outer = ScrollController();
    final inner = ScrollController();
    addTearDown(outer.dispose);
    addTearDown(inner.dispose);
    await MomentAnimationFixture.run(tester, (fixture) async {
      await tester.pumpWidget(
        _app(
          SingleChildScrollView(
            controller: outer,
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: SingleChildScrollView(
                    controller: inner,
                    child: Column(
                      children: [
                        MomentPlaybackImage(
                          previewUrls: [_media.thumbnailUrl!],
                          animationUrl: _media.url,
                          allowPlayback: true,
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 600),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 1400),
              ],
            ),
          ),
        ),
      );
      await _decode(tester);
      expect(_animationUrls(tester), [_media.url]);
      inner.jumpTo(250);
      await _settle(tester);
      expect(_animationUrls(tester), isEmpty);
      inner.jumpTo(0);
      await _settle(tester);
      expect(_animationUrls(tester), [_media.url]);
      outer.jumpTo(900);
      await _settle(tester);
      expect(_animationUrls(tester), isEmpty);
    });
  });
  testWidgets('失败跨轮播和全屏保持，显式重试成功后返回详情继续播放', (tester) async {
    await MomentAnimationFixture.run(tester, (fixture) async {
      fixture.failures.add(_media.url);
      await tester.pumpWidget(
        _app(const MomentGallery(momentId: 'm', images: [_media, _second])),
      );
      await _decode(tester);
      expect(find.text('重试播放'), findsOneWidget);
      final count = fixture.requests.where((url) => url == _media.url).length;
      final controller = tester
          .widget<PageView>(find.byType(PageView))
          .controller!;
      controller.jumpToPage(1);
      await _settle(tester);
      controller.jumpToPage(0);
      await _settle(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await _settle(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await _settle(tester);
      await _openGallery(tester);
      expect(_animationUrls(tester), isEmpty);
      expect(fixture.requests.where((url) => url == _media.url).length, count);
      fixture.failures.clear();
      await tester.tap(find.text('重试播放'));
      // 全屏双击缩放需要先结束单击／双击手势竞争。
      await tester.pump(const Duration(milliseconds: 350));
      await _decode(tester);
      expect(
        fixture.requests.where((url) => url == _media.url).length,
        count + 1,
      );
      expect(_animationUrls(tester), [_media.url]);
      final first = await _pixel(tester);
      await tester.pump(const Duration(milliseconds: 110));
      await tester.pump();
      expect(await _pixel(tester), isNot(first));
      await _closeGallery(tester);
      expect(_animationUrls(tester), [_media.url]);
    });
  });
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump();
  }
}

Future<void> _decode(WidgetTester tester) async {
  for (var i = 0; i < 80; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump();
  }
}

Future<void> _openGallery(WidgetTester tester) async {
  await tester.tapAt(
    tester.getTopLeft(find.byKey(const Key('moment-detail-image'))) +
        const Offset(20, 20),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await _settle(tester);
}

Future<void> _closeGallery(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('moment-gallery-close')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await _settle(tester);
}

Future<List<int>> _pixel(WidgetTester tester) async {
  final raw = tester
      .widgetList<RawImage>(find.byType(RawImage))
      .where((w) => w.image != null)
      .first;
  final data = await tester.runAsync(
    () => raw.image!.toByteData(format: ui.ImageByteFormat.rawRgba),
  );
  return data!.buffer.asUint8List().take(4).toList();
}

List<String> _animationUrls(WidgetTester tester) => tester
    .widgetList<CachedNetworkImage>(
      find.byType(CachedNetworkImage, skipOffstage: false),
    )
    .map((w) => w.imageUrl)
    .where((url) => url == _media.url || url == _second.url)
    .toList();
Widget _app(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: child),
  ),
);
const _media = MomentMedia(
  id: 'one',
  url: 'https://cdn.example/one',
  thumbnailUrl: 'https://cdn.example/one-thumb',
  contentType: 'image/gif',
  width: 100,
  height: 100,
);
const _second = MomentMedia(
  id: 'two',
  url: 'https://cdn.example/two',
  thumbnailUrl: 'https://cdn.example/two-thumb',
  animated: true,
  width: 100,
  height: 100,
);
MomentComment _comment({MomentMedia? media, bool sticker = false}) =>
    MomentComment(
      id: sticker ? 'reply' : 'root',
      momentId: 'm',
      author: const MomentAuthor(id: 'u', username: '用户', level: 1),
      deleted: false,
      canDelete: false,
      createdAt: DateTime.utc(2026),
      media: media,
      sticker: sticker
          ? MomentSticker(
              id: 's',
              url: _second.url,
              thumbnailUrl: _second.thumbnailUrl!,
              mediumUrl: _second.url,
              animated: true,
              frameCount: 2,
              durationMs: 200,
            )
          : null,
    );
