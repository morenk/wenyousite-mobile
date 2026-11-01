import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/wenyou_router_delegate.dart';

void main() {
  test('未解析路由时旧 delegate 抛错，应用边界消费返回', () async {
    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (_, _) => const SizedBox())],
    );
    final delegate = WenyouRouterDelegate(router);
    addTearDown(router.dispose);
    addTearDown(delegate.dispose);
    expect(router.routerDelegate.currentConfiguration.isEmpty, isTrue);
    await expectLater(router.routerDelegate.popRoute(), throwsStateError);
    expect(await delegate.popRoute(), isTrue);
    expect(await delegate.popRoute(), isTrue);
  });

  testWidgets('正常多层与 Shell 返回、弹层及 PopScope 按原顺序处理', (tester) async {
    var protectedPops = 0;
    final router = GoRouter(
      routes: [
        ShellRoute(
          builder: (_, _, child) => child,
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Scaffold(body: Text('首页')),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, _) => PopScope(
                    canPop: false,
                    onPopInvokedWithResult: (didPop, _) {
                      if (!didPop) protectedPops++;
                    },
                    child: const Scaffold(body: Text('编辑')),
                  ),
                ),
                GoRoute(
                  path: 'detail',
                  builder: (_, _) => const Scaffold(body: Text('详情')),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    final delegate = WenyouRouterDelegate(router);
    await _pump(tester, router, delegate);
    router.go('/detail');
    await tester.pumpAndSettle();
    expect(await delegate.popRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('首页'), findsOneWidget);
    router.go('/edit');
    await tester.pumpAndSettle();
    final context = tester.element(find.text('编辑'));
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(content: Text('弹层')),
      ),
    );
    await tester.pumpAndSettle();
    expect(await delegate.popRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('弹层'), findsNothing);
    expect(protectedPops, 0);
    expect(await delegate.popRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(protectedPops, 1);
    expect(find.text('编辑'), findsOneWidget);
    router.go('/');
    await tester.pumpAndSettle();
    expect(await delegate.popRoute(), isFalse);
    await tester.pumpWidget(const SizedBox());
    delegate.dispose();
    router.dispose();
  });

  testWidgets('等待退出期间换路和连续返回不会退出新页面', (tester) async {
    final entered = Completer<void>();
    final release = Completer<bool>();
    var exits = 0;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('旧页')),
          onExit: (_, _) {
            exits++;
            if (!entered.isCompleted) entered.complete();
            return release.future;
          },
        ),
        GoRoute(
          path: '/new',
          builder: (_, _) => const Scaffold(body: Text('新页')),
        ),
      ],
    );
    final delegate = WenyouRouterDelegate(router);
    await _pump(tester, router, delegate);
    final pop = delegate.popRoute();
    await entered.future;
    final repeated = delegate.popRoute();
    expect(identical(pop, repeated), isTrue);
    // 精确模拟 maybePop/onExit 等待期间解析配置被替换为空。
    router.routerDelegate.currentConfiguration = RouteMatchList.empty;
    release.complete(true);
    expect(await pop, isTrue);
    expect(exits, 1);
    router.go('/new');
    await tester.pumpAndSettle();
    expect(find.text('新页'), findsOneWidget);
    expect(await delegate.popRoute(), isFalse);
    await tester.pumpWidget(const SizedBox());
    delegate.dispose();
    router.dispose();
  });

  testWidgets('重定向完成后返回使用当前路由并保留根 onExit 拒绝', (tester) async {
    final router = GoRouter(
      initialLocation: '/old',
      routes: [
        GoRoute(path: '/old', redirect: (_, _) => '/'),
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('当前页')),
          onExit: (_, _) => false,
        ),
      ],
    );
    final delegate = WenyouRouterDelegate(router);
    await _pump(tester, router, delegate);
    expect(await delegate.popRoute(), isTrue);
    expect(find.text('当前页'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    delegate.dispose();
    router.dispose();
  });
}

Future<void> _pump(
  WidgetTester tester,
  GoRouter router,
  WenyouRouterDelegate delegate,
) async {
  await tester.pumpWidget(
    MaterialApp.router(
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: delegate,
    ),
  );
  await tester.pumpAndSettle();
}
