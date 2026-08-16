import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/social_states.dart';
import 'package:wenyousite_mobile/features/social/application/thread_interaction_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_interaction_models.dart';

export 'package:wenyousite_mobile/features/social/application/social_states.dart';

class ThreadInteractionController
    extends StateNotifier<ThreadInteractionState> {
  ThreadInteractionController(this._repository, this.target)
    : super(ThreadInteractionState.fromTarget(target));

  final ThreadInteractionRepository _repository;
  final ThreadInteractionTarget target;

  Future<bool> toggleLike() async {
    if (state.isPending) return false;
    final wasLiked = state.isLiked;
    state = state.copyWith(
      pendingAction: ThreadInteractionAction.like,
      clearFeedback: true,
    );
    try {
      final likeCount = wasLiked
          ? await _repository.unlike(target.threadId)
          : await _repository.like(target.threadId);
      if (!mounted) return false;
      state = ThreadInteractionState(
        isLiked: !wasLiked,
        likeCount: likeCount,
        isBookmarked: state.isBookmarked,
        bookmarkId: state.bookmarkId,
        successMessage: wasLiked ? '已取消喜欢。' : '已喜欢这个主题。',
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = ThreadInteractionState(
        isLiked: state.isLiked,
        likeCount: state.likeCount,
        isBookmarked: state.isBookmarked,
        bookmarkId: state.bookmarkId,
        failure: _asFailure(error, '点赞操作没有完成，请稍后重试。'),
      );
      return false;
    }
  }

  Future<bool> toggleBookmark() async {
    if (state.isPending) return false;
    final wasBookmarked = state.isBookmarked;
    final oldBookmarkId = state.bookmarkId;
    if (wasBookmarked && oldBookmarkId == null) {
      state = state.copyWith(
        failure: const ApiFailure(userMessage: '收藏状态缺少记录 ID，请下拉刷新后重试。'),
        clearPending: true,
      );
      return false;
    }
    state = state.copyWith(
      pendingAction: ThreadInteractionAction.bookmark,
      clearFeedback: true,
    );
    try {
      final String? bookmarkId;
      if (wasBookmarked) {
        await _repository.removeBookmark(oldBookmarkId!);
        bookmarkId = null;
      } else {
        bookmarkId = await _repository.createBookmark(target.threadId);
      }
      if (!mounted) return false;
      state = ThreadInteractionState(
        isLiked: state.isLiked,
        likeCount: state.likeCount,
        isBookmarked: !wasBookmarked,
        bookmarkId: bookmarkId,
        successMessage: wasBookmarked ? '已取消收藏。' : '已收藏这个主题。',
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = ThreadInteractionState(
        isLiked: state.isLiked,
        likeCount: state.likeCount,
        isBookmarked: state.isBookmarked,
        bookmarkId: state.bookmarkId,
        failure: _asFailure(error, '收藏操作没有完成，请稍后重试。'),
      );
      return false;
    }
  }

  void clearFeedback() {
    if (state.failure == null && state.successMessage == null) return;
    state = state.copyWith(clearFeedback: true);
  }

  String? takeSuccessMessage() {
    final message = state.successMessage;
    if (message != null) clearFeedback();
    return message;
  }

  ApiFailure? takeFailure() {
    final failure = state.failure;
    if (failure != null) clearFeedback();
    return failure;
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

final threadInteractionControllerProvider = StateNotifierProvider.autoDispose
    .family<
      ThreadInteractionController,
      ThreadInteractionState,
      ThreadInteractionTarget
    >((ref, target) {
      return ThreadInteractionController(
        ref.watch(threadInteractionRepositoryProvider),
        target,
      );
    }, dependencies: [threadInteractionRepositoryProvider]);
