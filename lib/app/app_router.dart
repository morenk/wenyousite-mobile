import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/internal_location.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/app_scaffold.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/baseline_pages.dart';
import 'package:wenyousite_mobile/features/auth/presentation/login_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/registration_page.dart';
import 'package:wenyousite_mobile/features/home/presentation/home_page.dart';
import 'package:wenyousite_mobile/features/notifications/presentation/notifications_page.dart';
import 'package:wenyousite_mobile/features/search/presentation/search_page.dart';
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
      final session = ref.read(sessionControllerProvider);
      final authenticated = session.isAuthenticated;
      final isLogin = state.matchedLocation == '/auth/login';
      final isRegistration = state.matchedLocation == '/auth/register';
      if (session.status == SessionStatus.invalidated && !isLogin) {
        return Uri(
          path: '/auth/login',
          queryParameters: {'returnTo': state.uri.toString()},
        ).toString();
      }
      final protectedRoute =
          state.matchedLocation == '/compose/thread' ||
          state.matchedLocation == '/me/following' ||
          state.matchedLocation == '/me/followers' ||
          state.matchedLocation == '/me/blocks' ||
          state.matchedLocation == '/me/bookmarks';
      if (!authenticated && protectedRoute) {
        return Uri(
          path: '/auth/login',
          queryParameters: {'returnTo': state.uri.toString()},
        ).toString();
      }
      if (authenticated && (isLogin || isRegistration)) {
        final returnTo = state.uri.queryParameters['returnTo'];
        return sanitizeReturnLocation(returnTo);
      }
      return null;
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
        path: '/compose/thread',
        name: 'compose-thread',
        builder: (context, state) => const ComposeBaselinePage(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) {
          return LoginPage(returnTo: state.uri.queryParameters['returnTo']);
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
    ],
  );
  ref.listen(sessionControllerProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});
