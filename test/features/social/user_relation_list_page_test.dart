import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/data/user_relation_list_repository.dart';
import 'package:wenyousite_mobile/features/social/data/user_relation_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/user_relation_list_page.dart';

void main() {
  testWidgets('公开关系列表展示用户并进入稳定资料路径', (tester) async {
    final repository = _FakeListRepository();
    await tester.pumpWidget(
      _relationApp(
        repository: repository,
        relationRepository: _FakeRelationRepository(),
        target: const UserRelationListTarget.public(
          kind: UserRelationListKind.following,
          userId: 'owner-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('关注的人'), findsOneWidget);
    expect(find.text('温柔旅人'), findsOneWidget);
    expect(find.text('Lv.4'), findsOneWidget);
    expect(repository.lastFollowingUserId, 'owner-1');

    await tester.tap(find.text('温柔旅人'));
    await tester.pumpAndSettle();
    expect(find.text('资料=user-1'), findsOneWidget);
  });

  testWidgets('列表失败显示请求 ID 并可重试为空状态', (tester) async {
    final repository = _FakeListRepository(failFirst: true, empty: true);
    await tester.pumpWidget(
      _relationApp(
        repository: repository,
        relationRepository: _FakeRelationRepository(),
        target: const UserRelationListTarget.public(
          kind: UserRelationListKind.followers,
          userId: 'owner-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('粉丝加载失败'), findsOneWidget);
    expect(find.textContaining('问题编号：list-request-id'), findsOneWidget);
    await tester.tap(find.byKey(const Key('user-relation-list-retry')));
    await tester.pumpAndSettle();

    expect(find.text('还没有粉丝'), findsOneWidget);
    expect(repository.followerCalls, 2);
  });

  testWidgets('取消拉黑失败保留条目，重试成功后移除', (tester) async {
    final relationRepository = _FakeRelationRepository(failUnblock: true);
    await tester.pumpWidget(
      _relationApp(
        repository: _FakeListRepository(),
        relationRepository: relationRepository,
        target: const UserRelationListTarget.current(
          kind: UserRelationListKind.blocks,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('unblock-user-1')));
    await tester.pumpAndSettle();
    expect(find.text('温柔旅人'), findsOneWidget);
    expect(find.textContaining('问题编号：unblock-request-id'), findsOneWidget);

    relationRepository.failUnblock = false;
    await tester.tap(find.byKey(const ValueKey('unblock-user-1')));
    await tester.pumpAndSettle();
    expect(find.text('温柔旅人'), findsNothing);
    expect(find.text('黑名单为空'), findsOneWidget);
    expect(find.text('已取消拉黑。'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 黑名单操作无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _relationApp(
          repository: _FakeListRepository(),
          relationRepository: _FakeRelationRepository(),
          target: const UserRelationListTarget.current(
            kind: UserRelationListKind.blocks,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}

Widget _relationApp({
  required UserRelationListRepository repository,
  required UserRelationRepository relationRepository,
  required UserRelationListTarget target,
}) {
  final router = GoRouter(
    initialLocation: '/relations',
    routes: [
      GoRoute(
        path: '/relations',
        builder: (_, _) => UserRelationListPage(target: target),
      ),
      GoRoute(
        path: '/users/:userId',
        name: 'user-profile',
        builder: (_, state) =>
            Scaffold(body: Text('资料=${state.pathParameters['userId']}')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      userRelationListRepositoryProvider.overrideWithValue(repository),
      userRelationRepositoryProvider.overrideWithValue(relationRepository),
    ],
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}

class _FakeListRepository implements UserRelationListRepository {
  _FakeListRepository({this.failFirst = false, this.empty = false});

  final bool failFirst;
  final bool empty;
  int calls = 0;
  int followerCalls = 0;
  String? lastFollowingUserId;

  @override
  Future<List<UserRelationListItem>> fetchFollowing({String? userId}) async {
    calls += 1;
    lastFollowingUserId = userId;
    return _result();
  }

  @override
  Future<List<UserRelationListItem>> fetchFollowers({String? userId}) async {
    calls += 1;
    followerCalls += 1;
    return _result();
  }

  @override
  Future<List<UserRelationListItem>> fetchBlocks() async {
    calls += 1;
    return _result();
  }

  List<UserRelationListItem> _result() {
    if (failFirst && calls == 1) {
      throw const ApiFailure(
        userMessage: '暂时无法连接温油站，请检查网络。',
        requestId: 'list-request-id',
      );
    }
    if (empty) return const [];
    return [
      UserRelationListItem(
        userId: 'user-1',
        username: '温柔旅人',
        level: 4,
        relatedAt: DateTime.utc(2026, 8, 10),
      ),
    ];
  }
}

class _FakeRelationRepository implements UserRelationRepository {
  _FakeRelationRepository({this.failUnblock = false});

  bool failUnblock;

  @override
  Future<void> unblock(String userId) async {
    if (failUnblock) {
      throw const ApiFailure(
        userMessage: '取消拉黑没有完成，请稍后重试。',
        requestId: 'unblock-request-id',
      );
    }
  }

  @override
  Future<void> block(String userId) async {}

  @override
  Future<void> follow(String userId) async {}

  @override
  Future<void> unfollow(String userId) async {}
}
