import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
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
  SessionController(
    this._tokenStore,
    this._refreshDio, [
    this._uuid = const Uuid(),
  ]) : super(const SessionState.guest());

  final TokenStore _tokenStore;
  final Dio _refreshDio;
  final Uuid _uuid;
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
      final response = await _refreshDio.post<Map<String, dynamic>>(
        'auth/refresh',
        data: {'refreshToken': current.refreshToken},
        options: Options(
          headers: {'X-Request-ID': _uuid.v4(), 'X-Client-Platform': 'mobile'},
        ),
      );
      final payload = response.data?['data'];
      if (payload is! Map) {
        throw const FormatException('刷新响应缺少 data');
      }
      final accessToken = payload['accessToken'];
      final refreshToken = payload['refreshToken'];
      if (accessToken is! String || refreshToken is! String) {
        throw const FormatException('刷新响应缺少双 Token');
      }
      final next = SessionTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await authenticate(next);
      return next;
    } on DioException catch (error) {
      final failure = ApiFailure.fromDio(error);
      await invalidate(
        failure.invalidatesSession
            ? _reasonFor(failure.businessCode)
            : SessionInvalidationReason.refreshFailed,
      );
      throw failure;
    } on Object catch (error) {
      await invalidate(SessionInvalidationReason.refreshFailed);
      throw ApiFailure(userMessage: '登录已失效，请重新登录。', cause: error);
    }
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
