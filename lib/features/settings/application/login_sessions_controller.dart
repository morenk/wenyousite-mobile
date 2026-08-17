import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/settings/application/login_sessions_state.dart';
import 'package:wenyousite_mobile/features/settings/application/settings_repository_ports.dart';

export 'package:wenyousite_mobile/features/settings/application/login_sessions_state.dart';

class LoginSessionsController extends StateNotifier<LoginSessionsState> {
  LoginSessionsController(this._repository)
    : super(const LoginSessionsState.loading()) {
    load();
  }

  final LoginSessionRepository _repository;
  var _loadEpoch = 0;

  Future<void> load() async {
    if (state.isMutating) return;
    final epoch = ++_loadEpoch;
    state = const LoginSessionsState.loading();
    try {
      final sessions = await _repository.fetchSessions();
      if (!mounted || epoch != _loadEpoch) return;
      state = LoginSessionsState(
        phase: LoginSessionsPhase.ready,
        sessions: sessions,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _loadEpoch) return;
      state = LoginSessionsState(
        phase: LoginSessionsPhase.failed,
        failure: _asFailure(error, '登录终端加载失败，请稍后重试。'),
      );
    }
  }

  Future<bool> revokeSession(String sessionId) async {
    if (state.phase != LoginSessionsPhase.ready || state.isMutating) {
      return false;
    }
    final target = state.sessions
        .where((session) => session.id == sessionId)
        .firstOrNull;
    if (target == null || target.isCurrent) return false;

    final oldSessions = state.sessions;
    state = LoginSessionsState(
      phase: LoginSessionsPhase.ready,
      sessions: oldSessions,
      pendingSessionId: sessionId,
    );
    try {
      await _repository.revokeSession(sessionId);
      if (!mounted) return false;
      state = LoginSessionsState(
        phase: LoginSessionsPhase.ready,
        sessions: oldSessions
            .where((session) => session.id != sessionId)
            .toList(growable: false),
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = LoginSessionsState(
        phase: LoginSessionsPhase.ready,
        sessions: oldSessions,
        actionFailure: _asFailure(error, '终端退出失败，请稍后重试。'),
      );
      return false;
    }
  }

  void clearActionFailure() {
    if (state.actionFailure == null) return;
    state = LoginSessionsState(
      phase: state.phase,
      sessions: state.sessions,
      failure: state.failure,
      pendingSessionId: state.pendingSessionId,
    );
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

final loginSessionsControllerProvider =
    StateNotifierProvider.autoDispose<
      LoginSessionsController,
      LoginSessionsState
    >(
      (ref) =>
          LoginSessionsController(ref.watch(loginSessionRepositoryProvider)),
      dependencies: [loginSessionRepositoryProvider],
    );
