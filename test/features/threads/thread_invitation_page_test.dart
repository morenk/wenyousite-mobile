import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_invitation_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_invitation_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_invitation_page.dart';

void main() {
  testWidgets('预览私密主题并接受邀请后进入稳定主题路径', (tester) async {
    final repository = _PageRepository();
    await _pumpPage(tester, repository);

    expect(find.text('星海密谈'), findsOneWidget);
    expect(find.text('楼主 楼主'), findsOneWidget);
    expect(find.text('8 位参与人'), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-invite-join')));
    await tester.pumpAndSettle();

    expect(repository.joinCalls, 1);
    expect(find.text('主题详情 thread-1'), findsOneWidget);
  });

  testWidgets('已加入用户不重复写入并可直接进入主题', (tester) async {
    final repository = _PageRepository(
      previewValue: _preview(alreadyJoined: true),
    );
    await _pumpPage(tester, repository);

    expect(find.textContaining('已经是这个主题的成员'), findsOneWidget);
    expect(find.byKey(const Key('thread-invite-join')), findsNothing);
    await tester.tap(find.byKey(const Key('thread-invite-open-thread')));
    await tester.pumpAndSettle();

    expect(repository.joinCalls, 0);
    expect(find.text('主题详情 thread-1'), findsOneWidget);
  });

  testWidgets('加入失败时保留预览并可显式重试', (tester) async {
    final repository = _PageRepository(
      joinFailureOnce: const ApiFailure(
        userMessage: '加入暂时没有完成。',
        requestId: 'join-request-id',
      ),
    );
    await _pumpPage(tester, repository);

    await tester.tap(find.byKey(const Key('thread-invite-join')));
    await tester.pumpAndSettle();
    expect(find.text('星海密谈'), findsOneWidget);
    expect(find.text('问题编号：join-request-id'), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-invite-dismiss-failure')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('thread-invite-join-failure')), findsNothing);
    await tester.tap(find.byKey(const Key('thread-invite-join')));
    await tester.pumpAndSettle();
    expect(repository.joinCalls, 2);
    expect(find.text('主题详情 thread-1'), findsOneWidget);
  });

  testWidgets('失效邀请显示确定结果且不提供无意义重试', (tester) async {
    await _pumpPage(
      tester,
      _PageRepository(
        previewFailure: const ApiFailure(
          userMessage: '邀请链接无效或已失效',
          businessCode: 40408,
          httpStatus: 404,
          requestId: 'invalid-request-id',
        ),
      ),
    );

    expect(find.text('邀请链接无效或已失效'), findsOneWidget);
    expect(find.text('问题编号：invalid-request-id'), findsOneWidget);
    expect(find.byKey(const Key('thread-invite-load-retry')), findsNothing);
    expect(find.byKey(const Key('thread-invite-back-home')), findsOneWidget);
  });

  testWidgets('临时加载失败显示请求 ID 且可重试恢复', (tester) async {
    final repository = _PageRepository(
      previewFailureOnce: const ApiFailure(
        userMessage: '网络暂时不可用',
        requestId: 'preview-request-id',
      ),
    );
    await _pumpPage(tester, repository);

    expect(find.text('问题编号：preview-request-id'), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-invite-load-retry')));
    await tester.pumpAndSettle();
    expect(find.text('星海密谈'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 私密邀请预览无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 760);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await _pumpPage(tester, _PageRepository());

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('thread-invite-join')), findsOneWidget);
    });
  }
}

Future<void> _pumpPage(
  WidgetTester tester,
  ThreadInvitationRepository repository,
) async {
  final container = ProviderContainer(
    overrides: [
      threadInvitationRepositoryProvider.overrideWithValue(repository),
    ],
  );
  final router = GoRouter(
    initialLocation: '/join/Abcd_1234-efGh56',
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('首页占位')),
      ),
      GoRoute(
        path: '/join/:token',
        builder: (_, state) =>
            ThreadInvitationPage(token: state.pathParameters['token']!),
      ),
      GoRoute(
        path: '/threads/:threadId',
        builder: (_, state) =>
            Scaffold(body: Text('主题详情 ${state.pathParameters['threadId']}')),
      ),
      GoRoute(
        path: '/users/:userId',
        builder: (_, state) =>
            Scaffold(body: Text('用户 ${state.pathParameters['userId']}')),
      ),
    ],
  );
  addTearDown(router.dispose);
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

class _PageRepository implements ThreadInvitationRepository {
  _PageRepository({
    ThreadInvitationPreview? previewValue,
    this.previewFailure,
    this.previewFailureOnce,
    this.joinFailureOnce,
  }) : previewValue = previewValue ?? _preview();

  final ThreadInvitationPreview previewValue;
  final ApiFailure? previewFailure;
  ApiFailure? previewFailureOnce;
  ApiFailure? joinFailureOnce;
  int joinCalls = 0;

  @override
  Future<ThreadInvitationPreview> preview(String token) async {
    if (previewFailure != null) throw previewFailure!;
    final failure = previewFailureOnce;
    previewFailureOnce = null;
    if (failure != null) throw failure;
    return previewValue;
  }

  @override
  Future<ThreadInvitationJoinResult> join(String token) async {
    joinCalls += 1;
    final failure = joinFailureOnce;
    joinFailureOnce = null;
    if (failure != null) throw failure;
    return const ThreadInvitationJoinResult(
      memberId: 'member-1',
      threadId: 'thread-1',
      threadTitle: '星海密谈',
      userId: 'user-1',
    );
  }

  @override
  Future<ThreadInvitationLink> generateLink(String threadId) {
    throw UnimplementedError();
  }
}

ThreadInvitationPreview _preview({bool alreadyJoined = false}) {
  return ThreadInvitationPreview(
    threadId: 'thread-1',
    title: '星海密谈',
    categorySlug: 'RPG',
    status: ThreadInvitationStatus.recruiting,
    ownerId: 'owner-1',
    ownerName: '楼主',
    memberCount: 8,
    createdAt: DateTime.utc(2026, 8, 9),
    alreadyJoined: alreadyJoined,
  );
}
