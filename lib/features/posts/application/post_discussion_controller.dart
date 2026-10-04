import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/models/discussion_window.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/application/post_repository_ports.dart';
import 'package:wenyousite_mobile/features/posts/application/post_states.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

typedef PostDiscussionTarget = ({String rootPostId, String? focusedReplyId});
typedef PostDiscussionControllerProvider =
    AutoDisposeStateNotifierProvider<
      PostDiscussionController,
      PostDiscussionState
    >;

class PostDiscussionController extends StateNotifier<PostDiscussionState> {
  PostDiscussionController(
    this._repository,
    this.target, {
    bool autoStart = true,
  }) : super(const PostDiscussionState()) {
    if (autoStart) unawaited(load());
  }

  final PostRepository _repository;
  final PostDiscussionTarget target;
  int _epoch = 0;
  bool _retryBefore = false;
  String? visibleReplyId;
  bool Function()? canApplyPage;
  void Function()? beforeWindowApply;
  bool _current(int epoch) => mounted && epoch == _epoch;

  Future<({DiscussionWindow<PostItem> page, String? author, bool cleared})>
  _read({
    required PostReplyOrder order,
    required String? authorId,
    int? number,
    String? postId,
    String? cursor,
    bool Function()? active,
  }) async {
    try {
      return (
        page: await _repository.fetchReplyWindow(
          rootPostId: target.rootPostId,
          number: number,
          postId: postId,
          cursor: cursor,
          order: order,
          authorId: authorId,
        ),
        author: authorId,
        cleared: false,
      );
    } on ApiFailure catch (failure) {
      if (failure.businessCode != 40010 ||
          authorId == null ||
          (number == null && postId == null) ||
          active == null ||
          !active()) {
        rethrow;
      }
      return (
        page: await _repository.fetchReplyWindow(
          rootPostId: target.rootPostId,
          number: number,
          postId: postId,
          order: order,
        ),
        author: null,
        cleared: true,
      );
    }
  }

  PostDiscussionState _withWindow(DiscussionWindowBuffer<PostItem> window) =>
      state.copyWith(
        window: window,
        replies: window.items,
        cursor: window.afterCursor,
        hasMore: window.afterCursor != null,
        isLoadingMore: false,
        isPrefetchingReplies: false,
        transientFailure: null,
        retryAction: null,
      );

  Future<void> load({bool locateEntry = true}) async {
    final epoch = ++_epoch;
    final order = state.order;
    final author = state.authorId;
    visibleReplyId = null;
    state = PostDiscussionState(order: order, authorId: author);
    try {
      final root = await _repository.fetchPost(target.rootPostId);
      _assertRoot(root);
      if (!_current(epoch)) return;
      final result = await _read(
        order: order,
        authorId: author,
        postId: locateEntry ? target.focusedReplyId : null,
        active: () => _current(epoch),
      );
      if (!_current(epoch)) return;
      _assertReplies(root, result.page.items);
      state = _withWindow(DiscussionWindowBuffer(result.page)).copyWith(
        phase: PostDiscussionPhase.ready,
        root: root,
        order: order,
        authorId: result.author,
      );
    } on Object catch (error) {
      if (!_current(epoch)) return;
      final failure = mapApplicationFailure(error, '楼中楼讨论加载失败，请稍后重试。');
      state = PostDiscussionState(
        phase: _restricted(failure)
            ? PostDiscussionPhase.restricted
            : PostDiscussionPhase.failed,
        order: order,
        authorId: author,
        failure: failure,
      );
    }
  }

