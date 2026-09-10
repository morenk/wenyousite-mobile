import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_animation_source_ports.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_playback_coordinator.dart';
import 'package:wenyousite_mobile/features/thread_feed/domain/thread_feed_models.dart';
import 'package:wenyousite_mobile/features/thread_feed/presentation/controlled_cover_animation.dart';
import 'package:wenyousite_mobile/features/thread_feed/presentation/cover_playback_scope.dart';
import 'package:wenyousite_mobile/features/thread_feed/presentation/thread_feed_cover.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/users/data/public_user_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/public_user_page.dart';

const _posterUrl = 'https://cdn.example/profile-poster.webp';

class _RecordingAnimation implements CoverAnimationSource {
  final urls = <String>[];
  final tokens = <CancelToken>[];
  @override
  Future<CoverAnimationData> load(String url, CancelToken cancel) {
    urls.add(url);
    tokens.add(cancel);
    return Completer<CoverAnimationData>().future;
  }

  @override
  Future<void> invalidate(String url) async {}
  @override
  void changeViewer(String? accountId, {required bool purge}) {}
  @override
  void releaseMemory() {}
  @override
  void dispose() {}
}

class _ProfileRepository implements PublicUserRepository {
  @override
  Future<PublicUserProfileModel> fetchUser(String userId) async =>
      PublicUserProfileModel(
        id: userId,
        username: '个人主页回归',
        level: 1,
        followingCount: 0,
        followerCount: 0,
        receivedTipTotal: '0',
        receivedTipCount: 0,
        showRecentReplies: true,
        showPlayedThreads: true,
        showBookmarks: true,
        isFollowing: false,
        isFollowedBy: false,
        isBlocked: false,
        isBlockedBy: false,
        isDeactivated: false,
      );
  @override
  Future<PublicUserActivitySummary> fetchActivitySummary(String userId) async =>
      const PublicUserActivitySummary(
        momentCount: 0,
        createdThreadCount: 8,
        playedThreadCount: 8,
        replyCount: 0,
      );

  CursorPage<PublicUserThreadModel> _page(String prefix, String? cursor) =>
      CursorPage(
        items: List.generate(4, (offset) {
          final index = offset + (cursor == null ? 0 : 4);
          final id = '$prefix-$index';
          return PublicUserThreadModel(
            id: id,
            title: '动画主题 $id',
            status: ThreadFeedStatus.recruiting,
            ownerName: '个人主页回归',
            ownerLevel: 1,
            memberCount: 1,
            postCount: 1,
            createdAt: DateTime.utc(2026, 9, 11),
            coverMedia: ThreadFeedCoverMedia(
              url: 'https://cdn.example/$id.gif',
              animated: true,
              posterUrl: _posterUrl,
            ),
          );
        }),
        cursor: cursor == null ? 'next' : null,
        hasMore: cursor == null,
      );
  @override
  Future<CursorPage<PublicUserThreadModel>> fetchCreatedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async => _page('created', cursor);
  @override
  Future<CursorPage<PublicUserThreadModel>> fetchPlayedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async => _page('played', cursor);
  @override
  Future<CursorPage<PublicUserThreadModel>> fetchBookmarks(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async => _page('bookmarks', cursor);
  @override
  Future<List<PublicUserReplyModel>> fetchRecentReplies(String userId) async =>
      [];
}

Future<void> _cachePoster(WidgetTester tester) async {
  // 真实解码的静态封面进入正常 ImageCache；不跳过生产 poster 资格回调。
  await tester.runAsync(() async {
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawColor(Colors.white, BlendMode.src);
    final picture = recorder.endRecording();
    final bitmap = await picture.toImage(16, 16);
    picture.dispose();
    const provider = CachedNetworkImageProvider(_posterUrl);
    for (final image in <ImageProvider>[
      provider,
      ResizeImage.resizeIfNeeded(540, null, provider),
    ]) {
      final key = await image.obtainKey(ImageConfiguration.empty);
      PaintingBinding.instance.imageCache.putIfAbsent(
        key,
        () => OneFrameImageStreamCompleter(
          Future.value(ImageInfo(image: bitmap.clone())),
        ),
      );
    }
    bitmap.dispose();
    await Future<void>.delayed(Duration.zero);
  });
}

void main() {
  testWidgets('个人主页可见封面轻滑持续，分页不重启，详情返回和收藏Tab恢复', (tester) async {
    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final source = _RecordingAnimation();
    final container = ProviderContainer(
      overrides: [
        publicUserRepositoryProvider.overrideWithValue(_ProfileRepository()),
        coverAnimationSourceProvider.overrideWithValue(source),
      ],
    );
    final navigator = GlobalKey<NavigatorState>();
    await _cachePoster(tester);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: navigator,
          theme: AppTheme.light,
          builder: (_, child) => CoverPlaybackScope(child: child!),
          home: const PublicUserPage(userId: 'profile'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final cover = find.byKey(const Key('home-thread-cover-created-0'));
    await tester.scrollUntilVisible(
      cover,
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final position = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
    position.jumpTo(
      (position.pixels + tester.getRect(cover).center.dy - 350).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(source.urls, contains('https://cdn.example/created-0.gif'));
    final beforeScroll = source.urls.length;
    final visibleTokens = source.tokens
        .where((token) => !token.isCancelled)
        .toList();
    expect(visibleTokens, isNotEmpty);
    final gesture = await tester.startGesture(const Offset(200, 400));
    await gesture.moveBy(const Offset(0, -30));
    await tester.pump();
    expect(visibleTokens.every((token) => !token.isCancelled), isTrue);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(source.urls.length, beforeScroll);
    final active = tester
        .widgetList<ControlledCoverAnimation>(
          find.byType(ControlledCoverAnimation),
        )
        .where((widget) => widget.phase!.value == CoverPlaybackPhase.playing)
        .toList();
    expect(active, isNotEmpty);
    final beforePagination = source.urls.length;
    await container
        .read(publicUserControllerProvider('profile').notifier)
        .loadMoreActive();
    await tester.pumpAndSettle();
    expect(source.urls.length, beforePagination);

    unawaited(
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('详情')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(source.tokens.every((token) => token.isCancelled), isTrue);
    navigator.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 140));
    expect(source.urls.length, beforePagination);
    await tester.pumpAndSettle();
    await tester.pump();
    expect(source.urls.length, greaterThan(beforePagination));

    await container
        .read(publicUserControllerProvider('profile').notifier)
        .selectTab(PublicUserContentTab.bookmarks);
    await tester.pumpAndSettle();
    await tester.pump();
    expect(source.urls.last, contains('/bookmarks-'));
    expect(
      tester
          .widgetList<ControlledCoverAnimation>(
            find.byType(ControlledCoverAnimation),
          )
          .where((widget) => widget.phase!.value != CoverPlaybackPhase.idle)
          .length,
      1,
    );
    expect(find.byType(ThreadFeedCover), findsWidgets);
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  });
}
