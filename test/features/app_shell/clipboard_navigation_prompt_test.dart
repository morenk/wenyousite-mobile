import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/features/app_shell/application/clipboard_navigation_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/clipboard_navigation_prompt.dart';

void main() {
  testWidgets('冷启动发现楼层链接时确认后前往准确位置', (tester) async {
    final gateway = _FakeClipboardGateway(
      text:
          'https://wenyou.site/threads/abcdefghijklmnopqrst'
          '?post=uvwxyzabcdefghijklmn',
      changeToken: 'android:1',
    );
    final router = await _pumpApp(tester, gateway: gateway);

    expect(find.text('打开楼层链接？'), findsOneWidget);
    await tester.tap(find.byKey(const Key('clipboard-navigation-open')));
    await tester.pumpAndSettle();

    expect(find.text('打开楼层链接？'), findsNothing);
    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/threads/abcdefghijklmnopqrst?post=uvwxyzabcdefghijklmn',
    );
  });

  testWidgets('取消后跨进程记住复制版本，站外重新复制相同链接才再次提示', (tester) async {
    const invite = 'https://wenyou.site/join/AbCdEfGh_123-XYZ';
    final gateway = _FakeClipboardGateway(
      text: invite,
      changeToken: 'android:10',
    );
    final store = _MemoryHandledClipboardStore();
    await _pumpApp(tester, gateway: gateway, store: store);

    expect(find.text('打开私密主题邀请？'), findsOneWidget);
    await tester.tap(find.byKey(const Key('clipboard-navigation-dismiss')));
    await tester.pumpAndSettle();
    expect(store.value?.changeToken, 'android:10');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await _pumpApp(tester, gateway: gateway, store: store);
    expect(find.text('打开私密主题邀请？'), findsNothing);
    expect(gateway.snapshotReads, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    gateway.changeToken = 'android:11';
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('打开私密主题邀请？'), findsOneWidget);
  });

  testWidgets('跳转选择同样跨进程记住且不保存原始邀请地址', (tester) async {
    const invite = 'https://wenyou.site/join/AbCdEfGh_123-XY2';
    final gateway = _FakeClipboardGateway(
      text: invite,
      changeToken: 'android:20',
    );
    final store = _MemoryHandledClipboardStore();
    final router = await _pumpApp(tester, gateway: gateway, store: store);

    await tester.tap(find.byKey(const Key('clipboard-navigation-open')));
    await tester.pumpAndSettle();
    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/join/AbCdEfGh_123-XY2',
    );
    expect(store.value?.changeToken, 'android:20');
    expect(store.value?.fingerprint, isNot(contains('AbCdEfGh_123-XY2')));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await _pumpApp(tester, gateway: gateway, store: store);
    expect(find.text('打开私密主题邀请？'), findsNothing);
  });

  testWidgets('普通主题传送门也先提示再进入', (tester) async {
    final gateway = _FakeClipboardGateway(
      text: 'https://wenyou.site/threads/abcdefghijklmnopqrst',
      changeToken: 'android:30',
    );
    final router = await _pumpApp(tester, gateway: gateway);

    expect(find.text('打开主题链接？'), findsOneWidget);
    await tester.tap(find.byKey(const Key('clipboard-navigation-open')));
    await tester.pumpAndSettle();
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/threads/abcdefghijklmnopqrst',
    );
  });

  testWidgets('普通文字、混合内容和不可读剪贴板均不提示', (tester) async {
    final gateway = _FakeClipboardGateway(
      text: '普通文字',
      changeToken: 'android:40',
    );
    await _pumpApp(tester, gateway: gateway);
    expect(find.byType(AlertDialog), findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    gateway
      ..text = '看看 https://wenyou.site/threads/abcdefghijklmnopqrst'
      ..changeToken = 'android:41';
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    gateway
      ..readable = false
      ..changeToken = 'android:42';
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}

Future<GoRouter> _pumpApp(
  WidgetTester tester, {
  required _FakeClipboardGateway gateway,
  _MemoryHandledClipboardStore? store,
}) async {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('首页')),
      ),
      GoRoute(
        path: '/threads/:threadId',
        builder: (_, _) => const Scaffold(body: Text('主题详情')),
      ),
      GoRoute(
        path: '/join/:token',
        builder: (_, _) => const Scaffold(body: Text('邀请详情')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appRouterProvider.overrideWithValue(router),
        clipboardNavigationGatewayProvider.overrideWithValue(gateway),
        if (store != null)
          handledClipboardNavigationStoreProvider.overrideWithValue(store),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        builder: (_, child) => ClipboardNavigationPrompt(child: child!),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

class _FakeClipboardGateway implements ClipboardNavigationGateway {
  _FakeClipboardGateway({required this.text, required this.changeToken});

  String? text;
  String? changeToken;
  bool readable = true;
  int snapshotReads = 0;

  @override
  Future<String?> readChangeToken() async => changeToken;

  @override
  Future<ClipboardNavigationSnapshot?> readSnapshot() async {
    if (!readable || text == null) return null;
    snapshotReads += 1;
    return ClipboardNavigationSnapshot(text: text!, changeToken: changeToken);
  }
}

class _MemoryHandledClipboardStore implements HandledClipboardNavigationStore {
  HandledClipboardNavigation? value;

  @override
  Future<HandledClipboardNavigation?> read() async => value;

  @override
  Future<void> write(HandledClipboardNavigation value) async {
    this.value = value;
  }
}
