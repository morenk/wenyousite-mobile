import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/features/auth/presentation/forgot_password_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/login_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/registration_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/reset_password_page.dart';

List<RouteBase> buildAuthRoutes() => [
  GoRoute(
    path: AppRoutePaths.login,
    name: AppRouteNames.login,
    builder: (context, state) => LoginPage(
      returnTo: state.uri.queryParameters['returnTo'],
      passwordResetSucceeded: state.extra is PasswordResetLoginNotice,
    ),
  ),
  GoRoute(
    path: AppRoutePaths.register,
    name: AppRouteNames.register,
    builder: (context, state) =>
        RegistrationPage(returnTo: state.uri.queryParameters['returnTo']),
  ),
  GoRoute(
    path: AppRoutePaths.forgotPassword,
    name: AppRouteNames.forgotPassword,
    builder: (context, state) =>
        ForgotPasswordPage(returnTo: state.uri.queryParameters['returnTo']),
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
            routeData is PasswordResetRouteData && routeData.codeRecentlySent,
        codeDeliveryUncertain:
            routeData is PasswordResetRouteData &&
            routeData.codeDeliveryUncertain,
        codeDeliveryRequestId: routeData is PasswordResetRouteData
            ? routeData.codeDeliveryRequestId
            : null,
      );
    },
  ),
];
