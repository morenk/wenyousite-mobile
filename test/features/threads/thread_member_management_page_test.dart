import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_member_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_member_management_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_member_management_page.dart';

void main() {
  testWidgets('楼主管理玩家标记并二次确认任命协作者', (tester) async {
    final repository = _FakeRepository(bootstrap: _bootstrap());
    await _pumpPage(tester, repository);

    expect(find.text('2 位参与人。回复后会自动进入候选池；玩家标记与协作者身份由管理者维护。'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('thread-member-player-player-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('thread-member-collaborator-player-1')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('thread-member-player-player-1')),
    );
    await tester.pumpAndSettle();
    expect(repository.playerValues, [true]);
    expect(find.text('玩家'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('thread-member-collaborator-player-1')),
    );
    await tester.pumpAndSettle();
    expect(find.text('设为协作者？'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('thread-member-role-confirm-player-1')),
    );
    await tester.pumpAndSettle();
    expect(repository.roles, [ThreadMemberManagementRole.collaborator]);
    expect(find.text('协作者'), findsOneWidget);
  });

  testWidgets('协作者只能维护玩家标记', (tester) async {
    await _pumpPage(
      tester,
      _FakeRepository(bootstrap: _bootstrap(actorIsOwner: false)),
    );

    expect(
      find.byKey(const ValueKey('thread-member-player-player-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('thread-member-collaborator-player-1')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('thread-member-player-owner-1')),
      findsNothing,
    );
  });

  testWidgets('成员资料使用稳定用户路径', (tester) async {
    await _pumpPage(tester, _FakeRepository(bootstrap: _bootstrap()));

    await tester.tap(
      find.byKey(const ValueKey('thread-member-profile-player-1')),
    );
    await tester.pumpAndSettle();
    expect(find.text('用户资料 player-1'), findsOneWidget);
  });

  testWidgets('40107 保留成员列表并进入邮箱验证', (tester) async {
    final repository = _FakeRepository(
      bootstrap: _bootstrap(),
      updateFailure: const ApiFailure(
        userMessage: '请先完成邮箱验证。',
        businessCode: 40107,
        requestId: 'member-verify-id',
      ),
    );
    await _pumpPage(tester, repository);

    await tester.tap(
      find.byKey(const ValueKey('thread-member-player-player-1')),
    );
    await tester.pumpAndSettle();
    expect(find.text('请求 ID：member-verify-id'), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-members-verify-email')));
    await tester.pumpAndSettle();
    expect(find.text('邮箱验证占位'), findsOneWidget);
    await tester.tap(find.text('完成验证'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('thread-members-action-failure')),
      findsNothing,
    );
    expect(find.text('玩家甲'), findsOneWidget);
  });

  testWidgets('加载失败保留请求 ID 并可重试', (tester) async {
    final repository = _FakeRepository(
      bootstrap: _bootstrap(),
      loadFailureOnce: const ApiFailure(
        userMessage: '成员加载失败',
        requestId: 'members-load-id',
      ),
    );
    await _pumpPage(tester, repository);
    expect(find.text('请求 ID：members-load-id'), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-members-load-retry')));
    await tester.pumpAndSettle();
    expect(find.text('玩家甲'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 成员管理页无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 820);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await _pumpPage(tester, _FakeRepository(bootstrap: _bootstrap()));

      expect(tester.takeException(), isNull);
      expect(find.text('玩家甲'), findsOneWidget);
    });
  }
}

Future<void> _pumpPage(
  WidgetTester tester,
  ThreadMemberManagementRepository repository,
) async {
  final router = GoRouter(
    initialLocation: '/threads/thread-1/manage/members',
    routes: [
      GoRoute(
        path: '/threads/:threadId/manage/members',
        builder: (_, state) => ThreadMemberManagementPage(
          threadId: state.pathParameters['threadId']!,
        ),
      ),
      GoRoute(
        path: '/users/:userId',
        builder: (_, state) =>
            Scaffold(body: Text('用户资料 ${state.pathParameters['userId']}')),
      ),
      GoRoute(
        path: '/me/security/verify-email',
        builder: (context, state) => Scaffold(
          body: Column(
            children: [
              const Text('邮箱验证占位'),
              TextButton(
                onPressed: () => context.pop(true),
                child: const Text('完成验证'),
              ),
            ],
          ),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        threadMemberManagementRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeRepository implements ThreadMemberManagementRepository {
  _FakeRepository({
    required this.bootstrap,
    this.updateFailure,
    this.loadFailureOnce,
  });

  ThreadMemberManagementBootstrap bootstrap;
  final ApiFailure? updateFailure;
  ApiFailure? loadFailureOnce;
  final List<bool> playerValues = [];
  final List<ThreadMemberManagementRole> roles = [];

  @override
  Future<void> exitPlayer(String threadId) async {}

  @override
  Future<ThreadMemberManagementBootstrap> load(String threadId) async {
    final failure = loadFailureOnce;
    loadFailureOnce = null;
    if (failure != null) throw failure;
    return bootstrap;
  }

  @override
  Future<ThreadMemberManagementMember> updateMember({
    required String threadId,
    required String userId,
    ThreadMemberManagementRole? role,
    bool? playerMarked,
  }) async {
    if (updateFailure != null) throw updateFailure!;
    if (role != null) roles.add(role);
    if (playerMarked != null) playerValues.add(playerMarked);
    final current = bootstrap.members.firstWhere(
      (member) => member.userId == userId,
    );
    final updated = ThreadMemberManagementMember(
      id: current.id,
      userId: current.userId,
      username: current.username,
      level: current.level,
      role: role ?? current.role,
      playerMarked: playerMarked ?? current.playerMarked,
      joinedAt: current.joinedAt,
    );
    bootstrap = bootstrap.replaceMember(updated);
    return updated;
  }
}

ThreadMemberManagementBootstrap _bootstrap({bool actorIsOwner = true}) {
  final joinedAt = DateTime.utc(2026, 8, 10);
  return ThreadMemberManagementBootstrap(
    threadId: 'thread-1',
    threadTitle: '星海旅团',
    actorIsOwner: actorIsOwner,
    members: [
      ThreadMemberManagementMember(
        id: 'member-owner',
        userId: 'owner-1',
        username: '楼主',
        level: 4,
        role: ThreadMemberManagementRole.owner,
        playerMarked: false,
        joinedAt: joinedAt,
      ),
      ThreadMemberManagementMember(
        id: 'member-player',
        userId: 'player-1',
        username: '玩家甲',
        level: 2,
        role: ThreadMemberManagementRole.participant,
        playerMarked: false,
        joinedAt: joinedAt,
      ),
    ],
  );
}
