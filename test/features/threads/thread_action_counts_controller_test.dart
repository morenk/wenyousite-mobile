import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/thread_interaction_controller.dart';
import 'package:wenyousite_mobile/features/social/data/thread_interaction_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_interaction_models.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

import '../../support/discussion_window_fixture.dart';
import 'thread_detail_page_test_support.dart';

void main() {
  test('总数刷新保留窗口与互动family，不覆盖快速点赞在途状态', () async {
    final repository = _Repository();
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();
    controller.visibleFloorId = controller.state.floors.single.id;
    final window = controller.state.window;
    final visible = controller.visibleFloorId;
    final likes = _LikeRepository();
    final container = ProviderContainer(
      overrides: [threadInteractionRepositoryProvider.overrideWithValue(likes)],
    );
    addTearDown(container.dispose);
    final target = _target(controller.state.detail!);
    final subscription = container.listen(
      threadInteractionControllerProvider(target),
      (_, _) {},
    );
    addTearDown(subscription.close);
    final notifier = container.read(
      threadInteractionControllerProvider(target).notifier,
    );
    final pendingLike = notifier.toggleLike();
    repository.detail = threadDetailPageTestCopyThreadDetail(
      repository.detail,
      subthreads: repository.detail.subthreads,
      likeCount: 999,
      bookmarkCount: 7,
      subscriberCount: 8,
    );
    await controller.refreshActionCounts();
    expect(controller.state.detail!.bookmarkCount, 7);
    expect(controller.state.detail!.subscriberCount, 8);
    expect(_target(controller.state.detail!), target);
    expect(
      container.read(
        threadInteractionControllerProvider(
          _target(controller.state.detail!),
        ).notifier,
      ),
      same(notifier),
    );
    expect(
      container.read(threadInteractionControllerProvider(target)).isPending,
      isTrue,
    );
    expect(controller.state.window, same(window));
    expect(controller.visibleFloorId, visible);
    expect(repository.floorCalls, 1);
    likes.pending.complete(13);
    await pendingLike;
    expect(
      container.read(threadInteractionControllerProvider(target)).likeCount,
      13,
    );
  });

  test('旧统计响应不能覆盖较新统计或切换后的子帖', () async {
    final repository = _Repository();
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();
    final stale = Completer<ThreadDetailModel>();
    repository.next = stale.future;
    final first = controller.refreshActionCounts();
    repository.detail = repository.detail.withActionCounts(
      bookmarkCount: 20,
      subscriberCount: 30,
    );
    await controller.refreshActionCounts();
    stale.complete(
      repository.detail.withActionCounts(bookmarkCount: 1, subscriberCount: 1),
    );
    await first;
    expect(controller.state.detail!.bookmarkCount, 20);
    final navigated = Completer<ThreadDetailModel>();
    repository.next = navigated.future;
    final second = controller.refreshActionCounts();
    await controller.selectSubthread(
      repository.detail.subthreads
          .firstWhere((item) => item.id != controller.state.selectedSubthreadId)
          .id,
    );
    navigated.complete(
      repository.detail.withActionCounts(
        bookmarkCount: 99,
        subscriberCount: 99,
      ),
    );
    await second;
    expect(controller.state.detail!.bookmarkCount, 20);
  });

  test('统计读取失败保留总数，成功只清除自己的错误', () async {
    final repository = _Repository();
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();
    repository.error = const ApiFailure(userMessage: '统计读失败');
    await controller.refreshActionCounts();
    expect(controller.state.detail!.bookmarkCount, 2);
    expect(controller.state.transientFailure?.userMessage, '统计读失败');
    repository.error = null;
    await controller.refreshActionCounts();
    expect(controller.state.transientFailure, isNull);
    repository.error = const ApiFailure(userMessage: '再次统计失败');
    await controller.refreshActionCounts();
    repository.floorError = const ApiFailure(userMessage: '分页读失败');
    await controller.loadMore();
    repository.error = null;
    await controller.refreshActionCounts();
    expect(controller.state.transientFailure?.userMessage, '分页读失败');
  });

  test('失去访问权限隐藏正文，离页后的迟到统计不写回', () async {
    final repository = _Repository();
    final controller = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    await controller.loadInitial();
    repository.error = const ApiFailure(httpStatus: 403, userMessage: '不可访问');
    await controller.refreshActionCounts();
    expect(controller.state.detail, isNull);
    expect(controller.state.floors, isEmpty);
    controller.dispose();
    repository.error = null;
    final nextController = ThreadDetailController(
      repository,
      'thread-1',
      autoStart: false,
    );
    await nextController.loadInitial();
    final late = Completer<ThreadDetailModel>();
    repository.next = late.future;
    final action = nextController.refreshActionCounts();
    nextController.dispose();
    late.complete(repository.detail);
    await action;
  });
}

ThreadInteractionTarget _target(ThreadDetailModel detail) =>
    ThreadInteractionTarget(
      threadId: detail.id,
      isLiked: detail.isLiked,
      likeCount: detail.likeCount,
      isBookmarked: detail.isBookmarked,
      bookmarkId: detail.bookmarkId,
    );

class _Repository extends Fake
    with FloorWindowFixture
    implements ThreadDetailRepository {
  ThreadDetailModel detail = threadDetailPageTestDetail.withActionCounts(
    bookmarkCount: 2,
    subscriberCount: 3,
  );
  Future<ThreadDetailModel>? next;
  ApiFailure? error;
  ApiFailure? floorError;
  int floorCalls = 0;

  @override
  Future<ThreadDetailModel> fetchThread(String threadId) async {
    final pending = next;
    next = null;
    if (pending != null) return pending;
    if (error != null) throw error!;
    return detail;
  }

  @override
  Future<CursorPage<ThreadFloorModel>> fetchFloors({
    required String subthreadId,
    String? cursor,
    int limit = 20,
    ThreadFloorOrder order = ThreadFloorOrder.oldest,
    String? authorId,
  }) async {
    floorCalls++;
    if (floorError != null) throw floorError!;
    return CursorPage(
      items: [threadDetailPageTestSideFloor],
      cursor: 'next',
      hasMore: true,
    );
  }
}

class _LikeRepository extends Fake implements ThreadInteractionRepository {
  final pending = Completer<int>();
  @override
  Future<int> like(String threadId) => pending.future;
}
