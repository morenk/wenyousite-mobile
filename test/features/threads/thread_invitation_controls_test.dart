import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_invitation_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_invitation_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_invitation_controls.dart';

void main() {
  testWidgets('生成邀请必须确认旧链接失效并保留可重复复制链接', (tester) async {
    final repository = _PanelRepository();
    await _pumpPanel(tester, repository);

    await tester.tap(find.byKey(const Key('thread-invite-link-generate')));
    await tester.pumpAndSettle();
    expect(find.text('生成新的邀请链接？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(repository.generateCalls, 0);

    await tester.tap(find.byKey(const Key('thread-invite-link-generate')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('thread-invite-link-generate-confirm')),
    );
    await tester.pumpAndSettle();

    expect(repository.generateCalls, 1);
    expect(
      find.text('https://wenyou.site/join/Abcd_1234-efGh56'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('thread-invite-link-copy')), findsOneWidget);
  });

  testWidgets('生成失败显示请求 ID 并可关闭提示', (tester) async {
    final repository = _PanelRepository(
      failure: const ApiFailure(
        userMessage: '邀请暂时没有生成。',
        requestId: 'invite-request-id',
      ),
    );
    await _pumpPanel(tester, repository);

    await tester.tap(find.byKey(const Key('thread-invite-link-generate')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('thread-invite-link-generate-confirm')),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('问题编号：invite-request-id'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('thread-invite-link-dismiss-failure')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('thread-invite-link-failure')), findsNothing);
  });
}

Future<void> _pumpPanel(
  WidgetTester tester,
  ThreadInvitationRepository repository,
) async {
  final container = ProviderContainer(
    overrides: [
      threadInvitationRepositoryProvider.overrideWithValue(repository),
    ],
  );
  final router = GoRouter(
    initialLocation: '/panel',
    routes: [
      GoRoute(
        path: '/panel',
        builder: (_, _) => const Scaffold(
          body: SingleChildScrollView(
            child: ThreadInviteLinkPanel(threadId: 'thread-1'),
          ),
        ),
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

class _PanelRepository implements ThreadInvitationRepository {
  _PanelRepository({this.failure});

  final ApiFailure? failure;
  int generateCalls = 0;

  @override
  Future<ThreadInvitationLink> generateLink(String threadId) async {
    generateCalls += 1;
    if (failure != null) throw failure!;
    return ThreadInvitationLink(
      id: 'invite-1',
      threadId: threadId,
      token: 'Abcd_1234-efGh56',
      url: Uri.parse('https://wenyou.site/join/Abcd_1234-efGh56'),
      createdAt: DateTime.utc(2026, 8, 10),
    );
  }

  @override
  Future<ThreadInvitationJoinResult> join(String token) {
    throw UnimplementedError();
  }

  @override
  Future<ThreadInvitationPreview> preview(String token) {
    throw UnimplementedError();
  }
}
