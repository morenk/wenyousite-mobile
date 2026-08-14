import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_models.dart';

class UserRelationController extends StateNotifier<UserRelationState> {
  UserRelationController(this._repository, this.target)
    : super(UserRelationState.fromTarget(target));

  final UserRelationRepository _repository;
  final UserRelationTarget target;

  Future<bool> toggleFollow() async {
    if (state.isPending) return false;
    final wasFollowing = state.isFollowing;
    state = state.copyWith(
      pendingAction: UserRelationAction.follow,
      clearFeedback: true,
    );
    try {
      if (wasFollowing) {
        await _repository.unfollow(target.userId);
      } else {
        await _repository.follow(target.userId);
      }
      if (!mounted) return false;
      final followerCount = wasFollowing
          ? (state.followerCount - 1).clamp(0, 1 << 31)
          : state.followerCount + 1;
      state = UserRelationState(
        isFollowing: !wasFollowing,
        isBlocked: state.isBlocked,
        isBlockedBy: state.isBlockedBy,
        followerCount: followerCount,
        successMessage: wasFollowing ? '已取消关注。' : '关注成功。',
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = UserRelationState(
        isFollowing: state.isFollowing,
        isBlocked: state.isBlocked,
        isBlockedBy: state.isBlockedBy,
        followerCount: state.followerCount,
        failure: _asFailure(error),
      );
      return false;
    }
  }

  Future<bool> toggleBlock() async {
    if (state.isPending) return false;
    final wasBlocked = state.isBlocked;
    state = state.copyWith(
      pendingAction: UserRelationAction.block,
      clearFeedback: true,
    );
    try {
      if (wasBlocked) {
        await _repository.unblock(target.userId);
      } else {
        await _repository.block(target.userId);
      }
      if (!mounted) return false;
      state = UserRelationState(
        isFollowing: state.isFollowing,
        isBlocked: !wasBlocked,
        isBlockedBy: state.isBlockedBy,
        followerCount: state.followerCount,
        successMessage: wasBlocked ? '已取消拉黑。' : '已拉黑该用户。',
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = UserRelationState(
        isFollowing: state.isFollowing,
        isBlocked: state.isBlocked,
        isBlockedBy: state.isBlockedBy,
        followerCount: state.followerCount,
        failure: _asFailure(error),
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

  ApiFailure _asFailure(Object error) {
    return error is ApiFailure
        ? error
        : ApiFailure(userMessage: '关系操作没有完成，请稍后重试。', cause: error);
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
