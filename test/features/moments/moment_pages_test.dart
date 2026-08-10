import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
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

  testWidgets('动态详情展示纯文本、评论筛选与游客评论登录入口', (tester) async {
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

    expect(find.text('动态正文是纯文本'), findsOneWidget);
    expect(find.text('主评论'), findsOneWidget);
    expect(find.text('最新'), findsOneWidget);
    await tester.ensureVisible(find.text('登录后参与评论'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moment-detail-login')), findsOneWidget);
  });

  testWidgets('纯文字动态可完成发布且保留稳定详情目标', (tester) async {
    final repository = _PageRepository();
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
        overrides: [momentRepositoryProvider.overrideWithValue(repository)],
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
    expect(find.text('动态=moment-1'), findsOneWidget);
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
          overrides: [momentRepositoryProvider.overrideWithValue(repository)],
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
          overrides: [momentRepositoryProvider.overrideWithValue(repository)],
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
    overrides: [momentRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(theme: AppTheme.light, home: const MomentFeedPage()),
  );
}

class _PageRepository extends Fake implements MomentRepository {
  final feedModes = <MomentFeedMode>[];
  final createdInputs = <MomentDraftInput>[];

  @override
  Future<CursorPage<MomentCard>> fetchFeed({
    required MomentFeedMode mode,
    String? cursor,
    int limit = 20,
  }) async {
    feedModes.add(mode);
    return CursorPage(items: [_card()], cursor: null, hasMore: false);
  }

  @override
  Future<MomentDetail> fetchDetail(String momentId) async => _detail();

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
  Future<MomentDetail> create(
    MomentDraftInput input, {
    required String clientRequestId,
  }) async {
    createdInputs.add(input.normalized());
    return _detail();
  }
}

MomentAuthor _author() =>
    const MomentAuthor(id: 'user-1', username: '温柔测试员', level: 4);

MomentCard _card() {
  final now = DateTime.utc(2026, 8, 10, 12);
  return MomentCard(
    id: 'moment-1',
    author: _author(),
    title: '今日微光',
    contentExcerpt: '动态正文是纯文本',
    coverType: MomentCoverType.text,
    textCoverTheme: MomentTextCoverTheme.mint,
    imageCount: 0,
    likeCount: 2,
    commentCount: 1,
    bookmarkCount: 0,
    tipTotal: 0,
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
