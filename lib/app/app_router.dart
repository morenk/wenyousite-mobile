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
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';

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
      if (!authenticated && state.matchedLocation == '/compose/thread') {
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
                builder: (context, state) => const SearchBaselinePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                name: 'notifications',
                builder: (context, state) => const NotificationsBaselinePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/me',
                name: 'me',
                builder: (context, state) => const ProfileBaselinePage(),
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
          );
        },
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
