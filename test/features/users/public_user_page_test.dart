import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/social/data/user_relation_repository.dart';
import 'package:wenyousite_mobile/features/users/data/me_profile_repository.dart';
import 'package:wenyousite_mobile/features/users/data/public_user_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/public_user_page.dart';

void main() {
  testWidgets('公开用户页展示资料、统计与只读关系状态', (tester) async {
    await tester.pumpWidget(_userApp(_FakePublicUserRepository()));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('public-user-profile-header')),
        matching: find.text('温柔测试员'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('public-user-profile-header')),
        matching: find.text('Lv.4'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('home-thread-card-thread-created')),
      findsOneWidget,
    );
    expect(find.text('一起写下温柔的故事。'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('18 升'), findsOneWidget);
    expect(find.text('创作概览'), findsOneWidget);
    expect(find.text('发布动态'), findsOneWidget);
    expect(find.text('创建主题'), findsWidgets);
    expect(find.text('参与主题'), findsOneWidget);
    expect(find.text('累计回复'), findsOneWidget);
    expect(find.text('已关注'), findsOneWidget);
    expect(find.text('关注了你'), findsOneWidget);
    expect(find.bySemanticsLabel('温柔测试员 的主页背景图'), findsNothing);
    expect(
      find.byKey(const Key('profile-identity-without-cover')),
      findsOneWidget,
    );
    final avatar = find.byKey(const ValueKey('profile-avatar-温柔测试员'));
    expect(tester.getSemantics(avatar).label, contains('温柔测试员 的头像'));
    final avatarRect = tester.getRect(avatar);
    expect(avatarRect.size, const Size.square(72));
  });

  testWidgets('公开用户页失败后可重试恢复', (tester) async {
    final repository = _FakePublicUserRepository(failFirstRequest: true);
    await tester.pumpWidget(_userApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('用户资料加载失败'), findsOneWidget);
    expect(find.text('问题编号：user-request-id'), findsOneWidget);
    await tester.tap(find.byKey(const Key('public-user-retry')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('public-user-profile-header')),
        matching: find.text('温柔测试员'),
      ),
      findsOneWidget,
    );
    expect(repository.calls, 2);
  });

  testWidgets('登录身份确认目标非本人后显示关系操作并同步粉丝数', (tester) async {
    final relationRepository = _FakeUserRelationRepository();
    final container = await _authenticatedContainer(
      currentUserId: 'me-1',
      publicRepository: _FakePublicUserRepository(),
      relationRepository: relationRepository,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PublicUserPage(userId: 'user-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('user-relation-follow')), findsOneWidget);
    expect(find.byKey(const Key('user-relation-block')), findsOneWidget);
    expect(find.byKey(const Key('public-user-report')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byKey(const Key('user-relation-block')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('public-user-profile-header')),
        matching: find.byKey(const Key('user-relation-block')),
      ),
      findsNothing,
    );
    expect(find.text('9'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('user-relation-follow')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('user-relation-follow')));
    await tester.pumpAndSettle();

    expect(relationRepository.unfollowCalls, 1);
    expect(find.text('8'), findsOneWidget);

    await tester.tap(find.byKey(const Key('user-relation-block')));
    await tester.pumpAndSettle();
    expect(find.text('拉黑用户？'), findsOneWidget);
    await tester.tap(find.byKey(const Key('user-relation-block-confirm')));
    await tester.pumpAndSettle();
    expect(relationRepository.blockCalls, 1);
    expect(find.byTooltip('取消拉黑'), findsOneWidget);
  });

  testWidgets('公开页目标是本人时不显示关注和拉黑操作', (tester) async {
    final container = await _authenticatedContainer(
      currentUserId: 'user-1',
      publicRepository: _FakePublicUserRepository(),
      relationRepository: _FakeUserRelationRepository(),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PublicUserPage(userId: 'user-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('user-relation-follow')), findsNothing);
    expect(find.byKey(const Key('user-relation-block')), findsNothing);
    expect(find.byKey(const Key('public-user-report')), findsNothing);
    expect(find.byKey(const Key('public-user-edit-profile')), findsOneWidget);
  });

  testWidgets('公开页不再提供本人只读预览分支', (tester) async {
    final container = await _authenticatedContainer(
      currentUserId: 'user-1',
      publicRepository: _FakePublicUserRepository(),
      relationRepository: _FakeUserRelationRepository(),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PublicUserPage(userId: 'user-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('用户主页'), findsOneWidget);
    expect(find.text('预览公开主页'), findsNothing);
    expect(find.byKey(const Key('public-user-edit-profile')), findsOneWidget);
    expect(find.byKey(const Key('public-user-open-moments')), findsOneWidget);
  });

  testWidgets('能力开启且目标非本人时可从用户主页发起私聊', (tester) async {
    final container = await _authenticatedContainer(
      currentUserId: 'me-1',
      publicRepository: _FakePublicUserRepository(),
      relationRepository: _FakeUserRelationRepository(),
      directMessagesEnabled: true,
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/users/user-1',
      routes: [
        GoRoute(
          path: '/users/:userId',
          builder: (_, state) =>
              PublicUserPage(userId: state.pathParameters['userId']!),
        ),
        GoRoute(
          path: '/messages/new/:userId',
          name: 'direct-message-new',
          builder: (_, state) =>
              Scaffold(body: Text('私聊对象=${state.pathParameters['userId']}')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final profileHeader = find.byKey(const Key('public-user-profile-header'));
    final actionKeys = [
      const Key('user-relation-follow'),
      const Key('public-user-open-direct-message'),
      const Key('public-user-open-moments'),
    ];
    expect(
      actionKeys.map((key) => tester.getSize(find.byKey(key)).width).toSet(),
      hasLength(1),
    );
    expect(
      find.descendant(
        of: profileHeader,
        matching: find.byKey(const Key('user-relation-block')),
      ),
      findsNothing,
    );
    expect(
      find.descendant(of: profileHeader, matching: find.byType(FilledButton)),
      findsNothing,
    );
    expect(
      find.descendant(of: profileHeader, matching: find.byType(OutlinedButton)),
      findsNothing,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('public-user-open-direct-message')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('public-user-open-direct-message')));
    await tester.pumpAndSettle();
    expect(find.text('私聊对象=user-1'), findsOneWidget);
  });

  testWidgets('公开内容按隐私页签惰性加载并展示真实结果', (tester) async {
    final repository = _FakePublicUserRepository();
    await tester.pumpWidget(_userApp(repository));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('home-thread-card-thread-created')),
      findsOneWidget,
    );
    expect(find.text('招募中'), findsOneWidget);
    expect(find.text('RPG'), findsNothing);
    expect(repository.createdCalls, 1);
    expect(repository.playedCalls, 0);
    expect(repository.replyCalls, 0);
    expect(repository.bookmarkCalls, 0);

    await tester.ensureVisible(find.text('参与'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('参与'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('home-thread-card-thread-played')),
      findsOneWidget,
    );
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
    expect(find.text('创建的主题加载失败'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('public-user-created-retry')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('public-user-created-retry')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('home-thread-card-thread-created')),
      findsOneWidget,
    );
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
        overrides: [
          appCapabilitiesProvider.overrideWithValue(const AppCapabilities()),
          publicUserRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final createdThread = find.byKey(
      const Key('home-thread-card-thread-created'),
    );
    await tester.ensureVisible(createdThread);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: createdThread, matching: find.text('创建主题')),
    );
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

  testWidgets('公开统计进入指定用户关注与粉丝稳定路径', (tester) async {
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
          path: '/users/:userId/following',
          name: 'user-following',
          builder: (_, state) => Text('关注列表=${state.pathParameters['userId']}'),
        ),
        GoRoute(
          path: '/users/:userId/followers',
          name: 'user-followers',
          builder: (_, state) => Text('粉丝列表=${state.pathParameters['userId']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appCapabilitiesProvider.overrideWithValue(const AppCapabilities()),
          publicUserRepositoryProvider.overrideWithValue(
            _FakePublicUserRepository(),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('关注'));
    await tester.pumpAndSettle();
    expect(find.text('关注列表=user-1'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('粉丝'));
    await tester.pumpAndSettle();
    expect(find.text('粉丝列表=user-1'), findsOneWidget);
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

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 公开用户资料与内容卡片始终占满内容宽度', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_userApp(_FakePublicUserRepository()));
      await tester.pumpAndSettle();

      final expectedWidth = width <= 400 ? width - 24 : width - 48;
      expect(
        tester
            .getSize(find.byKey(const Key('public-user-profile-header')))
            .width,
        expectedWidth,
      );
      expect(
        tester.getSize(find.byKey(const Key('public-user-content-area'))).width,
        expectedWidth,
      );
      final tabWidths = [
        for (final tab in ['created', 'played', 'replies', 'bookmarks'])
          tester.getSize(find.byKey(Key('public-user-$tab-tab'))).width,
      ];
      expect(tabWidths.toSet(), hasLength(1));
      expect(tester.takeException(), isNull);
    });
  }
}

Widget _userApp(PublicUserRepository repository) {
  return ProviderScope(
    overrides: [
      appCapabilitiesProvider.overrideWithValue(const AppCapabilities()),
      publicUserRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const PublicUserPage(userId: 'user-1'),
    ),
  );
}

Future<ProviderContainer> _authenticatedContainer({
  required String currentUserId,
  required PublicUserRepository publicRepository,
  required UserRelationRepository relationRepository,
  bool directMessagesEnabled = false,
}) async {
  final container = ProviderContainer(
    overrides: [
      appCapabilitiesProvider.overrideWithValue(
        AppCapabilities(directMessages: directMessagesEnabled),
      ),
      tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
      sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
      meProfileRepositoryProvider.overrideWithValue(
        _FakeMeProfileRepository(currentUserId),
      ),
      publicUserRepositoryProvider.overrideWithValue(publicRepository),
      userRelationRepositoryProvider.overrideWithValue(relationRepository),
    ],
  );
  await container
      .read(sessionControllerProvider.notifier)
      .authenticate(_tokens);
  return container;
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
  Future<PublicUserActivitySummary> fetchActivitySummary(String userId) async {
    return PublicUserActivitySummary(
      momentCount: 3,
      createdThreadCount: 2,
      playedThreadCount: showPrivateContent ? 1 : null,
      replyCount: showPrivateContent ? 4 : null,
    );
  }

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
        userMessage: '创建的主题加载失败，请稍后重试。',
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

class _FakeMeProfileRepository implements MeProfileRepository {
  _FakeMeProfileRepository(this.userId);

  final String userId;

  @override
  Future<MeProfileModel> fetchMe() async {
    return MeProfileModel(
      id: userId,
      email: 'owner@example.com',
      username: '本人',
      level: 4,
      experience: 150,
      currentLevelExperience: 100,
      nextLevelExperience: 200,
      receivedTipTotal: '18',
      receivedTipCount: 6,
      showRecentReplies: true,
      showPlayedThreads: true,
      showBookmarks: true,
      followingCount: 7,
      followerCount: 9,
      createdAt: DateTime.utc(2026, 8, 1),
      updatedAt: DateTime.utc(2026, 8, 10),
    );
  }

  @override
  Future<MeProfileUpdateResult> updateMe(MeProfilePatch patch) {
    throw UnimplementedError();
  }
}

class _FakeUserRelationRepository implements UserRelationRepository {
  int followCalls = 0;
  int unfollowCalls = 0;
  int blockCalls = 0;
  int unblockCalls = 0;

  @override
  Future<void> follow(String userId) async => followCalls += 1;

  @override
  Future<void> unfollow(String userId) async => unfollowCalls += 1;

  @override
  Future<void> block(String userId) async => blockCalls += 1;

  @override
  Future<void> unblock(String userId) async => unblockCalls += 1;
}

const _tokens = SessionTokens(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
);

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
  Future<SessionTokens> refresh(String refreshToken) async => _tokens;
}
