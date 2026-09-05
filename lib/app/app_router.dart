import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_access.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/internal_location.dart';
import 'package:wenyousite_mobile/app/routes/account_routes.dart';
import 'package:wenyousite_mobile/app/routes/app_shell_routes.dart';
import 'package:wenyousite_mobile/app/routes/auth_routes.dart';
import 'package:wenyousite_mobile/app/routes/content_routes.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_feedback_visibility.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';

final feedbackVisibilityProvider = Provider<WenyouFeedbackVisibility>((ref) {
  final visibility = WenyouFeedbackVisibility();
  ref.onDispose(visibility.dispose);
  return visibility;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final feedbackVisibility = ref.watch(feedbackVisibilityProvider);
  final router = GoRouter(
    observers: [feedbackVisibility.createObserver()],
    initialLocation: AppRouteLocations.home,
    redirect: (context, state) {
      return resolveSessionRedirect(
        session: ref.read(sessionControllerProvider),
        matchedLocation: state.matchedLocation,
        uri: state.uri,
      );
    },
    routes: [
      buildAppShellRoute(ref, feedbackVisibility: feedbackVisibility),
      ...buildContentRoutes(),
      ...buildAccountRoutes(),
      ...buildAuthRoutes(),
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
