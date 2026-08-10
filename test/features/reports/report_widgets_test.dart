import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
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

    await tester.tap(find.byKey(const Key('report-reason')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('其他原因').last);
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

  testWidgets('邮箱未验证时在表单内给出恢复入口和请求 ID', (tester) async {
    final repository = _WidgetReportRepository(
      nextFailure: const ApiFailure(
        userMessage: '请先完成邮箱验证。',
        businessCode: 40107,
        requestId: 'report-request-id',
      ),
    );
    final container = await _reportContainer(repository);
    final router = GoRouter(
      initialLocation: '/users/user-1',
      routes: [
        GoRoute(
          path: '/users/:userId',
          builder: (_, _) => const Scaffold(body: _ReportTestButton()),
        ),
        GoRoute(
          path: '/me/security/verify-email',
          builder: (context, _) => Scaffold(
            body: FilledButton(
              onPressed: () => context.pop(true),
              child: const Text('完成邮箱验证'),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );

    await tester.tap(find.text('举报'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('report-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('report-verify-email')), findsOneWidget);
    expect(find.text('请求 ID：report-request-id'), findsOneWidget);
    await tester.tap(find.byKey(const Key('report-verify-email')));
    await tester.pumpAndSettle();
    expect(find.text('完成邮箱验证'), findsOneWidget);
    await tester.tap(find.text('完成邮箱验证'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('report-reason')), findsOneWidget);
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
  _WidgetReportRepository({this.nextFailure});

  var calls = 0;
  ApiFailure? nextFailure;
  ReportInput? lastInput;

  @override
  Future<ReportResult> create(ReportInput input) async {
    calls += 1;
    lastInput = input;
    final failure = nextFailure;
    if (failure != null) {
      nextFailure = null;
      throw failure;
    }
    return ReportResult(
      id: 'report-1',
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
