import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_invitation_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_invitation_models.dart';

class ThreadInviteLinkController extends StateNotifier<ThreadInviteLinkState> {
  ThreadInviteLinkController(this._threadId, this._repository)
    : super(const ThreadInviteLinkState());

  final String _threadId;
  final ThreadInvitationRepository _repository;

  Future<ThreadInvitationLink?> generate() async {
    if (state.isGenerating) return null;
    state = state.copyWith(isGenerating: true, failure: null);
    try {
      final link = await _repository.generateLink(_threadId);
      if (!mounted) return null;
      state = ThreadInviteLinkState(link: link);
      return link;
    } on ApiFailure catch (failure) {
      if (!mounted) return null;
      state = state.copyWith(isGenerating: false, failure: failure);
      return null;
    }
  }

  void clearFailure() {
    if (!state.isGenerating) state = state.copyWith(failure: null);
  }
}

class ThreadInvitationAccessController
    extends StateNotifier<ThreadInvitationAccessState> {
  ThreadInvitationAccessController(this._token, this._repository)
    : super(const ThreadInvitationAccessState.loading()) {
    load();
  }

  final String _token;
  final ThreadInvitationRepository _repository;
  var _loadEpoch = 0;

  Future<void> load() async {
    final epoch = ++_loadEpoch;
    state = const ThreadInvitationAccessState.loading();
    try {
      final preview = await _repository.preview(_token);
      if (!mounted || epoch != _loadEpoch) return;
      state = ThreadInvitationAccessState(
        phase: ThreadInvitationAccessPhase.ready,
        preview: preview,
      );
    } on ApiFailure catch (failure) {
      if (!mounted || epoch != _loadEpoch) return;
      state = ThreadInvitationAccessState(
        phase: ThreadInvitationAccessPhase.failed,
        failure: failure,
      );
    }
  }

  Future<ThreadInvitationJoinResult?> join() async {
    final preview = state.preview;
    if (state.phase != ThreadInvitationAccessPhase.ready ||
        preview == null ||
        preview.alreadyJoined ||
        state.isJoining) {
      return null;
    }
    state = state.copyWith(isJoining: true, joinFailure: null);
    try {
      final result = await _repository.join(_token);
      if (!mounted) return null;
      if (result.threadId != preview.threadId) {
        throw const ApiFailure(userMessage: '邀请加入结果与预览主题不一致，请重新打开邀请。');
      }
      state = state.copyWith(
        preview: preview.copyWith(alreadyJoined: true),
        isJoining: false,
      );
      return result;
    } on ApiFailure catch (failure) {
      if (!mounted) return null;
      state = state.copyWith(isJoining: false, joinFailure: failure);
      return null;
    }
  }

  void clearJoinFailure() {
    if (!state.isJoining) state = state.copyWith(joinFailure: null);
  }
}

final threadInviteLinkControllerProvider = StateNotifierProvider.autoDispose
    .family<ThreadInviteLinkController, ThreadInviteLinkState, String>((
      ref,
      threadId,
    ) {
      return ThreadInviteLinkController(
        threadId,
        ref.watch(threadInvitationRepositoryProvider),
      );
    });

final threadInvitationAccessControllerProvider = StateNotifierProvider
    .autoDispose
    .family<
      ThreadInvitationAccessController,
      ThreadInvitationAccessState,
      String
    >((ref, token) {
      return ThreadInvitationAccessController(
        token,
        ref.watch(threadInvitationRepositoryProvider),
      );
    });
