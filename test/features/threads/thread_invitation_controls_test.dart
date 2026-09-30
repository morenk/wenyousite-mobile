import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_invitation_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_invitation_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_invitation_controls.dart';
import '../../support/deterministic_test_fonts.dart';

final _scope = StateProvider(
  (ref) => const SessionScope(accountId: 'owner', generation: 1),
);
const _copyKey = Key('thread-invite-link-copy');
const _resetKey = Key('thread-invite-link-reset');

void main() {
  setUpAll(loadDeterministicTestFonts);
  final copied = <String>[];
  setUp(() {
    copied.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
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
    await _pumpPanel(tester, _PanelRepository());
    expect(find.text('复制邀请链接'), findsOneWidget);
    expect(find.byKey(_copyKey), findsOneWidget);
    expect(find.text('生成新邀请链接'), findsNothing);
  });

  testWidgets('连续复制与重新打开都重新取得同一链接且不调用重置', (tester) async {
    final repository = _PanelRepository();
    await _pumpPanel(tester, repository);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byKey(_copyKey));
      await tester.pumpAndSettle();
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await _pumpPanel(tester, repository);
    await tester.tap(find.byKey(_copyKey));
    await tester.pumpAndSettle();
    expect(repository.ensureCalls, 3);
    expect(repository.resetCalls, 0);
    expect(copied, [for (var i = 0; i < 3; i++) _link.url.toString()]);
  });

  testWidgets('只有确认重置后才重置并复制', (tester) async {
    final repository = _PanelRepository();
    await _pumpPanel(tester, repository);
    await tester.tap(find.byKey(_resetKey));
    await tester.pumpAndSettle();
    expect(find.text('旧邀请链接将立即失效，已加入成员的权限不受影响。'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(repository.resetCalls, 0);
    await _reset(tester);
    expect(repository.resetCalls, 1);
    expect(repository.ensureCalls, 0);
    expect(copied, [_link.url.toString()]);
    expect(find.text('邀请链接已重置并复制，旧链接已失效。'), findsOneWidget);
  });

  testWidgets('取得失败不重置且隐藏旧凭据并保留问题编号', (tester) async {
    final repository = _PanelRepository();
    await _pumpPanel(tester, repository);
    await tester.tap(find.byKey(_copyKey));
    await tester.pumpAndSettle();
    repository.failure = const ApiFailure(
      userMessage: '邀请链接获取失败。',
      requestId: 'invite-request-id',
    );
    await tester.tap(find.byKey(_copyKey));
    await tester.pumpAndSettle();
    expect(repository.resetCalls, 0);
    expect(find.byKey(const Key('thread-invite-link-value')), findsNothing);
    expect(find.textContaining('问题编号：invite-request-id'), findsOneWidget);
    expect(copied.length, 1);
    await tester.tap(
      find.byKey(const Key('thread-invite-link-dismiss-failure')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-invite-link-failure')), findsNothing);
  });

  testWidgets('重置响应丢失仅取得当前链接不谎报重置成功', (tester) async {
    final repository = _PanelRepository()..resetFailure = _timeout;
    await _pumpPanel(tester, repository);
    await _reset(tester);
    expect(repository.resetCalls, 1);
    expect(repository.ensureCalls, 1);
    expect(find.text('暂时无法确认重置是否成功，当前邀请链接已获取并复制。'), findsOneWidget);
    expect(find.text('邀请链接已重置并复制，旧链接已失效。'), findsNothing);
    expect(copied.length, 1);
  });

  testWidgets('重置后取回失败保留上下文且不展示旧链接', (tester) async {
    final repository = _PanelRepository();
    await _pumpPanel(tester, repository);
    await tester.tap(find.byKey(_copyKey));
    await tester.pumpAndSettle();
    repository.resetFailure = _timeout;
    repository.failure = _timeout;
    await _reset(tester);
    expect(find.text('暂时无法确认重置是否成功，请先重新获取当前邀请链接。'), findsOneWidget);
    expect(find.byKey(const Key('thread-invite-link-value')), findsNothing);
    expect(repository.resetCalls, 1);
    expect(copied.length, 1);
  });

  testWidgets('重置核对成功但复制失败仍保留重置未确认提示', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            throw PlatformException(code: 'unavailable');
          }
          return null;
        });
    await _pumpPanel(tester, _PanelRepository()..resetFailure = _timeout);
    await _reset(tester);
    expect(
      find.text('暂时无法确认重置是否成功，当前邀请链接已获取，但自动复制失败，请长按上方链接复制。'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('thread-invite-link-value')), findsOneWidget);
  });

  for (final reset in [false, true]) {
    testWidgets('自动复制失败保留手动复制值 reset=$reset', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              throw PlatformException(code: 'unavailable');
            }
            return null;
          });
      final repository = _PanelRepository();
      await _pumpPanel(tester, repository);
      if (reset) {
        await _reset(tester);
      } else {
        await tester.tap(find.byKey(_copyKey));
        await tester.pumpAndSettle();
      }
      expect(find.byKey(const Key('thread-invite-link-value')), findsOneWidget);
      expect(find.textContaining('自动复制失败，请长按上方链接复制。'), findsOneWidget);
      expect(find.byKey(const Key('thread-invite-link-failure')), findsNothing);
      expect(repository.resetCalls, reset ? 1 : 0);
    });
  }

  testWidgets('请求及剪贴板期间禁止重复复制和重置', (tester) async {
    final response = Completer<ThreadInvitationLink>();
    final clipboard = Completer<void>();
    final repository = _PanelRepository()..pending = response.future;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') await clipboard.future;
          return null;
        });
    await _pumpPanel(tester, repository);
    await tester.tap(find.byKey(_copyKey));
    await tester.pump();
    await tester.tap(find.byKey(_copyKey));
    await tester.tap(find.byKey(_resetKey));
    await tester.pump();
    expect(repository.ensureCalls, 1);
    expect(repository.resetCalls, 0);
    response.complete(_link);
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(_copyKey));
    await tester.pump();
    expect(repository.ensureCalls, 1);
    clipboard.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('切号关闭重置确认且不发送旧账号请求', (tester) async {
    final repository = _PanelRepository();
    final container = await _pumpPanel(tester, repository);
    await tester.tap(find.byKey(_resetKey));
    await tester.pumpAndSettle();
    container.read(_scope.notifier).state = const SessionScope(
      accountId: 'other',
      generation: 2,
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(repository.resetCalls, 0);
    expect(copied, isEmpty);
  });

  for (final boundary in ['account', 'dispose', 'permission', 'thread']) {
    testWidgets('迟到链接在$boundary边界后不可复制或显示', (tester) async {
      final response = Completer<ThreadInvitationLink>();
      final repository = _PanelRepository()..pending = response.future;
      final props = ValueNotifier(('thread-1', true));
      addTearDown(props.dispose);
      final container = await _pumpPanel(tester, repository, props: props);
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
      }
      await tester.pump();
      response.complete(_link);
      await tester.pumpAndSettle();
      expect(copied, isEmpty);
      expect(find.byKey(const Key('thread-invite-link-value')), findsNothing);
      if (boundary == 'thread') {
        repository.pending = null;
        await tester.tap(find.byKey(_copyKey));
        await tester.pumpAndSettle();
        expect(repository.ensureCalls, 2);
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final dark in [false, true]) {
    testWidgets('320dp邀请链接及重置确认画面 dark=$dark', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 720);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await _pumpPanel(tester, _PanelRepository(), dark: dark);
      await tester.tap(find.byKey(_copyKey));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 8));
      await tester.pumpAndSettle();
      final tone = dark ? 'dark' : 'light';
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/thread_invite_320_$tone.png'),
      );
      await tester.tap(find.byKey(_resetKey));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/thread_invite_confirm_320_$tone.png'),
      );
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _reset(WidgetTester tester) async {
  await tester.tap(find.byKey(_resetKey));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('thread-invite-link-reset-confirm')));
  await tester.pumpAndSettle();
}

