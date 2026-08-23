import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';

/// Transient navigation intent that must never be persisted in a route URL.
enum WenyouRouteTransitionIntent { instantFallback }

/// The single page transition used by ordinary Android navigation routes.
class WenyouPageTransitionsBuilder extends PageTransitionsBuilder {
  const WenyouPageTransitionsBuilder();

  @override
  Duration get transitionDuration => _platformAnimationsDisabled
      ? Duration.zero
      : WenyouFoundationMotion.standard;

  @override
  Duration get reverseTransitionDuration => transitionDuration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (_animationsDisabled(context)) return child;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: animation,
              curve: _standardCurve,
              reverseCurve: _exitCurve,
            ),
          ),
      textDirection: Directionality.of(context),
      child: child,
    );
  }
}

/// Creates a declarative page that deliberately has no route transition.
NoTransitionPage<T> wenyouInstantPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return NoTransitionPage<T>(key: key, child: child);
}

/// Creates a declarative page that follows the app theme transition policy.
MaterialPage<T> wenyouStandardPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return MaterialPage<T>(key: key, child: child);
}

/// Pushes a full-screen task with the shared lightweight modal transition.
Future<T?> pushWenyouFullscreenPage<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  RouteSettings? settings,
}) {
  final platform = Theme.of(context).platform;
  final route =
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
      ? MaterialPageRoute<T>(
          settings: settings,
          fullscreenDialog: true,
          builder: builder,
        )
      : _wenyouFullscreenRoute<T>(
          context: context,
          builder: builder,
          settings: settings,
        );
  return Navigator.of(context).push<T>(route);
}

Route<T> _wenyouFullscreenRoute<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  RouteSettings? settings,
}) {
  final duration = _animationsDisabled(context)
      ? Duration.zero
      : WenyouFoundationMotion.fast;
  return PageRouteBuilder<T>(
    settings: settings,
    fullscreenDialog: true,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (_animationsDisabled(context)) return child;
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: _standardCurve,
          reverseCurve: _exitCurve,
        ),
        child: child,
      );
    },
  );
}

bool _animationsDisabled(BuildContext context) {
  return (MediaQuery.maybeOf(context)?.disableAnimations ?? false) ||
      _platformAnimationsDisabled;
}

bool get _platformAnimationsDisabled => WidgetsBinding
    .instance
    .platformDispatcher
    .accessibilityFeatures
    .disableAnimations;

// Exact Foundation v6.3.0 motion curves; kept only at the shared route boundary.
const _standardCurve = Cubic(0.2, 0.8, 0.2, 1);
const _exitCurve = Cubic(0.4, 0, 1, 1);
