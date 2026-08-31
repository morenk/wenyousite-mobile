import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/thread_interaction_controller.dart';
import 'package:wenyousite_mobile/features/social/data/thread_interaction_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_interaction_models.dart';

void main() {
  test('点赞采用服务端计数并阻止并发互动', () async {
    final pending = Completer<int>();
    final repository = _FakeRepository(likeFuture: pending.future);
    final controller = ThreadInteractionController(repository, _target);
    addTearDown(controller.dispose);

    final like = controller.toggleLike();
    expect(await controller.toggleBookmark(), isFalse);
    expect(repository.likeCalls, 1);
    expect(repository.createBookmarkCalls, 0);

    pending.complete(23);
    expect(await like, isTrue);
    expect(controller.state.isLiked, isTrue);
    expect(controller.state.likeCount, 23);
    expect(controller.state.isBookmarked, isFalse);
  });

  test('取消点赞采用服务端权威计数', () async {
    final repository = _FakeRepository(unlikeCount: 8);
    final controller = ThreadInteractionController(
      repository,
      const ThreadInteractionTarget(
        threadId: 'thread-1',
        isLiked: true,
        likeCount: 9,
        isBookmarked: false,
      ),
    );
    addTearDown(controller.dispose);

    expect(await controller.toggleLike(), isTrue);

    expect(controller.state.isLiked, isFalse);
    expect(controller.state.likeCount, 8);
    expect(repository.unlikeCalls, 1);
  });

  test('收藏成功保存记录 ID，取消时使用同一 ID', () async {
    final repository = _FakeRepository(createdBookmarkId: 'bookmark-new');
    final controller = ThreadInteractionController(repository, _target);
    addTearDown(controller.dispose);

    expect(await controller.toggleBookmark(folderId: 'folder-custom'), isTrue);
    expect(controller.state.isBookmarked, isTrue);
    expect(controller.state.bookmarkId, 'bookmark-new');
    expect(repository.createdFolderIds, ['folder-custom']);

    expect(await controller.toggleBookmark(), isTrue);
    expect(controller.state.isBookmarked, isFalse);
    expect(controller.state.bookmarkId, isNull);
    expect(repository.removedBookmarkIds, ['bookmark-new']);
  });

  test('已收藏但缺少记录 ID 时不发送错误删除', () async {
    final repository = _FakeRepository();
    final controller = ThreadInteractionController(
      repository,
      const ThreadInteractionTarget(
        threadId: 'thread-1',
        isLiked: false,
        likeCount: 12,
        isBookmarked: true,
      ),
    );
    addTearDown(controller.dispose);

    expect(await controller.toggleBookmark(folderId: 'folder-custom'), isFalse);

    expect(controller.state.isBookmarked, isTrue);
    expect(controller.state.failure?.reason, FailureReason.contractViolation);
    expect(
      controller.state.failure?.recoveryAction,
      FailureRecoveryAction.refresh,
    );
    expect(controller.state.failure?.userMessage, contains('刷新'));
    expect(repository.removedBookmarkIds, isEmpty);
  });

  test('互动失败保留旧状态与请求 ID', () async {
    final repository = _FakeRepository(
      failure: const ApiFailure(
        userMessage: '操作失败',
        requestId: 'interaction-request-id',
      ),
    );
    final controller = ThreadInteractionController(repository, _target);
    addTearDown(controller.dispose);

    expect(await controller.toggleLike(), isFalse);

    expect(controller.state.isLiked, isFalse);
    expect(controller.state.likeCount, 12);
    expect(controller.state.failure?.requestId, 'interaction-request-id');
  });

  test('点赞超时后读取到目标状态即采用最新互动投影', () async {
    final repository = _FakeRepository(
      failure: _timeoutFailure('like-timeout'),
      projection: const ThreadInteractionProjection(
        isLiked: true,
        likeCount: 14,
        isBookmarked: true,
        bookmarkId: 'bookmark-latest',
      ),
    );
    final controller = ThreadInteractionController(repository, _target);
    addTearDown(controller.dispose);

    expect(await controller.toggleLike(), isTrue);

    expect(controller.state.isLiked, isTrue);
    expect(controller.state.likeCount, 14);
    expect(controller.state.bookmarkId, 'bookmark-latest');
    expect(repository.projectionReads, 1);
  });

  test('收藏超时且投影相反时进入中性待刷新状态', () async {
    final repository = _FakeRepository(
      failure: _timeoutFailure('bookmark-timeout'),
      projection: const ThreadInteractionProjection(
        isLiked: false,
        likeCount: 13,
        isBookmarked: false,
      ),
    );
    final controller = ThreadInteractionController(repository, _target);
    addTearDown(controller.dispose);

    expect(await controller.toggleBookmark(folderId: 'folder-custom'), isFalse);

    expect(controller.state.failure, isNull);
    expect(controller.state.outcomeStatus, WriteOutcomeStatus.indeterminate);
    expect(controller.state.outcomeRequestId, 'bookmark-timeout');
    expect(
      controller.state.outcomeFailure?.effectiveSource,
      FailureSource.network,
    );
    expect(controller.state.likeCount, 13);
  });
}

const _target = ThreadInteractionTarget(
  threadId: 'thread-1',
  isLiked: false,
  likeCount: 12,
  isBookmarked: false,
);

class _FakeRepository
    implements ThreadInteractionRepository, ThreadInteractionProjectionReader {
  _FakeRepository({
    this.likeFuture,
    this.unlikeCount = 11,
    this.createdBookmarkId = 'bookmark-1',
    this.failure,
    this.projection,
  });

  final Future<int>? likeFuture;
  final int unlikeCount;
  final String createdBookmarkId;
  final ApiFailure? failure;
  final ThreadInteractionProjection? projection;
  int likeCalls = 0;
  int unlikeCalls = 0;
  int createBookmarkCalls = 0;
  int projectionReads = 0;
  final List<String> removedBookmarkIds = [];
  final List<String> createdFolderIds = [];

  @override
  Future<int> like(String threadId) async {
    likeCalls += 1;
    if (failure != null) throw failure!;
    return likeFuture == null ? 13 : await likeFuture!;
  }

  @override
  Future<int> unlike(String threadId) async {
    unlikeCalls += 1;
    if (failure != null) throw failure!;
    return unlikeCount;
  }

  @override
  Future<String> createBookmark(String threadId, String folderId) async {
    createBookmarkCalls += 1;
    createdFolderIds.add(folderId);
    if (failure != null) throw failure!;
    return createdBookmarkId;
  }

  @override
  Future<void> removeBookmark(String bookmarkId) async {
    if (failure != null) throw failure!;
    removedBookmarkIds.add(bookmarkId);
  }

  @override
  Future<ThreadInteractionProjection> fetchInteraction(String threadId) async {
    projectionReads += 1;
    return projection ??
        const ThreadInteractionProjection(
          isLiked: false,
          likeCount: 12,
          isBookmarked: false,
        );
  }
}

ApiFailure _timeoutFailure(String requestId) {
  return ApiFailure(
    userMessage: '连接超时，请检查网络后重试。',
    requestId: requestId,
    cause: DioException(
      requestOptions: RequestOptions(path: '/threads/thread-1/like'),
      type: DioExceptionType.receiveTimeout,
    ),
  );
}
