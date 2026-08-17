import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/settings/domain/login_session_models.dart';

enum LoginSessionsPhase { loading, ready, failed }

class LoginSessionsState {
  const LoginSessionsState({
    required this.phase,
    this.sessions = const [],
    this.failure,
    this.pendingSessionId,
    this.actionFailure,
    this.actionOutcome,
    this.actionRequestId,
  });

  const LoginSessionsState.loading() : this(phase: LoginSessionsPhase.loading);

  final LoginSessionsPhase phase;
  final List<LoginSessionModel> sessions;
  final ApiFailure? failure;
  final String? pendingSessionId;
  final ApiFailure? actionFailure;
  final WriteOutcomeStatus? actionOutcome;
  final String? actionRequestId;

  bool get isMutating => pendingSessionId != null;
}
