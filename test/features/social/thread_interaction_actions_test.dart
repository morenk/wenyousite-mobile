import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/social/application/bookmark_list_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/data/thread_interaction_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';
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
    final bookmarkRepository = _FakeBookmarkListRepository();
    final container = await _authenticatedContainer(
      repository,
      bookmarkRepository: bookmarkRepository,
    );
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
    expect(find.text('收藏到收藏夹'), findsOneWidget);
    await tester.tap(find.byKey(const Key('bookmark-folder-picker-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('已收藏'), findsOneWidget);
    expect(find.text('已收藏到“默认收藏夹”。'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('已收藏到“默认收藏夹”。'), findsNothing);
    expect(bookmarkRepository.moves, isEmpty);
    expect(repository.createdFolderIds, ['folder-default']);

    await tester.tap(find.byKey(const Key('thread-interaction-bookmark')));
    await tester.pumpAndSettle();
    expect(find.text('收藏'), findsOneWidget);
    expect(repository.removedBookmarkIds, ['bookmark-1']);
  });

  testWidgets('首次收藏可直接选择指定收藏夹且只写一次', (tester) async {
    final repository = _FakeRepository();
    final bookmarkRepository = _FakeBookmarkListRepository();
    final container = await _authenticatedContainer(
      repository,
      bookmarkRepository: bookmarkRepository,
    );
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

    await tester.tap(find.byKey(const Key('thread-interaction-bookmark')));
    await tester.pumpAndSettle();

    expect(find.text('选择收藏夹后确认，本次内容只会保存在一个收藏夹中。'), findsOneWidget);
    expect(find.text('默认收藏夹'), findsOneWidget);
    expect(find.text('稍后阅读'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('bookmark-folder-picker-option-folder-later')),
    );
    await tester.tap(find.byKey(const Key('bookmark-folder-picker-confirm')));
    await tester.pumpAndSettle();

    expect(repository.createdFolderIds, ['folder-later']);
    expect(bookmarkRepository.moves, isEmpty);
    expect(find.text('已收藏到“稍后阅读”。'), findsOneWidget);
  });

  testWidgets('首次收藏加载和写入失败时可在原面板重试', (tester) async {
    final repository = _FakeRepository(bookmarkFailures: 1);
    final bookmarkRepository = _FakeBookmarkListRepository(folderFailures: 1);
    final container = await _authenticatedContainer(
      repository,
      bookmarkRepository: bookmarkRepository,
    );
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

    await tester.tap(find.byKey(const Key('thread-interaction-bookmark')));
    await tester.pumpAndSettle();

    expect(find.text('收藏夹加载失败，请稍后重试。'), findsOneWidget);
    expect(find.textContaining('问题编号：folder-request-id'), findsOneWidget);
    await tester.tap(find.byKey(const Key('bookmark-folder-picker-retry')));
    await tester.pumpAndSettle();

    final customFolder = find.byKey(
      const ValueKey('bookmark-folder-picker-option-folder-later'),
    );
    await tester.tap(customFolder);
    await tester.tap(find.byKey(const Key('bookmark-folder-picker-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('收藏失败，请稍后重试。'), findsOneWidget);
    expect(customFolder, findsOneWidget);

    await tester.tap(find.byKey(const Key('bookmark-folder-picker-confirm')));
    await tester.pumpAndSettle();
    expect(repository.createdFolderIds, ['folder-later', 'folder-later']);
    expect(find.text('已收藏到“稍后阅读”。'), findsOneWidget);
  });

  testWidgets('首次收藏可在选择面板内新建收藏夹后一次写入', (tester) async {
    final repository = _FakeRepository();
    final bookmarkRepository = _FakeBookmarkListRepository();
    final container = await _authenticatedContainer(
      repository,
      bookmarkRepository: bookmarkRepository,
    );
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

    await tester.tap(find.byKey(const Key('thread-interaction-bookmark')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bookmark-folder-picker-create')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('bookmark-folder-picker-name')),
      '跑团资料',
    );
    await tester.tap(
      find.byKey(const Key('bookmark-folder-picker-create-confirm')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bookmark-folder-picker-confirm')));
    await tester.pumpAndSettle();

    expect(bookmarkRepository.createdNames, ['跑团资料']);
    expect(repository.createdFolderIds, ['folder-created']);
    expect(find.text('已收藏到“跑团资料”。'), findsOneWidget);
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
    expect(find.textContaining('问题编号：interaction-request-id'), findsOneWidget);
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
  ThreadInteractionRepository repository, {
  BookmarkListRepository? bookmarkRepository,
}) async {
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
      sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
      threadInteractionRepositoryProvider.overrideWithValue(repository),
      bookmarkListRepositoryProvider.overrideWithValue(
        bookmarkRepository ?? _FakeBookmarkListRepository(),
      ),
      bookmarkFolderCatalogProvider.overrideWith(
        (ref, kind) => bookmarkRepository ?? _FakeBookmarkListRepository(),
      ),
    ],
  );
  await container
      .read(sessionControllerProvider.notifier)
      .authenticate(_tokens);
  return container;
}

class _FakeBookmarkListRepository implements BookmarkListRepository {
  _FakeBookmarkListRepository({int folderFailures = 0, int moveFailures = 0})
    : _remainingFolderFailures = folderFailures,
      _remainingMoveFailures = moveFailures;

  int _remainingFolderFailures;
  int _remainingMoveFailures;
  final List<(String, String)> moves = [];
  final List<String> createdNames = [];

  @override
  Future<List<BookmarkFolderItem>> fetchFolders() async {
    if (_remainingFolderFailures > 0) {
      _remainingFolderFailures -= 1;
      throw const ApiFailure(
        userMessage: '收藏夹加载失败，请稍后重试。',
        requestId: 'folder-request-id',
      );
    }
    return [
      BookmarkFolderItem(
        id: 'folder-default',
        name: '默认收藏夹',
        isDefault: true,
        bookmarkCount: 1,
        createdAt: DateTime(2026),
      ),
      BookmarkFolderItem(
        id: 'folder-later',
        name: '稍后阅读',
        isDefault: false,
        bookmarkCount: 2,
        createdAt: DateTime(2026),
      ),
    ];
  }

  @override
  Future<void> move(String bookmarkId, String folderId) async {
    moves.add((bookmarkId, folderId));
    if (_remainingMoveFailures > 0) {
      _remainingMoveFailures -= 1;
      throw const ApiFailure(userMessage: '移动收藏失败，请稍后重试。');
    }
  }

  @override
  Future<CursorPage<BookmarkListItem>> fetchPage({
    String? cursor,
    String? folderId,
    int limit = 20,
  }) async => const CursorPage(items: [], hasMore: false);

  @override
  Future<BookmarkFolderItem> createFolder(String name) async {
    createdNames.add(name);
    return BookmarkFolderItem(
      id: 'folder-created',
      name: name,
      isDefault: false,
      bookmarkCount: 0,
      createdAt: DateTime(2026),
    );
  }

  @override
  Future<void> remove(String bookmarkId) => throw UnimplementedError();
}

class _FakeRepository implements ThreadInteractionRepository {
  _FakeRepository({this.failLike = false, this.bookmarkFailures = 0});

  final bool failLike;
  int bookmarkFailures;
  int likeCalls = 0;
  final List<String> createdFolderIds = [];
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
  Future<String> createBookmark(String threadId, String folderId) async {
    createdFolderIds.add(folderId);
    if (bookmarkFailures > 0) {
      bookmarkFailures -= 1;
      throw const ApiFailure(userMessage: '收藏失败，请稍后重试。');
    }
    return 'bookmark-1';
  }

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
