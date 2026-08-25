import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/models/paging.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

export 'moment_composer_controller.dart';

enum MomentLoadPhase { loading, ready, failed }

enum MomentFeedRetryAction { refresh, loadMore }

const _unset = Object();

class MomentFeedState {
  const MomentFeedState({
    required this.target,
    this.phase = MomentLoadPhase.loading,
    this.items = const [],
    this.cursor,
    this.hasMore = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.pendingMomentActions = const {},
    this.failure,
    this.transientFailure,
    this.retryAction = MomentFeedRetryAction.refresh,
  });

  final MomentFeedTarget target;
  final MomentLoadPhase phase;
  final List<MomentCard> items;
  final String? cursor;
  final bool hasMore;
  final bool isRefreshing;
  final bool isLoadingMore;
  final Map<String, MomentInteractionAction> pendingMomentActions;
  final ApiFailure? failure;
  final ApiFailure? transientFailure;
  final MomentFeedRetryAction retryAction;

  MomentFeedState copyWith({
    MomentLoadPhase? phase,
    List<MomentCard>? items,
    Object? cursor = _unset,
    bool? hasMore,
    bool? isRefreshing,
    bool? isLoadingMore,
    Map<String, MomentInteractionAction>? pendingMomentActions,
    Object? failure = _unset,
    Object? transientFailure = _unset,
    MomentFeedRetryAction? retryAction,
  }) {
    return MomentFeedState(
      target: target,
      phase: phase ?? this.phase,
      items: items ?? this.items,
      cursor: identical(cursor, _unset) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      pendingMomentActions: pendingMomentActions ?? this.pendingMomentActions,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      transientFailure: identical(transientFailure, _unset)
          ? this.transientFailure
          : transientFailure as ApiFailure?,
      retryAction: retryAction ?? this.retryAction,
    );
  }
}

class MomentFeedController extends StateNotifier<MomentFeedState> {
  MomentFeedController(
    this._repository,
    MomentFeedTarget target, {
    bool autoStart = true,
  }) : super(MomentFeedState(target: target)) {
    if (autoStart) unawaited(loadInitial());
  }

  final MomentRepository _repository;
  var _epoch = 0;

  Future<void> loadInitial() => _loadFirstPage(refreshing: false);

  Future<void> refresh() => _loadFirstPage(refreshing: state.items.isNotEmpty);

  Future<void> loadMore() async {
    if (state.phase != MomentLoadPhase.ready ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }
    final epoch = _epoch;
    state = state.copyWith(isLoadingMore: true, transientFailure: null);
    try {
      final page = await _fetch(cursor: state.cursor);
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        items: mergeUniqueBy(state.items, page.items, keyOf: (item) => item.id),
        cursor: page.cursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } on ApiFailure catch (failure) {
      if (!mounted || epoch != _epoch) return;
      if (failure.isInvalidCursor) {
        await _loadFirstPage(refreshing: state.items.isNotEmpty);
        return;
      }
      state = state.copyWith(
        isLoadingMore: false,
        transientFailure: failure,
        retryAction: MomentFeedRetryAction.loadMore,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        isLoadingMore: false,
        transientFailure: _asFailure(error, '加载更多动态失败，请重试。'),
        retryAction: MomentFeedRetryAction.loadMore,
      );
    }
  }

  Future<bool> toggleLike(MomentCard card) {
    return _runAction(card, bookmark: false);
  }

  Future<bool> toggleBookmark(MomentCard card) {
    return _runAction(card, bookmark: true);
  }

