import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/social/data/thread_interaction_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_interaction_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/thread_interaction_actions.dart';

void main() {
  testWidgets('游客看到点赞计数，点击只进入登录且不发写请求', (tester) async {
    final repository = _FakeRepository();
    var authRequests = 0;
    await tester.pumpWidget(
      _app(
        repository: repository,
        onRequireAuthentication: () => authRequests += 1,
      ),
    );

    expect(find.text('喜欢 12'), findsOneWidget);
    expect(find.byKey(const Key('thread-interaction-bookmark')), findsNothing);
    await tester.tap(find.byKey(const Key('thread-interaction-like')));
    await tester.pumpAndSettle();

    expect(authRequests, 1);
    expect(repository.likeCalls, 0);
  });

  testWidgets('登录用户点赞与收藏切换采用服务端结果并展示反馈', (tester) async {
    final repository = _FakeRepository();
    final container = await _authenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ThreadInteractionActions(
              target: _target,
              onRequireAuthentication: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('thread-interaction-like')));
    await tester.pumpAndSettle();
    expect(find.text('已喜欢 13'), findsOneWidget);
    expect(find.text('已喜欢这个主题。'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('thread-interaction-bookmark')));
    await tester.pumpAndSettle();
    expect(find.text('已收藏'), findsOneWidget);
    expect(find.text('已收藏这个主题。'), findsOneWidget);

    await tester.tap(find.byKey(const Key('thread-interaction-bookmark')));
    await tester.pumpAndSettle();
    expect(find.text('收藏'), findsOneWidget);
    expect(repository.removedBookmarkIds, ['bookmark-1']);
  });

  testWidgets('互动失败保留按钮状态并显示请求 ID', (tester) async {
    final repository = _FakeRepository(failLike: true);
    final container = await _authenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ThreadInteractionActions(
              target: _target,
              onRequireAuthentication: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('thread-interaction-like')));
    await tester.pumpAndSettle();

    expect(find.text('喜欢 12'), findsOneWidget);
    expect(find.text('请求 ID：interaction-request-id'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 主题互动操作无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 300);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final container = await _authenticatedContainer(_FakeRepository());
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: ThreadInteractionActions(
                target: _target,
                onRequireAuthentication: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  }
}

Widget _app({
  required ThreadInteractionRepository repository,
  required VoidCallback onRequireAuthentication,
}) {
  return ProviderScope(
    overrides: [
      threadInteractionRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: ThreadInteractionActions(
          target: _target,
          onRequireAuthentication: onRequireAuthentication,
        ),
      ),
    ),
  );
}

Future<ProviderContainer> _authenticatedContainer(
  ThreadInteractionRepository repository,
) async {
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
      sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
      threadInteractionRepositoryProvider.overrideWithValue(repository),
    ],
  );
  await container
      .read(sessionControllerProvider.notifier)
      .authenticate(_tokens);
  return container;
}

class _FakeRepository implements ThreadInteractionRepository {
  _FakeRepository({this.failLike = false});

  final bool failLike;
  int likeCalls = 0;
  final List<String> removedBookmarkIds = [];

  @override
  Future<int> like(String threadId) async {
    likeCalls += 1;
    if (failLike) {
      throw const ApiFailure(
        userMessage: '点赞操作没有完成，请稍后重试。',
        requestId: 'interaction-request-id',
      );
    }
    return 13;
  }

  @override
  Future<int> unlike(String threadId) async => 12;

  @override
  Future<String> createBookmark(String threadId) async => 'bookmark-1';

  @override
  Future<void> removeBookmark(String bookmarkId) async {
    removedBookmarkIds.add(bookmarkId);
  }
}

const _target = ThreadInteractionTarget(
  threadId: 'thread-1',
  isLiked: false,
  likeCount: 12,
  isBookmarked: false,
);

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
