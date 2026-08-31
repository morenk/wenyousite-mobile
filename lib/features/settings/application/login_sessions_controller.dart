import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/settings/application/login_sessions_state.dart';
import 'package:wenyousite_mobile/features/settings/application/settings_repository_ports.dart';
import 'package:wenyousite_mobile/features/settings/domain/login_session_models.dart';

export 'package:wenyousite_mobile/features/settings/application/login_sessions_state.dart';

class LoginSessionsController extends StateNotifier<LoginSessionsState> {
  LoginSessionsController(
    this._repository, {
    this._reconciler = const WriteReconciler(),
  }) : super(const LoginSessionsState.loading()) {
    load();
  }

  final LoginSessionRepository _repository;
  final WriteReconciler _reconciler;
  var _loadEpoch = 0;
  var _actionEpoch = 0;

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
    final epoch = ++_actionEpoch;
    final outcome = await _reconciler.run<void, List<LoginSessionModel>>(
      write: () => _repository.revokeSession(sessionId),
      read: _repository.fetchSessions,
      targetReached: (sessions) =>
          !sessions.any((session) => session.id == sessionId),
      failureMessage: '终端退出失败，请稍后重试。',
      convergentBusinessCodes: const {40400},
      isCurrent: () => mounted && epoch == _actionEpoch,
      onProgress: (progress) {
        if (!mounted || epoch != _actionEpoch) return;
        state = LoginSessionsState(
          phase: LoginSessionsPhase.ready,
          sessions: oldSessions,
          pendingSessionId: sessionId,
          actionOutcome: WriteOutcomeStatus.confirming,
          actionRequestId: progress.requestId,
          actionOutcomeFailure: progress.failure,
        );
      },
    );
    if (outcome.isDiscarded || !mounted || epoch != _actionEpoch) return false;
    switch (outcome.status) {
      case WriteOutcomeStatus.completed:
        state = LoginSessionsState(
          phase: LoginSessionsPhase.ready,
          sessions:
              outcome.projection ??
              oldSessions
                  .where((session) => session.id != sessionId)
                  .toList(growable: false),
        );
        return true;
      case WriteOutcomeStatus.failed:
        state = LoginSessionsState(
          phase: LoginSessionsPhase.ready,
          sessions: oldSessions,
          actionFailure: outcome.failure,
        );
        return false;
      case WriteOutcomeStatus.indeterminate:
        state = LoginSessionsState(
          phase: LoginSessionsPhase.ready,
          sessions: outcome.projection ?? oldSessions,
          actionOutcome: WriteOutcomeStatus.indeterminate,
          actionRequestId: outcome.requestId,
          actionOutcomeFailure: outcome.failure,
        );
        return false;
      case WriteOutcomeStatus.confirming:
        return false;
    }
  }

  void clearActionFailure() {
    if (state.actionFailure == null && state.actionOutcome == null) return;
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
