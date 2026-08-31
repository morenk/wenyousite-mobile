import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/social_states.dart';
import 'package:wenyousite_mobile/features/social/application/thread_interaction_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_interaction_models.dart';

export 'package:wenyousite_mobile/features/social/application/social_states.dart';

class ThreadInteractionController
    extends StateNotifier<ThreadInteractionState> {
  ThreadInteractionController(
    this._repository,
    this.target, {
    this._reconciler = const WriteReconciler(),
  }) : super(ThreadInteractionState.fromTarget(target));

  final ThreadInteractionRepository _repository;
  final ThreadInteractionTarget target;
  final WriteReconciler _reconciler;
  var _actionEpoch = 0;

  String? get currentBookmarkId => state.bookmarkId;

  Future<bool> toggleLike() async {
    if (state.isPending) return false;
    final before = state;
    final wasLiked = before.isLiked;
    final epoch = ++_actionEpoch;
    state = state.copyWith(
      pendingAction: ThreadInteractionAction.like,
      clearFeedback: true,
    );
    final outcome = await _reconciler.run<int, ThreadInteractionProjection>(
      write: () => wasLiked
          ? _repository.unlike(target.threadId)
          : _repository.like(target.threadId),
      read: _readProjection,
      targetReached: (projection) => projection.isLiked != wasLiked,
      failureMessage: '点赞失败，请稍后重试。',
      isCurrent: () => mounted && epoch == _actionEpoch,
      onProgress: (progress) => _showConfirming(epoch, progress.failure),
    );
    if (outcome.isDiscarded || !mounted || epoch != _actionEpoch) return false;
    switch (outcome.status) {
      case WriteOutcomeStatus.completed:
        final projection = outcome.projection;
        state = projection == null
            ? ThreadInteractionState(
                isLiked: !wasLiked,
                likeCount: outcome.writeValue!,
                isBookmarked: before.isBookmarked,
                bookmarkId: before.bookmarkId,
                successMessage: wasLiked ? '已取消喜欢。' : '已喜欢这个主题。',
              )
            : _fromProjection(
                projection,
                successMessage: wasLiked ? '已取消喜欢。' : '已喜欢这个主题。',
              );
        return true;
      case WriteOutcomeStatus.failed:
        state = _withFailure(before, outcome.failure!);
        return false;
      case WriteOutcomeStatus.indeterminate:
        state = _withIndeterminate(before, outcome);
        return false;
      case WriteOutcomeStatus.confirming:
        return false;
    }
  }

  Future<bool> toggleBookmark({String? folderId}) async {
    if (state.isPending) return false;
    final before = state;
    final wasBookmarked = before.isBookmarked;
    final oldBookmarkId = before.bookmarkId;
    if (wasBookmarked && oldBookmarkId == null) {
      state = state.copyWith(
        failure: const ApiFailure(
          userMessage: '这条收藏暂时无法管理，请下拉刷新后重试。',
          reason: FailureReason.contractViolation,
          recoveryAction: FailureRecoveryAction.refresh,
        ),
        clearPending: true,
      );
      return false;
    }
    if (!wasBookmarked && (folderId == null || folderId.trim().isEmpty)) {
      state = state.copyWith(
        failure: const ApiFailure(userMessage: '请选择收藏夹。'),
        clearPending: true,
      );
      return false;
    }
    state = state.copyWith(
      pendingAction: ThreadInteractionAction.bookmark,
      clearFeedback: true,
    );
    final epoch = ++_actionEpoch;
    final outcome = await _reconciler.run<String?, ThreadInteractionProjection>(
      write: () async {
        if (wasBookmarked) {
          await _repository.removeBookmark(oldBookmarkId!);
          return null;
        }
        return _repository.createBookmark(target.threadId, folderId!);
      },
      read: _readProjection,
      targetReached: (projection) => wasBookmarked
          ? !projection.isBookmarked
          : projection.isBookmarked && projection.bookmarkId != null,
      failureMessage: '收藏失败，请稍后重试。',
      convergentBusinessCodes: wasBookmarked ? const {40400} : const {40900},
      isCurrent: () => mounted && epoch == _actionEpoch,
      onProgress: (progress) => _showConfirming(epoch, progress.failure),
    );
    if (outcome.isDiscarded || !mounted || epoch != _actionEpoch) return false;
    switch (outcome.status) {
      case WriteOutcomeStatus.completed:
        final projection = outcome.projection;
        state = projection == null
            ? ThreadInteractionState(
                isLiked: before.isLiked,
                likeCount: before.likeCount,
                isBookmarked: !wasBookmarked,
                bookmarkId: outcome.writeValue,
                successMessage: wasBookmarked ? '已取消收藏。' : '已收藏。',
              )
            : _fromProjection(
                projection,
                successMessage: wasBookmarked ? '已取消收藏。' : '已收藏。',
              );
        return true;
      case WriteOutcomeStatus.failed:
        state = _withFailure(before, outcome.failure!);
        return false;
      case WriteOutcomeStatus.indeterminate:
        state = _withIndeterminate(before, outcome);
        return false;
      case WriteOutcomeStatus.confirming:
        return false;
    }
  }

  Future<ThreadInteractionProjection> _readProjection() {
    final repository = _repository;
    if (repository is ThreadInteractionProjectionReader) {
      return (repository as ThreadInteractionProjectionReader).fetchInteraction(
        target.threadId,
      );
    }
    return Future.error(
      const ApiFailure(userMessage: '现在无法继续互动。请先刷新主题查看是否已生效；应用不会自动重复提交。'),
    );
  }

  Future<void> refresh() async {
    if (state.isPending) return;
    final before = state;
    final epoch = ++_actionEpoch;
    try {
      final projection = await _readProjection();
      if (!mounted || epoch != _actionEpoch) return;
      state = _fromProjection(projection);
    } on Object catch (error) {
      if (!mounted || epoch != _actionEpoch) return;
      state = _withFailure(
        before,
        mapApplicationFailure(error, '互动状态刷新失败，请稍后重试。'),
      );
    }
  }

  void _showConfirming(int epoch, ApiFailure? failure) {
    if (!mounted || epoch != _actionEpoch) return;
    state = state.copyWith(
      outcomeStatus: WriteOutcomeStatus.confirming,
      outcomeRequestId: failure?.requestId,
      outcomeFailure: failure,
    );
  }

  ThreadInteractionState _fromProjection(
    ThreadInteractionProjection projection, {
    String? successMessage,
    WriteOutcomeStatus? outcomeStatus,
    String? outcomeRequestId,
    ApiFailure? outcomeFailure,
  }) {
    return ThreadInteractionState(
      isLiked: projection.isLiked,
      likeCount: projection.likeCount,
      isBookmarked: projection.isBookmarked,
      bookmarkId: projection.bookmarkId,
      successMessage: successMessage,
      outcomeStatus: outcomeStatus,
      outcomeRequestId: outcomeRequestId,
      outcomeFailure: outcomeFailure,
    );
  }

  ThreadInteractionState _withFailure(
    ThreadInteractionState before,
    ApiFailure failure,
  ) {
    return ThreadInteractionState(
      isLiked: before.isLiked,
      likeCount: before.likeCount,
      isBookmarked: before.isBookmarked,
      bookmarkId: before.bookmarkId,
      failure: failure,
    );
  }

  ThreadInteractionState _withIndeterminate(
    ThreadInteractionState before,
    WriteOutcome<Object?, ThreadInteractionProjection> outcome,
  ) {
    final projection = outcome.projection;
    if (projection != null) {
      return _fromProjection(
        projection,
        outcomeStatus: WriteOutcomeStatus.indeterminate,
        outcomeRequestId: outcome.requestId,
        outcomeFailure: outcome.failure,
      );
    }
    return ThreadInteractionState(
      isLiked: before.isLiked,
      likeCount: before.likeCount,
      isBookmarked: before.isBookmarked,
      bookmarkId: before.bookmarkId,
      outcomeStatus: WriteOutcomeStatus.indeterminate,
      outcomeRequestId: outcome.requestId,
      outcomeFailure: outcome.failure,
    );
  }

  void clearFeedback() {
    if (state.failure == null &&
        state.successMessage == null &&
        state.outcomeStatus == null) {
      return;
    }
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

  String? takeIndeterminateNotice() {
    if (state.outcomeStatus != WriteOutcomeStatus.indeterminate) return null;
    final failure = state.outcomeFailure;
    final detail = failure == null
        ? null
        : UserFacingFailure.fromApi(failure, treatAsWrite: true).problemDetail;
    clearFeedback();
    return ['现在无法继续互动。请先刷新主题查看是否已生效；应用不会自动重复提交。', ?detail].join('\n');
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
