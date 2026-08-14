import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';

class RegistrationCodeInfo {
  const RegistrationCodeInfo({required this.expiresIn});

  final Duration expiresIn;
}

abstract interface class AuthRepository {
  Future<SessionTokens> login({
    required String account,
    required String password,
  });

  Future<RegistrationCodeInfo> requestRegistrationCode({required String email});

  Future<SessionTokens> completeRegistration({
    required String email,
    required String code,
    required String username,
    required String password,
  });
}

class EmailVerificationAccount {
  const EmailVerificationAccount({
    required this.email,
    required this.isVerified,
  });

  final String email;
  final bool isVerified;
}

abstract interface class EmailVerificationRepository {
  Future<EmailVerificationAccount> fetchAccount();

  Future<void> resendCode({required String email});

  Future<void> verifyCode({required String code});
}

abstract interface class PasswordRecoveryRepository {
  Future<void> requestCode({required String email});

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return const _UnboundAuthRepository();
});

final emailVerificationRepositoryProvider =
    Provider<EmailVerificationRepository>((ref) {
      return const _UnboundEmailVerificationRepository();
    });

final passwordRecoveryRepositoryProvider = Provider<PasswordRecoveryRepository>(
  (ref) {
    return const _UnboundPasswordRecoveryRepository();
  },
);

class _UnboundAuthRepository implements AuthRepository {
  const _UnboundAuthRepository();

  @override
  Future<SessionTokens> completeRegistration({
    required String email,
    required String code,
    required String username,
    required String password,
  }) {
    return Future.error(_unboundError());
  }

  @override
  Future<SessionTokens> login({
    required String account,
    required String password,
  }) {
    return Future.error(_unboundError());
  }

  @override
  Future<RegistrationCodeInfo> requestRegistrationCode({
    required String email,
  }) {
    return Future.error(_unboundError());
  }
}

class _UnboundEmailVerificationRepository
    implements EmailVerificationRepository {
  const _UnboundEmailVerificationRepository();

  @override
  Future<EmailVerificationAccount> fetchAccount() {
    return Future.error(_unboundError());
  }

  @override
  Future<void> resendCode({required String email}) {
    return Future.error(_unboundError());
  }

  @override
  Future<void> verifyCode({required String code}) {
    return Future.error(_unboundError());
  }
}

class _UnboundPasswordRecoveryRepository implements PasswordRecoveryRepository {
  const _UnboundPasswordRecoveryRepository();

  @override
  Future<void> requestCode({required String email}) {
    return Future.error(_unboundError());
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return Future.error(_unboundError());
  }
}

StateError _unboundError() {
  return StateError('认证仓储尚未在应用组合根绑定。');
}
