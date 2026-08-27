import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/features/reports/data/report_repository.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';

void main() {
  testWidgets('其他原因必须填写说明，成功展示人工审核确认', (tester) async {
    final repository = _WidgetReportRepository();
    await tester.pumpWidget(await _reportApp(repository));

    await tester.tap(find.text('举报'));
    await tester.pumpAndSettle();
    expect(find.textContaining('管理员可看到你的举报账号'), findsOneWidget);

    final reasonFilter = find.byKey(const Key('report-reason'));
    expect(reasonFilter, findsOneWidget);
    expect(
      tester.widget<WenyouDropdownFilter<ReportReason>>(reasonFilter).selected,
      ReportReason.spam,
    );
    expect(find.byType(WenyouDropdownFormField<ReportReason>), findsNothing);
    await tester.tap(reasonFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('report-reason-option-other')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('report-submit')));
    await tester.pumpAndSettle();
    expect(find.textContaining('请填写补充说明'), findsOneWidget);
    expect(repository.calls, 0);

    await tester.enterText(
      find.byKey(const Key('report-details')),
      '  这里是具体问题  ',
    );
    await tester.tap(find.byKey(const Key('report-submit')));
    await tester.pumpAndSettle();
    expect(repository.calls, 1);
    expect(repository.lastInput?.reason, ReportReason.other);
    expect(repository.lastInput?.details, '这里是具体问题');
    expect(find.textContaining('管理员会根据站点规范进行审核'), findsOneWidget);
  });

  testWidgets('举报提交在途时系统返回不会关闭待确认弹窗', (tester) async {
    final repository = _DelayedWidgetReportRepository();
    await tester.pumpWidget(await _reportApp(repository));
    await tester.tap(find.text('举报'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('report-submit')));
    await tester.pump();

    expect(repository.calls, 1);
    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.text('举报这个用户'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repository.complete();
    await tester.pumpAndSettle();

    expect(find.text('举报这个用户'), findsNothing);
    expect(find.textContaining('管理员会根据站点规范进行审核'), findsOneWidget);
  });

  testWidgets('游客举报公开主题先登录并保留精确返回位置', (tester) async {
    final repository = _WidgetReportRepository();
    await tester.pumpWidget(await _guestReportApp(repository));

    await tester.tap(find.text('举报'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('guest-report-login')), findsOneWidget);
    expect(find.text('/threads/thread-1?post=reply-1'), findsOneWidget);
    expect(repository.calls, 0);
  });

  testWidgets('40914、429 和网络结果不明时保留表单并可显式重试', (tester) async {
    final requestOptions = RequestOptions(path: '/api/v1/reports');
    final repository = _ScriptedWidgetReportRepository([
      const ApiFailure(userMessage: '已提交过相同的待处理举报。', businessCode: 40914),
      const ApiFailure(userMessage: '操作太频繁，请稍后再试。', businessCode: 42900),
      ApiFailure(
        userMessage: '暂时无法确认举报是否提交，请检查网络后重试。',
        cause: DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionError,
        ),
      ),
    ]);
    await tester.pumpWidget(await _reportApp(repository));
    await tester.tap(find.text('举报'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('report-details')), '保留的现场说明');

    final expectedMessages = ['已提交过', '操作太频繁', '暂时无法确认举报是否提交'];
    for (var index = 0; index < expectedMessages.length; index++) {
      await tester.tap(find.byKey(const Key('report-submit')));
      await tester.pumpAndSettle();

      expect(find.text('举报这个用户'), findsOneWidget);
      expect(find.textContaining(expectedMessages[index]), findsOneWidget);
      expect(find.text('保留的现场说明'), findsOneWidget);
      expect(repository.calls, index + 1);
    }

    await tester.tap(find.byKey(const Key('report-submit')));
    await tester.pumpAndSettle();

    expect(repository.calls, 4);
    expect(find.text('举报这个用户'), findsNothing);
    expect(find.textContaining('管理员会根据站点规范进行审核'), findsOneWidget);
  });
}

Future<Widget> _reportApp(_WidgetReportRepository repository) async {
  final container = await _reportContainer(repository);
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: Scaffold(body: _ReportTestButton())),
  );
}

Future<ProviderContainer> _reportContainer(
  _WidgetReportRepository repository,
) async {
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
      sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
      reportRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  await container
      .read(sessionControllerProvider.notifier)
      .authenticate(_tokens('reporter-1'));
  return container;
}

Future<Widget> _guestReportApp(_WidgetReportRepository repository) async {
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
      sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
      reportRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  final router = GoRouter(
    initialLocation: '/threads/thread-1',
    routes: [
      GoRoute(
        path: '/threads/:threadId',
        builder: (context, state) => const Scaffold(
          body: WenyouReportButton(
            target: ReportTarget.thread('thread-1'),
            targetLabel: '这个主题',
            returnTo: '/threads/thread-1?post=reply-1',
          ),
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => Scaffold(
          body: Text(
            state.uri.queryParameters['returnTo'] ?? '',
            key: const Key('guest-report-login'),
          ),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  );
}

class _ReportTestButton extends StatelessWidget {
  const _ReportTestButton();

  @override
  Widget build(BuildContext context) {
    return const WenyouReportButton(
      target: ReportTarget.user('user-1'),
      targetLabel: '这个用户',
      returnTo: '/users/user-1',
    );
  }
}

class _WidgetReportRepository implements ReportRepository {
  var calls = 0;
  ReportInput? lastInput;

  @override
  Future<ReportResult> create(ReportInput input) async {
    calls += 1;
    lastInput = input;
    return ReportResult(
      id: 'report-1',
      target: input.target,
      reason: input.reason,
      createdAt: DateTime.utc(2026, 8, 10),
    );
  }
}

class _DelayedWidgetReportRepository extends _WidgetReportRepository {
  final _completer = Completer<ReportResult>();

  @override
  Future<ReportResult> create(ReportInput input) {
    calls += 1;
    lastInput = input;
    return _completer.future;
  }

  void complete() {
    final input = lastInput!;
    _completer.complete(
      ReportResult(
        id: 'report-delayed',
        target: input.target,
        reason: input.reason,
        createdAt: DateTime.utc(2026, 8, 10),
      ),
    );
  }
}

class _ScriptedWidgetReportRepository extends _WidgetReportRepository {
  _ScriptedWidgetReportRepository(this.failures);

  final List<ApiFailure> failures;

  @override
  Future<ReportResult> create(ReportInput input) async {
    calls += 1;
    lastInput = input;
    if (failures.isNotEmpty) throw failures.removeAt(0);
    return ReportResult(
      id: 'report-retried',
      target: input.target,
      reason: input.reason,
      createdAt: DateTime.utc(2026, 8, 10),
    );
  }
}

SessionTokens _tokens(String userId) {
  final payload = base64Url
      .encode(utf8.encode('{"sub":"$userId"}'))
      .replaceAll('=', '');
  return SessionTokens(
    accessToken: 'header.$payload.signature',
    refreshToken: 'refresh-token',
  );
}

class _MemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class _FakeSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) async =>
      throw UnimplementedError();
}
