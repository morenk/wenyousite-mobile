import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// 系统返回保留 Navigator/PopScope 与 onExit；初始化和异步换路期间不退出。
class WenyouRouterDelegate extends RouterDelegate<RouteMatchList>
    with ChangeNotifier {
  WenyouRouterDelegate(this.router) {
    router.routerDelegate.addListener(notifyListeners);
  }

  final GoRouter router;
  Future<bool>? _pendingPop;
  GoRouterDelegate get _delegate => router.routerDelegate;

  @override
  RouteMatchList get currentConfiguration => _delegate.currentConfiguration;

  @override
  Widget build(BuildContext context) => _delegate.build(context);

  @override
  Future<void> setNewRoutePath(RouteMatchList configuration) =>
      _delegate.setNewRoutePath(configuration);

  @override
  Future<void> setInitialRoutePath(RouteMatchList configuration) =>
      _delegate.setInitialRoutePath(configuration);

  @override
  Future<void> setRestoredRoutePath(RouteMatchList configuration) =>
      _delegate.setRestoredRoutePath(configuration);

  @override
  Future<bool> popRoute() => _pendingPop ??= _pop().whenComplete(() {
    _pendingPop = null;
  });

  Future<bool> _pop() async {
    final configuration = currentConfiguration;
    if (configuration.isEmpty) return true;
    final routeState = _delegate.state;
    // 从根到当前 Shell，弹层存在时止于承载它的 Navigator。
    final navigators = <NavigatorState>[];
    final root = _delegate.navigatorKey.currentState;
    if (root == null || !root.mounted) return true;
    navigators.add(root);
    RouteMatchBase match = configuration.matches.last;
    while (match is ShellRouteMatch) {
      final navigator = match.navigatorKey.currentState;
      if (navigator == null || match.matches.isEmpty) return true;
      final modal = ModalRoute.of(navigator.context);
      if (modal != null && !modal.isCurrent) break;
      navigators.add(navigator);
      match = match.matches.last;
    }
    for (final navigator in navigators.reversed) {
      if (await navigator.maybePop()) return true;
      // maybePop 可等待退出确认；其间发生导航后，不对新页面再执行返回。
      if (!identical(configuration, currentConfiguration)) return true;
    }
    final last = configuration.last;
    final onExit = last.route.onExit;
    final context = _delegate.navigatorKey.currentContext;
    if (onExit == null || context == null || !context.mounted) return false;
    final allowed = await onExit(context, routeState);
    if (!identical(configuration, currentConfiguration)) return true;
    return !allowed;
  }

  @override
  void dispose() {
    _delegate.removeListener(notifyListeners);
    super.dispose();
  }
}
