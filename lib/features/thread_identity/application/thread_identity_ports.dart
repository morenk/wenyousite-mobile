import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';

abstract interface class ThreadIdentityRepository {
  Future<ThreadIdentityCollection> list(String threadId);
  Future<ThreadIdentityState> find(String threadId, String identityId);
  Future<ThreadIdentityState> create(
    String threadId,
    ThreadIdentityUpdate input,
  );
  Future<ThreadIdentityState> updateRole(
    String threadId,
    String identityId,
    ThreadIdentityUpdate input,
  );
  Future<ThreadIdentityState> remove(
    String threadId,
    String identityId,
    int version,
  );
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
    this.deleted = false,
    this.canDelete = false,
    this.compatibilityIdentity = false,
    this.profilePostId,
    this.editableProfilePostId,
    this.profilePostStatus = IdentityProfilePostStatus.none,
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
  final bool deleted;
  final bool canDelete;
  final bool compatibilityIdentity;
  final String? profilePostId;
  final String? editableProfilePostId;
  final IdentityProfilePostStatus profilePostStatus;

  bool get hasRp => !deleted && enabled && eligible && display != null;
  String get displayName => hasRp ? display!.nickname : accountName;
  String? get displayAvatarUrl => hasRp ? display!.avatarUrl : accountAvatarUrl;
}

enum IdentityProfilePostStatus { none, available, unavailable }

class ThreadIdentityCollection {
  const ThreadIdentityCollection({
    required this.account,
    required this.identities,
    this.limit = 10,
    this.compatibilityIdentityId,
    this.defaultIdentityId,
  });
  final ThreadIdentityState account;
  final List<ThreadIdentityState> identities;
  final int limit;
  final String? compatibilityIdentityId;
  final String? defaultIdentityId;
  ThreadIdentityState? find(String? id) {
    if (id == null) return null;
    for (final value in identities) {
      if (value.identityId == id) return value;
    }
    return null;
  }
}

typedef RpIdentityTarget = ({
  String threadId,
  String userId,
  String identityId,
});
final rpIdentityCardProvider = FutureProvider.autoDispose
    .family<ThreadIdentityState, RpIdentityTarget>(
      (ref, target) async {
        ref.watch(viewerScopeProvider);
        final repo = ref.watch(threadIdentityRepositoryProvider);
        final legacy = ref
            .watch(appCapabilitiesProvider)
            .legacySingleThreadIdentity;
        final value = legacy
            ? await repo.findUser(target.threadId, target.userId)
            : await repo.find(target.threadId, target.identityId);
        if (legacy && value.identityId != target.identityId) {
          throw StateError('帖内身份不匹配。');
        }
        if (value.userId != target.userId) throw StateError('帖内身份账号不匹配。');
        return value;
      },
      dependencies: [
        viewerScopeProvider,
        threadIdentityRepositoryProvider,
        appCapabilitiesProvider,
      ],
    );
