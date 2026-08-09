import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/settings/application/login_sessions_controller.dart';
import 'package:wenyousite_mobile/features/settings/data/login_session_repository.dart';
import 'package:wenyousite_mobile/features/settings/domain/login_session_models.dart';

void main() {
  test('首次读取服务端终端并撤销非当前终端', () async {
    final repository = _FakeRepository(sessions: [_current, _other]);
    final controller = LoginSessionsController(repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(controller.state.phase, LoginSessionsPhase.ready);
    expect(controller.state.sessions, [_current, _other]);
    expect(await controller.revokeSession(_other.id), isTrue);

    expect(repository.revokedIds, [_other.id]);
    expect(controller.state.sessions, [_current]);
  });

  test('客户端拒绝撤销当前终端且不发请求', () async {
    final repository = _FakeRepository(sessions: [_current, _other]);
    final controller = LoginSessionsController(repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.revokeSession(_current.id), isFalse);
    expect(repository.revokedIds, isEmpty);
    expect(controller.state.sessions, [_current, _other]);
  });

  test('撤销失败保留终端并显示请求 ID', () async {
    final repository = _FakeRepository(
      sessions: [_current, _other],
      revokeFailure: const ApiFailure(
        userMessage: '终端退出失败',
        requestId: 'session-revoke-request',
      ),
    );
    final controller = LoginSessionsController(repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.revokeSession(_other.id), isFalse);

    expect(controller.state.sessions, [_current, _other]);
    expect(controller.state.actionFailure?.requestId, 'session-revoke-request');
  });

  test('撤销期间串行化写入并阻止刷新覆盖', () async {
    final revokeCompleter = Completer<void>();
    final repository = _FakeRepository(
      sessions: [_current, _other],
      revokeCompleter: revokeCompleter,
    );
    final controller = LoginSessionsController(repository);
    addTearDown(controller.dispose);
    await _settle();

    final pending = controller.revokeSession(_other.id);
    expect(controller.state.pendingSessionId, _other.id);
    await controller.load();
    expect(repository.fetchCalls, 1);
    expect(await controller.revokeSession(_other.id), isFalse);
    revokeCompleter.complete();
    expect(await pending, isTrue);
  });
}

class _FakeRepository implements LoginSessionRepository {
  _FakeRepository({
    required this.sessions,
    this.revokeFailure,
    this.revokeCompleter,
  });

  final List<LoginSessionModel> sessions;
  final ApiFailure? revokeFailure;
  final Completer<void>? revokeCompleter;
  int fetchCalls = 0;
  final List<String> revokedIds = [];

  @override
  Future<List<LoginSessionModel>> fetchSessions() async {
    fetchCalls += 1;
    return sessions;
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    if (revokeFailure != null) throw revokeFailure!;
    if (revokeCompleter != null) await revokeCompleter!.future;
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

final _signedInAt = DateTime.utc(2026, 8, 5, 9);
final _lastActiveAt = DateTime.utc(2026, 8, 9, 10);
final _expiresAt = DateTime.utc(2026, 8, 12, 9);

Future<void> _settle() => Future<void>.delayed(Duration.zero);
