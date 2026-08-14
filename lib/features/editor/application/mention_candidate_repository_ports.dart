import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/editor/domain/mention_models.dart';

abstract interface class MentionCandidateRepository {
  Future<MentionCandidatesResult> findCandidates({
    required String threadId,
    required String query,
  });
}

final mentionCandidateRepositoryProvider = Provider<MentionCandidateRepository>(
  (ref) => const _UnboundMentionCandidateRepository(),
);

class _UnboundMentionCandidateRepository implements MentionCandidateRepository {
  const _UnboundMentionCandidateRepository();

  @override
  Future<MentionCandidatesResult> findCandidates({
    required String threadId,
    required String query,
  }) {
    return Future.error(StateError('提及候选仓储尚未在应用组合根绑定。'));
  }
}
