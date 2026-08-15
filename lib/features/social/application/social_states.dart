import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_interaction_models.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_models.dart';

enum UserRelationAction { follow, block }

class UserRelationState {
  const UserRelationState({
    required this.isFollowing,
    required this.isBlocked,
    required this.isBlockedBy,
    required this.followerCount,
    this.pendingAction,
    this.failure,
    this.successMessage,
  });

  factory UserRelationState.fromTarget(UserRelationTarget target) {
    return UserRelationState(
      isFollowing: target.isFollowing,
      isBlocked: target.isBlocked,
      isBlockedBy: target.isBlockedBy,
      followerCount: target.followerCount,
    );
  }

  final bool isFollowing;
  final bool isBlocked;
  final bool isBlockedBy;
  final int followerCount;
  final UserRelationAction? pendingAction;
  final ApiFailure? failure;
  final String? successMessage;

  bool get isPending => pendingAction != null;

  UserRelationState copyWith({
    bool? isFollowing,
    bool? isBlocked,
    bool? isBlockedBy,
    int? followerCount,
    UserRelationAction? pendingAction,
    ApiFailure? failure,
    String? successMessage,
    bool clearPending = false,
    bool clearFeedback = false,
  }) {
    return UserRelationState(
      isFollowing: isFollowing ?? this.isFollowing,
      isBlocked: isBlocked ?? this.isBlocked,
      isBlockedBy: isBlockedBy ?? this.isBlockedBy,
      followerCount: followerCount ?? this.followerCount,
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

enum UserRelationListPhase { loading, ready, failed }

class UserRelationListState {
  const UserRelationListState({
    required this.phase,
    this.items = const [],
    this.failure,
    this.pendingUnblockUserId,
    this.actionFailure,
  });

  const UserRelationListState.loading()
    : this(phase: UserRelationListPhase.loading);

  final UserRelationListPhase phase;
  final List<UserRelationListItem> items;
  final ApiFailure? failure;
  final String? pendingUnblockUserId;
  final ApiFailure? actionFailure;

  bool get isMutating => pendingUnblockUserId != null;

  UserRelationListState copyWith({
    UserRelationListPhase? phase,
    List<UserRelationListItem>? items,
    ApiFailure? failure,
    String? pendingUnblockUserId,
    ApiFailure? actionFailure,
    bool clearPending = false,
    bool clearActionFailure = false,
  }) {
    return UserRelationListState(
      phase: phase ?? this.phase,
      items: items ?? this.items,
      failure: failure ?? this.failure,
      pendingUnblockUserId: clearPending
          ? null
          : (pendingUnblockUserId ?? this.pendingUnblockUserId),
      actionFailure: clearActionFailure
          ? null
          : (actionFailure ?? this.actionFailure),
    );
  }
}

enum ThreadInteractionAction { like, bookmark }

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

enum ThreadSubscriptionPhase { loading, ready, failed }

class ThreadSubscriptionState {
  const ThreadSubscriptionState({
    required this.phase,
    this.subscriptions = const [],
    this.candidates = const [],
    this.failure,
    this.pendingType,
    this.pendingTargetUserId,
    this.actionFailure,
    this.successMessage,
  });

  const ThreadSubscriptionState.loading()
    : this(phase: ThreadSubscriptionPhase.loading);

  final ThreadSubscriptionPhase phase;
  final List<ThreadSubscriptionRecord> subscriptions;
  final List<ThreadSubscriptionCandidate> candidates;
  final ApiFailure? failure;
  final ThreadSubscriptionType? pendingType;
  final String? pendingTargetUserId;
  final ApiFailure? actionFailure;
  final String? successMessage;

  bool get isPending => pendingType != null;

  ThreadSubscriptionRecord? get threadSubscription {
    for (final subscription in subscriptions) {
      if (subscription.type == ThreadSubscriptionType.thread) {
        return subscription;
      }
    }
    return null;
  }

  ThreadSubscriptionRecord? userSubscriptionFor(String userId) {
    for (final subscription in subscriptions) {
      if (subscription.type == ThreadSubscriptionType.user &&
          subscription.targetUserId == userId) {
        return subscription;
      }
    }
    return null;
  }

  int get userSubscriptionCount => subscriptions
      .where((item) => item.type == ThreadSubscriptionType.user)
      .length;
}

enum BookmarkListPhase { loading, ready, failed }

enum BookmarkPendingAction { move, remove }

const _unset = Object();

class BookmarkListState {
  const BookmarkListState({
    required this.phase,
    this.folders = const [],
    this.items = const [],
    this.selectedFolderId,
    this.cursor,
    this.hasMore = false,
    this.isLoadingFolders = false,
    this.isRefreshingList = false,
    this.isLoadingMore = false,
    this.isCreatingFolder = false,
    this.failure,
    this.folderFailure,
    this.loadMoreFailure,
    this.pendingBookmarkId,
    this.pendingAction,
    this.actionFailure,
  });

  const BookmarkListState.loading()
    : this(
        phase: BookmarkListPhase.loading,
        isLoadingFolders: true,
        isRefreshingList: true,
      );

  final BookmarkListPhase phase;
  final List<BookmarkFolderItem> folders;
  final List<BookmarkListItem> items;
  final String? selectedFolderId;
  final String? cursor;
  final bool hasMore;
  final bool isLoadingFolders;
  final bool isRefreshingList;
  final bool isLoadingMore;
  final bool isCreatingFolder;
  final ApiFailure? failure;
  final ApiFailure? folderFailure;
  final ApiFailure? loadMoreFailure;
  final String? pendingBookmarkId;
  final BookmarkPendingAction? pendingAction;
  final ApiFailure? actionFailure;

  bool get isMutating => pendingBookmarkId != null || isCreatingFolder;
  bool get isBusy =>
      isRefreshingList || isLoadingMore || isLoadingFolders || isMutating;
  int get totalBookmarkCount =>
      folders.fold(0, (total, folder) => total + folder.bookmarkCount);

  BookmarkFolderItem? folderById(String? id) {
    if (id == null) return null;
    for (final folder in folders) {
      if (folder.id == id) return folder;
    }
    return null;
  }

  BookmarkListState copyWith({
    BookmarkListPhase? phase,
    List<BookmarkFolderItem>? folders,
    List<BookmarkListItem>? items,
    Object? selectedFolderId = _unset,
    Object? cursor = _unset,
    bool? hasMore,
    bool? isLoadingFolders,
    bool? isRefreshingList,
    bool? isLoadingMore,
    bool? isCreatingFolder,
    Object? failure = _unset,
    Object? folderFailure = _unset,
    Object? loadMoreFailure = _unset,
    Object? pendingBookmarkId = _unset,
    Object? pendingAction = _unset,
    Object? actionFailure = _unset,
  }) {
    return BookmarkListState(
      phase: phase ?? this.phase,
      folders: folders ?? this.folders,
      items: items ?? this.items,
      selectedFolderId: identical(selectedFolderId, _unset)
          ? this.selectedFolderId
          : selectedFolderId as String?,
      cursor: identical(cursor, _unset) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isLoadingFolders: isLoadingFolders ?? this.isLoadingFolders,
      isRefreshingList: isRefreshingList ?? this.isRefreshingList,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isCreatingFolder: isCreatingFolder ?? this.isCreatingFolder,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      folderFailure: identical(folderFailure, _unset)
          ? this.folderFailure
          : folderFailure as ApiFailure?,
      loadMoreFailure: identical(loadMoreFailure, _unset)
          ? this.loadMoreFailure
          : loadMoreFailure as ApiFailure?,
      pendingBookmarkId: identical(pendingBookmarkId, _unset)
          ? this.pendingBookmarkId
          : pendingBookmarkId as String?,
      pendingAction: identical(pendingAction, _unset)
          ? this.pendingAction
          : pendingAction as BookmarkPendingAction?,
      actionFailure: identical(actionFailure, _unset)
          ? this.actionFailure
          : actionFailure as ApiFailure?,
    );
  }
}
