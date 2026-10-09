import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionTokens {
  const SessionTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

abstract interface class TokenStore {
  Future<SessionTokens?> read();

  Future<void> write(SessionTokens tokens);

  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore(this._storage);

  static const _sessionKey = 'wenyou_mobile_session_v1';
  final FlutterSecureStorage _storage;

  @override
  Future<SessionTokens?> read() async {
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final accessToken = json['accessToken'] as String?;
      final refreshToken = json['refreshToken'] as String?;
      if (accessToken == null || refreshToken == null) {
        await clear();
        return null;
      }
      return SessionTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on FormatException {
      await clear();
      return null;
    } on TypeError {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(SessionTokens tokens) {
    return _storage.write(
      key: _sessionKey,
      value: jsonEncode({
        'accessToken': tokens.accessToken,
        'refreshToken': tokens.refreshToken,
      }),
    );
  }

  @override
  Future<void> clear() => _storage.delete(key: _sessionKey);
}
