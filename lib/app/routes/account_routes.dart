import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/bookmark_folder_catalog_page.dart';
import 'package:wenyousite_mobile/features/moderation/presentation/moderation_appeal_page.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_bookmark_folder_page.dart';
import 'package:wenyousite_mobile/features/settings/presentation/appearance_settings_page.dart';
import 'package:wenyousite_mobile/features/settings/presentation/change_email_page.dart';
import 'package:wenyousite_mobile/features/settings/presentation/change_password_page.dart';
import 'package:wenyousite_mobile/features/settings/presentation/delete_account_page.dart';
import 'package:wenyousite_mobile/features/settings/presentation/login_sessions_page.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/bookmark_list_page.dart';
import 'package:wenyousite_mobile/features/social/presentation/user_relation_list_page.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_collection_page.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';
import 'package:wenyousite_mobile/features/users/presentation/public_user_page.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_page.dart';

List<RouteBase> buildAccountRoutes() => [
  GoRoute(
    path: AppRouteLocations.appearance,
    name: AppRouteNames.appearance,
    builder: (context, state) => const AppearanceSettingsPage(),
  ),
  GoRoute(
    path: AppRouteLocations.moderationAppeals,
    name: AppRouteNames.moderationAppeals,
    builder: (context, state) => const ModerationAppealPage(),
  ),
  GoRoute(
    path: AppRoutePaths.userProfile,
    name: AppRouteNames.userProfile,
    builder: (context, state) =>
        PublicUserPage(userId: state.pathParameters['userId']!),
  ),
  GoRoute(
    path: AppRoutePaths.userFollowing,
    name: AppRouteNames.userFollowing,
    builder: (context, state) => UserRelationListPage(
      target: UserRelationListTarget.public(
        kind: UserRelationListKind.following,
        userId: state.pathParameters['userId']!,
      ),
    ),
  ),
  GoRoute(
    path: AppRoutePaths.userFollowers,
    name: AppRouteNames.userFollowers,
    builder: (context, state) => UserRelationListPage(
      target: UserRelationListTarget.public(
        kind: UserRelationListKind.followers,
        userId: state.pathParameters['userId']!,
      ),
    ),
  ),
  GoRoute(
    path: AppRoutePaths.meEdit,
    name: AppRouteNames.meEdit,
    builder: (context, state) => const MeEditPage(),
  ),
  GoRoute(
    path: AppRoutePaths.meSettings,
    name: AppRouteNames.meSettings,
    builder: (context, state) => const MeSettingsPage(),
  ),
  GoRoute(
    path: AppRoutePaths.wallet,
    name: AppRouteNames.wallet,
    builder: (context, state) => const WalletPage(),
  ),
  GoRoute(
    path: AppRoutePaths.meFollowing,
    name: AppRouteNames.meFollowing,
    builder: (context, state) => const UserRelationListPage(
      target: UserRelationListTarget.current(
        kind: UserRelationListKind.following,
      ),
    ),
  ),
  GoRoute(
    path: AppRoutePaths.meFollowers,
    name: AppRouteNames.meFollowers,
    builder: (context, state) => const UserRelationListPage(
      target: UserRelationListTarget.current(
        kind: UserRelationListKind.followers,
      ),
    ),
  ),
  GoRoute(
    path: AppRoutePaths.meBlocks,
    name: AppRouteNames.meBlocks,
    builder: (context, state) => const UserRelationListPage(
      target: UserRelationListTarget.current(kind: UserRelationListKind.blocks),
    ),
  ),
  GoRoute(
    path: AppRoutePaths.momentBookmarks,
    redirect: (context, state) => AppRouteLocations.meBookmarkMoments,
  ),
  GoRoute(
    path: AppRoutePaths.meBookmarks,
    name: AppRouteNames.meBookmarks,
    builder: (context, state) => BookmarkFolderCatalogPage(
      initialKind: state.uri.queryParameters['kind'] == 'moment'
          ? BookmarkFolderContentKind.moment
          : BookmarkFolderContentKind.thread,
      contentBuilder: (context, kind, folder, refreshCatalog) => switch (kind) {
        BookmarkFolderContentKind.thread => BookmarkListView(
          key: ValueKey('thread-bookmarks-${folder.id}'),
          folderId: folder.id,
          additionalRefresh: refreshCatalog,
          onCatalogChanged: refreshCatalog,
        ),
        BookmarkFolderContentKind.moment => MomentBookmarkFolderPage(
          key: ValueKey('moment-bookmarks-${folder.id}'),
          folderId: folder.id,
          initialFolderName: folder.name,
          embedded: true,
        ),
      },
    ),
  ),
  GoRoute(
    path: AppRoutePaths.meBookmarkThreads,
    name: AppRouteNames.meBookmarkThreads,
    redirect: (context, state) => AppRouteLocations.meBookmarks,
  ),
  GoRoute(
    path: AppRoutePaths.meBookmarkMoments,
    name: AppRouteNames.meBookmarkMoments,
    redirect: (context, state) =>
        '${AppRouteLocations.meBookmarks}?kind=moment',
  ),
  GoRoute(
    path: AppRoutePaths.meThreadBookmarkFolder,
    name: AppRouteNames.meThreadBookmarkFolder,
    builder: (context, state) => BookmarkListPage(
      folderId: state.pathParameters['folderId']!,
      initialFolderName: state.uri.queryParameters['name'],
    ),
  ),
  GoRoute(
    path: AppRoutePaths.meMomentBookmarkFolder,
    name: AppRouteNames.meMomentBookmarkFolder,
    builder: (context, state) => MomentBookmarkFolderPage(
      folderId: state.pathParameters['folderId']!,
      initialFolderName: state.uri.queryParameters['name'],
    ),
  ),
  GoRoute(
    path: AppRoutePaths.legacyMeBookmarkFolder,
    redirect: (context, state) => AppRouteLocations.meThreadBookmarkFolder(
      state.pathParameters['folderId']!,
      name: state.uri.queryParameters['name'],
    ),
  ),
  GoRoute(
    path: AppRoutePaths.meStickers,
    name: AppRouteNames.meStickers,
    builder: (context, state) => const StickerCollectionPage(),
  ),
  GoRoute(
    path: AppRoutePaths.loginSessions,
    name: AppRouteNames.loginSessions,
    builder: (context, state) => const LoginSessionsPage(),
  ),
  GoRoute(
    path: AppRoutePaths.changePassword,
    name: AppRouteNames.changePassword,
    builder: (context, state) => const ChangePasswordPage(),
  ),
  GoRoute(
    path: AppRoutePaths.changeEmail,
    name: AppRouteNames.changeEmail,
    builder: (context, state) => const ChangeEmailPage(),
  ),
  GoRoute(
    path: AppRoutePaths.deleteAccount,
    name: AppRouteNames.deleteAccount,
    builder: (context, state) => const DeleteAccountPage(),
  ),
];
