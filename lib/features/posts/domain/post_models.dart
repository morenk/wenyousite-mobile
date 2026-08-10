import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum PostReplyOrder {
  oldest('最早回复在前', 'OLDEST'),
  newest('最新回复在前', 'NEWEST');

  const PostReplyOrder(this.label, this.apiValue);

  final String label;
  final String apiValue;
}

class PostAuthor {
  const PostAuthor({
    required this.id,
    required this.username,
    required this.level,
    this.avatarUrl,
  });

  final String id;
  final String username;
  final int level;
  final String? avatarUrl;
}

class PostDiceRoll {
  const PostDiceRoll({
    required this.nodeId,
    required this.notation,
    required this.results,
    required this.total,
  });

  final String nodeId;
  final String notation;
  final List<int> results;
  final int total;
}

class PostItem {
  const PostItem({
    required this.id,
    required this.threadId,
    required this.subthreadId,
    required this.author,
    required this.content,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.isBody,
    required this.isDeleted,
    this.floorNumber,
    this.parentPostId,
    this.replyToPostId,
    this.replyToAuthor,
    this.clientRequestId,
    this.replyCount = 0,
    this.threadTitle,
    this.subthreadTitle,
    this.diceRolls = const [],
  });

  final String id;
  final String threadId;
  final String subthreadId;
  final PostAuthor author;
  final String content;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isBody;
  final bool isDeleted;
  final int? floorNumber;
  final String? parentPostId;
  final String? replyToPostId;
  final PostAuthor? replyToAuthor;
  final String? clientRequestId;
  final int replyCount;
  final String? threadTitle;
  final String? subthreadTitle;
  final List<PostDiceRoll> diceRolls;

  bool isAuthoredBy(String? userId) => userId != null && author.id == userId;
}

class PostCreateInput {
  const PostCreateInput({
    required this.subthreadId,
    required this.content,
    required this.clientRequestId,
    this.parentPostId,
    this.replyToPostId,
  });

  final String subthreadId;
  final String content;
  final String clientRequestId;
  final String? parentPostId;
  final String? replyToPostId;
}

enum PostDiscussionPhase { loading, ready, failed }

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
    this.failure,
    this.transientFailure,
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
  final ApiFailure? failure;
  final ApiFailure? transientFailure;

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
    Object? failure = _unset,
    Object? transientFailure = _unset,
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
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      transientFailure: identical(transientFailure, _unset)
          ? this.transientFailure
          : transientFailure as ApiFailure?,
    );
  }
}

enum PostComposerKind { createFloor, createReply, editPost, upsertBody }

typedef PostComposerTarget = ({
  PostComposerKind kind,
  String threadId,
  String subthreadId,
  String? postId,
  String? parentPostId,
  String? replyToPostId,
  int? version,
  String initialContent,
  String label,
});

class PendingPostCreate {
  const PendingPostCreate({required this.input});

  final PostCreateInput input;
}

class PostEditConflict {
  const PostEditConflict({required this.latest, required this.pendingContent});

  final PostItem latest;
  final String pendingContent;
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
  });

  final String? pendingPostId;
  final ApiFailure? failure;
  final String? successMessage;

  bool get isBusy => pendingPostId != null;

  PostActionState copyWith({
    Object? pendingPostId = _unset,
    Object? failure = _unset,
    Object? successMessage = _unset,
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
    );
  }
}

typedef PostReplyPage = CursorPage<PostItem>;
