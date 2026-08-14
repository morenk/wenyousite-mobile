import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_invitation_models.dart';

abstract interface class ThreadInvitationRepository {
  Future<ThreadInvitationLink> generateLink(String threadId);

  Future<ThreadInvitationPreview> preview(String token);

  Future<ThreadInvitationJoinResult> join(String token);
}

final threadInvitationRepositoryProvider = Provider<ThreadInvitationRepository>(
  (ref) {
    return const _UnboundThreadInvitationRepository();
  },
);

class _UnboundThreadInvitationRepository implements ThreadInvitationRepository {
  const _UnboundThreadInvitationRepository();

  @override
  Future<ThreadInvitationLink> generateLink(String threadId) {
    return Future.error(_error());
  }

  @override
  Future<ThreadInvitationPreview> preview(String token) {
    return Future.error(_error());
  }

  @override
  Future<ThreadInvitationJoinResult> join(String token) {
    return Future.error(_error());
  }
}

StateError _error() => StateError('主题邀请仓储尚未在应用组合根绑定。');
