import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';

enum SessionStatus { guest, restoring, authenticated, invalidated }

enum SessionInvalidationReason {
  revoked,
  compromised,
  locked,
  deactivated,
  refreshFailed,
}

/// Stable account boundary for state that must survive access-token rotation.
///
/// [generation] advances when a login session starts or ends. Token refreshes
/// keep the same scope so account-owned editors and pending writes are not
/// disposed while credentials rotate.
class SessionScope {
  const SessionScope({required this.accountId, required this.generation});

  final String? accountId;
  final int generation;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SessionScope &&
            other.accountId == accountId &&
            other.generation == generation;
  }

  @override
  int get hashCode => Object.hash(accountId, generation);
}

class SessionState {
  const SessionState._(this.status, {this.reason, this.generation = 0});

  const SessionState.guest({int generation = 0})
    : this._(SessionStatus.guest, generation: generation);

  const SessionState.restoring({int generation = 0})
    : this._(SessionStatus.restoring, generation: generation);

  const SessionState.authenticated({int generation = 0})
    : this._(SessionStatus.authenticated, generation: generation);

  const SessionState.invalidated(
    SessionInvalidationReason reason, {
    int generation = 0,
  }) : this._(
         SessionStatus.invalidated,
         reason: reason,
         generation: generation,
       );

  final SessionStatus status;
  final SessionInvalidationReason? reason;
  final int generation;

  bool get isAuthenticated => status == SessionStatus.authenticated;
}

class SessionController extends StateNotifier<SessionState> {
  SessionController(this._tokenStore, this._remote)
    : super(const SessionState.guest());

  final TokenStore _tokenStore;
  final SessionRemote _remote;
  SessionTokens? _tokens;
  Future<SessionTokens>? _refreshInFlight;
  int _sessionGeneration = 0;

  SessionTokens? get tokens => _tokens;

  SessionScope get scope =>
      SessionScope(accountId: currentUserId, generation: _sessionGeneration);

  /// 仅用于把本地敏感数据按当前登录用户隔离。
  ///
  /// 身份与权限仍由服务端校验；这里不把未验签 JWT 当作授权事实，也不持久化
  /// payload。若后端未来改用不透明 Token，则安全降级为 null 并由业务请求取得
  /// 当前用户 ID。
  String? get currentUserId {
    final token = _tokens?.accessToken;
    if (token == null) return null;
    final segments = token.split('.');
    if (segments.length != 3) return null;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(segments[1]))),
      );
      if (payload is! Map) return null;
      final subject = payload['sub'];
      return subject is String && subject.isNotEmpty ? subject : null;
    } on Object {
      return null;
    }
  }

  Future<void> restore() async {
    final hadTokens = _tokens != null;
    final previousAccountId = currentUserId;
    state = SessionState.restoring(generation: _sessionGeneration);
    try {
      final restored = await _tokenStore.read();
      _tokens = restored;
      if (hadTokens != (restored != null) ||
          previousAccountId != currentUserId) {
        _sessionGeneration += 1;
      }
      state = _tokens == null
          ? SessionState.guest(generation: _sessionGeneration)
          : SessionState.authenticated(generation: _sessionGeneration);
    } on Object {
      _tokens = null;
      await _tokenStore.clear();
      if (hadTokens) _sessionGeneration += 1;
      state = SessionState.guest(generation: _sessionGeneration);
    }
  }

  Future<void> authenticate(SessionTokens tokens) async {
    await _replaceTokens(tokens, advanceGeneration: true);
  }

  Future<SessionTokens> refresh() {
    final existing = _refreshInFlight;
    if (existing != null) return existing;
    final operation = _performRefresh();
    _refreshInFlight = operation;
    return operation.whenComplete(() => _refreshInFlight = null);
  }

  Future<SessionTokens> _performRefresh() async {
    final current = _tokens;
    if (current == null) {
      throw const ApiFailure(userMessage: '登录已失效，请重新登录。');
    }
    final generation = _sessionGeneration;
    try {
      final next = await _remote.refresh(current.refreshToken);
      _ensureRefreshStillCurrent(current, generation);
      await _replaceTokens(next, advanceGeneration: false);
      return next;
    } on ApiFailure catch (failure) {
      // A refresh can fail because the device is temporarily offline or the
      // service is unavailable. Keep durable tokens in those cases so a
      // later request can retry instead of forcing a needless login.
      if (_refreshFailureInvalidatesSession(failure) &&
          _isRefreshStillCurrent(current, generation)) {
        await invalidate(_reasonFor(failure.businessCode));
      }
      rethrow;
    } on Object catch (error) {
      if (_isRefreshStillCurrent(current, generation)) {
        await invalidate(SessionInvalidationReason.refreshFailed);
      }
      throw ApiFailure(userMessage: '登录已失效，请重新登录。', cause: error);
    }
  }

  bool _isRefreshStillCurrent(SessionTokens tokens, int generation) {
    return identical(_tokens, tokens) && _sessionGeneration == generation;
  }

  void _ensureRefreshStillCurrent(SessionTokens tokens, int generation) {
    if (_isRefreshStillCurrent(tokens, generation)) return;
    throw const ApiFailure(userMessage: '登录状态已变化，请重试。');
  }

  Future<void> logout() async {
    var current = _tokens;
    if (current == null) {
      await logoutLocally();
      return;
    }
    try {
      await _remote.logout(current);
    } on ApiFailure catch (failure) {
      if (failure.isExpiredAccessToken) {
        current = await refresh();
        try {
          await _remote.logout(current);
        } on ApiFailure catch (retryFailure) {
          if (retryFailure.invalidatesSession) {
            await logoutLocally();
            return;
          }
          rethrow;
        }
        await logoutLocally();
        return;
      }
      if (failure.invalidatesSession) {
        await logoutLocally();
        return;
      }
      rethrow;
    }
    await logoutLocally();
  }

  Future<void> invalidate(SessionInvalidationReason reason) async {
    _tokens = null;
    await _tokenStore.clear();
    _sessionGeneration += 1;
    state = SessionState.invalidated(reason, generation: _sessionGeneration);
  }

  Future<void> logoutLocally() async {
    _tokens = null;
    await _tokenStore.clear();
    _sessionGeneration += 1;
    state = SessionState.guest(generation: _sessionGeneration);
  }

  Future<void> _replaceTokens(
    SessionTokens tokens, {
    required bool advanceGeneration,
  }) async {
    await _tokenStore.write(tokens);
    _tokens = tokens;
    if (advanceGeneration) _sessionGeneration += 1;
    state = SessionState.authenticated(generation: _sessionGeneration);
  }

  SessionInvalidationReason _reasonFor(int? code) {
    return switch (code) {
      40103 => SessionInvalidationReason.revoked,
      40104 => SessionInvalidationReason.compromised,
      40105 => SessionInvalidationReason.locked,
      40106 => SessionInvalidationReason.deactivated,
      _ => SessionInvalidationReason.refreshFailed,
    };
  }

  bool _refreshFailureInvalidatesSession(ApiFailure failure) {
    // Refresh responses use HTTP 401 for an invalid/expired/revoked session.
    final code = failure.businessCode;
    if (code != null && code >= 40100 && code <= 40115) return true;
    return failure.httpStatus == 401;
  }
}