Future<ProviderContainer> _pumpPanel(
  WidgetTester tester,
  ThreadInvitationRepository repository, {
  bool dark = false,
  ValueNotifier<(String, bool)>? props,
}) async {
  final container = ProviderContainer(
    overrides: [
      threadInvitationRepositoryProvider.overrideWithValue(repository),
      sessionScopeProvider.overrideWith((ref) => ref.watch(_scope)),
    ],
  );
  addTearDown(container.dispose);
  Widget panel(String id, bool enabled) => Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ThreadInviteLinkPanel(threadId: id, enabled: enabled),
    ),
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: props == null
            ? panel('thread-1', true)
            : ValueListenableBuilder(
                valueListenable: props,
                builder: (_, value, _) => panel(value.$1, value.$2),
              ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

class _PanelRepository implements ThreadInvitationRepository {
  ApiFailure? failure;
  ApiFailure? resetFailure;
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
    if (resetFailure != null) throw resetFailure!;
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
  id: 'invite-1',
  threadId: 'thread-1',
  token: 'Abcd_1234-efGh56',
  url: Uri.parse('https://wenyou.site/join/Abcd_1234-efGh56'),
  createdAt: DateTime.utc(2026, 8, 10),
);
final _timeout = ApiFailure.fromDio(
  DioException(
    requestOptions: RequestOptions(path: '/invite-link'),
    type: DioExceptionType.receiveTimeout,
  ),
);