  Future<bool> _runAction(MomentCard card, {required bool bookmark}) async {
    if (state.pendingMomentActions.containsKey(card.id)) return false;
    final action = bookmark
        ? MomentInteractionAction.bookmark
        : MomentInteractionAction.like;
    state = state.copyWith(
      pendingMomentActions: {...state.pendingMomentActions, card.id: action},
      transientFailure: null,
    );
    try {
      final result = bookmark
          ? await _repository.setBookmark(
              card.id,
              active: !card.viewerBookmarked,
            )
          : await _repository.setLike(card.id, active: !card.viewerLiked);
      if (!mounted) return false;
      final updated = state.items
          .map((item) {
            if (item.id != card.id) return item;
            return bookmark
                ? item.copyWith(
                    bookmarkCount: result.count,
                    viewerBookmarked: result.active,
                  )
                : item.copyWith(
                    likeCount: result.count,
                    viewerLiked: result.active,
                  );
          })
          .toList(growable: false);
      state = state.copyWith(
        items: List.unmodifiable(updated),
        pendingMomentActions: {...state.pendingMomentActions}..remove(card.id),
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        pendingMomentActions: {...state.pendingMomentActions}..remove(card.id),
        transientFailure: _asFailure(
          error,
          bookmark ? '收藏状态没有更新，请重试。' : '点赞状态没有更新，请重试。',
        ),
      );
      return false;
    }
  }

  Future<void> _loadFirstPage({required bool refreshing}) async {
    final epoch = ++_epoch;
    final retained = refreshing ? state.items : const <MomentCard>[];
    state = state.copyWith(
      phase: refreshing ? MomentLoadPhase.ready : MomentLoadPhase.loading,
      items: retained,
      cursor: refreshing ? state.cursor : null,
      hasMore: refreshing && state.hasMore,
      isRefreshing: refreshing,
      isLoadingMore: false,
      failure: null,
      transientFailure: null,
    );
    try {
      final page = await _fetch();
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        phase: MomentLoadPhase.ready,
        items: page.items,
        cursor: page.cursor,
        hasMore: page.hasMore,
        isRefreshing: false,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      final failure = _asFailure(error, '动态列表加载失败，请稍后重试。');
      state = state.copyWith(
        phase: retained.isEmpty
            ? MomentLoadPhase.failed
            : MomentLoadPhase.ready,
        isRefreshing: false,
        failure: retained.isEmpty ? failure : null,
        transientFailure: retained.isEmpty ? null : failure,
      );
    }
  }

