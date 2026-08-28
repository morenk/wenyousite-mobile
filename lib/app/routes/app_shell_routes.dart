import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_page_transitions.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/app_scaffold.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/message_center_page.dart';
import 'package:wenyousite_mobile/features/home/presentation/home_page.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_feed_page.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_content_dashboard.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';

RouteBase buildAppShellRoute(Ref ref) {
  return StatefulShellRoute.indexedStack(
    pageBuilder: (context, state, navigationShell) => wenyouInstantPage<void>(
      key: state.pageKey,
      child: AppScaffold(navigationShell: navigationShell),
    ),
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
              userMoments: MeUserMomentsIntegration(
                builder: (userId) => MomentFeedList(
                  target: MomentFeedTarget.user(userId),
                  emptyTitle: '还没有发布动态',
                  emptyMessage: '',
                  pullToRefreshEnabled: false,
                ),
                refresh: (userId) => ref
                    .read(
                      momentFeedControllerProvider(
                        MomentFeedTarget.user(userId),
                      ).notifier,
                    )
                    .refresh(),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
