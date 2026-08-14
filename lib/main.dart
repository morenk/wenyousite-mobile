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
import 'package:wenyousite_mobile/features/drafts/data/content_draft_repository.dart';
import 'package:wenyousite_mobile/features/editor/data/editor_snapshot_store.dart';
import 'package:wenyousite_mobile/features/editor/data/mention_candidate_repository.dart';
import 'package:wenyousite_mobile/features/editor/data/thread_compose_repository.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/moderation/data/moderation_appeal_repository.dart';
import 'package:wenyousite_mobile/features/notifications/data/notification_repository.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/reports/data/report_repository.dart';
import 'package:wenyousite_mobile/features/search/data/search_repository.dart';
import 'package:wenyousite_mobile/features/settings/application/settings_repository_ports.dart';
import 'package:wenyousite_mobile/features/settings/data/account_deletion_repository.dart';
import 'package:wenyousite_mobile/features/settings/data/credential_security_repository.dart';
import 'package:wenyousite_mobile/features/settings/data/login_session_repository.dart';
import 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart';
import 'package:wenyousite_mobile/features/users/data/avatar_repository.dart';
import 'package:wenyousite_mobile/features/users/data/me_profile_repository.dart';
import 'package:wenyousite_mobile/features/users/data/public_user_repository.dart';
import 'package:wenyousite_mobile/features/wallet/data/wallet_repository.dart';

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
        contentDraftRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiContentDraftRepositoryProvider),
        ),
        editorSnapshotStoreProvider.overrideWith(
          (ref) => ref.watch(databaseEditorSnapshotStoreProvider),
        ),
        mentionCandidateRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiMentionCandidateRepositoryProvider),
        ),
        threadComposeRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiThreadComposeRepositoryProvider),
        ),
        avatarRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiAvatarRepositoryProvider),
        ),
        meProfileRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiMeProfileRepositoryProvider),
        ),
        publicUserRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiPublicUserRepositoryProvider),
        ),
        accountDeletionRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiAccountDeletionRepositoryProvider),
        ),
        credentialSecurityRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiCredentialSecurityRepositoryProvider),
        ),
        loginSessionRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiLoginSessionRepositoryProvider),
        ),
        homeRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiHomeRepositoryProvider),
        ),
        moderationAppealRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiModerationAppealRepositoryProvider),
        ),
        notificationRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiNotificationRepositoryProvider),
        ),
        postRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiPostRepositoryProvider),
        ),
        reportRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiReportRepositoryProvider),
        ),
        searchRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiSearchRepositoryProvider),
        ),
        walletRepositoryProvider.overrideWith(
          (ref) => ref.watch(apiWalletRepositoryProvider),
        ),
      ],
      child: const WenyouApp(),
    ),
  );
}
