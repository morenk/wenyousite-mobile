import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_access.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/internal_location.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/app_scaffold.dart';
import 'package:wenyousite_mobile/features/auth/presentation/email_verification_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/forgot_password_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/login_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/registration_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/reset_password_page.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_conversation_page.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_messages_page.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/new_direct_conversation_page.dart';
import 'package:wenyousite_mobile/features/editor/presentation/thread_compose_page.dart';
import 'package:wenyousite_mobile/features/home/presentation/home_page.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_page.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_page.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_feed_page.dart';
import 'package:wenyousite_mobile/features/notifications/presentation/notifications_page.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';
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
import 'package:wenyousite_mobile/features/tags/presentation/thread_tag_management_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/subthread_management_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_invitation_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_management_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_member_management_page.dart';
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
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/moments',
                name: 'moments',
                builder: (context, state) => const MomentFeedPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: 'search',
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                name: 'notifications',
                builder: (context, state) => const NotificationsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/me',
                name: 'me',
                builder: (context, state) => const MePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/moments/bookmarks',
        name: 'moment-bookmarks',
        builder: (context, state) => const MomentCollectionPage(
          target: MomentFeedTarget.bookmarks(),
          title: '动态收藏',
          emptyTitle: '还没有收藏动态',
          emptyMessage: '在动态列表或详情点击收藏后，会集中显示在这里。',
        ),
      ),
      GoRoute(
        path: '/moments/:momentId/edit',
        name: 'moment-edit',
        builder: (context, state) =>
            MomentComposePage(momentId: state.pathParameters['momentId']!),
      ),
      GoRoute(
        path: '/moments/:momentId',
        name: 'moment-detail',
        builder: (context, state) =>
            MomentDetailPage(momentId: state.pathParameters['momentId']!),
      ),
      GoRoute(
        path: '/users/:userId/moments',
        name: 'user-moments',
        builder: (context, state) => MomentCollectionPage(
          target: MomentFeedTarget.user(state.pathParameters['userId']!),
          title: '用户动态',
          emptyTitle: '还没有公开动态',
          emptyMessage: '这位用户暂时没有发布公开动态。',
        ),
      ),
      GoRoute(
        path: '/messages',
        name: 'direct-messages',
        builder: (context, state) => const DirectMessagesPage(),
      ),
      GoRoute(
        path: '/messages/new/:userId',
        name: 'direct-message-new',
        builder: (context, state) {
          return NewDirectConversationPage(
            userId: state.pathParameters['userId']!,
          );
        },
      ),
      GoRoute(
        path: '/messages/:conversationId',
        name: 'direct-conversation',
        builder: (context, state) {
          return DirectConversationPage(
            conversationId: state.pathParameters['conversationId']!,
          );
        },
      ),
      GoRoute(
        path: '/join/:token',
        name: 'thread-invitation',
        builder: (context, state) {
          return ThreadInvitationPage(token: state.pathParameters['token']!);
        },
      ),
      GoRoute(
        path: '/tags/:tagId',
        name: 'tag-threads',
        builder: (context, state) {
          return TagThreadsPage(tagId: state.pathParameters['tagId']!);
        },
      ),
      GoRoute(
        path: '/threads/:threadId/posts/:postId/replies',
        name: 'post-replies',
        builder: (context, state) {
          return PostRepliesPage(
            threadId: state.pathParameters['threadId']!,
            rootPostId: state.pathParameters['postId']!,
            focusedReplyId: state.uri.queryParameters['post'],
            reportsEnabled: state.uri.queryParameters['reports'] == '1',
          );
        },
      ),
      GoRoute(
        path: '/threads/:threadId/manage/members',
        name: 'thread-member-management',
        builder: (context, state) {
          return ThreadMemberManagementPage(
            threadId: state.pathParameters['threadId']!,
          );
        },
      ),
      GoRoute(
        path: '/threads/:threadId/manage/tags',
        name: 'thread-tag-management',
        builder: (context, state) {
          return ThreadTagManagementPage(
            threadId: state.pathParameters['threadId']!,
          );
        },
      ),
      GoRoute(
        path: '/threads/:threadId/manage/subthreads',
        name: 'subthread-management',
        builder: (context, state) {
          return SubthreadManagementPage(
            threadId: state.pathParameters['threadId']!,
          );
        },
      ),
      GoRoute(
        path: '/threads/:threadId/manage',
        name: 'thread-management',
        builder: (context, state) {
          return ThreadManagementPage(
            threadId: state.pathParameters['threadId']!,
          );
        },
      ),
      GoRoute(
        path: '/threads/:threadId/search',
        name: 'thread-post-search',
        builder: (context, state) =>
            ThreadPostSearchPage(threadId: state.pathParameters['threadId']!),
      ),
      GoRoute(
        path: '/threads/:threadId',
        name: 'thread-detail',
        builder: (context, state) {
          final extra = state.extra;
          return ThreadDetailPage(
            threadId: state.pathParameters['threadId']!,
            categoryNameHint: extra is String ? extra : null,
            targetPostId: state.uri.queryParameters['post'],
          );
        },
      ),
      GoRoute(
        path: '/users/:userId',
        name: 'user-profile',
        builder: (context, state) {
          return PublicUserPage(userId: state.pathParameters['userId']!);
        },
      ),
      GoRoute(
        path: '/users/:userId/following',
        name: 'user-following',
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
        path: '/users/:userId/followers',
        name: 'user-followers',
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
        path: '/me/edit',
        name: 'me-edit',
        builder: (context, state) => const MeEditPage(),
      ),
      GoRoute(
        path: '/me/settings',
        name: 'me-settings',
        builder: (context, state) => const MeSettingsPage(),
      ),
      GoRoute(
        path: '/me/wallet',
        name: 'wallet',
        builder: (context, state) => const WalletPage(),
      ),
      GoRoute(
        path: '/me/following',
        name: 'me-following',
        builder: (context, state) => const UserRelationListPage(
          target: UserRelationListTarget.current(
            kind: UserRelationListKind.following,
          ),
        ),
      ),
      GoRoute(
        path: '/me/followers',
        name: 'me-followers',
        builder: (context, state) => const UserRelationListPage(
          target: UserRelationListTarget.current(
            kind: UserRelationListKind.followers,
          ),
        ),
      ),
      GoRoute(
        path: '/me/blocks',
        name: 'me-blocks',
        builder: (context, state) => const UserRelationListPage(
          target: UserRelationListTarget.current(
            kind: UserRelationListKind.blocks,
          ),
        ),
      ),
      GoRoute(
        path: '/me/bookmarks',
        name: 'me-bookmarks',
        builder: (context, state) => const BookmarkListPage(),
      ),
      GoRoute(
        path: '/me/stickers',
        name: 'me-stickers',
        builder: (context, state) => const StickerCollectionPage(),
      ),
      GoRoute(
        path: '/me/security/sessions',
        name: 'login-sessions',
        builder: (context, state) => const LoginSessionsPage(),
      ),
      GoRoute(
        path: '/me/security/password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/me/security/email',
        name: 'change-email',
        builder: (context, state) => const ChangeEmailPage(),
      ),
      GoRoute(
        path: '/me/security/verify-email',
        name: 'verify-email',
        builder: (context, state) => EmailVerificationPage(
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
      GoRoute(
        path: '/me/security/delete-account',
        name: 'delete-account',
        builder: (context, state) => const DeleteAccountPage(),
      ),
      GoRoute(
        path: '/compose/moment',
        name: 'compose-moment',
        builder: (context, state) => const MomentComposePage(),
      ),
      GoRoute(
        path: '/compose/thread',
        name: 'compose-thread',
        builder: (context, state) => const ThreadComposePage(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) {
          return LoginPage(
            returnTo: state.uri.queryParameters['returnTo'],
            passwordResetSucceeded: state.extra is PasswordResetLoginNotice,
          );
        },
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) {
          return RegistrationPage(
            returnTo: state.uri.queryParameters['returnTo'],
          );
        },
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgot-password',
        builder: (context, state) {
          return ForgotPasswordPage(
            returnTo: state.uri.queryParameters['returnTo'],
          );
        },
      ),
      GoRoute(
        path: '/auth/reset-password',
        name: 'reset-password',
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
