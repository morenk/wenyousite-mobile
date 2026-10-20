import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/core/navigation/navigation_link_writer.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_feedback_visibility.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_content_action_menu.dart';
import 'package:wenyousite_mobile/features/app_shell/application/clipboard_navigation_coordinator.dart';
import 'package:wenyousite_mobile/features/app_shell/application/clipboard_navigation_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/clipboard_navigation_prompt.dart';

import 'clipboard_navigation_test_support.dart';

const _floor =
    'https://wenyou.site/threads/abcdefghijklmnopqrst?post=uvwxyzabcdefghijklmn';

void main() {
  testWidgets('写成功却瞬时无法回读版本，重启后凭收据认领一次再绑定系统版本', (tester) async {
    const marker = '550e8400-e29b-41d4-a716-446655440000';
    final gateway = FakeNavigationClipboard()
      ..writeReceipt = 'android:own:$marker'
      ..writtenEvent = 'android:100:$marker';
    final store = FakeNavigationStore();
    final container = await _pump(tester, gateway, store);
    await container.read(navigationLinkWriterProvider)(_floor);
    expect(store.value?.changeToken, 'android:own:$marker');
    await tester.pumpWidget(const SizedBox.shrink());
    await _pump(tester, gateway, store);
    expect(find.byType(AlertDialog), findsNothing);
    expect(store.value?.changeToken, 'android:100:$marker');
    gateway.token = 'android:101:$marker';
    await _resume(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.byKey(const Key('clipboard-navigation-dismiss')));
    await tester.pumpAndSettle();
  });

  testWidgets('未回读收据不会吞掉站外重复制相同文字的新事件', (tester) async {
    const marker = '550e8400-e29b-41d4-a716-446655440000';
    final gateway = FakeNavigationClipboard()
      ..writeReceipt = 'android:own:$marker';
    final store = FakeNavigationStore();
    final container = await _pump(tester, gateway, store);
    await container.read(navigationLinkWriterProvider)(_floor);
    gateway.token = 'android:201';
    await _resume(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.byKey(const Key('clipboard-navigation-dismiss')));
    await tester.pumpAndSettle();
  });

  testWidgets('已排队首帧在后台执行时不读取剪贴板', (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    final gateway = FakeNavigationClipboard();
    await _pump(tester, gateway, FakeNavigationStore());
    expect(gateway.reads, 0);
    await _resume(tester);
    expect(gateway.reads, 1);
  });

  for (final entry in {
    '主题': 'https://wenyou.site/threads/abcdefghijklmnopqrst',
    '子贴':
        'https://wenyou.site/threads/abcdefghijklmnopqrst?subthread=bcdefghijklmnopqrstu',
    '楼层': _floor,
    '回复':
        'https://wenyou.site/threads/abcdefghijklmnopqrst?post=cdefghijklmnopqrstuv',
    '邀请': 'https://wenyou.site/join/AbCdEfGh_123-XYZ',
  }.entries) {
    testWidgets('空剪贴板中复制${entry.key}后立即切出，失焦不可读也不反向提示', (tester) async {
      final gateway = FakeNavigationClipboard();
      final store = FakeNavigationStore();
      await _pump(tester, gateway, store, link: entry.value);
      await tester.tap(find.text('复制链接'));
      gateway.readable = false;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pumpAndSettle();
      gateway.readable = true;
      await _resume(tester);
      expect(find.byType(AlertDialog), findsNothing);
      expect(gateway.text, entry.value);
      expect(store.value?.changeToken, gateway.token);
      await _resume(tester);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await _pump(tester, gateway, store, link: entry.value);
      expect(find.byType(AlertDialog), findsNothing);
      // 相同文字来自站外的新复制事件，仍应询问。
      gateway.token = 'android:external:2';
      await _resume(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.byKey(const Key('clipboard-navigation-dismiss')));
      await tester.pumpAndSettle();
    });
  }

  testWidgets('在途旧剪贴板快照不会在自己复制后弹出', (tester) async {
    final gateway = FakeNavigationClipboard()
      ..pendingSnapshot = Completer<ClipboardNavigationSnapshot?>();
    final store = FakeNavigationStore();
    final container = await _pump(tester, gateway, store);
    await container.read(navigationLinkWriterProvider)(_floor);
    gateway.pendingSnapshot!.complete(
      const ClipboardNavigationSnapshot(text: _floor, changeToken: 'old'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('旧弹窗取消不会覆盖自己后来复制的事件', (tester) async {
    final gateway = FakeNavigationClipboard()
      ..text = _floor
      ..token = 'old';
    final store = FakeNavigationStore();
    final container = await _pump(tester, gateway, store);
    expect(find.byType(AlertDialog), findsOneWidget);
    await container.read(navigationLinkWriterProvider)(_floor);
    await tester.tap(find.byKey(const Key('clipboard-navigation-dismiss')));
    await tester.pumpAndSettle();
    expect(store.value?.changeToken, 'android:copy:1');
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('原生复制尚未返回时恢复，等待本次收据后去重', (tester) async {
    final gateway = FakeNavigationClipboard()
      ..pendingWrite = Completer<String?>();
    final store = FakeNavigationStore();
    final container = await _pump(tester, gateway, store);
    final copy = container.read(navigationLinkWriterProvider)(_floor);
    await _resume(tester);
    expect(find.byType(AlertDialog), findsNothing);
    gateway.pendingWrite!.complete(gateway.token);
    await copy;
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('模态退场后重新读取站外链接并准确跳转', (tester) async {
    final gateway = FakeNavigationClipboard();
    final store = FakeNavigationStore();
    final container = await _pump(tester, gateway, store);
    final router = container.read(appRouterProvider);
    unawaited(
      showDialog<void>(
        context: router.routerDelegate.navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text('正在查看其他提示'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    gateway
      ..text = _floor
      ..token = 'external';
    await _resume(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('打开楼层链接？'), findsNothing);
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();
    expect(find.text('打开楼层链接？'), findsOneWidget);
    await tester.tap(find.byKey(const Key('clipboard-navigation-open')));
    await tester.pumpAndSettle();
    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/threads/abcdefghijklmnopqrst?post=uvwxyzabcdefghijklmn',
    );
  });
}

Future<void> _resume(WidgetTester tester) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  await tester.pump();
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pumpAndSettle();
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  FakeNavigationClipboard gateway,
  FakeNavigationStore store, {
  String link = _floor,
}) async {
  final visibility = WenyouFeedbackVisibility();
  final router = GoRouter(
    observers: [visibility.createObserver()],
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, _) => Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  unawaited(copyPostCardLink(context, link, '已复制')),
              child: const Text('复制链接'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/threads/:id',
        builder: (_, _) => const Scaffold(body: Text('主题')),
      ),
      GoRoute(
        path: '/join/:id',
        builder: (_, _) => const Scaffold(body: Text('邀请')),
      ),
    ],
  );
  final container = ProviderContainer(
    overrides: [
      feedbackVisibilityProvider.overrideWithValue(visibility),
      appRouterProvider.overrideWithValue(router),
      clipboardNavigationGatewayProvider.overrideWithValue(gateway),
      handledClipboardNavigationStoreProvider.overrideWithValue(store),
      navigationLinkWriterProvider.overrideWith(
        (ref) => ref.watch(clipboardNavigationCoordinatorProvider).copyLink,
      ),
    ],
  );
  addTearDown(() {
    router.dispose();
    container.dispose();
    visibility.dispose();
  });
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        builder: (_, child) => ClipboardNavigationPrompt(child: child!),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}
