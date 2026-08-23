import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

void main() {
  test('加载详情后优先选择默认子贴并读取首屏楼层', () async {
    final repository = _FakeThreadDetailRepository();
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();

    expect(controller.state.phase, ThreadDetailPhase.ready);
    expect(controller.state.selectedSubthreadId, 'subthread-2');
    expect(controller.state.selectedSubthread?.title, '支线');
    expect(controller.state.floors.single.id, 'floor-subthread-2');
    expect(repository.floorRequests, ['subthread-2:null']);
  });

  test('首屏完成后串行预取剩余全部楼层并逐页合并', () async {
    var activeRequests = 0;
    var maximumActiveRequests = 0;
    final repository = _FakeThreadDetailRepository(
      onFloors: (subthreadId, cursor) async {
        activeRequests += 1;
        maximumActiveRequests = maximumActiveRequests < activeRequests
            ? activeRequests
            : maximumActiveRequests;
        await Future<void>.delayed(Duration.zero);
        activeRequests -= 1;
        return switch (cursor) {
          null => CursorPage(
            items: [_floor('floor-1')],
            cursor: 'page-2',
            hasMore: true,
          ),
          'page-2' => CursorPage(
            items: [_floor('floor-2')],
            cursor: 'page-3',
            hasMore: true,
          ),
          _ => CursorPage(items: [_floor('floor-3')], hasMore: false),
        };
      },
    );
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();
    expect(controller.state.floors.map((item) => item.id), ['floor-1']);

    final prefetch = controller.prefetchRemainingFloors();
    expect(controller.state.isPrefetchingFloors, isTrue);
    await prefetch;

    expect(controller.state.floors.map((item) => item.id), [
      'floor-1',
      'floor-2',
      'floor-3',
    ]);
    expect(controller.state.hasMore, isFalse);
    expect(controller.state.isPrefetchingFloors, isFalse);
    expect(maximumActiveRequests, 1);
    expect(repository.floorRequests, [
      'subthread-2:null',
      'subthread-2:page-2',
      'subthread-2:page-3',
    ]);
  });

  test('切换筛选会取消旧楼层预取且不合并迟到页', () async {
    final stalePage = Completer<CursorPage<ThreadFloorModel>>();
    final repository = _FakeThreadDetailRepository(
      onFloors: (subthreadId, cursor) {
        if (cursor == 'old-next') return stalePage.future;
        if (cursor == null) {
          return Future.value(
            CursorPage(
              items: [_floor('first')],
              cursor: 'old-next',
              hasMore: true,
            ),
          );
        }
        return Future.value(
          CursorPage(items: [_floor('filtered')], hasMore: false),
        );
      },
    );
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();
    final prefetch = controller.prefetchRemainingFloors();
    await Future<void>.delayed(Duration.zero);
    final filter = controller.applyFloorFilters(
      order: ThreadFloorOrder.newest,
      authorId: 'user-owner',
    );
    stalePage.complete(CursorPage(items: [_floor('stale')], hasMore: false));
    await Future.wait([prefetch, filter]);

    expect(controller.state.floorOrder, ThreadFloorOrder.newest);
    expect(controller.state.floors.map((item) => item.id), ['first']);
    expect(controller.state.floors.any((item) => item.id == 'stale'), isFalse);
    expect(controller.state.isPrefetchingFloors, isFalse);
  });

  test('切换子贴重置楼层，分页按 ID 去重', () async {
    final repository = _FakeThreadDetailRepository(
      onFloors: (subthreadId, cursor) async {
        if (cursor == null) {
          return CursorPage(
            items: [_floor('floor-1')],
            cursor: 'cursor-1',
            hasMore: true,
          );
        }
        return CursorPage(
          items: [_floor('floor-1'), _floor('floor-2')],
          hasMore: false,
        );
      },
    );
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();
    await controller.selectSubthread('subthread-1');
    expect(controller.state.selectedSubthreadId, 'subthread-1');
    expect(controller.state.floors.map((item) => item.id), ['floor-1']);

    await controller.loadMore();
    expect(controller.state.floors.map((item) => item.id), [
      'floor-1',
      'floor-2',
    ]);
    expect(controller.state.hasMore, isFalse);
  });

  test('切换楼层顺序重置游标并以同一顺序请求分页', () async {
    final repository = _FakeThreadDetailRepository(
      onFloors: (subthreadId, cursor) async => CursorPage(
        items: cursor == null
            ? [_floor('floor-1', number: 1), _floor('floor-3', number: 3)]
            : [_floor('floor-2', number: 2)],
        cursor: cursor == null ? 'cursor-1' : null,
        hasMore: cursor == null,
      ),
    );
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();
    expect(controller.state.floors.map((item) => item.floorNumber), [1, 3]);

    await controller.setFloorOrder(ThreadFloorOrder.newest);
    expect(controller.state.floorOrder, ThreadFloorOrder.newest);
    expect(controller.state.floors.map((item) => item.floorNumber), [3, 1]);
    expect(repository.floorRequests, ['subthread-2:null', 'subthread-2:null']);
    expect(repository.floorOrders, [
      ThreadFloorOrder.oldest,
      ThreadFloorOrder.newest,
    ]);

    await controller.loadMore();
    expect(controller.state.floors.map((item) => item.floorNumber), [3, 2, 1]);
    expect(repository.floorOrders.last, ThreadFloorOrder.newest);
  });

  test('排序与发言者一次应用只重载一次，并在后续分页保持同一筛选', () async {
    final repository = _FakeThreadDetailRepository(
      onFloors: (subthreadId, cursor) async => CursorPage(
        items: cursor == null
            ? [_floor('filtered-first', number: 3)]
            : [_floor('filtered-next', number: 2)],
        cursor: cursor == null ? 'cursor-1' : null,
        hasMore: cursor == null,
      ),
    );
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();
    await controller.applyFloorFilters(
      order: ThreadFloorOrder.newest,
      authorId: ' user-owner ',
    );

    expect(controller.state.floorOrder, ThreadFloorOrder.newest);
    expect(controller.state.floorAuthorId, 'user-owner');
    expect(repository.floorRequests, ['subthread-2:null', 'subthread-2:null']);
    expect(repository.floorOrders.last, ThreadFloorOrder.newest);
    expect(repository.floorAuthors, [null, 'user-owner']);

    await controller.loadMore();

    expect(repository.floorAuthors.last, 'user-owner');
    expect(repository.floorOrders.last, ThreadFloorOrder.newest);
    expect(controller.state.floors.map((floor) => floor.id), [
      'filtered-first',
      'filtered-next',
    ]);
  });

  test('切换子贴清除发言者筛选但保留楼层顺序', () async {
    final repository = _FakeThreadDetailRepository();
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();
    await controller.applyFloorFilters(
      order: ThreadFloorOrder.newest,
      authorId: 'user-owner',
    );
    await controller.selectSubthread('subthread-1');

    expect(controller.state.selectedSubthreadId, 'subthread-1');
    expect(controller.state.floorOrder, ThreadFloorOrder.newest);
    expect(controller.state.floorAuthorId, isNull);
    expect(repository.floorAuthors.last, isNull);
    expect(repository.floorOrders.last, ThreadFloorOrder.newest);
  });

  test('连续切换发言者时丢弃旧筛选的迟到结果', () async {
    final stalePage = Completer<CursorPage<ThreadFloorModel>>();
    var floorCalls = 0;
    final repository = _FakeThreadDetailRepository(
      onFloors: (subthreadId, cursor) {
        floorCalls += 1;
        if (floorCalls == 2) return stalePage.future;
        return Future.value(
          CursorPage(items: [_floor('fresh-$floorCalls')], hasMore: false),
        );
      },
    );
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();
    final staleFilter = controller.applyFloorFilters(
      order: ThreadFloorOrder.oldest,
      authorId: 'user-owner',
    );
    await Future<void>.delayed(Duration.zero);
    await controller.applyFloorFilters(
      order: ThreadFloorOrder.oldest,
      authorId: 'user-player',
    );
    stalePage.complete(
      CursorPage(items: [_floor('stale-floor')], hasMore: false),
    );
    await staleFilter;

    expect(controller.state.floorAuthorId, 'user-player');
    expect(controller.state.floors.single.id, 'fresh-3');
    expect(repository.floorAuthors, [null, 'user-owner', 'user-player']);
  });

  test('分页 cursor 连续失效时只重载一次首页并提供重试', () async {
    var firstPageCalls = 0;
    final repository = _FakeThreadDetailRepository(
      onFloors: (subthreadId, cursor) async {
        if (cursor != null) {
          throw const ApiFailure(
            userMessage: '列表位置已失效，正在重新加载。',
            businessCode: 40007,
          );
        }
        firstPageCalls += 1;
        return CursorPage(
          items: [_floor('fresh-$firstPageCalls')],
          cursor: 'expired',
          hasMore: true,
        );
      },
    );
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();
    await controller.applyFloorFilters(
      order: ThreadFloorOrder.oldest,
      authorId: 'user-owner',
    );
    await controller.loadMore();

    expect(firstPageCalls, 3);
    expect(controller.state.floors.single.id, 'fresh-3');
    expect(repository.floorAuthors, [
      null,
      'user-owner',
      'user-owner',
      'user-owner',
      'user-owner',
    ]);
    expect(controller.state.transientFailure?.isInvalidCursor, isTrue);
    expect(controller.state.retryAction, ThreadDetailRetryAction.loadMore);
    expect(controller.state.isPrefetchingFloors, isFalse);
  });

  test('快速切换子贴时丢弃旧请求的迟到结果', () async {
    final stalePage = Completer<CursorPage<ThreadFloorModel>>();
    var subthread2Calls = 0;
    final repository = _FakeThreadDetailRepository(
      onFloors: (subthreadId, cursor) async {
        if (subthreadId == 'subthread-1') return stalePage.future;
        subthread2Calls += 1;
        return CursorPage(
          items: [_floor('subthread-2-$subthread2Calls')],
          hasMore: false,
        );
      },
    );
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();
    final staleSwitch = controller.selectSubthread('subthread-1');
    await Future<void>.delayed(Duration.zero);
    await controller.selectSubthread('subthread-2');
    stalePage.complete(
      CursorPage(items: [_floor('stale-floor')], hasMore: false),
    );
    await staleSwitch;

    expect(controller.state.selectedSubthreadId, 'subthread-2');
    expect(controller.state.floors.single.id, 'subthread-2-2');
  });

  for (final status in [403, 404]) {
    test('刷新详情返回 $status 时清空已展示内容并进入不可见终态', () async {
      var threadCalls = 0;
      final repository = _FakeThreadDetailRepository(
        onThread: (_) async {
          threadCalls += 1;
          if (threadCalls == 1) return _detail;
          throw ApiFailure(userMessage: '主题不可见。', httpStatus: status);
        },
      );
      final controller = ThreadDetailController(
        repository,
        'thread-1',
        autoStart: false,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      expect(controller.state.detail, isNotNull);
      expect(controller.state.floors, isNotEmpty);

      await controller.refresh();

      _expectRestrictedTerminal(controller.state, status);
    });

    test('首屏楼层返回 $status 时清空详情并进入不可见终态', () async {
      final repository = _FakeThreadDetailRepository(
        onFloors: (_, _) =>
            throw ApiFailure(userMessage: '子贴不可见。', httpStatus: status),
      );
      final controller = ThreadDetailController(
        repository,
        'thread-1',
        autoStart: false,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      _expectRestrictedTerminal(controller.state, status);
    });

    test('加载更多返回 $status 时清空已分页内容并进入不可见终态', () async {
      final repository = _FakeThreadDetailRepository(
        onFloors: (_, cursor) async {
          if (cursor == null) {
            return CursorPage(
              items: [_floor('visible-floor')],
              cursor: 'cursor-1',
              hasMore: true,
            );
          }
          throw ApiFailure(userMessage: '主题不可见。', httpStatus: status);
        },
      );
      final controller = ThreadDetailController(
        repository,
        'thread-1',
        autoStart: false,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      expect(controller.state.floors.single.id, 'visible-floor');
      expect(controller.state.hasMore, isTrue);

      await controller.loadMore();

      _expectRestrictedTerminal(controller.state, status);
    });
  }

  test('刷新详情遇到普通网络错误时保留旧内容并显示局部失败', () async {
    var threadCalls = 0;
    final repository = _FakeThreadDetailRepository(
      onThread: (_) async {
        threadCalls += 1;
        if (threadCalls == 1) return _detail;
        throw const ApiFailure(userMessage: '网络暂时不可用。');
      },
      onFloors: (_, _) async => CursorPage(
        items: [_floor('retained-floor')],
        cursor: 'cursor-1',
        hasMore: true,
      ),
    );
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();
    await controller.refresh();

    expect(controller.state.phase, ThreadDetailPhase.ready);
    expect(controller.state.detail?.id, 'thread-1');
    expect(controller.state.selectedSubthreadId, 'subthread-2');
    expect(controller.state.floors.single.id, 'retained-floor');
    expect(controller.state.cursor, 'cursor-1');
    expect(controller.state.hasMore, isTrue);
    expect(controller.state.failure, isNull);
    expect(controller.state.transientFailure?.userMessage, '网络暂时不可用。');
    expect(controller.state.retryAction, ThreadDetailRetryAction.refresh);
  });

  test('发表后只刷新主题元信息并保留已加载楼层窗口', () async {
    var threadCalls = 0;
    final repository = _FakeThreadDetailRepository(
      onThread: (_) async {
        threadCalls += 1;
        return _detail;
      },
      onFloors: (_, _) async => CursorPage(
        items: [_floor('retained-floor')],
        cursor: 'cursor-1',
        hasMore: true,
      ),
    );
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();
    await controller.refreshMetadata();

    expect(threadCalls, 2);
    expect(repository.floorRequests, ['subthread-2:null']);
    expect(controller.state.floors.single.id, 'retained-floor');
    expect(controller.state.cursor, 'cursor-1');
    expect(controller.state.hasMore, isTrue);
    expect(controller.state.isRefreshing, isFalse);
  });

  test('元数据刷新打断首屏楼层时主动重载，迟到旧结果不能制造假空态', () async {
    final staleFloors = Completer<CursorPage<ThreadFloorModel>>();
    var floorCalls = 0;
    final repository = _FakeThreadDetailRepository(
      onFloors: (_, _) {
        floorCalls += 1;
        if (floorCalls == 1) return staleFloors.future;
        return Future.value(
          CursorPage(items: [_floor('fresh-floor')], hasMore: false),
        );
      },
    );
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    final initialLoad = controller.loadInitial();
    while (repository.floorRequests.isEmpty) {
      await Future<void>.delayed(Duration.zero);
    }
    await controller.refreshMetadata();
    staleFloors.complete(
      CursorPage(items: [_floor('stale-floor')], hasMore: false),
    );
    await initialLoad;

    expect(repository.floorRequests, ['subthread-2:null', 'subthread-2:null']);
    expect(controller.state.floors.single.id, 'fresh-floor');
    expect(controller.state.isLoadingFloors, isFalse);
  });

  test('元数据刷新回退到其他子贴时清空旧窗口并加载新首页', () async {
    var threadCalls = 0;
    final repository = _FakeThreadDetailRepository(
      onThread: (_) async {
        threadCalls += 1;
        return threadCalls == 1 ? _detail : _detailWithoutSelectedSubthread;
      },
      onFloors: (subthreadId, _) async => CursorPage(
        items: [
          _floor(
            subthreadId == 'subthread-2' ? 'old-subthread-floor' : 'new-floor',
          ),
        ],
        cursor: subthreadId == 'subthread-2' ? 'old-cursor' : null,
        hasMore: subthreadId == 'subthread-2',
      ),
    );
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();
    expect(controller.state.selectedSubthreadId, 'subthread-2');
    expect(controller.state.floors.single.id, 'old-subthread-floor');

    await controller.refreshMetadata();

    expect(controller.state.selectedSubthreadId, 'subthread-1');
    expect(controller.state.floors.single.id, 'new-floor');
    expect(controller.state.cursor, isNull);
    expect(controller.state.hasMore, isFalse);
    expect(repository.floorRequests, ['subthread-2:null', 'subthread-1:null']);
  });

  test('详情首屏失败进入可重试终态并保留请求 ID', () async {
    final repository = _FakeThreadDetailRepository(
      onThread: (_) => throw const ApiFailure(
        userMessage: '主题不存在。',
        httpStatus: 404,
        requestId: 'thread-request-id',
      ),
    );
    final controller = ThreadDetailController(
      repository,
      'missing',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();

    expect(controller.state.phase, ThreadDetailPhase.failed);
    expect(controller.state.failure?.httpStatus, 404);
    expect(controller.state.failure?.requestId, 'thread-request-id');
  });
}

void _expectRestrictedTerminal(ThreadDetailState state, int status) {
  expect(state.phase, ThreadDetailPhase.failed);
  expect(state.detail, isNull);
  expect(state.selectedSubthreadId, isNull);
  expect(state.floorAuthorId, isNull);
  expect(state.floors, isEmpty);
  expect(state.cursor, isNull);
  expect(state.hasMore, isFalse);
  expect(state.isRefreshing, isFalse);
  expect(state.isLoadingFloors, isFalse);
  expect(state.isLoadingMore, isFalse);
  expect(state.isPrefetchingFloors, isFalse);
  expect(state.failure?.httpStatus, status);
  expect(state.transientFailure, isNull);
}

class _FakeThreadDetailRepository implements ThreadDetailRepository {
  _FakeThreadDetailRepository({this.onThread, this.onFloors});

  final Future<ThreadDetailModel> Function(String threadId)? onThread;
  final Future<CursorPage<ThreadFloorModel>> Function(
    String subthreadId,
    String? cursor,
  )?
  onFloors;
  final List<String> floorRequests = [];
  final List<ThreadFloorOrder> floorOrders = [];
  final List<String?> floorAuthors = [];

  @override
  Future<ThreadDetailModel> fetchThread(String threadId) {
    return onThread?.call(threadId) ?? Future.value(_detail);
  }

  @override
  Future<ThreadPostTargetModel> fetchPostTarget(String postId) {
    throw UnsupportedError('not used by controller tests');
  }

  @override
  Future<CursorPage<ThreadFloorModel>> fetchFloors({
    required String subthreadId,
    String? cursor,
    int limit = 20,
    ThreadFloorOrder order = ThreadFloorOrder.oldest,
    String? authorId,
  }) {
    floorRequests.add('$subthreadId:$cursor');
    floorOrders.add(order);
    floorAuthors.add(authorId);
    return onFloors?.call(subthreadId, cursor) ??
        Future.value(
          CursorPage(items: [_floor('floor-$subthreadId')], hasMore: false),
        );
  }
}

final _detail = ThreadDetailModel(
  id: 'thread-1',
  title: '星海旅团',
  owner: _author,
  categorySlug: 'RPG',
  status: ThreadDetailStatus.recruiting,
  isPrivate: false,
  isPinned: false,
  viewCount: 20,
  likeCount: 3,
  tipTotal: '8',
  memberCount: 5,
  playerCount: 2,
  postCount: 12,
  tags: const [],
  subthreads: const [
    ThreadSubthreadModel(
      id: 'subthread-1',
      title: '主线',
      sortOrder: 1,
      postCount: 8,
      postingPolicyLabel: '参与者发言',
    ),
    ThreadSubthreadModel(
      id: 'subthread-2',
      title: '支线',
      sortOrder: 2,
      postCount: 4,
      postingPolicyLabel: '玩家发言',
    ),
  ],
  defaultSubthreadId: 'subthread-2',
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 9),
);

final _detailWithoutSelectedSubthread = ThreadDetailModel(
  id: 'thread-1',
  title: '星海旅团',
  owner: _author,
  categorySlug: 'RPG',
  status: ThreadDetailStatus.recruiting,
  isPrivate: false,
  isPinned: false,
  viewCount: 21,
  likeCount: 3,
  tipTotal: '8',
  memberCount: 5,
  playerCount: 2,
  postCount: 9,
  tags: const [],
  subthreads: const [
    ThreadSubthreadModel(
      id: 'subthread-1',
      title: '主线',
      sortOrder: 1,
      postCount: 9,
      postingPolicyLabel: '参与者发言',
    ),
  ],
  defaultSubthreadId: 'subthread-1',
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 10),
);

const _author = ThreadAuthorModel(id: 'user-1', username: '温柔测试员', level: 3);

ThreadFloorModel _floor(String id, {int number = 1}) {
  return ThreadFloorModel(
    id: id,
    floorNumber: number,
    author: _author,
    body: const ThreadBodyModel(markdown: '楼层正文'),
    createdAt: DateTime.utc(2026, 8, 9),
    isDeleted: false,
    replyCount: 0,
    replies: const [],
  );
}
