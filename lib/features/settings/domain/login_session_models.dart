import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum LoginSessionPlatform { web, mobile, unknown }

class LoginSessionModel {
  const LoginSessionModel({
    required this.id,
    required this.platform,
    required this.isCurrent,
    required this.signedInAt,
    required this.lastActiveAt,
    required this.expiresAt,
  });

  final String id;
  final LoginSessionPlatform platform;
  final bool isCurrent;
  final DateTime signedInAt;
  final DateTime lastActiveAt;
  final DateTime expiresAt;
}

enum LoginSessionsPhase { loading, ready, failed }

class LoginSessionsState {
  const LoginSessionsState({
    required this.phase,
    this.sessions = const [],
    this.failure,
    this.pendingSessionId,
    this.actionFailure,
  });

  const LoginSessionsState.loading() : this(phase: LoginSessionsPhase.loading);

  final LoginSessionsPhase phase;
  final List<LoginSessionModel> sessions;
  final ApiFailure? failure;
  final String? pendingSessionId;
  final ApiFailure? actionFailure;

  bool get isMutating => pendingSessionId != null;
}
