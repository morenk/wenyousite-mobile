import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';

abstract interface class ThreadIdentityRepository {
  Future<ThreadIdentityState> mine(String threadId);
  Future<ThreadIdentityState> findUser(String threadId, String userId);
  Future<ThreadIdentityState> update(
    String threadId,
    ThreadIdentityUpdate input,
  );
  Future<ThreadIdentityState> clear(String threadId);
  Future<void> setEnabled(String threadId, {required bool enabled});
}

final threadIdentityRepositoryProvider = Provider<ThreadIdentityRepository>(
  (ref) => throw StateError('帖内身份仓储尚未在应用组合根绑定。'),
);

final myThreadIdentityProvider = FutureProvider.autoDispose
    .family<ThreadIdentityState, String>((ref, threadId) {
      ref.watch(viewerScopeProvider);
      return ref.watch(threadIdentityRepositoryProvider).mine(threadId);
    }, dependencies: [viewerScopeProvider, threadIdentityRepositoryProvider]);

typedef ThreadIdentityTarget = ({String threadId, String userId});

final threadIdentityCardProvider = FutureProvider.autoDispose
    .family<ThreadIdentityState, ThreadIdentityTarget>((ref, target) {
      ref.watch(viewerScopeProvider);
      return ref
          .watch(threadIdentityRepositoryProvider)
          .findUser(target.threadId, target.userId);
    }, dependencies: [viewerScopeProvider, threadIdentityRepositoryProvider]);

class ThreadIdentityState {
  const ThreadIdentityState({
    required this.threadId,
    required this.userId,
    required this.enabled,
    required this.eligible,
    required this.canEdit,
    required this.accountName,
    this.accountAvatarUrl,
    this.identityId,
    this.nickname,
    this.avatarMediaId,
    this.version,
    this.display,
    this.identityToken,
  });

  final String threadId;
  final String userId;
  final bool enabled;
  final bool eligible;
  final bool canEdit;
  final String accountName;
  final String? accountAvatarUrl;
  final String? identityId;
  final String? nickname;
  final String? avatarMediaId;
  final int? version;
  final RpIdentity? display;
  final String? identityToken;

  bool get hasRp => enabled && eligible && display != null;
  String get displayName => hasRp ? display!.nickname : accountName;
  String? get displayAvatarUrl => hasRp ? display!.avatarUrl : accountAvatarUrl;
}
