import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/users/data/public_user_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/public_user_page.dart';

void main() {
  testWidgets('公开用户页展示资料、统计与只读关系状态', (tester) async {
    await tester.pumpWidget(_userApp(_FakePublicUserRepository()));
    await tester.pumpAndSettle();

    expect(find.text('温柔测试员'), findsOneWidget);
    expect(find.text('Lv.4'), findsOneWidget);
    expect(find.text('一起写下温柔的故事。'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('18L'), findsOneWidget);
    expect(find.text('已关注'), findsOneWidget);
    expect(find.text('关注了你'), findsOneWidget);
  });

  testWidgets('公开用户页失败后可重试恢复', (tester) async {
    final repository = _FakePublicUserRepository(failFirstRequest: true);
    await tester.pumpWidget(_userApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('用户资料没有加载完成'), findsOneWidget);
    expect(find.text('请求 ID：user-request-id'), findsOneWidget);
    await tester.tap(find.byKey(const Key('public-user-retry')));
    await tester.pumpAndSettle();

    expect(find.text('温柔测试员'), findsOneWidget);
    expect(repository.calls, 2);
  });

  testWidgets('公开内容按隐私页签惰性加载并展示真实结果', (tester) async {
    final repository = _FakePublicUserRepository();
    await tester.pumpWidget(_userApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('创建主题'), findsOneWidget);
    expect(repository.createdCalls, 1);
    expect(repository.playedCalls, 0);
    expect(repository.replyCalls, 0);
    expect(repository.bookmarkCalls, 0);

    await tester.ensureVisible(find.text('参与'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('参与'));
    await tester.pumpAndSettle();
    expect(find.text('参与主题'), findsOneWidget);
    expect(repository.playedCalls, 1);

    await tester.ensureVisible(find.text('回复'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('回复'));
    await tester.pumpAndSettle();
    expect(find.text('回复正文预览'), findsOneWidget);
    expect(repository.replyCalls, 1);

    await tester.ensureVisible(find.text('收藏'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('收藏'));
    await tester.pumpAndSettle();
    expect(find.text('收藏主题'), findsOneWidget);
    expect(repository.bookmarkCalls, 1);
  });

  testWidgets('关闭的隐私内容不显示页签也不触发请求', (tester) async {
    final repository = _FakePublicUserRepository(showPrivateContent: false);
    await tester.pumpWidget(_userApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('创建'), findsOneWidget);
    expect(find.text('参与'), findsNothing);
    expect(find.text('回复'), findsNothing);
    expect(find.text('收藏'), findsNothing);
    expect(repository.playedCalls, 0);
    expect(repository.replyCalls, 0);
    expect(repository.bookmarkCalls, 0);
  });

  testWidgets('公开内容首屏失败可局部重试且保留资料', (tester) async {
    final repository = _FakePublicUserRepository(failFirstCreated: true);
    await tester.pumpWidget(_userApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('温柔测试员'), findsOneWidget);
    expect(find.text('创建的主题没有加载完成'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('public-user-created-retry')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('public-user-created-retry')));
    await tester.pumpAndSettle();

    expect(find.text('创建主题'), findsOneWidget);
    expect(repository.createdCalls, 2);
  });

  testWidgets('公开主题和最近回复进入稳定主题目标路径', (tester) async {
    final repository = _FakePublicUserRepository();
    final router = GoRouter(
      initialLocation: '/users/user-1',
      routes: [
        GoRoute(
          path: '/users/:userId',
          name: 'user-profile',
          builder: (_, state) =>
              PublicUserPage(userId: state.pathParameters['userId']!),
        ),
        GoRoute(
          path: '/threads/:threadId',
          name: 'thread-detail',
          builder: (_, state) => Text(
            '主题=${state.pathParameters['threadId']};'
            '帖子=${state.uri.queryParameters['post']}',
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [publicUserRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('创建主题'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('创建主题'));
    await tester.pumpAndSettle();
    expect(find.text('主题=thread-created;帖子=null'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('回复'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('回复'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('回复正文预览'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('回复正文预览'));
    await tester.pumpAndSettle();
    expect(find.text('主题=thread-1;帖子=reply-1'), findsOneWidget);
  });

  testWidgets('404 与已注销资料使用不泄露旧信息的收敛状态', (tester) async {
    await tester.pumpWidget(
      _userApp(_FakePublicUserRepository(notFound: true)),
    );
    await tester.pumpAndSettle();
    expect(find.text('用户不存在'), findsOneWidget);
    expect(find.text('温柔测试员'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(
      _userApp(_FakePublicUserRepository(deactivated: true)),
    );
    await tester.pumpAndSettle();
    expect(find.text('已注销用户'), findsOneWidget);
    expect(find.text('温柔测试员'), findsNothing);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 公开用户资料无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_userApp(_FakePublicUserRepository()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}

Widget _userApp(PublicUserRepository repository) {
  return ProviderScope(
    overrides: [publicUserRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const PublicUserPage(userId: 'user-1'),
    ),
  );
}

class _FakePublicUserRepository implements PublicUserRepository {
  _FakePublicUserRepository({
    this.failFirstRequest = false,
    this.notFound = false,
    this.deactivated = false,
    this.showPrivateContent = true,
    this.failFirstCreated = false,
  });

  final bool failFirstRequest;
  final bool notFound;
  final bool deactivated;
  final bool showPrivateContent;
  final bool failFirstCreated;
  int calls = 0;
  int createdCalls = 0;
  int playedCalls = 0;
  int replyCalls = 0;
  int bookmarkCalls = 0;

  @override
  Future<PublicUserProfileModel> fetchUser(String userId) async {
    calls += 1;
    if (failFirstRequest && calls == 1) {
      throw const ApiFailure(
        userMessage: '暂时无法连接温油站，请检查网络。',
        requestId: 'user-request-id',
      );
    }
    if (notFound) {
      throw const ApiFailure(userMessage: '请求没有完成，请稍后重试。', httpStatus: 404);
    }
    return PublicUserProfileModel(
      id: userId,
      username: '温柔测试员',
      bio: '一起写下温柔的故事。',
      level: 4,
      followingCount: 7,
      followerCount: 9,
      receivedTipTotal: '18',
      receivedTipCount: 6,
      showRecentReplies: showPrivateContent,
      showPlayedThreads: showPrivateContent,
      showBookmarks: showPrivateContent,
      isFollowing: true,
      isFollowedBy: true,
      isBlocked: false,
      isBlockedBy: false,
      isDeactivated: deactivated,
      createdAt: DateTime.utc(2026, 8, 10),
    );
  }

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchCreatedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async {
    createdCalls += 1;
    if (failFirstCreated && createdCalls == 1) {
      throw const ApiFailure(
        userMessage: '创建的主题没有加载完成，请稍后重试。',
        requestId: 'created-request-id',
      );
    }
    return CursorPage(
      items: [_contentThread('thread-created', '创建主题')],
      hasMore: false,
    );
  }

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchPlayedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async {
    playedCalls += 1;
    return CursorPage(
      items: [_contentThread('thread-played', '参与主题')],
      hasMore: false,
    );
  }

  @override
  Future<List<PublicUserReplyModel>> fetchRecentReplies(String userId) async {
    replyCalls += 1;
    return [_contentReply];
  }

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchBookmarks(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async {
    bookmarkCalls += 1;
    return CursorPage(
      items: [_contentThread('thread-bookmark', '收藏主题')],
      hasMore: false,
    );
  }
}

PublicUserThreadModel _contentThread(String id, String title) {
  return PublicUserThreadModel(
    id: id,
    title: title,
    categorySlug: 'RPG',
    status: PublicUserThreadStatus.recruiting,
    isPrivate: false,
    ownerName: '温柔测试员',
    ownerLevel: 4,
    createdAt: DateTime.utc(2026, 8, 10),
    memberCount: 5,
    postCount: 12,
  );
}

final _contentReply = PublicUserReplyModel(
  id: 'reply-1',
  threadId: 'thread-1',
  threadTitle: '星海旅团',
  subthreadId: 'subthread-1',
  subthreadTitle: '主线',
  preview: '回复正文预览',
  createdAt: DateTime.utc(2026, 8, 10, 8),
  parentPostId: 'floor-1',
);
