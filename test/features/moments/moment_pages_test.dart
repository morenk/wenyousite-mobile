import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_draft_store.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_repository.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_page.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_page.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_feed_page.dart';

void main() {
  testWidgets('发现信息流展示文本封面，游客切到关注只发起登录引导', (tester) async {
    final repository = _PageRepository();
    await tester.pumpWidget(_feedApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('今日微光'), findsWidgets);
    expect(find.byKey(const Key('moment-card-moment-1')), findsOneWidget);
    expect(repository.feedModes, [MomentFeedMode.discover]);

    await tester.tap(find.text('关注'));
    await tester.pumpAndSettle();
    expect(find.text('登录后查看关注动态'), findsOneWidget);
    expect(repository.feedModes, [MomentFeedMode.discover]);
  });

  testWidgets('360dp 动态信息流使用双列瀑布布局并保留 48dp 点赞目标', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(_feedApp(_PageRepository()));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('动态瀑布流'), findsOneWidget);
    expect(find.bySemanticsLabel('查看动态：今日微光'), findsOneWidget);
    expect(find.text('动态正文是纯文本'), findsNothing);
    expect(find.byKey(const Key('moment-bookmark-moment-1')), findsNothing);

    final first = find.byKey(const Key('moment-card-moment-1'));
    final second = find.byKey(const Key('moment-card-moment-2'));
    final third = find.byKey(const Key('moment-card-moment-3'));
    final firstTopLeft = tester.getTopLeft(first);
    final secondTopLeft = tester.getTopLeft(second);
    final thirdTopLeft = tester.getTopLeft(third);
    expect(firstTopLeft.dx, lessThan(secondTopLeft.dx));
    expect(thirdTopLeft.dx, closeTo(firstTopLeft.dx, 0.1));
    expect(thirdTopLeft.dy, greaterThan(firstTopLeft.dy));
    expect(thirdTopLeft.dy, lessThan(tester.getBottomRight(second).dy));

    final likeSize = tester.getSize(
      find.byKey(const Key('moment-like-moment-1')),
    );
    expect(likeSize.width, greaterThanOrEqualTo(48));
    expect(likeSize.height, greaterThanOrEqualTo(48));
    semantics.dispose();
  });

  testWidgets('动态首屏加载态使用双列瀑布骨架', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = _PendingPageRepository();
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(_feedApp(repository));
    await tester.pump();

    expect(find.bySemanticsLabel('正在加载动态'), findsNWidgets(4));
    final skeletons = find.bySemanticsLabel('正在加载动态');
    expect(
      tester.getTopLeft(skeletons.at(0)).dx,
      lessThan(tester.getTopLeft(skeletons.at(1)).dx),
    );

    repository.feed.complete(
      CursorPage(items: [_card()], cursor: null, hasMore: false),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moment-card-moment-1')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('360dp 动态瀑布流保持 Foundation 视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_feedApp(_PageRepository()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('moment-feed-visual')),
      matchesGoldenFile('goldens/moment_waterfall_360.png'),
    );
  });

  testWidgets('动态详情展示纯文本、评论筛选与游客常驻评论入口', (tester) async {
    final repository = _PageRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [momentRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentDetailPage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('moment-detail-report')), findsOneWidget);
    expect(find.text('动态正文是纯文本'), findsOneWidget);
    expect(find.text('主评论'), findsOneWidget);
    expect(
      find.byKey(const Key('moment-comment-report-comment-root')),
      findsOneWidget,
    );
    expect(find.text('最新在前'), findsOneWidget);
    expect(find.byType(DropdownButton<String?>), findsNothing);
    expect(find.byKey(const Key('moment-comment-dock')), findsOneWidget);
    expect(find.text('登录后发表评论'), findsOneWidget);
    expect(find.byKey(const Key('moment-detail-login')), findsNothing);
  });

  testWidgets('动态评论入口常驻首屏并从评论动作带入回复对象', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = _PageRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        momentRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('user-1'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentDetailPage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final dock = find.byKey(const Key('moment-comment-dock'));
    expect(dock, findsOneWidget);
    expect(find.text('发表评论…'), findsOneWidget);
    expect(tester.getBottomRight(dock).dy, lessThanOrEqualTo(760));

    await tester.tap(dock);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moment-comment-input')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('moment-comment-input')),
      '从常驻入口发表',
    );
    await tester.tap(find.byKey(const Key('moment-comment-send')));
    await tester.pumpAndSettle();

    expect(repository.commentInputs, hasLength(1));
    expect(repository.commentInputs.single.content, '从常驻入口发表');
    expect(repository.commentInputs.single.replyToCommentId, isNull);
    expect(find.byKey(const Key('moment-comment-input')), findsNothing);

    final replyAction = find.widgetWithText(
      TextButton,
      '回复',
      skipOffstage: false,
    );
    await tester.ensureVisible(replyAction);
    await tester.tap(replyAction);
    await tester.pumpAndSettle();
    expect(find.text('回复 @温柔测试员'), findsOneWidget);
    expect(find.byKey(const Key('moment-comment-input')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('moment-comment-input')),
      '暂时不发送的草稿',
    );
    await tester.tap(find.byKey(const Key('moment-comment-close')));
    await tester.pumpAndSettle();
    expect(find.text('放弃这条评论？'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, '继续编辑'));
    await tester.pumpAndSettle();
    expect(find.text('暂时不发送的草稿'), findsOneWidget);
    await tester.tap(find.byKey(const Key('moment-comment-close')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '放弃评论'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moment-comment-input')), findsNothing);
  });

  testWidgets('动态详情多图使用固定舞台横滑并从当前图片进入原图', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final semantics = tester.ensureSemantics();
    final repository = _PageRepository(detail: _detailWithImages());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [momentRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentDetailPage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final gallery = find.byKey(const Key('moment-detail-gallery'));
    final carousel = find.byKey(const Key('moment-detail-carousel'));
    expect(gallery, findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('动态图片轮播，共 3 张，左右滑动切换')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: gallery, matching: find.byType(GridView)),
      findsNothing,
    );
    expect(
      find.descendant(of: gallery, matching: find.byType(PageView)),
      findsOneWidget,
    );
    expect(find.text('1 / 3'), findsOneWidget);
    final firstImage = tester.widget<CachedNetworkImage>(
      find.byKey(const Key('moment-content-image-0')),
    );
    expect(firstImage.imageUrl, 'https://cdn.example.com/1-md.webp');
    expect(firstImage.fit, BoxFit.contain);
    expect(
      tester.getBottomRight(find.text('今日微光')).dy,
      lessThan(tester.getTopLeft(gallery).dy),
    );
    expect(
      tester.getTopLeft(find.text('动态正文是纯文本')).dy,
      greaterThan(tester.getBottomRight(gallery).dy),
    );
    final initialStageSize = tester.getSize(gallery);
    expect(initialStageSize.width, 336);
    expect(initialStageSize.aspectRatio, closeTo(1, 0.01));

    await tester.drag(carousel, const Offset(-320, 0));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('2 / 3'), findsOneWidget);
    expect(tester.getSize(gallery), initialStageSize);
    final secondImage = tester.widget<CachedNetworkImage>(
      find.byKey(const Key('moment-content-image-1')),
    );
    expect(secondImage.imageUrl, 'https://cdn.example.com/2-md.webp');
    expect(secondImage.fit, BoxFit.contain);

    await tester.tap(find.byKey(const Key('moment-detail-image')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const Key('moment-gallery-close')), findsOneWidget);
    expect(find.text('2 / 3'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('纯文字动态可完成发布且保留稳定详情目标', (tester) async {
    final repository = _PageRepository();
    final draftStore = _MemoryMomentDraftStore();
    final router = GoRouter(
      initialLocation: '/compose/moment',
      routes: [
        GoRoute(
          path: '/compose/moment',
          builder: (_, _) => const MomentComposePage(),
        ),
        GoRoute(
          path: '/moments/:momentId',
          name: 'moment-detail',
          builder: (_, state) =>
              Scaffold(body: Text('动态=${state.pathParameters['momentId']}')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(repository),
          momentDraftStoreProvider.overrideWithValue(draftStore),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('moment-compose-title')),
      '新的动态',
    );
    await tester.enterText(
      find.byKey(const Key('moment-compose-content')),
      '纯文字也可以发布',
    );
    await tester.ensureVisible(find.byKey(const Key('moment-compose-submit')));
    await tester.tap(find.byKey(const Key('moment-compose-submit')));
    await tester.pumpAndSettle();

    expect(repository.createdInputs.single.mediaIds, isEmpty);
    expect(repository.createdInputs.single.title, '新的动态');
    expect(draftStore.draft, isNull);
    expect(find.text('动态=moment-1'), findsOneWidget);
  });

  testWidgets('动态草稿恢复文字与图片顺序并在离开前确认', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final draftStore = _MemoryMomentDraftStore()
      ..draft = MomentLocalDraft(
        title: '未完成的标题',
        content: '未完成的正文',
        images: const [
          UploadedEditorImage(
            mediaId: 'media-2',
            url: 'https://cdn.example.com/2.webp',
          ),
          UploadedEditorImage(
            mediaId: 'media-1',
            url: 'https://cdn.example.com/1.webp',
          ),
        ],
        coverMediaId: 'media-2',
        updatedAt: DateTime.utc(2026, 8, 11, 8),
      );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(_PageRepository()),
          momentDraftStoreProvider.overrideWithValue(draftStore),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('恢复未完成的动态？'), findsOneWidget);
    await tester.tap(find.byKey(const Key('moment-draft-restore')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('moment-compose-title')))
          .controller!
          .text,
      '未完成的标题',
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('media-2'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const ValueKey('media-1'))).dy),
    );
    final publish = find.byKey(const Key('moment-compose-submit'));
    expect(publish, findsOneWidget);
    expect(tester.getBottomRight(publish).dy, lessThanOrEqualTo(752));

    await tester.enterText(
      find.byKey(const Key('moment-compose-title')),
      '自动保存后的标题',
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(draftStore.draft?.title, '自动保存后的标题');
    expect(draftStore.draft?.images.map((image) => image.mediaId), [
      'media-2',
      'media-1',
    ]);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('离开动态编辑？'), findsOneWidget);
    expect(find.byKey(const Key('moment-leave-save')), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 动态信息流、详情与发布页无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 760);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = _PageRepository();

      await tester.pumpWidget(_feedApp(repository));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            momentRepositoryProvider.overrideWithValue(repository),
            momentDraftStoreProvider.overrideWithValue(
              _MemoryMomentDraftStore(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MomentDetailPage(momentId: 'moment-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            momentRepositoryProvider.overrideWithValue(repository),
            momentDraftStoreProvider.overrideWithValue(
              _MemoryMomentDraftStore(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MomentComposePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

Widget _feedApp(MomentRepository repository) {
  return ProviderScope(
    overrides: [
      momentRepositoryProvider.overrideWithValue(repository),
      momentDraftStoreProvider.overrideWithValue(_MemoryMomentDraftStore()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const RepaintBoundary(
        key: Key('moment-feed-visual'),
        child: MomentFeedPage(),
      ),
    ),
  );
}

class _PageRepository extends Fake implements MomentRepository {
  _PageRepository({MomentDetail? detail}) : _detailValue = detail ?? _detail();

  final feedModes = <MomentFeedMode>[];
  final createdInputs = <MomentDraftInput>[];
  final commentInputs = <MomentCommentInput>[];
  final MomentDetail _detailValue;

  @override
  Future<CursorPage<MomentCard>> fetchFeed({
    required MomentFeedMode mode,
    String? cursor,
    int limit = 20,
  }) async {
    feedModes.add(mode);
    return CursorPage(
      items: [
        _card(),
        _card(
          id: 'moment-2',
          title: '这是一个足够长并且会占据两行空间的动态标题',
          theme: MomentTextCoverTheme.rose,
        ),
        _card(
          id: 'moment-3',
          title: '第三条动态',
          theme: MomentTextCoverTheme.amber,
        ),
      ],
      cursor: null,
      hasMore: false,
    );
  }

  @override
  Future<MomentDetail> fetchDetail(String momentId) async => _detailValue;

  @override
  Future<CursorPage<MomentRootComment>> fetchComments({
    required String momentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  }) async {
    return CursorPage(items: [_rootComment()], cursor: null, hasMore: false);
  }

  @override
  Future<List<MomentAuthor>> fetchCommentAuthors(String momentId) async {
    return [_author()];
  }

  @override
  Future<MomentComment> createComment(
    String momentId,
    MomentCommentInput input, {
    required String clientRequestId,
  }) async {
    commentInputs.add(input);
    return MomentComment(
      id: 'comment-created',
      momentId: momentId,
      author: _author(),
      content: input.content,
      parentCommentId: input.replyToCommentId == null ? null : 'comment-root',
      deleted: false,
      canDelete: true,
      createdAt: DateTime.utc(2026, 8, 10, 14),
    );
  }

  @override
  Future<MomentDetail> create(
    MomentDraftInput input, {
    required String clientRequestId,
  }) async {
    createdInputs.add(input.normalized());
    return _detail();
  }
}

class _PendingPageRepository extends _PageRepository {
  final feed = Completer<CursorPage<MomentCard>>();

  @override
  Future<CursorPage<MomentCard>> fetchFeed({
    required MomentFeedMode mode,
    String? cursor,
    int limit = 20,
  }) {
    feedModes.add(mode);
    return feed.future;
  }
}

class _MemoryMomentDraftStore implements MomentDraftStore {
  MomentLocalDraft? draft;

  @override
  Future<void> delete(String? momentId) async => draft = null;

  @override
  Future<MomentLocalDraft?> read(String? momentId) async => draft;

  @override
  Future<void> write(String? momentId, MomentLocalDraft value) async {
    draft = value;
  }
}

MomentAuthor _author() =>
    const MomentAuthor(id: 'user-1', username: '温柔测试员', level: 4);

MomentCard _card({
  String id = 'moment-1',
  String title = '今日微光',
  MomentTextCoverTheme theme = MomentTextCoverTheme.mint,
  MomentMedia? coverMedia,
  int imageCount = 0,
}) {
  final now = DateTime.utc(2026, 8, 10, 12);
  return MomentCard(
    id: id,
    author: _author(),
    title: title,
    contentExcerpt: '动态正文是纯文本',
    coverType: coverMedia == null
        ? MomentCoverType.text
        : MomentCoverType.image,
    textCoverTheme: theme,
    coverMedia: coverMedia,
    imageCount: imageCount,
    likeCount: 2,
    commentCount: 1,
    bookmarkCount: 0,
    tipTotal: '0',
    viewerLiked: false,
    viewerBookmarked: false,
    createdAt: now,
    updatedAt: now,
  );
}

MomentDetail _detail() => MomentDetail(
  card: _card(),
  content: '动态正文是纯文本',
  images: const [],
  version: 3,
  canEdit: false,
  canDelete: false,
);

MomentDetail _detailWithImages() {
  const images = [
    MomentMedia(
      id: 'image-1',
      url: 'https://cdn.example.com/1.webp',
      mediumUrl: 'https://cdn.example.com/1-md.webp',
      width: 1200,
      height: 1600,
    ),
    MomentMedia(
      id: 'image-2',
      url: 'https://cdn.example.com/2.webp',
      mediumUrl: 'https://cdn.example.com/2-md.webp',
      width: 1600,
      height: 1000,
    ),
    MomentMedia(
      id: 'image-3',
      url: 'https://cdn.example.com/3.webp',
      mediumUrl: 'https://cdn.example.com/3-md.webp',
      width: 1000,
      height: 1000,
    ),
  ];
  return MomentDetail(
    card: _card(coverMedia: images[2], imageCount: images.length),
    content: '动态正文是纯文本',
    images: images,
    version: 3,
    canEdit: false,
    canDelete: false,
  );
}

MomentRootComment _rootComment() => MomentRootComment(
  id: 'comment-root',
  momentId: 'moment-1',
  author: _author(),
  content: '主评论',
  deleted: false,
  canDelete: false,
  createdAt: DateTime.utc(2026, 8, 10, 13),
  replyCount: 0,
  replies: const [],
);

SessionTokens _tokensFor(String userId) {
  final payload = base64Url.encode(utf8.encode(jsonEncode({'sub': userId})));
  return SessionTokens(
    accessToken: 'e30.$payload.signature',
    refreshToken: 'refresh-token',
  );
}

class _MemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class _FakeSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) async =>
      _tokensFor('user-1');
}
