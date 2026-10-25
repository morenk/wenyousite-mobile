import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/application/cursor_page_request.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/models/paging.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

import 'moment_optimistic_actions.dart';

export 'moment_composer_controller.dart';

enum MomentLoadPhase { loading, ready, failed }

enum MomentFeedRetryAction { refresh, loadMore }

enum _MomentCommentRetryAction { detail, comments, nextPage }

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
        state.isRefreshing ||
        state.pendingMomentActions.isNotEmpty ||
        !state.hasMore) {
      return;
    }
    final epoch = _epoch;
    state = state.copyWith(isLoadingMore: true, transientFailure: null);
    await loadCursorPage(
      fetch: () => _fetch(cursor: state.cursor),
      isCurrent: () => mounted && epoch == _epoch,
      onPage: (page) {
        state = state.copyWith(
          items: mergeUniqueBy(
            state.items,
            page.items,
            keyOf: (item) => item.id,
          ),
          cursor: page.cursor,
          hasMore: page.hasMore,
          isLoadingMore: false,
        );
      },
      onInvalidCursor: () async {
        await _loadFirstPage(refreshing: state.items.isNotEmpty);
      },
      mapFailure: (error) => _asFailure(error, '加载更多动态失败，请重试。'),
      onFailure: (failure) {
        state = state.copyWith(
          isLoadingMore: false,
          transientFailure: failure,
          retryAction: MomentFeedRetryAction.loadMore,
        );
      },
    );
  }

  Future<bool> toggleLike(MomentCard card) {
    return _runAction(card, bookmark: false);
  }

  Future<bool> toggleBookmark(MomentCard card, {String? folderId}) {
    return _runAction(card, bookmark: true, folderId: folderId);
  }

  Future<bool> _runAction(
    MomentCard card, {
    required bool bookmark,
    String? folderId,
  }) async {
    if (state.pendingMomentActions.containsKey(card.id)) return false;
    final before = state.items.where((item) => item.id == card.id).firstOrNull;
    if (before == null) return false;
    if (!bookmark && !before.viewerLiked && !before.canInteract) return false;
    if (bookmark &&
        !before.viewerBookmarked &&
        (!before.canInteract || folderId == null || folderId.trim().isEmpty)) {
      state = state.copyWith(
        transientFailure: ApiFailure(
          userMessage: before.canInteract ? '请选择收藏夹。' : '这条动态暂时无法收藏。',
        ),
      );
      return false;
    }

    ++_epoch; // 旧分页/刷新不能覆盖本次点按；不同动态仍可分别提交。
    final optimistic = optimisticMomentAction(
      before,
      bookmark: bookmark,
      folderId: folderId,
    );
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == card.id) optimistic else item,
      ],
      isRefreshing: false,
      isLoadingMore: false,
      pendingMomentActions: {
        ...state.pendingMomentActions,
        card.id: bookmark
            ? MomentInteractionAction.bookmark
            : MomentInteractionAction.like,
      },
      transientFailure: null,
    );
    final outcome = await writeMomentAction(
      _repository,
      before,
      bookmark: bookmark,
      folderId: folderId,
      isCurrent: () => mounted,
    );
    if (!mounted || outcome.isDiscarded) return false;
    final confirmed = confirmedMomentAction(
      before,
      outcome,
      bookmark: bookmark,
      folderId: folderId,
    );
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == card.id)
            projectMomentAction(item, confirmed, bookmark: bookmark)
          else
            item,
      ],
      pendingMomentActions: {...state.pendingMomentActions}..remove(card.id),
      transientFailure: outcome.status == WriteOutcomeStatus.completed
          ? null
          : outcome.failure,
    );
    return outcome.status == WriteOutcomeStatus.completed;
  }

  Future<void> _loadFirstPage({required bool refreshing}) async {
    if (state.pendingMomentActions.isNotEmpty) return;
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
    .family<MomentFeedController, MomentFeedState, MomentFeedTarget>((
      ref,
      target,
    ) {
      ref.watch(viewerScopeProvider);
      return MomentFeedController(ref.watch(momentRepositoryProvider), target);
    }, dependencies: [viewerScopeProvider, momentRepositoryProvider]);

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
    this.commentPageFailure,
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
  final ApiFailure? commentPageFailure;
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
    Object? commentPageFailure = _unset,
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
      commentPageFailure: identical(commentPageFailure, _unset)
          ? this.commentPageFailure
          : commentPageFailure as ApiFailure?,
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
  var _interactionRevision = 0;

  var _commentRetryAction = _MomentCommentRetryAction.nextPage;
  var _recoveringInvalidCommentCursor = false;
  final _consumedCommentCursors = <String>{};

  Future<void> load() async {
    if (state.pendingMomentAction != null) return;
    final epoch = ++_epoch;
    _commentRetryAction = _MomentCommentRetryAction.detail;
    _recoveringInvalidCommentCursor = false;
    _consumedCommentCursors.clear();
    final interactionRevision = _interactionRevision;
    final retained = state.detail;
    state = state.copyWith(
      phase: retained == null ? MomentLoadPhase.loading : MomentLoadPhase.ready,
      isRefreshing: retained != null,
      isLoadingMoreComments: false,
      commentCursor: null,
      hasMoreComments: false,
      commentPageFailure: null,
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
      var detail = values[0] as MomentDetail;
      final currentCard = state.detail?.card;
      if (interactionRevision != _interactionRevision && currentCard != null) {
        detail = detail.copyWith(
          card: projectMomentAction(
            projectMomentAction(detail.card, currentCard, bookmark: false),
            currentCard,
            bookmark: true,
          ),
        );
      }
      final page = values[1] as CursorPage<MomentRootComment>;
      _commentRetryAction = _MomentCommentRetryAction.nextPage;
      state = state.copyWith(
        phase: MomentLoadPhase.ready,
        detail: detail,
        comments: page.items,
        commentCursor: page.cursor,
        hasMoreComments: page.hasMore,
        isRefreshing: false,
        isLoadingMoreComments: false,
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
        commentPageFailure: retained == null ? null : failure,
        transientFailure: retained == null ? null : failure,
      );
    }
  }

  Future<void> selectCommentOrder(MomentCommentOrder order) async {
    if (state.commentOrder == order) return;
    state = state.copyWith(commentOrder: order);
    await _reloadComments();
  }

  Future<void> loadMoreComments({bool retry = false}) async {
    if (state.phase != MomentLoadPhase.ready ||
        state.isRefreshing ||
        state.isLoadingMoreComments ||
        (!retry && state.commentPageFailure != null)) {
      return;
    }
    if (retry) _recoveringInvalidCommentCursor = false;
    if (_commentRetryAction != _MomentCommentRetryAction.nextPage) {
      if (retry) {
        await (_commentRetryAction == _MomentCommentRetryAction.detail
            ? load()
            : _reloadComments());
      }
      return;
    }
    if (!state.hasMoreComments) return;
    final epoch = _epoch;
    final cursor = state.commentCursor;
    state = state.copyWith(
      isLoadingMoreComments: true,
      commentPageFailure: null,
    );
    await loadCursorPage(
      fetch: () {
        if (cursor == null) {
          throw const ApiFailure(userMessage: '评论加载失败，请重试。');
        }
        return _repository.fetchComments(
          momentId: momentId,
          order: state.commentOrder,
          cursor: cursor,
        );
      },
      isCurrent: () => mounted && epoch == _epoch,
      onPage: (page) {
        // 自动分页不能反复请求不前进或循环的游标；保留原位置供明确重试。
        if (page.hasMore &&
            (page.cursor == null ||
                page.cursor == cursor ||
                _consumedCommentCursors.contains(page.cursor))) {
          throw const ApiFailure(userMessage: '评论加载失败，请重试。');
        }
        _consumedCommentCursors.add(cursor!);
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
      },
      onInvalidCursor: () async {
        if (!_recoveringInvalidCommentCursor) {
          await _reloadComments(recoveringInvalidCursor: true);
          return;
        }
        state = state.copyWith(
          isLoadingMoreComments: false,
          commentPageFailure: const ApiFailure(
            businessCode: 40007,
            userMessage: '评论加载失败，请重试。',
          ),
        );
      },
      mapFailure: (error) => _asFailure(error, '评论加载失败，请重试。'),
      onFailure: (failure) {
        state = state.copyWith(
          isLoadingMoreComments: false,
          commentPageFailure: failure,
        );
      },
    );
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
    await loadCursorPage(
      fetch: () => _repository.fetchReplies(
        momentId: momentId,
        rootCommentId: rootCommentId,
        order: MomentCommentOrder.oldest,
        cursor: loadMore ? before.cursor : null,
      ),
      isCurrent: () => mounted && epoch == _epoch,
      onPage: (page) {
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
      },
      onInvalidCursor: () async {
        final reset = {...state.replyPages}..remove(rootCommentId);
        state = state.copyWith(replyPages: Map.unmodifiable(reset));
        await loadReplies(rootCommentId);
      },
      mapFailure: (error) => _asFailure(error, '楼中楼加载失败，请重试。'),
      onFailure: (failure) {
        _setReplyFailure(rootCommentId, failure);
      },
    );
  }

  Future<bool> toggleLike() => _runMomentAction(bookmark: false);

  Future<bool> toggleBookmark({String? folderId}) =>
      _runMomentAction(bookmark: true, folderId: folderId);

  ApiFailure? get momentActionFailure => state.transientFailure;

  Future<bool> _runMomentAction({
    required bool bookmark,
    String? folderId,
  }) async {
    final detail = state.detail;
    if (detail == null || state.pendingMomentAction != null) return false;
    final card = detail.card;
    if (!bookmark && !card.viewerLiked && !card.canInteract) return false;
    if (bookmark &&
        !card.viewerBookmarked &&
        (!card.canInteract || folderId == null || folderId.trim().isEmpty)) {
      state = state.copyWith(
        transientFailure: ApiFailure(
          userMessage: card.canInteract ? '请选择收藏夹。' : '这条动态暂时无法收藏。',
        ),
      );
      return false;
    }
    ++_interactionRevision;
    state = state.copyWith(
      detail: detail.copyWith(
        card: optimisticMomentAction(
          card,
          bookmark: bookmark,
          folderId: folderId,
        ),
      ),
      isRefreshing: false,
      pendingMomentAction: bookmark
          ? MomentInteractionAction.bookmark
          : MomentInteractionAction.like,
      transientFailure: null,
    );
    final outcome = await writeMomentAction(
      _repository,
      card,
      bookmark: bookmark,
      folderId: folderId,
      isCurrent: () => mounted,
    );
    if (!mounted || outcome.isDiscarded) return false;
    final confirmed = confirmedMomentAction(
      card,
      outcome,
      bookmark: bookmark,
      folderId: folderId,
    );
    final latest = state.detail!;
    state = state.copyWith(
      detail: latest.copyWith(
        card: projectMomentAction(latest.card, confirmed, bookmark: bookmark),
      ),
      pendingMomentAction: null,
      transientFailure: outcome.status == WriteOutcomeStatus.completed
          ? null
          : outcome.failure,
    );
    return outcome.status == WriteOutcomeStatus.completed;
  }

  Future<MomentComment?> sendComment(MomentCommentInput input) async {
    if (state.isSendingComment) return null;
    if (state.detail?.card.canInteract != true) {
      state = state.copyWith(
        transientFailure: const ApiFailure(userMessage: '这条动态暂时无法评论。'),
      );
      return null;
    }
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

  Future<void> _reloadComments({bool recoveringInvalidCursor = false}) async {
    final epoch = ++_epoch;
    _commentRetryAction = _MomentCommentRetryAction.comments;
    _recoveringInvalidCommentCursor = recoveringInvalidCursor;
    _consumedCommentCursors.clear();
    state = state.copyWith(
      isRefreshing: false,
      isLoadingMoreComments: true,
      commentCursor: null,
      hasMoreComments: false,
      commentPageFailure: null,
      transientFailure: null,
    );
    try {
      final page = await _repository.fetchComments(
        momentId: momentId,
        order: state.commentOrder,
      );
      if (!mounted || epoch != _epoch) return;
      _commentRetryAction = _MomentCommentRetryAction.nextPage;
      state = state.copyWith(
        comments: page.items,
        commentCursor: page.cursor,
        hasMoreComments: page.hasMore,
        isLoadingMoreComments: false,
        replyPages: const {},
      );
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      final failure = _asFailure(error, '评论列表加载失败，请重试。');
      state = state.copyWith(
        isLoadingMoreComments: false,
        commentPageFailure: failure,
        transientFailure: failure,
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
      ref.watch(viewerScopeProvider);
      return MomentDetailController(
        ref.watch(momentRepositoryProvider),
        momentId,
      );
    }, dependencies: [viewerScopeProvider, momentRepositoryProvider]);

typedef MomentCommentContextScope = ({String momentId, String commentId});

final momentCommentContextProvider = FutureProvider.autoDispose
    .family<MomentCommentContext, MomentCommentContextScope>((ref, scope) {
      ref.watch(viewerScopeProvider);

      return ref
          .watch(momentRepositoryProvider)
          .fetchCommentContext(
            momentId: scope.momentId,
            commentId: scope.commentId,
          );
    }, dependencies: [momentRepositoryProvider, viewerScopeProvider]);
