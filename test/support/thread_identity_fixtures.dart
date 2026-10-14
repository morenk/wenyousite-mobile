import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';

/// 将既有单角色场景显式转换为新的集合，保留原权限和变更条件。
ThreadIdentityCollection identityTestCollection(ThreadIdentityState state) {
  final id = state.identityId ?? state.display?.id;
  final role = ThreadIdentityState(
    threadId: state.threadId,
    userId: state.userId,
    enabled: state.enabled,
    eligible: state.eligible,
    canEdit: state.canEdit,
    accountName: state.accountName,
    accountAvatarUrl: state.accountAvatarUrl,
    identityId: id,
    nickname: state.nickname,
    avatarMediaId: state.avatarMediaId,
    version: state.version,
    display: state.display,
    identityToken: state.identityToken,
    canDelete: id != null,
  );
  return ThreadIdentityCollection(
    account: ThreadIdentityState(
      threadId: state.threadId,
      userId: state.userId,
      enabled: state.enabled,
      eligible: state.eligible,
      canEdit: state.canEdit,
      accountName: state.accountName,
      accountAvatarUrl: state.accountAvatarUrl,
    ),
    identities: [if (id != null) role],
    compatibilityIdentityId: id,
    defaultIdentityId: role.hasRp ? id : null,
  );
}
