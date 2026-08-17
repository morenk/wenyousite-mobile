import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';

abstract interface class SessionRemote {
  Future<SessionTokens> refresh(String refreshToken);

  Future<void> logout(SessionTokens tokens);
}

class ApiSessionRemote implements SessionRemote {
  ApiSessionRemote(this._api, [this._uuid = const Uuid()]);

  final AuthApi _api;
  final Uuid _uuid;

  @override
  Future<SessionTokens> refresh(String refreshToken) async {
    try {
      final response = await _api.authRefresh(
        refreshDto: RefreshDto(
          (builder) => builder.refreshToken = refreshToken,
        ),
        // Refreshing a native session must keep the mobile platform marker.
        // Without it the backend treats the request as Web and omits the
        // rotated refresh token from the response, which makes the client
        // clear an otherwise valid session after the access token expires.
        headers: {'X-Request-ID': _uuid.v4(), 'X-Client-Platform': 'mobile'},
      );
      final data = response.data?.data;
      final nextRefreshToken = data?.refreshToken;
      if (data == null ||
          data.accessToken.isEmpty ||
          nextRefreshToken == null ||
          nextRefreshToken.isEmpty) {
        throw const ApiFailure(userMessage: '登录状态已失效，请重新登录。');
      }
      return SessionTokens(
        accessToken: data.accessToken,
        refreshToken: nextRefreshToken,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> logout(SessionTokens tokens) async {
    try {
      await _api.authLogout(
        logoutDto: LogoutDto(
          (builder) => builder.refreshToken = tokens.refreshToken,
        ),
        headers: {
          'Authorization': 'Bearer ${tokens.accessToken}',
          'X-Request-ID': _uuid.v4(),
        },
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}
