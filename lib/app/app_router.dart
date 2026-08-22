import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_access.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/internal_location.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/app_scaffold.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/message_center_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/forgot_password_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/login_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/registration_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/reset_password_page.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_conversation_page.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/new_direct_conversation_page.dart';
import 'package:wenyousite_mobile/features/home/presentation/home_page.dart';
import 'package:wenyousite_mobile/features/moderation/presentation/moderation_appeal_page.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_page.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_page.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_feed_page.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';
import 'package:wenyousite_mobile/features/search/presentation/search_page.dart';
import 'package:wenyousite_mobile/features/search/presentation/thread_post_search_page.dart';
import 'package:wenyousite_mobile/features/settings/presentation/change_email_page.dart';
import 'package:wenyousite_mobile/features/settings/presentation/change_password_page.dart';
import 'package:wenyousite_mobile/features/settings/presentation/delete_account_page.dart';
import 'package:wenyousite_mobile/features/settings/presentation/login_sessions_page.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/bookmark_list_page.dart';
import 'package:wenyousite_mobile/features/social/presentation/user_relation_list_page.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_collection_page.dart';
import 'package:wenyousite_mobile/features/tags/presentation/tag_threads_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/subthread_editor_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_compose_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_invitation_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_management_page.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';
import 'package:wenyousite_mobile/features/users/presentation/public_user_page.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRouteLocations.home,
    redirect: (context, state) {
      return resolveSessionRedirect(
        session: ref.read(sessionControllerProvider),
        matchedLocation: state.matchedLocation,
        uri: state.uri,
      );
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.home,
                name: AppRouteNames.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.moments,
                name: AppRouteNames.moments,
                builder: (context, state) => const MomentFeedPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.notifications,
                name: AppRouteNames.notifications,
                builder: (context, state) => MessageCenterPage(
                  requestedSection: state.uri.queryParameters['section'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.me,
                name: AppRouteNames.me,
                builder: (context, state) => MePage(
                  userMomentsBuilder: (userId, additionalRefresh) =>
                      MomentFeedList(
                        target: MomentFeedTarget.user(userId),
                        emptyTitle: '还没有发布动态',
                        emptyMessage: '',
                        additionalRefresh: additionalRefresh,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRouteLocations.search,
        name: AppRouteNames.search,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: AppRouteLocations.moderationAppeals,
        name: AppRouteNames.moderationAppeals,
        builder: (context, state) => const ModerationAppealPage(),
      ),
      GoRoute(
        path: AppRoutePaths.momentBookmarks,
        name: AppRouteNames.momentBookmarks,
        builder: (context, state) => BookmarkListPage(
          initialTab: BookmarkContentTab.moments,
          momentBookmarksBuilder: () => const MomentFeedList(
            target: MomentFeedTarget.bookmarks(),
            emptyTitle: '还没有收藏动态',
            emptyMessage: '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.momentEdit,
        name: AppRouteNames.momentEdit,
        builder: (context, state) =>
            MomentComposePage(momentId: state.pathParameters['momentId']!),
      ),
      GoRoute(
        path: AppRoutePaths.momentDetail,
        name: AppRouteNames.momentDetail,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: MomentDetailPage(momentId: state.pathParameters['momentId']!),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.userMoments,
        name: AppRouteNames.userMoments,
        builder: (context, state) => MomentCollectionPage(
          target: MomentFeedTarget.user(state.pathParameters['userId']!),
          title: '用户动态',
          emptyTitle: '还没有公开动态',
          emptyMessage: '这位用户暂时没有发布公开动态。',
        ),
      ),
      GoRoute(
        path: AppRoutePaths.directMessages,
        name: AppRouteNames.directMessages,
        redirect: (context, state) => AppRouteLocations.messageCenter(
          section: MessageCenterSections.directMessages,
        ),
      ),
      GoRoute(
        path: AppRoutePaths.directMessageNew,
        name: AppRouteNames.directMessageNew,
        builder: (context, state) {
          return NewDirectConversationPage(
            userId: state.pathParameters['userId']!,
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.directConversation,
        name: AppRouteNames.directConversation,
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          return Consumer(
            builder: (_, ref, _) => DirectConversationPage(
              conversationId: conversationId,
              onReportMessage: (reportContext, messageId) =>
                  showWenyouReportFlow(
                    context: reportContext,
                    ref: ref,
                    target: ReportTarget.directMessage(messageId),
                    targetLabel: '这条私信',
                    returnTo: Uri(
                      pathSegments: ['', 'messages', conversationId],
                    ).toString(),
                  ),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.threadInvitation,
        name: AppRouteNames.threadInvitation,
        builder: (context, state) {
          return ThreadInvitationPage(token: state.pathParameters['token']!);
        },
      ),
      GoRoute(
        path: AppRoutePaths.tagThreads,
        name: AppRouteNames.tagThreads,
        builder: (context, state) {
          return TagThreadsPage(tagId: state.pathParameters['tagId']!);
        },
      ),
      GoRoute(
        path: AppRoutePaths.postReplies,
        name: AppRouteNames.postReplies,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: PostRepliesPage(
              threadId: state.pathParameters['threadId']!,
              rootPostId: state.pathParameters['postId']!,
              focusedReplyId: state.uri.queryParameters['post'],
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.threadMemberManagement,
        name: AppRouteNames.threadMemberManagement,
        builder: (context, state) {
          return ThreadManagementPage(
            threadId: state.pathParameters['threadId']!,
            initialSection: ThreadManagementSection.members,
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.threadTagManagement,
        name: AppRouteNames.threadTagManagement,
        builder: (context, state) {
          return ThreadManagementPage(
            threadId: state.pathParameters['threadId']!,
            openTagEditor: true,
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.subthreadCreate,
        name: AppRouteNames.subthreadCreate,
        builder: (context, state) =>
            SubthreadEditorPage(threadId: state.pathParameters['threadId']!),
      ),
      GoRoute(
        path: AppRoutePaths.subthreadEdit,
        name: AppRouteNames.subthreadEdit,
        builder: (context, state) => SubthreadEditorPage(
          threadId: state.pathParameters['threadId']!,
          subthreadId: state.pathParameters['subthreadId']!,
        ),
      ),
      GoRoute(
        path: AppRoutePaths.subthreadManagement,
        name: AppRouteNames.subthreadManagement,
        builder: (context, state) {
          return ThreadManagementPage(
            threadId: state.pathParameters['threadId']!,
            initialSection: ThreadManagementSection.subthreads,
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.threadManagement,
        name: AppRouteNames.threadManagement,
        builder: (context, state) {
          return ThreadManagementPage(
            threadId: state.pathParameters['threadId']!,
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.threadPostSearch,
        name: AppRouteNames.threadPostSearch,
        builder: (context, state) =>
            ThreadPostSearchPage(threadId: state.pathParameters['threadId']!),
      ),
      GoRoute(
        path: AppRoutePaths.threadDetail,
        name: AppRouteNames.threadDetail,
        pageBuilder: (context, state) {
          final extra = state.extra;
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ThreadDetailPage(
              threadId: state.pathParameters['threadId']!,
              categoryNameHint: extra is String ? extra : null,
              targetPostId: state.uri.queryParameters['post'],
              subthreadIdHint: state.uri.queryParameters['subthread'],
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.userProfile,
        name: AppRouteNames.userProfile,
        builder: (context, state) {
          return PublicUserPage(
            userId: state.pathParameters['userId']!,
            previewOnly: state.uri.queryParameters['mode'] == 'preview',
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.userFollowing,
        name: AppRouteNames.userFollowing,
        builder: (context, state) {
          return UserRelationListPage(
            target: UserRelationListTarget.public(
              kind: UserRelationListKind.following,
              userId: state.pathParameters['userId']!,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.userFollowers,
        name: AppRouteNames.userFollowers,
        builder: (context, state) {
          return UserRelationListPage(
            target: UserRelationListTarget.public(
              kind: UserRelationListKind.followers,
              userId: state.pathParameters['userId']!,
            ),
          );
        },
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
          target: UserRelationListTarget.current(
            kind: UserRelationListKind.blocks,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.meBookmarks,
        name: AppRouteNames.meBookmarks,
        builder: (context, state) => BookmarkListPage(
          momentBookmarksBuilder: () => const MomentFeedList(
            target: MomentFeedTarget.bookmarks(),
            emptyTitle: '还没有收藏动态',
            emptyMessage: '',
          ),
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
      GoRoute(
        path: AppRoutePaths.composeMoment,
        name: AppRouteNames.composeMoment,
        builder: (context, state) => const MomentComposePage(),
      ),
      GoRoute(
        path: AppRoutePaths.composeThread,
        name: AppRouteNames.composeThread,
        builder: (context, state) => const ThreadComposePage(),
      ),
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        builder: (context, state) {
          return LoginPage(
            returnTo: state.uri.queryParameters['returnTo'],
            passwordResetSucceeded: state.extra is PasswordResetLoginNotice,
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.register,
        name: AppRouteNames.register,
        builder: (context, state) {
          return RegistrationPage(
            returnTo: state.uri.queryParameters['returnTo'],
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.forgotPassword,
        name: AppRouteNames.forgotPassword,
        builder: (context, state) {
          return ForgotPasswordPage(
            returnTo: state.uri.queryParameters['returnTo'],
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.resetPassword,
        name: AppRouteNames.resetPassword,
        builder: (context, state) {
          final routeData = state.extra;
          return ResetPasswordPage(
            returnTo: state.uri.queryParameters['returnTo'],
            initialEmail: routeData is PasswordResetRouteData
                ? routeData.initialEmail
                : null,
            codeRecentlySent:
                routeData is PasswordResetRouteData &&
                routeData.codeRecentlySent,
            codeDeliveryUncertain:
                routeData is PasswordResetRouteData &&
                routeData.codeDeliveryUncertain,
            codeDeliveryRequestId: routeData is PasswordResetRouteData
                ? routeData.codeDeliveryRequestId
                : null,
          );
        },
      ),
    ],
  );
  ref.listen(sessionControllerProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});

String? resolveSessionRedirect({
  required SessionState session,
  required String matchedLocation,
  required Uri uri,
}) {
  final access = AppRouteAccessPolicy.forLocation(matchedLocation);
  final isGuestOnlyAuth = access == AppRouteAccess.guestOnly;
  if (session.status == SessionStatus.invalidated && !isGuestOnlyAuth) {
    return AppRouteLocations.login(returnTo: uri.toString());
  }
  if (!session.isAuthenticated && access == AppRouteAccess.authenticated) {
    return AppRouteLocations.login(returnTo: uri.toString());
  }
  if (session.isAuthenticated && isGuestOnlyAuth) {
    return sanitizeReturnLocation(uri.queryParameters['returnTo']);
  }
  return null;
}
