import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';

enum MeProfilePhase { loading, ready, failed }

enum MeProfileAction { username, settings }

class MeProfileState {
  const MeProfileState({
    this.phase = MeProfilePhase.loading,
    this.profile,
    this.failure,
    this.isRefreshing = false,
    this.refreshFailure,
    this.submitting,
    this.submissionFailure,
    this.failedAction,
    this.successMessage,
  });

  final MeProfilePhase phase;
  final MeProfileModel? profile;
  final ApiFailure? failure;
  final bool isRefreshing;
  final ApiFailure? refreshFailure;
  final MeProfileAction? submitting;
  final ApiFailure? submissionFailure;
  final MeProfileAction? failedAction;
  final String? successMessage;

  bool get isSubmitting => submitting != null;

  MeProfileState copyWith({
    MeProfilePhase? phase,
    MeProfileModel? profile,
    ApiFailure? failure,
    bool? isRefreshing,
    ApiFailure? refreshFailure,
    MeProfileAction? submitting,
    ApiFailure? submissionFailure,
    MeProfileAction? failedAction,
    String? successMessage,
    bool clearFailure = false,
    bool clearRefreshFailure = false,
    bool clearSubmission = false,
    bool clearFeedback = false,
  }) {
    return MeProfileState(
      phase: phase ?? this.phase,
      profile: profile ?? this.profile,
      failure: clearFailure ? null : (failure ?? this.failure),
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshFailure: clearRefreshFailure
          ? null
          : (refreshFailure ?? this.refreshFailure),
      submitting: clearSubmission ? null : (submitting ?? this.submitting),
      submissionFailure: clearFeedback
          ? null
          : (submissionFailure ?? this.submissionFailure),
      failedAction: clearFeedback ? null : (failedAction ?? this.failedAction),
      successMessage: clearFeedback
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

class MeProfileController extends StateNotifier<MeProfileState> {
  MeProfileController(this._repository, {bool autoStart = true})
    : super(const MeProfileState()) {
    if (autoStart) unawaited(load());
  }

  final MeProfileRepository _repository;
  int _epoch = 0;

  Future<void> load() async {
    final epoch = ++_epoch;
    state = const MeProfileState();
    try {
      final profile = await _repository.fetchMe();
      if (!_isCurrent(epoch)) return;
      state = MeProfileState(phase: MeProfilePhase.ready, profile: profile);
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return;
      state = MeProfileState(
        phase: MeProfilePhase.failed,
        failure: _asFailure(error, '本人资料加载失败，请稍后重试。'),
      );
    }
  }

  Future<void> refresh() async {
    if (state.phase != MeProfilePhase.ready || state.profile == null) {
      await load();
      return;
    }
    if (state.isRefreshing) return;
    final epoch = ++_epoch;
    state = state.copyWith(
      isRefreshing: true,
      clearFailure: true,
      clearRefreshFailure: true,
    );
    try {
      final profile = await _repository.fetchMe();
      if (!_isCurrent(epoch)) return;
      state = state.copyWith(
        phase: MeProfilePhase.ready,
        profile: profile,
        isRefreshing: false,
        clearRefreshFailure: true,
      );
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return;
      state = state.copyWith(
        isRefreshing: false,
        refreshFailure: _asFailure(error, '个人资料刷新失败，请稍后重试。'),
      );
    }
  }

  Future<bool> saveUsername(String username) async {
    final profile = state.profile;
    final next = username.trim();
    if (profile == null || state.isSubmitting) return false;
    if (next == profile.username) {
      state = MeProfileState(
        phase: MeProfilePhase.ready,
        profile: profile,
        successMessage: '用户名没有变化。',
      );
      return true;
    }
    return _submit(
      MeProfilePatch(username: next),
      MeProfileAction.username,
      '用户名已更新。',
    );
  }

  Future<bool> saveSettings({
    required String bio,
    required bool showRecentReplies,
    required bool showPlayedThreads,
    required bool showBookmarks,
  }) async {
    final profile = state.profile;
    if (profile == null || state.isSubmitting) return false;
    final nextBio = bio.trim();
    final patch = MeProfilePatch(
      bio: nextBio != (profile.bio ?? '') && nextBio.isNotEmpty
          ? nextBio
          : null,
      showRecentReplies: showRecentReplies == profile.showRecentReplies
          ? null
          : showRecentReplies,
      showPlayedThreads: showPlayedThreads == profile.showPlayedThreads
          ? null
          : showPlayedThreads,
      showBookmarks: showBookmarks == profile.showBookmarks
          ? null
          : showBookmarks,
    );
    if (patch.isEmpty) {
      state = MeProfileState(
        phase: MeProfilePhase.ready,
        profile: profile,
        successMessage: '资料设置没有变化。',
      );
      return true;
    }
    return _submit(patch, MeProfileAction.settings, '资料与隐私设置已保存。');
  }

  void clearFeedback() {
    if (state.submissionFailure == null && state.successMessage == null) return;
    state = state.copyWith(clearFeedback: true);
  }

  void applyAvatarUpdate(AvatarUpdateResult update) {
    final profile = state.profile;
    if (profile == null || state.isSubmitting) return;
    state = MeProfileState(
      phase: MeProfilePhase.ready,
      profile: profile.applyAvatar(update),
    );
  }

  void applyProfileCoverUpdate(ProfileCoverUpdateResult update) {
    final profile = state.profile;
    if (profile == null || state.isSubmitting) return;
    state = MeProfileState(
      phase: MeProfilePhase.ready,
      profile: profile.applyProfileCover(update),
    );
  }

  Future<bool> _submit(
    MeProfilePatch patch,
    MeProfileAction action,
    String successMessage,
  ) async {
    final epoch = _epoch;
    state = state.copyWith(submitting: action, clearFeedback: true);
    try {
      final update = await _repository.updateMe(patch);
      if (!_isCurrent(epoch)) return false;
      final profile = state.profile;
      if (profile == null) return false;
      state = MeProfileState(
        phase: MeProfilePhase.ready,
        profile: profile.apply(update),
        successMessage: successMessage,
      );
      return true;
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return false;
      state = MeProfileState(
        phase: MeProfilePhase.ready,
        profile: state.profile,
        submissionFailure: _asFailure(error, '资料没有保存成功，请稍后重试。'),
        failedAction: action,
      );
      return false;
    }
  }

  bool _isCurrent(int epoch) => mounted && epoch == _epoch;

  ApiFailure _asFailure(Object error, String message) {
    return mapApplicationFailure(error, message);
  }
}

final meProfileControllerProvider =
    StateNotifierProvider.autoDispose<MeProfileController, MeProfileState>((
      ref,
    ) {
      return MeProfileController(ref.watch(meProfileRepositoryProvider));
    }, dependencies: [meProfileRepositoryProvider]);
