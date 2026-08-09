import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/settings/data/login_session_repository.dart';
import 'package:wenyousite_mobile/features/settings/domain/login_session_models.dart';
import 'package:wenyousite_mobile/features/settings/presentation/login_sessions_page.dart';

void main() {
  testWidgets('只展示平台与时间，当前终端不可远程退出', (tester) async {
    final repository = _FakeRepository(sessions: [_current, _other]);
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('移动端登录'), findsOneWidget);
    expect(find.text('Web 端登录'), findsOneWidget);
    expect(find.text('当前终端'), findsOneWidget);
    expect(find.textContaining('登录时间：'), findsNWidgets(2));
    expect(find.textContaining('Mozilla'), findsNothing);
    expect(
      find.byKey(const ValueKey('login-session-revoke-mobile-current')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('login-session-revoke-web-other')),
      findsOneWidget,
    );
  });

  testWidgets('确认后退出其他终端并原地移除', (tester) async {
    final repository = _FakeRepository(sessions: [_current, _other]);
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('login-session-revoke-web-other')),
    );
    await tester.pumpAndSettle();
    expect(find.text('退出这个登录终端？'), findsOneWidget);
    await tester.tap(find.byKey(const Key('login-session-revoke-confirm')));
    await tester.pumpAndSettle();

    expect(repository.revokedIds, ['web-other']);
    expect(find.text('Web 端登录'), findsNothing);
    expect(find.text('该登录终端已退出。'), findsOneWidget);
  });

  testWidgets('读取和撤销失败均保留请求 ID 与恢复入口', (tester) async {
    await tester.pumpWidget(_app(_FakeRepository(failLoad: true)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login-sessions-retry')), findsOneWidget);
    expect(find.text('请求 ID：session-load-request'), findsOneWidget);

    final repository = _FakeRepository(sessions: [_other], failRevoke: true);
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('login-session-revoke-web-other')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login-session-revoke-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Web 端登录'), findsOneWidget);
    expect(find.text('请求 ID：session-revoke-request'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 登录终端页无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 760);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        _app(_FakeRepository(sessions: [_current, _other, _unknown])),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('其他终端登录'), findsOneWidget);
    });
  }
}

Widget _app(LoginSessionRepository repository) {
  return ProviderScope(
    overrides: [loginSessionRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(theme: AppTheme.light, home: const LoginSessionsPage()),
  );
}

class _FakeRepository implements LoginSessionRepository {
  _FakeRepository({
    this.sessions = const [],
    this.failLoad = false,
    this.failRevoke = false,
  });

  final List<LoginSessionModel> sessions;
  final bool failLoad;
  final bool failRevoke;
  final List<String> revokedIds = [];

  @override
  Future<List<LoginSessionModel>> fetchSessions() async {
    if (failLoad) {
      throw const ApiFailure(
        userMessage: '终端加载失败',
        requestId: 'session-load-request',
      );
    }
    return sessions;
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    if (failRevoke) {
      throw const ApiFailure(
        userMessage: '终端退出失败',
        requestId: 'session-revoke-request',
      );
    }
    revokedIds.add(sessionId);
  }
}

final _current = LoginSessionModel(
  id: 'mobile-current',
  platform: LoginSessionPlatform.mobile,
  isCurrent: true,
  signedInAt: _signedInAt,
  lastActiveAt: _lastActiveAt,
  expiresAt: _expiresAt,
);

final _other = LoginSessionModel(
  id: 'web-other',
  platform: LoginSessionPlatform.web,
  isCurrent: false,
  signedInAt: _signedInAt,
  lastActiveAt: _lastActiveAt,
  expiresAt: _expiresAt,
);

final _unknown = LoginSessionModel(
  id: 'unknown-other',
  platform: LoginSessionPlatform.unknown,
  isCurrent: false,
  signedInAt: _signedInAt,
  lastActiveAt: _lastActiveAt,
  expiresAt: _expiresAt,
);

final _signedInAt = DateTime.utc(2026, 8, 5, 9);
final _lastActiveAt = DateTime.utc(2026, 8, 9, 10);
final _expiresAt = DateTime.utc(2026, 8, 12, 9);