  Future<void> refresh() async {
    if (state.phase != PostDiscussionPhase.ready || state.isRefreshing) return;
    final epoch = ++_epoch;
    final id = visibleReplyId ?? state.replies.firstOrNull?.id;
    var rootVerified = false;
    state = state.copyWith(
      isRefreshing: true,
      isLoadingMore: false,
      isPrefetchingReplies: false,
      transientFailure: null,
    );
    try {
      final root = await _repository.fetchPost(target.rootPostId);
      _assertRoot(root);
      rootVerified = true;
      if (!_current(epoch)) return;
      final result = await _read(
        order: state.order,
        authorId: state.authorId,
        postId: id,
        active: () => _current(epoch),
      );
      if (!_current(epoch)) return;
      _assertReplies(root, result.page.items);
      beforeWindowApply?.call();
      state = _withWindow(
        DiscussionWindowBuffer(result.page),
      ).copyWith(root: root, authorId: result.author, isRefreshing: false);
    } on Object catch (error) {
      if (!_current(epoch)) return;
      final failure = mapApplicationFailure(error, '讨论刷新失败，请重试。');
      if (rootVerified &&
          failure.httpStatus == 404 &&
          id != null &&
          state.window != null) {
        beforeWindowApply?.call();
        state = _withWindow(
          state.window!.removeWhere((item) => item.id == id),
        ).copyWith(isRefreshing: false);
        visibleReplyId = state.replies.firstOrNull?.id;
        return;
      }
      if (failure.httpStatus == 403 ||
          (!rootVerified && failure.httpStatus == 404)) {
        state = PostDiscussionState(
          phase: PostDiscussionPhase.restricted,
          failure: failure,
        );
        return;
      }
      state = state.copyWith(
        isRefreshing: false,
        transientFailure: failure,
        retryAction: PostDiscussionRetryAction.refresh,
      );
    }
  }

  Future<void> setOrder(PostReplyOrder order) =>
      applyFilters(order: order, authorId: state.authorId);
  Future<void> setAuthor(String? authorId) =>
      applyFilters(order: state.order, authorId: authorId);
  Future<void> applyFilters({
    required PostReplyOrder order,
    required String? authorId,
  }) async {
    final author = authorId?.trim();
    final normalized = author == null || author.isEmpty ? null : author;
    if (state.phase != PostDiscussionPhase.ready ||
        (order == state.order && normalized == state.authorId)) {
      return;
    }
    state = state.copyWith(order: order, authorId: normalized);
    await load(locateEntry: false);
  }

  Future<({String id, bool clearedAuthor})?> locate({
    int? number,
    String? postId,
    required PostReplyOrder order,
    required String? authorId,
    required bool Function() active,
  }) async {
    if (state.phase != PostDiscussionPhase.ready) return null;
    final epoch = ++_epoch;
    state = state.copyWith(isLoadingMore: false, isPrefetchingReplies: false);
    bool current() => _current(epoch) && active();
    final result = await _read(
      order: order,
      authorId: authorId,
      number: number,
      postId: postId,
      active: current,
    );
    if (!current()) return null;
    _assertReplies(state.root!, result.page.items);
    final id = result.page.targetId;
    if (id == null) throw const ApiFailure(userMessage: '未找到该回复。');
    state = _withWindow(
      DiscussionWindowBuffer(result.page),
    ).copyWith(order: order, authorId: result.author);
    visibleReplyId = id;
    return (id: id, clearedAuthor: result.cleared);
  }

  Future<void> locateReply(String id) async {
    if (state.replies.any((reply) => reply.id == id)) return;
    final epoch = _epoch;
    try {
      await locate(
        postId: id,
        order: state.order,
        authorId: state.authorId,
        active: () => mounted,
      );
    } on Object catch (error) {
      if (!mounted || _epoch != epoch + 1) return;
      _pageFailure(mapApplicationFailure(error, '目标回复加载失败，请重试。'));
    }
  }

