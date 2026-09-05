import 'package:flutter/material.dart';

/// One observer per Navigator, shared visibility across the root and branches.
class WenyouFeedbackVisibility extends ChangeNotifier {
  final _observers = <_FeedbackRouteObserver>[];

  NavigatorObserver createObserver() {
    final observer = _FeedbackRouteObserver(this);
    _observers.add(observer);
    return observer;
  }

  bool get ready =>
      _observers.any(
        (observer) =>
            observer.navigator?.mounted == true && observer._routes.isNotEmpty,
      ) &&
      !_observers.any(
        (observer) =>
            observer.navigator?.mounted == true && observer.blocksFeedback,
      );

  void changed() => notifyListeners();

  @override
  void dispose() {
    for (final observer in _observers) {
      observer.detachAnimations();
    }
    super.dispose();
  }
}

class _FeedbackRouteObserver extends NavigatorObserver {
  _FeedbackRouteObserver(this.visibility);
  final WenyouFeedbackVisibility visibility;
  final _routes = <Route<dynamic>>[];
  final _leaving = <ModalRoute<dynamic>>{};

  bool get blocksFeedback {
    if (_leaving.isNotEmpty) return true;
    if (_routes.isEmpty) return false;
    final route = _routes.last;
    if (route is PopupRoute) return true;
    return route is ModalRoute &&
        route.animation != null &&
        route.animation!.status != AnimationStatus.completed;
  }

  void _animationChanged(AnimationStatus _) {
    for (final route in _leaving.toList()) {
      if (route.animation?.status == AnimationStatus.dismissed) {
        route.animation?.removeStatusListener(_animationChanged);
        _leaving.remove(route);
      }
    }
    visibility.changed();
  }

  void _add(Route<dynamic> route) {
    _routes.add(route);
    if (route is ModalRoute) {
      route.animation?.addStatusListener(_animationChanged);
    }
    visibility.changed();
  }

  void _remove(Route<dynamic> route) {
    _routes.remove(route);
    if (route is ModalRoute) {
      route.animation?.removeStatusListener(_animationChanged);
    }
    visibility.changed();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _add(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
    if (route is ModalRoute &&
        route.animation != null &&
        route.animation!.status != AnimationStatus.dismissed) {
      _leaving.add(route);
    } else if (route is ModalRoute) {
      route.animation?.removeStatusListener(_animationChanged);
    }
    visibility.changed();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _remove(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) _remove(oldRoute);
    if (newRoute != null) _add(newRoute);
  }

  void detachAnimations() {
    for (final route in [..._routes, ..._leaving]) {
      if (route is ModalRoute) {
        route.animation?.removeStatusListener(_animationChanged);
      }
    }
    _routes.clear();
    _leaving.clear();
  }
}
