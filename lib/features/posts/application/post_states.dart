import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

enum PostDiscussionPhase { loading, ready, restricted, failed }

enum PostDiscussionRetryAction { refresh, loadMore }

const _unset = Object();

class PostDiscussionState {
  const PostDiscussionState({
    this.phase = PostDiscussionPhase.loading,
    this.root,
    this.replies = const [],
    this.cursor,
    this.hasMore = false,
    this.order = PostReplyOrder.oldest,
    this.authorId,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.isPrefetchingReplies = false,
    this.failure,
    this.transientFailure,
    this.retryAction,
  });

  final PostDiscussionPhase phase;
  final PostItem? root;
  final List<PostItem> replies;
  final String? cursor;
  final bool hasMore;
  final PostReplyOrder order;
  final String? authorId;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool isPrefetchingReplies;
  final ApiFailure? failure;
  final ApiFailure? transientFailure;
  final PostDiscussionRetryAction? retryAction;

  PostDiscussionState copyWith({
    PostDiscussionPhase? phase,
    Object? root = _unset,
    List<PostItem>? replies,
    Object? cursor = _unset,
    bool? hasMore,
    PostReplyOrder? order,
    Object? authorId = _unset,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? isPrefetchingReplies,
    Object? failure = _unset,
    Object? transientFailure = _unset,
    Object? retryAction = _unset,
  }) {
    return PostDiscussionState(
      phase: phase ?? this.phase,
      root: identical(root, _unset) ? this.root : root as PostItem?,
      replies: replies ?? this.replies,
      cursor: identical(cursor, _unset) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      order: order ?? this.order,
      authorId: identical(authorId, _unset)
          ? this.authorId
          : authorId as String?,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isPrefetchingReplies: isPrefetchingReplies ?? this.isPrefetchingReplies,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      transientFailure: identical(transientFailure, _unset)
          ? this.transientFailure
          : transientFailure as ApiFailure?,
      retryAction: identical(retryAction, _unset)
          ? this.retryAction
          : retryAction as PostDiscussionRetryAction?,
    );
  }
}

class PostComposerState {
  const PostComposerState({
    required this.content,
    this.documentRevision = 0,
    this.isSubmitting = false,
    this.failure,
    this.result,
    this.pendingCreate,
    this.conflict,
  });

  final String content;
  final int documentRevision;
  final bool isSubmitting;
  final ApiFailure? failure;
  final PostItem? result;
  final PendingPostCreate? pendingCreate;
  final PostEditConflict? conflict;

  bool get hasAmbiguousCreate => pendingCreate != null;

  PostComposerState copyWith({
    String? content,
    int? documentRevision,
    bool? isSubmitting,
    Object? failure = _unset,
    Object? result = _unset,
    Object? pendingCreate = _unset,
    Object? conflict = _unset,
  }) {
    return PostComposerState(
      content: content ?? this.content,
      documentRevision: documentRevision ?? this.documentRevision,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      result: identical(result, _unset) ? this.result : result as PostItem?,
      pendingCreate: identical(pendingCreate, _unset)
          ? this.pendingCreate
          : pendingCreate as PendingPostCreate?,
      conflict: identical(conflict, _unset)
          ? this.conflict
          : conflict as PostEditConflict?,
    );
  }
}

class PostActionState {
  const PostActionState({
    this.pendingPostId,
    this.failure,
    this.successMessage,
    this.pinRevision = 0,
  });

  final String? pendingPostId;
  final ApiFailure? failure;
  final String? successMessage;
  final int pinRevision;

  bool get isBusy => pendingPostId != null;

  PostActionState copyWith({
    Object? pendingPostId = _unset,
    Object? failure = _unset,
    Object? successMessage = _unset,
    int? pinRevision,
  }) {
    return PostActionState(
      pendingPostId: identical(pendingPostId, _unset)
          ? this.pendingPostId
          : pendingPostId as String?,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
      pinRevision: pinRevision ?? this.pinRevision,
    );
  }
}