  Future<CursorPage<MomentCard>> _fetch({String? cursor}) {
    return switch (state.target.kind) {
      MomentFeedKind.main => _repository.fetchFeed(
        mode: state.target.mode,
        cursor: cursor,
      ),
      MomentFeedKind.bookmarks => _repository.fetchBookmarks(cursor: cursor),
      MomentFeedKind.user => _repository.fetchUserMoments(
        userId: state.target.userId!,
        cursor: cursor,
      ),
    };
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

final momentFeedControllerProvider = StateNotifierProvider.autoDispose
    .family<MomentFeedController, MomentFeedState, MomentFeedTarget>(
      (ref, target) =>
          MomentFeedController(ref.watch(momentRepositoryProvider), target),
      dependencies: [momentRepositoryProvider],
    );

class MomentReplyPageState {
  const MomentReplyPageState({
    this.items = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoading = false,
    this.failure,
  });

  final List<MomentComment> items;
  final String? cursor;
  final bool hasMore;
  final bool isLoading;
  final ApiFailure? failure;

  MomentReplyPageState copyWith({
    List<MomentComment>? items,
    Object? cursor = _unset,
    bool? hasMore,
    bool? isLoading,
    Object? failure = _unset,
  }) {
    return MomentReplyPageState(
      items: items ?? this.items,
      cursor: identical(cursor, _unset) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
    );
  }
}

class MomentDetailState {
  const MomentDetailState({
    this.phase = MomentLoadPhase.loading,
    this.detail,
    this.comments = const [],
    this.commentOrder = MomentCommentOrder.newest,
    this.commentCursor,
    this.hasMoreComments = false,
    this.isRefreshing = false,
    this.isLoadingMoreComments = false,
    this.replyPages = const {},
    this.pendingMomentAction,
    this.busyCommentIds = const {},
    this.isSendingComment = false,
    this.failure,
    this.transientFailure,
  });

  final MomentLoadPhase phase;
  final MomentDetail? detail;
  final List<MomentRootComment> comments;
  final MomentCommentOrder commentOrder;
  final String? commentCursor;
  final bool hasMoreComments;
  final bool isRefreshing;
  final bool isLoadingMoreComments;
  final Map<String, MomentReplyPageState> replyPages;
  final MomentInteractionAction? pendingMomentAction;
  final Set<String> busyCommentIds;
  final bool isSendingComment;
  final ApiFailure? failure;
  final ApiFailure? transientFailure;

  MomentDetailState copyWith({
    MomentLoadPhase? phase,
    Object? detail = _unset,
    List<MomentRootComment>? comments,
    MomentCommentOrder? commentOrder,
    Object? commentCursor = _unset,
    bool? hasMoreComments,
    bool? isRefreshing,
    bool? isLoadingMoreComments,
    Map<String, MomentReplyPageState>? replyPages,
    Object? pendingMomentAction = _unset,
    Set<String>? busyCommentIds,
    bool? isSendingComment,
    Object? failure = _unset,
    Object? transientFailure = _unset,
  }) {
    return MomentDetailState(
      phase: phase ?? this.phase,
      detail: identical(detail, _unset) ? this.detail : detail as MomentDetail?,
      comments: comments ?? this.comments,
      commentOrder: commentOrder ?? this.commentOrder,
      commentCursor: identical(commentCursor, _unset)
          ? this.commentCursor
          : commentCursor as String?,
      hasMoreComments: hasMoreComments ?? this.hasMoreComments,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMoreComments:
          isLoadingMoreComments ?? this.isLoadingMoreComments,
      replyPages: replyPages ?? this.replyPages,
      pendingMomentAction: identical(pendingMomentAction, _unset)
          ? this.pendingMomentAction
          : pendingMomentAction as MomentInteractionAction?,
      busyCommentIds: busyCommentIds ?? this.busyCommentIds,
      isSendingComment: isSendingComment ?? this.isSendingComment,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      transientFailure: identical(transientFailure, _unset)
          ? this.transientFailure
          : transientFailure as ApiFailure?,
    );
  }
}

typedef MomentRequestIdFactory = String Function();

class MomentDetailController extends StateNotifier<MomentDetailState> {
  MomentDetailController(
    this._repository,
    this.momentId, {
    bool autoStart = true,
    MomentRequestIdFactory? requestIdFactory,
  }) : _requestIdFactory = requestIdFactory ?? const Uuid().v4,
       super(const MomentDetailState()) {
    if (autoStart) unawaited(load());
  }

  final MomentRepository _repository;
  final String momentId;
  final MomentRequestIdFactory _requestIdFactory;
  final Map<String, String> _commentRequestIds = {};
  var _epoch = 0;

  Future<void> load() async {
    final epoch = ++_epoch;
    final retained = state.detail;
    state = state.copyWith(
      phase: retained == null ? MomentLoadPhase.loading : MomentLoadPhase.ready,
      isRefreshing: retained != null,
      failure: null,
      transientFailure: null,
    );
    try {
      final values = await Future.wait<Object>([
        _repository.fetchDetail(momentId),
        _repository.fetchComments(
          momentId: momentId,
          order: state.commentOrder,
        ),
      ]);
      if (!mounted || epoch != _epoch) return;
      final detail = values[0] as MomentDetail;
      final page = values[1] as CursorPage<MomentRootComment>;
      state = state.copyWith(
        phase: MomentLoadPhase.ready,
        detail: detail,
        comments: page.items,
        commentCursor: page.cursor,
        hasMoreComments: page.hasMore,
        isRefreshing: false,
        replyPages: const {},
      );
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      final failure = _asFailure(error, '动态详情加载失败，请稍后重试。');
      state = state.copyWith(
        phase: retained == null
            ? MomentLoadPhase.failed
            : MomentLoadPhase.ready,
        isRefreshing: false,
        failure: retained == null ? failure : null,
        transientFailure: retained == null ? null : failure,
      );
    }
  }

  Future<void> selectCommentOrder(MomentCommentOrder order) async {
    if (state.commentOrder == order) return;
    state = state.copyWith(commentOrder: order);
    await _reloadComments();
  }

  Future<void> loadMoreComments() async {
    if (state.isLoadingMoreComments || !state.hasMoreComments) return;
    final epoch = _epoch;
    state = state.copyWith(isLoadingMoreComments: true, transientFailure: null);
    try {
      final page = await _repository.fetchComments(
        momentId: momentId,
        order: state.commentOrder,
        cursor: state.commentCursor,
      );
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        comments: mergeUniqueBy(
          state.comments,
          page.items,
          keyOf: (item) => item.id,
        ),
        commentCursor: page.cursor,
        hasMoreComments: page.hasMore,
        isLoadingMoreComments: false,
      );
    } on ApiFailure catch (failure) {
      if (!mounted || epoch != _epoch) return;
      if (failure.isInvalidCursor) {
        await _reloadComments();
        return;
      }
      state = state.copyWith(
        isLoadingMoreComments: false,
        transientFailure: failure,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        isLoadingMoreComments: false,
        transientFailure: _asFailure(error, '加载更多评论失败，请重试。'),
      );
    }
  }

  Future<void> loadReplies(String rootCommentId) async {
    final epoch = _epoch;
    final before = state.replyPages[rootCommentId];
    if (before?.isLoading ?? false) return;
    final loadMore = before != null && before.items.isNotEmpty;
    if (loadMore && !before.hasMore) return;
    final pages = {...state.replyPages};
    pages[rootCommentId] = (before ?? const MomentReplyPageState()).copyWith(
      isLoading: true,
      failure: null,
    );
    state = state.copyWith(replyPages: Map.unmodifiable(pages));
    try {
      final page = await _repository.fetchReplies(
        momentId: momentId,
        rootCommentId: rootCommentId,
        order: MomentCommentOrder.oldest,
        cursor: loadMore ? before.cursor : null,
      );
      if (!mounted || epoch != _epoch) return;
      final updated = {...state.replyPages};
      updated[rootCommentId] = MomentReplyPageState(
        items: mergeUniqueBy(
          loadMore ? before.items : const <MomentComment>[],
          page.items,
          keyOf: (item) => item.id,
        ),
        cursor: page.cursor,
        hasMore: page.hasMore,
      );
      state = state.copyWith(replyPages: Map.unmodifiable(updated));
    } on ApiFailure catch (failure) {
      if (!mounted || epoch != _epoch) return;
      if (failure.isInvalidCursor) {
        final reset = {...state.replyPages}..remove(rootCommentId);
        state = state.copyWith(replyPages: Map.unmodifiable(reset));
        await loadReplies(rootCommentId);
        return;
      }
      _setReplyFailure(rootCommentId, failure);
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      _setReplyFailure(rootCommentId, _asFailure(error, '楼中楼加载失败，请重试。'));
    }
  }

  Future<bool> toggleLike() => _runMomentAction(bookmark: false);

  Future<bool> toggleBookmark() => _runMomentAction(bookmark: true);

  Future<bool> _runMomentAction({required bool bookmark}) async {
    final detail = state.detail;
    if (detail == null || state.pendingMomentAction != null) return false;
    state = state.copyWith(
      pendingMomentAction: bookmark
          ? MomentInteractionAction.bookmark
          : MomentInteractionAction.like,
      transientFailure: null,
    );
    try {
      final card = detail.card;
      final result = bookmark
          ? await _repository.setBookmark(
              momentId,
              active: !card.viewerBookmarked,
            )
          : await _repository.setLike(momentId, active: !card.viewerLiked);
      if (!mounted) return false;
      final updatedCard = bookmark
          ? card.copyWith(
              bookmarkCount: result.count,
              viewerBookmarked: result.active,
            )
          : card.copyWith(likeCount: result.count, viewerLiked: result.active);
      state = state.copyWith(
        detail: detail.copyWith(card: updatedCard),
        pendingMomentAction: null,
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        pendingMomentAction: null,
        transientFailure: _asFailure(
          error,
          bookmark ? '收藏状态没有更新，请重试。' : '点赞状态没有更新，请重试。',
        ),
      );
      return false;
    }
  }

  Future<MomentComment?> sendComment(MomentCommentInput input) async {
    if (state.isSendingComment) return null;
    MomentCommentInput normalized;
    try {
      normalized = input.normalized();
    } on Object catch (error) {
      state = state.copyWith(
        transientFailure: _asFailure(error, '评论内容无效，请检查后重试。'),
      );
      return null;
    }
    final key = normalized.requestKey;
    final requestId = _commentRequestIds.putIfAbsent(key, _requestIdFactory);
    state = state.copyWith(isSendingComment: true, transientFailure: null);
    try {
      final created = await _repository.createComment(
        momentId,
        normalized,
        clientRequestId: requestId,
      );
      if (!mounted) return null;
      _commentRequestIds.remove(key);
      final detail = state.detail;
      state = state.copyWith(
        isSendingComment: false,
        detail: detail?.copyWith(
          card: detail.card.copyWith(
            commentCount: detail.card.commentCount + 1,
          ),
        ),
      );
      await _reloadComments();
      return created;
    } on Object catch (error) {
      if (!mounted) return null;
      state = state.copyWith(
        isSendingComment: false,
        transientFailure: _asFailure(error, '评论没有发布成功，请使用原内容重试。'),
      );
      return null;
    }
  }

  Future<bool> removeComment(String commentId) async {
    if (state.busyCommentIds.contains(commentId)) return false;
    state = state.copyWith(
      busyCommentIds: {...state.busyCommentIds, commentId},
      transientFailure: null,
    );
    try {
      await _repository.removeComment(momentId, commentId);
      if (!mounted) return false;
      state = state.copyWith(
        busyCommentIds: {...state.busyCommentIds}..remove(commentId),
      );
      await load();
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        busyCommentIds: {...state.busyCommentIds}..remove(commentId),
        transientFailure: _asFailure(error, '评论没有删除成功，请重试。'),
      );
      return false;
    }
  }

