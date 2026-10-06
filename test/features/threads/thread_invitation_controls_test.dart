import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/navigation/navigation_link_writer.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_invitation_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_invitation_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_invitation_controls.dart';

final _scope = StateProvider(
  (ref) => const SessionScope(accountId: 'owner', generation: 1),
);
const _copyKey = Key('thread-invite-link-copy');
const _valueKey = Key('thread-invite-link-value');

void main() {
  final copied = <String>[];
  bool clipboardFails = false;
  setUp(() {
    copied.clear();
    clipboardFails = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            if (clipboardFails) throw PlatformException(code: 'unavailable');
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null),
  );

  testWidgets('重新打开私密邀请可直接复制而不必重置链接', (tester) async {
    await _pumpRow(tester, _Repository());
    expect(find.text('复制邀请链接'), findsOneWidget);
    expect(find.text('私密邀请'), findsNothing);
    expect(find.text('重置邀请链接'), findsNothing);
    final tile = tester.widget<ListTile>(
      find.descendant(
        of: find.byKey(_copyKey),
        matching: find.byType(ListTile),
      ),
    );
    expect(
      (tile.leading! as WenyouIcon).semanticId,
      WenyouIconIds.actionCopyAll,
    );
    expect(
      (tile.trailing! as WenyouIcon).semanticId,
      WenyouIconIds.navigationNext,
    );
  });

  testWidgets('连续复制与重开均重新取链，正常态不展示链接正文', (tester) async {
    final repository = _Repository();
    await _pumpRow(tester, repository);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byKey(_copyKey));
      await tester.pumpAndSettle();
      expect(find.byKey(_valueKey), findsNothing);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await _pumpRow(tester, repository);
    await tester.tap(find.byKey(_copyKey));
    await tester.pumpAndSettle();
    expect(repository.ensureCalls, 3);
    expect(repository.resetCalls, 0);
    expect(copied, List.filled(3, _link.url.toString()));
  });

  testWidgets('取得当前邀请后通过共享复制入口登记每次复制', (tester) async {
    clipboardFails = true;
    final repository = _Repository();
    final sharedCopies = <String>[];
    await _pumpRow(
      tester,
      repository,
      linkWriter: (text) async => sharedCopies.add(text),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byKey(_copyKey));
      await tester.pumpAndSettle();
    }
    expect(repository.ensureCalls, 2);
    expect(repository.resetCalls, 0);
    expect(sharedCopies, List.filled(2, _link.url.toString()));
    expect(copied, isEmpty);
    expect(find.byKey(_valueKey), findsNothing);
  });

  testWidgets('获取失败只提示重试，不重置或展示旧链接', (tester) async {
    final repository = _Repository()
      ..failure = const ApiFailure(requestId: 'invite-request-id');
    await _pumpRow(tester, repository);
    await tester.tap(find.byKey(_copyKey));
    await tester.pumpAndSettle();
    expect(repository.resetCalls, 0);
    expect(find.textContaining('邀请链接获取失败，请重试。'), findsOneWidget);
    expect(find.textContaining('问题编号：invite-request-id'), findsOneWidget);
    expect(find.byKey(_valueKey), findsNothing);
  });

  testWidgets('唯剪贴板失败展示完整可选链接，再次操作清空后重新取链', (tester) async {
    clipboardFails = true;
    final repository = _Repository();
    await _pumpRow(tester, repository);
    await tester.tap(find.byKey(_copyKey));
    await tester.pumpAndSettle();
    final value = tester.widget<SelectableText>(find.byKey(_valueKey));
    expect(value.data, _link.url.toString());
    expect(value.maxLines, isNull);
    expect(find.text('自动复制失败，请长按下方链接复制。'), findsOneWidget);
    clipboardFails = false;
    await tester.tap(find.byKey(_copyKey));
    await tester.pumpAndSettle();
    expect(repository.ensureCalls, 2);
    expect(find.byKey(_valueKey), findsNothing);
  });

  testWidgets('保存前置未完成时局部等待并防重复，失败不取链', (tester) async {
    final saved = Completer<bool>();
    final repository = _Repository();
    await _pumpRow(tester, repository, beforeCopy: () => saved.future);
    await tester.tap(find.byKey(_copyKey));
    await tester.pump();
    await tester.tap(find.byKey(_copyKey));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(repository.ensureCalls, 0);
    saved.complete(false);
    await tester.pumpAndSettle();
    expect(repository.ensureCalls, 0);
    expect(find.textContaining('暂时无法复制'), findsOneWidget);
  });

  testWidgets('保存前置完成后同次点击取链并复制', (tester) async {
    final saved = Completer<bool>();
    final repository = _Repository();
    await _pumpRow(tester, repository, beforeCopy: () => saved.future);
    await tester.tap(find.byKey(_copyKey));
    await tester.pump();
    expect(repository.ensureCalls, 0);
    saved.complete(true);
    await tester.pumpAndSettle();
    expect(repository.ensureCalls, 1);
    expect(copied, [_link.url.toString()]);
  });

  for (final boundary in [
    'account',
    'dispose',
    'permission',
    'thread',
    'route',
  ]) {
    testWidgets('$boundary 改变后迟到取链不复制或回填', (tester) async {
      final pending = Completer<ThreadInvitationLink>();
      final repository = _Repository()..pending = pending.future;
      final props = ValueNotifier(('thread-1', true));
      final navigator = GlobalKey<NavigatorState>();
      addTearDown(props.dispose);
      final container = await _pumpRow(
        tester,
        repository,
        props: props,
        navigator: navigator,
      );
      await tester.tap(find.byKey(_copyKey));
      await tester.pump();
      switch (boundary) {
        case 'account':
          container.read(_scope.notifier).state = const SessionScope(
            accountId: 'other',
            generation: 2,
          );
        case 'dispose':
          await tester.pumpWidget(const SizedBox.shrink());
        case 'permission':
          props.value = ('thread-1', false);
        case 'thread':
          props.value = ('thread-2', true);
        case 'route':
          unawaited(
            navigator.currentState!.push(
              MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: Text('其他页面')),
              ),
            ),
          );
      }
      await tester.pump();
      pending.complete(_link);
      await tester.pumpAndSettle();
      expect(copied, isEmpty);
      expect(find.byKey(_valueKey), findsNothing);
      if (boundary == 'thread') {
        repository.pending = null;
        await tester.tap(find.byKey(_copyKey));
        await tester.pumpAndSettle();
        expect(repository.ensureCalls, 2);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('已有手动链接切号或push覆盖后返回都清空', (tester) async {
    clipboardFails = true;
    final navigator = GlobalKey<NavigatorState>();
    final container = await _pumpRow(
      tester,
      _Repository(),
      navigator: navigator,
    );
    await tester.tap(find.byKey(_copyKey));
    await tester.pumpAndSettle();
    expect(find.byKey(_valueKey), findsOneWidget);
    unawaited(
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('其他页面')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(_valueKey), findsNothing);
    await tester.tap(find.byKey(_copyKey));
    await tester.pumpAndSettle();
    container.read(_scope.notifier).state = const SessionScope(
      accountId: 'other',
      generation: 2,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(_valueKey), findsNothing);
  });
}

Future<ProviderContainer> _pumpRow(
  WidgetTester tester,
  ThreadInvitationRepository repository, {
  NavigationLinkWriter? linkWriter,
  Future<bool> Function()? beforeCopy,
  ValueNotifier<(String, bool)>? props,
  GlobalKey<NavigatorState>? navigator,
}) async {
  final container = ProviderContainer(
    overrides: [
      threadInvitationRepositoryProvider.overrideWithValue(repository),
      if (linkWriter != null)
        navigationLinkWriterProvider.overrideWithValue(linkWriter),
      sessionScopeProvider.overrideWith((ref) => ref.watch(_scope)),
    ],
  );
  addTearDown(container.dispose);
  Widget row(String id, bool enabled) => Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ThreadInviteLinkCopyRow(
        threadId: id,
        enabled: enabled,
        beforeCopy: beforeCopy ?? () async => true,
      ),
    ),
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: navigator,
        home: props == null
            ? row('thread-1', true)
            : ValueListenableBuilder(
                valueListenable: props,
                builder: (_, value, _) => row(value.$1, value.$2),
              ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

class _Repository implements ThreadInvitationRepository {
  ApiFailure? failure;
  Future<ThreadInvitationLink>? pending;
  int ensureCalls = 0;
  int resetCalls = 0;
  @override
  Future<ThreadInvitationLink> ensureLink(String threadId) async {
    ensureCalls++;
    if (failure != null) throw failure!;
    return pending ?? _link;
  }

  @override
  Future<ThreadInvitationLink> resetLink(String threadId) async {
    resetCalls++;
    return _link;
  }

  @override
  Future<ThreadInvitationJoinResult> join(String token) =>
      throw UnimplementedError();
  @override
  Future<ThreadInvitationPreview> preview(String token) =>
      throw UnimplementedError();
}

final _link = ThreadInvitationLink(
  id: 'invite',
  threadId: 'thread-1',
  token: 'Abcd_1234-efGh56',
  url: Uri.parse('https://wenyou.site/join/Abcd_1234-efGh56'),
  createdAt: DateTime.utc(2026),
);
