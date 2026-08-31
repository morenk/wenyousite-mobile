import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/social_states.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_models.dart';

export 'package:wenyousite_mobile/features/social/application/social_states.dart';

class UserRelationController extends StateNotifier<UserRelationState> {
  UserRelationController(
    this._repository,
    this.target, {
    this._reconciler = const WriteReconciler(),
  }) : super(UserRelationState.fromTarget(target));

  final UserRelationRepository _repository;
  final UserRelationTarget target;
  final WriteReconciler _reconciler;
  var _actionEpoch = 0;

  Future<bool> toggleFollow() async {
    if (state.isPending) return false;
    final before = state;
    final wasFollowing = before.isFollowing;
    final epoch = ++_actionEpoch;
    state = state.copyWith(
      pendingAction: UserRelationAction.follow,
      clearFeedback: true,
    );
    return _runToggle(
      action: UserRelationAction.follow,
      before: before,
      epoch: epoch,
      write: () => wasFollowing
          ? _repository.unfollow(target.userId)
          : _repository.follow(target.userId),
      targetReached: (projection) => projection.isFollowing != wasFollowing,
      directState: () {
        final followerCount = wasFollowing
            ? (before.followerCount - 1).clamp(0, 1 << 31)
            : before.followerCount + 1;
        return UserRelationState(
          isFollowing: !wasFollowing,
          isBlocked: before.isBlocked,
          isBlockedBy: before.isBlockedBy,
          followerCount: followerCount,
          successMessage: wasFollowing ? '已取消关注。' : '关注成功。',
        );
      },
      successMessage: wasFollowing ? '已取消关注。' : '关注成功。',
    );
  }

  Future<bool> toggleBlock() async {
    if (state.isPending) return false;
    final before = state;
    final wasBlocked = before.isBlocked;
    final epoch = ++_actionEpoch;
    state = state.copyWith(
      pendingAction: UserRelationAction.block,
      clearFeedback: true,
    );
    return _runToggle(
      action: UserRelationAction.block,
      before: before,
      epoch: epoch,
      write: () => wasBlocked
          ? _repository.unblock(target.userId)
          : _repository.block(target.userId),
      targetReached: (projection) => projection.isBlocked != wasBlocked,
      directState: () => UserRelationState(
        isFollowing: before.isFollowing,
        isBlocked: !wasBlocked,
        isBlockedBy: before.isBlockedBy,
        followerCount: before.followerCount,
        successMessage: wasBlocked ? '已取消拉黑。' : '已拉黑该用户。',
      ),
      successMessage: wasBlocked ? '已取消拉黑。' : '已拉黑该用户。',
    );
  }

  Future<bool> _runToggle({
    required UserRelationAction action,
    required UserRelationState before,
    required int epoch,
    required Future<void> Function() write,
    required bool Function(UserRelationProjection projection) targetReached,
    required UserRelationState Function() directState,
    required String successMessage,
  }) async {
    final outcome = await _reconciler.run<void, UserRelationProjection>(
      write: write,
      read: _readProjection,
      targetReached: targetReached,
      failureMessage: '关系操作失败，请稍后重试。',
      isCurrent: () => mounted && epoch == _actionEpoch,
      onProgress: (progress) {
        if (!mounted || epoch != _actionEpoch) return;
        state = state.copyWith(
          pendingAction: action,
          outcomeStatus: WriteOutcomeStatus.confirming,
          outcomeRequestId: progress.requestId,
          outcomeFailure: progress.failure,
        );
      },
    );
    if (outcome.isDiscarded || !mounted || epoch != _actionEpoch) return false;
    switch (outcome.status) {
      case WriteOutcomeStatus.completed:
        state = outcome.projection == null
            ? directState()
            : _fromProjection(
                outcome.projection!,
                successMessage: successMessage,
              );
        return true;
      case WriteOutcomeStatus.failed:
        state = _fromBefore(before, failure: outcome.failure);
        return false;
      case WriteOutcomeStatus.indeterminate:
        state = outcome.projection == null
            ? _fromBefore(
                before,
                outcomeStatus: WriteOutcomeStatus.indeterminate,
                outcomeRequestId: outcome.requestId,
                outcomeFailure: outcome.failure,
              )
            : _fromProjection(
                outcome.projection!,
                outcomeStatus: WriteOutcomeStatus.indeterminate,
                outcomeRequestId: outcome.requestId,
                outcomeFailure: outcome.failure,
              );
        return false;
      case WriteOutcomeStatus.confirming:
        return false;
    }
  }

  Future<UserRelationProjection> _readProjection() {
    final repository = _repository;
    if (repository is UserRelationProjectionReader) {
      return (repository as UserRelationProjectionReader).fetchRelation(
        target.userId,
      );
    }
    return Future.error(
      const ApiFailure(userMessage: '现在无法继续关系操作。请先刷新用户资料查看是否已生效；应用不会自动重复提交。'),
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
      state = _fromBefore(
        before,
        failure: mapApplicationFailure(error, '关系状态刷新失败，请稍后重试。'),
      );
    }
  }

  UserRelationState _fromBefore(
    UserRelationState before, {
    ApiFailure? failure,
    WriteOutcomeStatus? outcomeStatus,
    String? outcomeRequestId,
    ApiFailure? outcomeFailure,
  }) {
    return UserRelationState(
      isFollowing: before.isFollowing,
      isBlocked: before.isBlocked,
      isBlockedBy: before.isBlockedBy,
      followerCount: before.followerCount,
      failure: failure,
      outcomeStatus: outcomeStatus,
      outcomeRequestId: outcomeRequestId,
      outcomeFailure: outcomeFailure,
    );
  }

  UserRelationState _fromProjection(
    UserRelationProjection projection, {
    String? successMessage,
    WriteOutcomeStatus? outcomeStatus,
    String? outcomeRequestId,
    ApiFailure? outcomeFailure,
  }) {
    return UserRelationState(
      isFollowing: projection.isFollowing,
      isBlocked: projection.isBlocked,
      isBlockedBy: projection.isBlockedBy,
      followerCount: projection.followerCount,
      successMessage: successMessage,
      outcomeStatus: outcomeStatus,
      outcomeRequestId: outcomeRequestId,
      outcomeFailure: outcomeFailure,
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
}

final userRelationControllerProvider = StateNotifierProvider.autoDispose
    .family<UserRelationController, UserRelationState, UserRelationTarget>((
      ref,
      target,
    ) {
      return UserRelationController(
        ref.watch(userRelationRepositoryProvider),
        target,
      );
    }, dependencies: [userRelationRepositoryProvider]);
