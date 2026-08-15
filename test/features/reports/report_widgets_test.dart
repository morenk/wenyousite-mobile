import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
