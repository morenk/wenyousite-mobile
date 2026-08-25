import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_target_utils.dart';

void main() {
  final mainState = ThreadDetailState(
    phase: ThreadDetailPhase.ready,
    detail: _detail,
    selectedSubthreadId: 'subthread-1',
  );

  test('post 查询优先于同时出现的 subthread 查询', () {
    final target = ThreadDetailEntryTarget.fromQuery(
      postId: 'post-1',
      subthreadId: 'subthread-2',
    );

    expect(target, const ThreadDetailEntryTarget.post('post-1'));
  });

  test('有效入口只消费一次且目标已是当前子贴也会完成消费', () {
    final coordinator = ThreadDetailEntryTargetCoordinator()
      ..synchronize(
        threadId: 'thread-1',
        target: const ThreadDetailEntryTarget.subthread('subthread-1'),
        sessionScope: const _Scope(1),
      );

    expect(coordinator.resolve(state: mainState, postTarget: null), isNull);
    expect(
      coordinator.resolve(
        state: mainState.copyWith(selectedSubthreadId: 'subthread-2'),
        postTarget: null,
      ),
      isNull,
    );
  });

  test('用户切换取消尚未返回的帖子目标', () {
    final coordinator = ThreadDetailEntryTargetCoordinator()
      ..synchronize(
        threadId: 'thread-1',
        target: const ThreadDetailEntryTarget.post('post-1'),
        sessionScope: const _Scope(1),
      );

    expect(coordinator.resolve(state: mainState, postTarget: null), isNull);
    coordinator.cancelForUserSelection();
    expect(coordinator.allowsTargetEffects, isFalse);
    expect(
      coordinator.resolve(state: mainState, postTarget: _sideTarget),
      isNull,
    );
  });

  test('显式重试、坐标变化和会话变化会重新武装入口', () {
    final coordinator = ThreadDetailEntryTargetCoordinator()
      ..synchronize(
        threadId: 'thread-1',
        target: const ThreadDetailEntryTarget.post('post-1'),
        sessionScope: const _Scope(1),
      )
      ..cancelForUserSelection()
      ..rearmForRetry();

    expect(
      coordinator.resolve(state: mainState, postTarget: _sideTarget),
      isA<ThreadDetailEntrySelection>().having(
        (selection) => selection.subthreadId,
        'subthreadId',
        'subthread-2',
      ),
    );

    coordinator.synchronize(
      threadId: 'thread-1',
      target: const ThreadDetailEntryTarget.subthread('subthread-2'),
      sessionScope: const _Scope(1),
    );
    expect(coordinator.resolve(state: mainState, postTarget: null), isNotNull);

    coordinator.synchronize(
      threadId: 'thread-1',
      target: const ThreadDetailEntryTarget.subthread('subthread-2'),
      sessionScope: const _Scope(2),
    );
    expect(coordinator.resolve(state: mainState, postTarget: null), isNotNull);
  });

  test('失效子贴坐标消费后不会在目录变化时突然生效', () {
    final coordinator = ThreadDetailEntryTargetCoordinator()
      ..synchronize(
        threadId: 'thread-1',
        target: const ThreadDetailEntryTarget.subthread('subthread-missing'),
        sessionScope: const _Scope(1),
      );

    expect(coordinator.resolve(state: mainState, postTarget: null), isNull);
    expect(
      coordinator.resolve(
        state: ThreadDetailState(
          phase: ThreadDetailPhase.ready,
          detail: _detailWithMissingSubthread,
          selectedSubthreadId: 'subthread-1',
        ),
        postTarget: null,
      ),
      isNull,
    );
  });

  test('旧帧回调会被用户操作代次拒绝', () {
    final coordinator = ThreadDetailEntryTargetCoordinator()
      ..synchronize(
        threadId: 'thread-1',
        target: const ThreadDetailEntryTarget.subthread('subthread-2'),
        sessionScope: const _Scope(1),
      );
    final selection = coordinator.resolve(state: mainState, postTarget: null)!;

    expect(coordinator.isCurrent(selection.generation), isTrue);
    coordinator.cancelForUserSelection();
    expect(coordinator.isCurrent(selection.generation), isFalse);
  });
}

class _Scope {
  const _Scope(this.generation);

  final int generation;

  @override
  bool operator ==(Object other) =>
      other is _Scope && other.generation == generation;

  @override
  int get hashCode => generation;
}

const _author = ThreadAuthorModel(id: 'user-1', username: '测试者', level: 1);

const _mainSubthread = ThreadSubthreadModel(
  id: 'subthread-1',
  title: '主线',
  sortOrder: 1,
  postCount: 1,
  postingPolicyLabel: '参与者发言',
);

const _sideSubthread = ThreadSubthreadModel(
  id: 'subthread-2',
  title: '支线',
  sortOrder: 2,
  postCount: 1,
  postingPolicyLabel: '参与者发言',
);

final _detail = ThreadDetailModel(
  id: 'thread-1',
  title: '测试主题',
  owner: _author,
  categorySlug: 'RPG',
  status: ThreadDetailStatus.recruiting,
  isPrivate: false,
  isPinned: false,
  viewCount: 0,
  likeCount: 0,
  tipTotal: '0',
  memberCount: 1,
  playerCount: 0,
  postCount: 1,
  tags: const [],
  subthreads: const [_mainSubthread, _sideSubthread],
  defaultSubthreadId: 'subthread-1',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

final _detailWithMissingSubthread = ThreadDetailModel(
  id: 'thread-1',
  title: '测试主题',
  owner: _author,
  categorySlug: 'RPG',
  status: ThreadDetailStatus.recruiting,
  isPrivate: false,
  isPinned: false,
  viewCount: 0,
  likeCount: 0,
  tipTotal: '0',
  memberCount: 1,
  playerCount: 0,
  postCount: 1,
  tags: const [],
  subthreads: const [
    _mainSubthread,
    _sideSubthread,
    ThreadSubthreadModel(
      id: 'subthread-missing',
      title: '迟到目录',
      sortOrder: 3,
      postCount: 0,
      postingPolicyLabel: '参与者发言',
    ),
  ],
  defaultSubthreadId: 'subthread-1',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

final _sideTarget = ThreadPostTargetModel(
  requestedPostId: 'post-1',
  threadId: 'thread-1',
  subthreadId: 'subthread-2',
  floor: ThreadFloorModel(
    id: 'post-1',
    floorNumber: 1,
    author: _author,
    body: const ThreadBodyModel(markdown: '目标'),
    createdAt: DateTime.utc(2026),
    isDeleted: false,
    replyCount: 0,
    replies: const [],
  ),
);
