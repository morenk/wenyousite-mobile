import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/wenyou_app.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/data/meta_repository.dart';
import 'package:wenyousite_mobile/features/app_shell/data/mobile_update_service.dart';
import 'package:wenyousite_mobile/features/app_shell/data/recommended_update_dismiss_store.dart';
import 'package:wenyousite_mobile/features/auth/application/auth_ports.dart';
import 'package:wenyousite_mobile/features/auth/data/auth_repository.dart';
import 'package:wenyousite_mobile/features/auth/data/email_verification_repository.dart';
import 'package:wenyousite_mobile/features/auth/data/password_recovery_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        metaRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiMetaRepositoryProvider),
        ),
        mobileUpdateServiceProvider.overrideWith(
          (ref) => ref.watch(deviceMobileUpdateServiceProvider),
        ),
        recommendedUpdateDismissStoreProvider.overrideWith(
          (ref) =>
              ref.watch(sharedPreferencesRecommendedUpdateDismissStoreProvider),
        ),
        authRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiAuthRepositoryProvider),
        ),
        emailVerificationRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiEmailVerificationRepositoryProvider),
        ),
        passwordRecoveryRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiPasswordRecoveryRepositoryProvider),
        ),
      ],
      child: const WenyouApp(),
    ),
  );
}
