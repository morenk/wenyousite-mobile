import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/settings/domain/login_session_models.dart';

abstract interface class AccountDeletionRepository {
  Future<void> deleteAccount();
}

abstract interface class CredentialSecurityRepository {
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<void> requestEmailChangeCode({
    required String newEmail,
    required String oldPassword,
  });

  Future<void> verifyEmailChange({
    required String newEmail,
    required String code,
  });
}

abstract interface class LoginSessionRepository {
  Future<List<LoginSessionModel>> fetchSessions();

  Future<void> revokeSession(String sessionId);
}

final accountDeletionRepositoryProvider = Provider<AccountDeletionRepository>((
  ref,
) {
  return const _UnboundAccountDeletionRepository();
});

final credentialSecurityRepositoryProvider =
    Provider<CredentialSecurityRepository>((ref) {
      return const _UnboundCredentialSecurityRepository();
    });

final loginSessionRepositoryProvider = Provider<LoginSessionRepository>((ref) {
  return const _UnboundLoginSessionRepository();
});

class _UnboundAccountDeletionRepository implements AccountDeletionRepository {
  const _UnboundAccountDeletionRepository();

  @override
  Future<void> deleteAccount() {
    return Future.error(_unboundError());
  }
}

class _UnboundCredentialSecurityRepository
    implements CredentialSecurityRepository {
  const _UnboundCredentialSecurityRepository();

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return Future.error(_unboundError());
  }

  @override
  Future<void> requestEmailChangeCode({
    required String newEmail,
    required String oldPassword,
  }) {
    return Future.error(_unboundError());
  }

  @override
  Future<void> verifyEmailChange({
    required String newEmail,
    required String code,
  }) {
    return Future.error(_unboundError());
  }
}

class _UnboundLoginSessionRepository implements LoginSessionRepository {
  const _UnboundLoginSessionRepository();

  @override
  Future<List<LoginSessionModel>> fetchSessions() {
    return Future.error(_unboundError());
  }

  @override
  Future<void> revokeSession(String sessionId) {
    return Future.error(_unboundError());
  }
}

StateError _unboundError() {
  return StateError('设置仓储尚未在应用组合根绑定。');
}
