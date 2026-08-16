import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/social_states.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_list_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';

export 'package:wenyousite_mobile/features/social/application/social_states.dart';

class UserRelationListController extends StateNotifier<UserRelationListState> {
  UserRelationListController(
    this._listRepository,
    this._relationRepository,
    this.target,
  ) : super(const UserRelationListState.loading()) {
    load();
  }

  final UserRelationListRepository _listRepository;
  final UserRelationRepository _relationRepository;
  final UserRelationListTarget target;
  var _loadEpoch = 0;

  Future<void> load() async {
    final epoch = ++_loadEpoch;
    state = const UserRelationListState.loading();
    try {
      final items = await switch (target.kind) {
        UserRelationListKind.following => _listRepository.fetchFollowing(
          userId: target.userId,
        ),
        UserRelationListKind.followers => _listRepository.fetchFollowers(
          userId: target.userId,
        ),
        UserRelationListKind.blocks => _listRepository.fetchBlocks(),
      };
      if (!mounted || epoch != _loadEpoch) return;
      state = UserRelationListState(
        phase: UserRelationListPhase.ready,
        items: items,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _loadEpoch) return;
      state = UserRelationListState(
        phase: UserRelationListPhase.failed,
        failure: _asFailure(error, '关系列表没有加载完成，请稍后重试。'),
      );
    }
  }

  Future<bool> unblock(String userId) async {
    if (target.kind != UserRelationListKind.blocks || state.isMutating) {
      return false;
    }
    state = state.copyWith(
      pendingUnblockUserId: userId,
      clearActionFailure: true,
    );
    try {
      await _relationRepository.unblock(userId);
      if (!mounted) return false;
      state = UserRelationListState(
        phase: UserRelationListPhase.ready,
        items: state.items
            .where((item) => item.userId != userId)
            .toList(growable: false),
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        actionFailure: _asFailure(error, '取消拉黑没有完成，请稍后重试。'),
        clearPending: true,
      );
      return false;
    }
  }

  void clearActionFailure() {
    if (state.actionFailure == null) return;
    state = state.copyWith(clearActionFailure: true);
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

final userRelationListControllerProvider = StateNotifierProvider.autoDispose
    .family<
      UserRelationListController,
      UserRelationListState,
      UserRelationListTarget
    >(
      (ref, target) {
        return UserRelationListController(
          ref.watch(userRelationListRepositoryProvider),
          ref.watch(userRelationRepositoryProvider),
          target,
        );
      },
      dependencies: [
        userRelationListRepositoryProvider,
        userRelationRepositoryProvider,
      ],
    );