  Future<void> _reloadComments() async {
    final epoch = ++_epoch;
    state = state.copyWith(isLoadingMoreComments: true, transientFailure: null);
    try {
      final page = await _repository.fetchComments(
        momentId: momentId,
        order: state.commentOrder,
      );
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        comments: page.items,
        commentCursor: page.cursor,
        hasMoreComments: page.hasMore,
        isLoadingMoreComments: false,
        replyPages: const {},
      );
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = state.copyWith(
        isLoadingMoreComments: false,
        transientFailure: _asFailure(error, '评论列表加载失败，请重试。'),
      );
    }
  }

  void _setReplyFailure(String rootCommentId, ApiFailure failure) {
    final pages = {...state.replyPages};
    pages[rootCommentId] =
        (pages[rootCommentId] ?? const MomentReplyPageState()).copyWith(
          isLoading: false,
          failure: failure,
        );
    state = state.copyWith(replyPages: Map.unmodifiable(pages));
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

final momentDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<MomentDetailController, MomentDetailState, String>((ref, momentId) {
      return MomentDetailController(
        ref.watch(momentRepositoryProvider),
        momentId,
      );
    }, dependencies: [momentRepositoryProvider]);

typedef MomentCommentContextScope = ({String momentId, String commentId});

final momentCommentContextProvider = FutureProvider.autoDispose
    .family<MomentCommentContext, MomentCommentContextScope>((ref, scope) {
      ref.watch(sessionScopeProvider);
      return ref
          .watch(momentRepositoryProvider)
          .fetchCommentContext(
            momentId: scope.momentId,
            commentId: scope.commentId,
          );
    }, dependencies: [momentRepositoryProvider, sessionScopeProvider]);
