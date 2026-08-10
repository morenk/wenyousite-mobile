import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/internal_location.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/app_scaffold.dart';
import 'package:wenyousite_mobile/features/auth/presentation/email_verification_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/forgot_password_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/login_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/registration_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/reset_password_page.dart';
import 'package:wenyousite_mobile/features/editor/presentation/thread_compose_page.dart';
import 'package:wenyousite_mobile/features/home/presentation/home_page.dart';
import 'package:wenyousite_mobile/features/notifications/presentation/notifications_page.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';
import 'package:wenyousite_mobile/features/search/presentation/search_page.dart';
import 'package:wenyousite_mobile/features/settings/presentation/change_email_page.dart';
import 'package:wenyousite_mobile/features/settings/presentation/change_password_page.dart';
import 'package:wenyousite_mobile/features/settings/presentation/login_sessions_page.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/bookmark_list_page.dart';
import 'package:wenyousite_mobile/features/social/presentation/user_relation_list_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';
import 'package:wenyousite_mobile/features/users/presentation/public_user_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/home',
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
        path: '/threads/:threadId/posts/:postId/replies',
        name: 'post-replies',
        builder: (context, state) {
          return PostRepliesPage(
            threadId: state.pathParameters['threadId']!,
            rootPostId: state.pathParameters['postId']!,
            focusedReplyId: state.uri.queryParameters['post'],
          );
        },
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
  final isGuestOnlyAuth = switch (matchedLocation) {
    '/auth/login' ||
    '/auth/register' ||
    '/auth/forgot-password' ||
    '/auth/reset-password' => true,
    _ => false,
  };
  if (session.status == SessionStatus.invalidated && !isGuestOnlyAuth) {
    return Uri(
      path: '/auth/login',
      queryParameters: {'returnTo': uri.toString()},
    ).toString();
  }
  final protectedRoute = switch (matchedLocation) {
    '/compose/thread' ||
    '/me/following' ||
    '/me/followers' ||
    '/me/blocks' ||
    '/me/bookmarks' ||
    '/me/security/sessions' ||
    '/me/security/password' ||
    '/me/security/email' ||
    '/me/security/verify-email' => true,
    _ => false,
  };
  if (!session.isAuthenticated && protectedRoute) {
    return Uri(
      path: '/auth/login',
      queryParameters: {'returnTo': uri.toString()},
    ).toString();
  }
  if (session.isAuthenticated && isGuestOnlyAuth) {
    return sanitizeReturnLocation(uri.queryParameters['returnTo']);
  }
  return null;
}
