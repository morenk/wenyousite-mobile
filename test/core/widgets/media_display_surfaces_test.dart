import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/media/media_display.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_message_media.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_comment_body.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_widgets.dart';
import 'package:wenyousite_mobile/features/thread_feed/presentation/cover_playback_scope.dart';
import 'package:wenyousite_mobile/features/thread_feed/presentation/thread_feed_cover.dart';

import '../../features/moments/moment_animation_fixture.dart';

const source = 'https://cdn.example/original.gif';
const full = 'https://cdn.example/full.webp';
const poster = 'https://cdn.example/poster.png';
const display = MediaDisplay(
  url: full,
  width: 320,
  height: 180,
  bytes: 180,
  animated: true,
  frameCount: 2,
  durationMs: 360,
  loopCount: 2,
);
const media = MomentMedia(
  id: 'media-one',
  url: source,
  thumbnailUrl: poster,
  animated: true,
  width: 320,
  height: 180,
  display: display,
);

void main() {
  final resources = {
    for (final entry in {
      source: 'original.gif',
      full: 'full.webp',
      poster: 'poster.png',
    }.entries)
      entry.key: File(
        'test/fixtures/animation-webp-all-surfaces/${entry.value}',
      ).readAsBytesSync(),
  };
  for (final sticker in [false, true]) {
    testWidgets('私聊 ${sticker ? '表情' : '图片'} 及大图实际请求完整 WebP', (tester) async {
      await MomentAnimationFixture.run(tester, (fixture) async {
        await tester.pumpWidget(
          _app(
            DirectMessageImage(
              media: DirectMessageMedia(
                id: 'media-one',
                url: source,
                display: display,
                isSticker: sticker,
                animated: true,
                width: 320,
                height: 180,
                thumbnailUrl: poster,
              ),
            ),
          ),
        );
        await _decode(tester);
        expect(fixture.requests, [full]);
        await tester.tap(find.byType(DirectMessageImage));
        await tester.pumpAndSettle();
        await _decode(tester);
        expect(fixture.requests, isNot(contains(source)));
        expect(find.byKey(const Key('content-image-viewer')), findsOneWidget);
      }, resources: resources);
    });
    testWidgets('动态回复 ${sticker ? '表情' : '图片'} 使用完整 WebP', (tester) async {
      await MomentAnimationFixture.run(tester, (fixture) async {
        await tester.pumpWidget(
          _app(
            MomentCommentBody(
              comment: MomentComment(
                id: 'comment',
                momentId: 'moment',
                author: const MomentAuthor(id: 'u', username: '用户', level: 1),
                deleted: false,
                canDelete: false,
                createdAt: DateTime.utc(2026),
                media: sticker ? null : media,
                sticker: sticker
                    ? const MomentSticker(
                        id: 's',
                        url: source,
                        thumbnailUrl: poster,
                        mediumUrl: source,
                        animated: true,
                        frameCount: 2,
                        durationMs: 360,
                        width: 320,
                        height: 180,
                        display: display,
                      )
                    : null,
              ),
              busy: false,
            ),
          ),
        );
        await _decode(tester);
        expect(fixture.requests, contains(full));
        expect(fixture.requests, isNot(contains(source)));
      }, resources: resources);
    });
  }
  testWidgets('动态列表保持静态，详情画廊使用完整 WebP', (tester) async {
    await MomentAnimationFixture.run(tester, (fixture) async {
      await tester.pumpWidget(
        _app(
          const SizedBox.square(
            dimension: 100,
            child: MomentCoverImage(media: media),
          ),
        ),
      );
      await _decode(tester);
      expect(fixture.requests, [poster]);
      await tester.pumpWidget(
        _app(const MomentGallery(momentId: 'moment', images: [media])),
      );
      await _decode(tester);
      expect(fixture.requests, contains(full));
      expect(fixture.requests, isNot(contains(source)));
    }, resources: resources);
  });
  for (final mode in ['missing', 'loading', 'failed']) {
    testWidgets('已验证 display 不被 $mode poster 阻断，后台仍取消', (tester) async {
      final requests = <String>[];
      final tokens = <CancelToken>[];
      await tester.pumpWidget(
        _app(
          Center(
            child: SizedBox(
              width: 300,
              child: ThreadFeedCover(
                posterUrl: mode == 'missing' ? null : poster,
                animationUrl: full,
                hasVerifiedDisplay: true,
                posterBuilder: (_, _, ready, failed) {
                  if (mode == 'failed') {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => failed(),
                    );
                  }
                  return const ColoredBox(color: Colors.white);
                },
                animationLoader: (url, token) {
                  requests.add(url);
                  tokens.add(token);
                  return Completer<Uint8List>().future;
                },
              ),
            ),
          ),
          covers: true,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(requests, [full]);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(tokens.single.isCancelled, isTrue);
      await tester.pumpWidget(const SizedBox());
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });
  }
}

Widget _app(Widget child, {bool covers = false}) => ProviderScope(
  child: MaterialApp(
    theme: AppTheme.light,
    builder: (_, child) => covers ? CoverPlaybackScope(child: child!) : child!,
    home: Scaffold(body: child),
  ),
);
Future<void> _decode(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}
