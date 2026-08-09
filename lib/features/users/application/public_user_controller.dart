import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/users/data/public_user_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';

enum PublicUserPhase { loading, ready, failed }

class PublicUserState {
  const PublicUserState({
    this.phase = PublicUserPhase.loading,
    this.profile,
    this.failure,
  });

  final PublicUserPhase phase;
  final PublicUserProfileModel? profile;
  final ApiFailure? failure;
}

class PublicUserController extends StateNotifier<PublicUserState> {
  PublicUserController(this._repository, this.userId)
    : super(const PublicUserState()) {
    unawaited(load());
  }

  final PublicUserRepository _repository;
  final String userId;
  int _epoch = 0;

  Future<void> load() async {
    final epoch = ++_epoch;
    state = const PublicUserState();
    try {
      final profile = await _repository.fetchUser(userId);
      if (!mounted || epoch != _epoch) return;
      state = PublicUserState(phase: PublicUserPhase.ready, profile: profile);
    } on Object catch (error) {
      if (!mounted || epoch != _epoch) return;
      state = PublicUserState(
        phase: PublicUserPhase.failed,
        failure: error is ApiFailure
            ? error
            : ApiFailure(userMessage: '用户资料没有加载完成，请稍后重试。', cause: error),
      );
    }
  }
}

final publicUserControllerProvider = StateNotifierProvider.autoDispose
    .family<PublicUserController, PublicUserState, String>((ref, userId) {
      return PublicUserController(
        ref.watch(publicUserRepositoryProvider),
        userId,
      );
    });
