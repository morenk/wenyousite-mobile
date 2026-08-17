import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_member_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_member_management_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_membership_controls.dart';

void main() {
  testWidgets('未标记为玩家时不显示退出入口', (tester) async {
    await _pumpControls(
      tester,
      _ExitRepository(),
      canExit: false,
      onExited: () async {},
    );
    expect(find.byKey(const Key('thread-player-exit')), findsNothing);
  });

  testWidgets('退出玩家身份要求二次确认并回调刷新详情', (tester) async {
    final repository = _ExitRepository();
    var exitedCalls = 0;
    await _pumpControls(
      tester,
      repository,
      onExited: () async => exitedCalls += 1,
    );

    await tester.tap(find.byKey(const Key('thread-player-exit')));
    await tester.pumpAndSettle();
    expect(find.text('退出玩家身份？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(repository.calls, 0);

    await tester.tap(find.byKey(const Key('thread-player-exit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-player-exit-confirm')));
    await tester.pumpAndSettle();
    expect(repository.calls, 1);
    expect(exitedCalls, 1);
  });

  testWidgets('退出失败显示请求 ID 且可幂等重试', (tester) async {
    final repository = _ExitRepository(
      failureOnce: const ApiFailure(
        userMessage: '退出失败',
        requestId: 'exit-request-id',
      ),
    );
    var exitedCalls = 0;
    await _pumpControls(
      tester,
      repository,
      onExited: () async => exitedCalls += 1,
    );

    await tester.tap(find.byKey(const Key('thread-player-exit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-player-exit-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('问题编号：exit-request-id'), findsOneWidget);

    await tester.tap(find.byKey(const Key('thread-player-exit-retry')));
    await tester.pumpAndSettle();
    expect(repository.calls, 2);
    expect(exitedCalls, 1);
  });
}

Future<void> _pumpControls(
  WidgetTester tester,
  ThreadMemberManagementRepository repository, {
  bool canExit = true,
  required Future<void> Function() onExited,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        threadMemberManagementRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ThreadMembershipControls(
            threadId: 'thread-1',
            canExitPlayer: canExit,
            onExited: onExited,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _ExitRepository implements ThreadMemberManagementRepository {
  _ExitRepository({this.failureOnce});

  ApiFailure? failureOnce;
  int calls = 0;

  @override
  Future<void> exitPlayer(String threadId) async {
    calls += 1;
    final failure = failureOnce;
    failureOnce = null;
    if (failure != null) throw failure;
  }

  @override
  Future<ThreadMemberManagementBootstrap> load(String threadId) {
    throw UnimplementedError();
  }

  @override
  Future<ThreadMemberManagementMember> updateMember({
    required String threadId,
    required String userId,
    ThreadMemberManagementRole? role,
    bool? playerMarked,
  }) {
    throw UnimplementedError();
  }
}
