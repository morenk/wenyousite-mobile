import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/editor/application/mention_candidate_repository_ports.dart';
import 'package:wenyousite_mobile/features/editor/domain/mention_models.dart';

enum MentionCandidatesPhase { idle, loading, ready, failed }

class MentionCandidatesState {
  const MentionCandidatesState({
    this.phase = MentionCandidatesPhase.idle,
    this.query = '',
    this.result = const MentionCandidatesResult.empty(),
    this.failure,
  });

  final MentionCandidatesPhase phase;
  final String query;
  final MentionCandidatesResult result;
  final ApiFailure? failure;
}

class MentionCandidatesController
    extends StateNotifier<MentionCandidatesState> {
  MentionCandidatesController(this._repository, this._threadId)
    : super(const MentionCandidatesState());

  final MentionCandidateRepository _repository;
  final String _threadId;
  int _generation = 0;

  Future<void> search(String query, {bool force = false}) async {
    if (!force &&
        state.phase == MentionCandidatesPhase.ready &&
        state.query == query) {
      return;
    }
    final generation = ++_generation;
    state = MentionCandidatesState(
      phase: MentionCandidatesPhase.loading,
      query: query,
    );
    try {
      final result = await _repository.findCandidates(
        threadId: _threadId,
        query: query,
      );
      if (!mounted || generation != _generation) return;
      state = MentionCandidatesState(
        phase: MentionCandidatesPhase.ready,
        query: query,
        result: result,
      );
    } on Object catch (error) {
      if (!mounted || generation != _generation) return;
      state = MentionCandidatesState(
        phase: MentionCandidatesPhase.failed,
        query: query,
        failure: error is ApiFailure
            ? error
            : ApiFailure(userMessage: '可提及用户没有加载成功，请重试。', cause: error),
      );
    }
  }

  void clear() {
    _generation += 1;
    state = const MentionCandidatesState();
  }

  Future<void> retry() => search(state.query, force: true);
}

final mentionCandidatesControllerProvider = StateNotifierProvider.autoDispose
    .family<MentionCandidatesController, MentionCandidatesState, String>(
      (ref, threadId) => MentionCandidatesController(
        ref.watch(mentionCandidateRepositoryProvider),
        threadId,
      ),
      dependencies: [mentionCandidateRepositoryProvider],
    );
