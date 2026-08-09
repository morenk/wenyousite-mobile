import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum ThreadInteractionAction { like, bookmark }

class ThreadInteractionTarget {
  const ThreadInteractionTarget({
    required this.threadId,
    required this.isLiked,
    required this.likeCount,
    required this.isBookmarked,
    this.bookmarkId,
  });

  final String threadId;
  final bool isLiked;
  final int likeCount;
  final bool isBookmarked;
  final String? bookmarkId;

  @override
  bool operator ==(Object other) {
    return other is ThreadInteractionTarget &&
        other.threadId == threadId &&
        other.isLiked == isLiked &&
        other.likeCount == likeCount &&
        other.isBookmarked == isBookmarked &&
        other.bookmarkId == bookmarkId;
  }

  @override
  int get hashCode =>
      Object.hash(threadId, isLiked, likeCount, isBookmarked, bookmarkId);
}

class ThreadInteractionState {
  const ThreadInteractionState({
    required this.isLiked,
    required this.likeCount,
    required this.isBookmarked,
    this.bookmarkId,
    this.pendingAction,
    this.failure,
    this.successMessage,
  });

  factory ThreadInteractionState.fromTarget(ThreadInteractionTarget target) {
    return ThreadInteractionState(
      isLiked: target.isLiked,
      likeCount: target.likeCount,
      isBookmarked: target.isBookmarked,
      bookmarkId: target.bookmarkId,
    );
  }

  final bool isLiked;
  final int likeCount;
  final bool isBookmarked;
  final String? bookmarkId;
  final ThreadInteractionAction? pendingAction;
  final ApiFailure? failure;
  final String? successMessage;

  bool get isPending => pendingAction != null;

  ThreadInteractionState copyWith({
    bool? isLiked,
    int? likeCount,
    bool? isBookmarked,
    Object? bookmarkId = _unset,
    ThreadInteractionAction? pendingAction,
    ApiFailure? failure,
    String? successMessage,
    bool clearPending = false,
    bool clearFeedback = false,
  }) {
    return ThreadInteractionState(
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      bookmarkId: identical(bookmarkId, _unset)
          ? this.bookmarkId
          : bookmarkId as String?,
      pendingAction: clearPending
          ? null
          : (pendingAction ?? this.pendingAction),
      failure: clearFeedback ? null : (failure ?? this.failure),
      successMessage: clearFeedback
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

const _unset = Object();
