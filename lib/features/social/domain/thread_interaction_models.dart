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

class ThreadInteractionProjection {
  const ThreadInteractionProjection({
    required this.isLiked,
    required this.likeCount,
    required this.isBookmarked,
    this.bookmarkId,
  });

  final bool isLiked;
  final int likeCount;
  final bool isBookmarked;
  final String? bookmarkId;
}
