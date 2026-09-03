import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/clipboard_navigation_prompt.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String? clipboardText;
  late bool clipboardReadable;

  setUp(() {
    clipboardText = null;
    clipboardReadable = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.getData') {
            if (!clipboardReadable) return null;
            return {'text': clipboardText};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('冷启动发现楼层链接时确认后前往准确位置', (tester) async {
    clipboardText =
        'https://wenyou.site/threads/abcdefghijklmnopqrst'
        '?post=uvwxyzabcdefghijklmn';
    final router = await _pumpApp(tester);

    expect(find.text('打开楼层链接？'), findsOneWidget);
    await tester.tap(find.byKey(const Key('clipboard-navigation-open')));
    await tester.pumpAndSettle();

    expect(find.text('打开楼层链接？'), findsNothing);
    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/threads/abcdefghijklmnopqrst?post=uvwxyzabcdefghijklmn',
    );
  });

  testWidgets('回前台发现新的私密邀请时先询问、可进入且同一内容不重复提示', (tester) async {
    clipboardText = '普通文字';
    final router = await _pumpApp(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    clipboardText = 'https://wenyou.site/join/AbCdEfGh_123-XYZ';
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('打开私密主题邀请？'), findsOneWidget);
    await tester.tap(find.byKey(const Key('clipboard-navigation-dismiss')));
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/home');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('打开私密主题邀请？'), findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    clipboardText = 'https://wenyou.site/join/AbCdEfGh_123-XY2';
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('clipboard-navigation-open')));
    await tester.pumpAndSettle();
    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/join/AbCdEfGh_123-XY2',
    );
  });

  testWidgets('普通主题链接不触发楼层跳转提示', (tester) async {
    clipboardText = 'https://wenyou.site/threads/abcdefghijklmnopqrst';
    await _pumpApp(tester);

    expect(find.byKey(const Key('clipboard-navigation-open')), findsNothing);
  });

  testWidgets('回前台须等窗口稳定后再读取剪贴板', (tester) async {
    clipboardText = '普通文字';
    await _pumpApp(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    clipboardText = 'https://wenyou.site/join/AbCdEfGh_123-XYZ';
    clipboardReadable = false;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    clipboardReadable = true;
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('打开私密主题邀请？'), findsOneWidget);
  });
}

Future<GoRouter> _pumpApp(WidgetTester tester) async {
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
      overrides: [appRouterProvider.overrideWithValue(router)],
      child: MaterialApp.router(
        routerConfig: router,
        builder: (_, child) => ClipboardNavigationPrompt(child: child!),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}
