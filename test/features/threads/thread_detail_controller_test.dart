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

  test('分页 cursor 失效时自动从当前子贴第一页重载', () async {
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
    await controller.loadMore();

    expect(firstPageCalls, 2);
    expect(controller.state.floors.single.id, 'fresh-2');
    expect(controller.state.transientFailure, isNull);
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
  expect(state.floors, isEmpty);
  expect(state.cursor, isNull);
  expect(state.hasMore, isFalse);
  expect(state.isRefreshing, isFalse);
  expect(state.isLoadingFloors, isFalse);
  expect(state.isLoadingMore, isFalse);
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

  @override
  Future<ThreadDetailModel> fetchThread(String threadId) {
    return onThread?.call(threadId) ?? Future.value(_detail);
  }

  @override
  Future<CursorPage<ThreadFloorModel>> fetchFloors({
    required String subthreadId,
    String? cursor,
    int limit = 20,
  }) {
    floorRequests.add('$subthreadId:$cursor');
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

const _author = ThreadAuthorModel(id: 'user-1', username: '温柔测试员', level: 3);

ThreadFloorModel _floor(String id) {
  return ThreadFloorModel(
    id: id,
    floorNumber: 1,
    author: _author,
    body: const ThreadBodyModel(markdown: '楼层正文'),
    createdAt: DateTime.utc(2026, 8, 9),
    isDeleted: false,
    replyCount: 0,
    replies: const [],
  );
}
