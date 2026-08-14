import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/moderation/domain/moderation_appeal_models.dart';

abstract interface class ModerationAppealRepository {
  Future<AppealCredential> issueCredential({
    required String account,
    required String password,
  });

  Future<List<ModerationDecision>> fetchMyDecisions({String? appealToken});

  Future<void> submitAppeal({
    required String decisionId,
    required String statement,
    String? appealToken,
  });
}

final moderationAppealRepositoryProvider = Provider<ModerationAppealRepository>(
  (ref) {
    return const _UnboundModerationAppealRepository();
  },
);

class _UnboundModerationAppealRepository implements ModerationAppealRepository {
  const _UnboundModerationAppealRepository();

  @override
  Future<List<ModerationDecision>> fetchMyDecisions({String? appealToken}) {
    return Future.error(_unboundError());
  }

  @override
  Future<AppealCredential> issueCredential({
    required String account,
    required String password,
  }) {
    return Future.error(_unboundError());
  }

  @override
  Future<void> submitAppeal({
    required String decisionId,
    required String statement,
    String? appealToken,
  }) {
    return Future.error(_unboundError());
  }
}

StateError _unboundError() => StateError('申诉仓储尚未在应用组合根绑定。');
