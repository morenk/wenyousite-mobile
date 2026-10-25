import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

import 'moment_comment_pagination_test_support.dart';

void main() {
  late CommentPaginationRepository repository;
  late MomentDetailController controller;
  setUp(() {
    repository = CommentPaginationRepository();
    repository.onComments = (_) => commentPage(['first'], cursor: 'next');
    controller = MomentDetailController(
      repository,
      'moment-1',
      autoStart: false,
    );
  });
  tearDown(() => controller.dispose());

  test('一级评论自动续页去重，进行中和到底不再请求', () async {
    await controller.load();
    final pending = Completer<CursorPage<MomentRootComment>>();
    repository.onComments = (_) => pending.future;
    final loading = controller.loadMoreComments();
    await controller.loadMoreComments();
    expect(repository.requests.map((e) => e.cursor), [null, 'next']);
    pending.complete(commentPage(['first', 'second']));
    await loading;
    expect(controller.state.comments.map((e) => e.id), ['first', 'second']);
    expect(controller.state.isLoadingMoreComments, isFalse);
    await controller.loadMoreComments();
    expect(repository.requests, hasLength(2));
  });

  test('分页失败保留内容与游标，自动调用暂停，明确重试成功', () async {
    await controller.load();
    repository.onComments = (_) => throw const ApiFailure(userMessage: '加载失败');
    await controller.loadMoreComments();
    expect(controller.state.comments.single.id, 'first');
    expect(controller.state.commentCursor, 'next');
    expect(controller.state.commentPageFailure, isNotNull);
    expect(controller.state.transientFailure, isNull);
    await controller.loadMoreComments();
    expect(repository.requests, hasLength(2));
    repository.onComments = (_) => commentPage(['second']);
    await controller.loadMoreComments(retry: true);
    expect(repository.requests.last.cursor, 'next');
    expect(controller.state.commentPageFailure, isNull);
    expect(controller.state.comments.map((e) => e.id), ['first', 'second']);
  });

  test('排序首页失败后不会使用旧游标，重试读取新排序首页', () async {
    await controller.load();
    repository.onComments = (_) => throw StateError('offline');
    await controller.selectCommentOrder(MomentCommentOrder.oldest);
    expect(controller.state.commentCursor, isNull);
    expect(controller.state.hasMoreComments, isFalse);
    expect(controller.state.commentPageFailure, isNotNull);
    expect(controller.state.transientFailure, isNotNull);
    await controller.loadMoreComments();
    expect(repository.requests, hasLength(2));
    repository.onComments = (_) =>
        commentPage(['oldest'], cursor: 'oldest-next');
    await controller.loadMoreComments(retry: true);
    expect(repository.requests.last, (
      order: MomentCommentOrder.oldest,
      cursor: null,
    ));
    expect(controller.state.comments.single.id, 'oldest');
    expect(controller.state.commentCursor, 'oldest-next');
  });

  for (final sort in [false, true]) {
    test('${sort ? '排序' : '刷新'}覆盖在途分页，旧结果不追加且加载锁释放', () async {
      await controller.load();
      final stale = Completer<CursorPage<MomentRootComment>>();
      final fresh = Completer<CursorPage<MomentRootComment>>();
      repository.onComments = (request) =>
          request.cursor != null ? stale.future : fresh.future;
      final loading = controller.loadMoreComments();
      final reloading = sort
          ? controller.selectCommentOrder(MomentCommentOrder.oldest)
          : controller.load();
      await controller.loadMoreComments();
      expect(repository.requests, hasLength(3));
      fresh.complete(commentPage(['fresh'], cursor: 'fresh-next'));
      await reloading;
      stale.complete(commentPage(['stale'], cursor: 'stale-next'));
      await loading;
      expect(controller.state.comments.single.id, 'fresh');
      expect(controller.state.commentCursor, 'fresh-next');
      expect(controller.state.isLoadingMoreComments, isFalse);
      expect(controller.state.isRefreshing, isFalse);
      repository.onComments = (_) => commentPage(['fresh-second']);
      await controller.loadMoreComments();
      expect(repository.requests.last.cursor, 'fresh-next');
    });
  }

  test('刷新失败在当前视口反馈，停止自动续页，重试仍刷新详情', () async {
    await controller.load();
    repository.failDetail = true;
    await controller.load();
    expect(controller.state.transientFailure, isNotNull);
    expect(controller.state.commentPageFailure, isNotNull);
    expect(controller.state.commentCursor, isNull);
    await controller.loadMoreComments();
    expect(repository.requests, hasLength(2));
    repository.failDetail = false;
    await controller.loadMoreComments(retry: true);
    expect(repository.detailCalls, 3);
    expect(controller.state.commentPageFailure, isNull);
  });

  test('旧分页迟到的失效游标不会重置新排序或清除新请求状态', () async {
    await controller.load();
    final stale = Completer<CursorPage<MomentRootComment>>();
    repository.onComments = (request) => request.cursor != null
        ? stale.future
        : commentPage(['oldest'], cursor: 'oldest-next');
    final loading = controller.loadMoreComments();
    await controller.selectCommentOrder(MomentCommentOrder.oldest);
    stale.completeError(
      const ApiFailure(businessCode: 40007, userMessage: '加载失败'),
    );
    await loading;
    expect(repository.requests, hasLength(3));
    expect(controller.state.comments.single.id, 'oldest');
    expect(controller.state.commentCursor, 'oldest-next');
    expect(controller.state.commentPageFailure, isNull);
    repository.onComments = (_) => commentPage(['oldest-second']);
    await controller.loadMoreComments();
    expect(repository.requests.last, (
      order: MomentCommentOrder.oldest,
      cursor: 'oldest-next',
    ));
  });

  test('失效游标恢复首页失败后暂停，明确重试仍从首页读取', () async {
    await controller.load();
    repository.onComments = (request) {
      if (request.cursor != null) {
        throw const ApiFailure(businessCode: 40007, userMessage: '加载失败');
      }
      throw StateError('offline');
    };
    await controller.loadMoreComments();
    expect(repository.requests.map((e) => e.cursor), [null, 'next', null]);
    expect(controller.state.comments.single.id, 'first');
    expect(controller.state.commentPageFailure, isNotNull);
    expect(controller.state.commentCursor, isNull);
    await controller.loadMoreComments();
    expect(repository.requests, hasLength(3));
    repository.onComments = (_) => commentPage(['recovered']);
    await controller.loadMoreComments(retry: true);
    expect(repository.requests.last.cursor, isNull);
    expect(controller.state.comments.single.id, 'recovered');
    expect(controller.state.commentPageFailure, isNull);
  });

  test('游标失效只自动回首页一次，连续失效暂停到明确重试', () async {
    await controller.load();
    repository.onComments = (request) {
      if (request.cursor != null) {
        throw const ApiFailure(businessCode: 40007, userMessage: '加载失败');
      }
      return commentPage(['fresh'], cursor: 'new-next');
    };
    await controller.loadMoreComments();
    expect(repository.requests.map((e) => e.cursor), [null, 'next', null]);
    expect(controller.state.comments.single.id, 'fresh');
    await controller.loadMoreComments();
    expect(controller.state.commentPageFailure, isNotNull);
    await controller.loadMoreComments();
    expect(repository.requests, hasLength(4));
    repository.onComments = (_) => commentPage(['recovered']);
    await controller.loadMoreComments(retry: true);
    expect(controller.state.commentPageFailure, isNull);
  });

  for (final cursor in ['next', null]) {
    test('仍有下一页但游标${cursor == null ? '缺失' : '不前进'}不会循环请求', () async {
      await controller.load();
      repository.onComments = (_) => CursorPage(
        items: [paginationComment('next')],
        cursor: cursor,
        hasMore: true,
      );
      await controller.loadMoreComments();
      expect(controller.state.commentPageFailure, isNotNull);
      expect(controller.state.comments.single.id, 'first');
      await controller.loadMoreComments();
      expect(repository.requests, hasLength(2));
    });
  }

  test('多页游标循环被阻断，失败重试仍使用最后有效位置', () async {
    await controller.load();
    repository.onComments = (_) => commentPage(['second'], cursor: 'third');
    await controller.loadMoreComments();
    repository.onComments = (_) => commentPage(['third'], cursor: 'next');
    await controller.loadMoreComments();
    expect(controller.state.commentPageFailure, isNotNull);
    expect(controller.state.commentCursor, 'third');
    await controller.loadMoreComments();
    expect(repository.requests, hasLength(3));
  });
}
