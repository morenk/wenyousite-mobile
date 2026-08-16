import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/core/application/profile_cache_invalidation.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/data/meta_repository.dart';
import 'package:wenyousite_mobile/features/app_shell/data/mobile_update_service.dart';
import 'package:wenyousite_mobile/features/app_shell/data/recommended_update_dismiss_store.dart';
import 'package:wenyousite_mobile/features/auth/application/auth_ports.dart';
import 'package:wenyousite_mobile/features/auth/data/auth_repository.dart';
import 'package:wenyousite_mobile/features/auth/data/password_recovery_repository.dart';
import 'package:wenyousite_mobile/features/direct_messages/data/direct_message_repository.dart';
import 'package:wenyousite_mobile/features/drafts/data/content_draft_repository.dart';
import 'package:wenyousite_mobile/features/editor/data/editor_snapshot_store.dart';
import 'package:wenyousite_mobile/features/editor/data/mention_candidate_repository.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/media/application/avatar_image_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_ports.dart';
import 'package:wenyousite_mobile/features/media/data/editor_image_picker.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/data/profile_cover_image_picker.dart';
import 'package:wenyousite_mobile/features/moderation/data/moderation_appeal_repository.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_draft_store.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_repository.dart';
import 'package:wenyousite_mobile/features/notifications/data/notification_repository.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/reports/data/report_repository.dart';
import 'package:wenyousite_mobile/features/search/data/search_repository.dart';
import 'package:wenyousite_mobile/features/settings/application/settings_repository_ports.dart';
import 'package:wenyousite_mobile/features/settings/data/account_deletion_repository.dart';
import 'package:wenyousite_mobile/features/settings/data/credential_security_repository.dart';
import 'package:wenyousite_mobile/features/settings/data/login_session_repository.dart';
import 'package:wenyousite_mobile/features/social/data/bookmark_list_repository.dart';
import 'package:wenyousite_mobile/features/social/data/thread_interaction_repository.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/social/data/user_relation_list_repository.dart';
import 'package:wenyousite_mobile/features/social/data/user_relation_repository.dart';
import 'package:wenyousite_mobile/features/stickers/data/sticker_repository.dart';
import 'package:wenyousite_mobile/features/tags/data/tag_repository.dart';
import 'package:wenyousite_mobile/features/threads/data/subthread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_compose_repository.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_invitation_repository.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_member_management_repository.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart';
import 'package:wenyousite_mobile/features/users/data/avatar_repository.dart';
import 'package:wenyousite_mobile/features/users/data/me_profile_repository.dart';
import 'package:wenyousite_mobile/features/users/data/profile_cover_repository.dart';
import 'package:wenyousite_mobile/features/users/data/public_user_repository.dart';
import 'package:wenyousite_mobile/features/wallet/data/wallet_repository.dart';

List<Override> productionProviderOverrides() => [
  metaRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiMetaRepositoryProvider),
  ),
  mobileUpdateServiceProvider.overrideWith(
    (ref) => ref.watch(deviceMobileUpdateServiceProvider),
  ),
  recommendedUpdateDismissStoreProvider.overrideWith(
    (ref) => ref.watch(sharedPreferencesRecommendedUpdateDismissStoreProvider),
  ),
  authRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiAuthRepositoryProvider),
  ),
  passwordRecoveryRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiPasswordRecoveryRepositoryProvider),
  ),
  contentDraftRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiContentDraftRepositoryProvider),
  ),
  directMessageRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiDirectMessageRepositoryProvider),
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
  profileCoverRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiProfileCoverRepositoryProvider),
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
  momentDraftStoreProvider.overrideWith(
    (ref) => ref.watch(sharedPreferencesMomentDraftStoreProvider),
  ),
  momentRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiMomentRepositoryProvider),
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
  bookmarkListRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiBookmarkListRepositoryProvider),
  ),
  threadInteractionRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiThreadInteractionRepositoryProvider),
  ),
  threadSubscriptionRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiThreadSubscriptionRepositoryProvider),
  ),
  userRelationListRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiUserRelationListRepositoryProvider),
  ),
  userRelationRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiUserRelationRepositoryProvider),
  ),
  stickerRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiStickerRepositoryProvider),
  ),
  tagRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiTagRepositoryProvider),
  ),
  subthreadManagementRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiSubthreadManagementRepositoryProvider),
  ),
  threadDetailRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiThreadDetailRepositoryProvider),
  ),
  threadInvitationRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiThreadInvitationRepositoryProvider),
  ),
  threadManagementRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiThreadManagementRepositoryProvider),
  ),
  threadMemberManagementRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiThreadMemberManagementRepositoryProvider),
  ),
  walletRepositoryProvider.overrideWith(
    (ref) => ref.watch(apiWalletRepositoryProvider),
  ),
  avatarImagePickerPortProvider.overrideWith(
    (ref) => ref.watch(avatarImagePickerProvider),
  ),
  profileCoverImagePickerPortProvider.overrideWith(
    (ref) => ref.watch(profileCoverImagePickerProvider),
  ),
  editorImagePickerPortProvider.overrideWith(
    (ref) => ref.watch(editorImagePickerProvider),
  ),
  mediaUploadGatewayPortProvider.overrideWith(
    (ref) => ref.watch(mediaUploadGatewayAdapterProvider),
  ),
  appCapabilitiesProvider.overrideWith((ref) {
    final contract = ref.watch(
      startupControllerProvider.select((state) => state.contract),
    );
    return AppCapabilities(
      stickers: contract?.stickersEnabled ?? false,
      directMessages: contract?.directMessagesEnabled ?? false,
      pushNotifications: contract?.pushNotificationsEnabled ?? false,
    );
  }),
  profileCacheInvalidatorProvider.overrideWith((ref) {
    return (userId) {
      ref.invalidate(meProfileControllerProvider);
      if (userId != null) {
        ref.invalidate(publicUserControllerProvider(userId));
      }
    };
  }),
];