  Future<void> loadMore() => loadAdjacent();
  Future<void> prefetchRemainingReplies() => loadAdjacent();
  Future<void> loadAdjacent({bool before = false}) async {
    final window = state.window;
    final cursor = before ? window?.beforeCursor : window?.afterCursor;
    if (state.phase != PostDiscussionPhase.ready ||
        state.isRefreshing ||
        state.isPrefetchingReplies ||
        cursor == null ||
        canApplyPage?.call() == false) {
      return;
    }
    final epoch = _epoch;
    _retryBefore = before;
    state = state.copyWith(
      isLoadingMore: true,
      isPrefetchingReplies: true,
      transientFailure: null,
      retryAction: null,
    );
    try {
      DiscussionWindow<PostItem> page;
      var replace = false;
      try {
        page = (await _read(
          order: state.order,
          authorId: state.authorId,
          cursor: cursor,
        )).page;
      } on ApiFailure catch (failure) {
        if (!failure.isInvalidCursor || !_current(epoch)) rethrow;
        page = (await _read(
          order: state.order,
          authorId: state.authorId,
          postId: visibleReplyId ?? state.replies.firstOrNull?.id,
        )).page;
        replace = true;
      }
      if (!_current(epoch)) return;
      if (canApplyPage?.call() == false) {
        state = state.copyWith(
          isLoadingMore: false,
          isPrefetchingReplies: false,
        );
        return;
      }
      _assertReplies(state.root!, page.items);
      if (!replace &&
          (before ? page.beforeCursor : page.afterCursor) == cursor) {
        throw const ApiFailure(userMessage: '回复位置没有更新，请重试。');
      }
      final next = replace
          ? DiscussionWindowBuffer(page)
          : window!.extend(
              page,
              before: before,
              idOf: (item) => item.id,
              visibleId: visibleReplyId,
            );
      beforeWindowApply?.call();
      state = _withWindow(next);
    } on Object catch (error) {
      if (!_current(epoch)) return;
      final failure = mapApplicationFailure(error, '更多回复加载失败，请重试。');
      if (failure.httpStatus == 403 || failure.httpStatus == 404) {
        state = PostDiscussionState(
          phase: PostDiscussionPhase.restricted,
          failure: failure,
        );
      } else {
        _pageFailure(failure);
      }
    }
  }

  Future<void> removeDeletedReply(String id) async {
    final epoch = ++_epoch;
    final window = state.window;
    if (window != null) {
      state = _withWindow(window.removeWhere((item) => item.id == id));
    }
    if (visibleReplyId == id) visibleReplyId = state.replies.firstOrNull?.id;
    try {
      final root = await _repository.fetchPost(target.rootPostId);
      _assertRoot(root);
      if (_current(epoch)) state = state.copyWith(root: root);
    } on Object catch (error) {
      if (!_current(epoch)) return;
      final failure = mapApplicationFailure(error, '回复统计刷新失败，请重试。');
      if (_restricted(failure)) {
        state = PostDiscussionState(
          phase: PostDiscussionPhase.restricted,
          failure: failure,
        );
      } else {
        _pageFailure(failure);
      }
    }
  }

  Future<void> retryTransientFailure() =>
      state.retryAction == PostDiscussionRetryAction.refresh
      ? refresh()
      : loadAdjacent(before: _retryBefore);
  void _pageFailure(ApiFailure failure) => state = state.copyWith(
    isLoadingMore: false,
    isPrefetchingReplies: false,
    transientFailure: failure,
    retryAction: PostDiscussionRetryAction.loadMore,
  );
  bool _restricted(ApiFailure failure) =>
      failure.httpStatus == 403 || failure.httpStatus == 404;
  void _assertRoot(PostItem root) {
    if (root.isBody || root.parentPostId != null || root.isDeleted) {
      throw const ApiFailure(userMessage: '当前无法查看这组回复。', httpStatus: 404);
    }
  }

  void _assertReplies(PostItem root, List<PostItem> replies) {
    if (replies.any(
      (reply) =>
          reply.parentPostId != root.id ||
          reply.threadId != root.threadId ||
          reply.subthreadId != root.subthreadId,
    )) {
      throw const ApiFailure.invalidResponse(
        diagnosticCode: 'replies.window.scope_mismatch',
      );
    }
  }
}
