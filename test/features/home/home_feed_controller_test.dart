import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/home/application/home_feed_controller.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';

void main() {
  test('首屏加载分类与主题并按 ID 去重追加下一页', () async {
    final repository = _FakeHomeRepository(
      onThreads: (query, cursor) async {
        if (cursor == null) {
          return CursorPage(
            items: [_firstThread],
            cursor: 'next-cursor',
            hasMore: true,
          );
        }
        return CursorPage(items: [_firstThread, _secondThread], hasMore: false);
      },
    );
    final controller = HomeFeedController(repository, autoStart: false);

    await controller.loadInitial();
    expect(controller.state.phase, HomeFeedPhase.ready);
    expect(controller.state.categories.single.slug, 'RPG');
    expect(controller.state.items.single.id, 'thread-1');
    expect(controller.state.hasMore, isTrue);

    await controller.loadMore();
    expect(controller.state.items.map((item) => item.id), [
      'thread-1',
      'thread-2',
    ]);
    expect(controller.state.hasMore, isFalse);
  });

  test('改变分类、状态和排序会清空 cursor 并重新加载第一页', () async {
    final repository = _FakeHomeRepository();
    final controller = HomeFeedController(repository, autoStart: false);
    await controller.loadInitial();

    await controller.selectCategory('RPG');
    await controller.selectStatus(HomeThreadStatusFilter.recruiting);
    await controller.selectSort(HomeFeedSort.active);

    expect(controller.state.query.categorySlug, 'RPG');
    expect(controller.state.query.status, HomeThreadStatusFilter.recruiting);
    expect(controller.state.query.sort, HomeFeedSort.active);
    expect(repository.cursors.where((cursor) => cursor != null), isEmpty);
    expect(repository.queries.last.categorySlug, 'RPG');
    expect(repository.queries.last.status.wireValue, 'RECRUITING');
    expect(repository.queries.last.sort.wireValue, 'active');
  });

  test('分页 cursor 失效时自动丢弃旧列表并从第一页恢复', () async {
    var firstPageCalls = 0;
    final repository = _FakeHomeRepository(
      onThreads: (query, cursor) async {
        if (cursor != null) {
          throw const ApiFailure(
            userMessage: '列表位置已失效，正在重新加载。',
            businessCode: 40007,
          );
        }
        firstPageCalls += 1;
        return CursorPage(
          items: [firstPageCalls == 1 ? _firstThread : _secondThread],
          cursor: 'expired-cursor',
          hasMore: true,
        );
      },
    );
    final controller = HomeFeedController(repository, autoStart: false);
    await controller.loadInitial();

    await controller.loadMore();

    expect(firstPageCalls, 2);
    expect(controller.state.items.single.id, 'thread-2');
    expect(controller.state.transientFailure, isNull);
    expect(controller.state.isLoadingMore, isFalse);
  });

  test('已有内容刷新失败时保留列表并提供局部错误', () async {
    var shouldFail = false;
    final repository = _FakeHomeRepository(
      onThreads: (query, cursor) async {
        if (shouldFail) {
          throw const ApiFailure(
            userMessage: '暂时无法连接温油站，请检查网络。',
            requestId: 'home-request-id',
          );
        }
        return CursorPage(items: [_firstThread], hasMore: false);
      },
    );
    final controller = HomeFeedController(repository, autoStart: false);
    await controller.loadInitial();
    shouldFail = true;

    await controller.refresh();

    expect(controller.state.items.single.id, 'thread-1');
    expect(controller.state.phase, HomeFeedPhase.ready);
    expect(controller.state.transientFailure?.requestId, 'home-request-id');
  });

  test('会话结束后用发现列表权威结果替换长驻缓存', () async {
    var serverItems = [_firstThread];
    final repository = _FakeHomeRepository(
      onThreads: (_, _) async => CursorPage(items: serverItems, hasMore: false),
    );
    final tokenStore = _MemoryTokenStore();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(tokenStore),
        sessionRemoteProvider.overrideWithValue(_UnusedSessionRemote()),
        homeRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final session = container.read(sessionControllerProvider.notifier);
    await session.authenticate(_tokens);
    final controller = container.read(homeFeedControllerProvider.notifier);
    await controller.loadInitial();
    expect(controller.state.items.single.id, 'thread-1');

    serverItems = [_secondThread];
    await session.logoutLocally();
    await pumpEventQueue();

    expect(controller.state.items.single.id, 'thread-2');
    expect(controller.state.phase, HomeFeedPhase.ready);
  });
}

class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository({this.onThreads});

  final Future<CursorPage<HomeThreadCardModel>> Function(
    HomeFeedQuery query,
    String? cursor,
  )?
  onThreads;
  final queries = <HomeFeedQuery>[];
  final cursors = <String?>[];

  @override
  Future<List<HomeCategory>> fetchCategories() async => const [
    HomeCategory(id: 'category-rpg', slug: 'RPG', name: '角色扮演', sortOrder: 1),
  ];

  @override
  Future<CursorPage<HomeThreadCardModel>> fetchThreads({
    required HomeFeedQuery query,
    String? cursor,
    int limit = 20,
  }) {
    queries.add(query);
    cursors.add(cursor);
    return onThreads?.call(query, cursor) ??
        Future.value(CursorPage(items: [_firstThread], hasMore: false));
  }
}

final _firstThread = HomeThreadCardModel(
  id: 'thread-1',
  title: '第一个主题',
  categorySlug: 'RPG',
  status: HomeThreadStatus.recruiting,
  isPinned: false,
  ownerId: 'user-1',
  ownerName: '温柔一号',
  ownerLevel: 1,
  tags: [],
  coverImageUrls: [],
  memberCount: 3,
  playerCount: 1,
  postCount: 8,
  tipTotal: '0',
  lastActivityAt: _activityAt,
);

final _secondThread = HomeThreadCardModel(
  id: 'thread-2',
  title: '第二个主题',
  status: HomeThreadStatus.closed,
  isPinned: false,
  ownerId: 'user-2',
  ownerName: '温柔二号',
  ownerLevel: 2,
  tags: [],
  coverImageUrls: [],
  memberCount: 2,
  playerCount: 1,
  postCount: 4,
  tipTotal: '2',
  lastActivityAt: _activityAt,
);

final _activityAt = DateTime.utc(2026, 8, 9);

class _MemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class _UnusedSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) async => _tokens;
}

const _tokens = SessionTokens(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
);
