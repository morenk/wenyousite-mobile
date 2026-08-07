import 'dart:async';

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

class SessionState {
  const SessionState._(this.status, {this.reason});

  const SessionState.guest() : this._(SessionStatus.guest);

  const SessionState.restoring() : this._(SessionStatus.restoring);

  const SessionState.authenticated() : this._(SessionStatus.authenticated);

  const SessionState.invalidated(SessionInvalidationReason reason)
    : this._(SessionStatus.invalidated, reason: reason);

  final SessionStatus status;
  final SessionInvalidationReason? reason;

  bool get isAuthenticated => status == SessionStatus.authenticated;
}

class SessionController extends StateNotifier<SessionState> {
  SessionController(this._tokenStore, this._remote)
    : super(const SessionState.guest());

  final TokenStore _tokenStore;
  final SessionRemote _remote;
  SessionTokens? _tokens;
  Future<SessionTokens>? _refreshInFlight;

  SessionTokens? get tokens => _tokens;

  Future<void> restore() async {
    state = const SessionState.restoring();
    try {
      _tokens = await _tokenStore.read();
      state = _tokens == null
          ? const SessionState.guest()
          : const SessionState.authenticated();
    } on Object {
      _tokens = null;
      await _tokenStore.clear();
      state = const SessionState.guest();
    }
  }

  Future<void> authenticate(SessionTokens tokens) async {
    await _tokenStore.write(tokens);
    _tokens = tokens;
    state = const SessionState.authenticated();
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
    try {
      final next = await _remote.refresh(current.refreshToken);
      await authenticate(next);
      return next;
    } on ApiFailure catch (failure) {
      await invalidate(
        failure.invalidatesSession
            ? _reasonFor(failure.businessCode)
            : SessionInvalidationReason.refreshFailed,
      );
      rethrow;
    } on Object catch (error) {
      await invalidate(SessionInvalidationReason.refreshFailed);
      throw ApiFailure(userMessage: '登录已失效，请重新登录。', cause: error);
    }
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
    state = SessionState.invalidated(reason);
  }

  Future<void> logoutLocally() async {
    _tokens = null;
    await _tokenStore.clear();
    state = const SessionState.guest();
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
}
