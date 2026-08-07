import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';

abstract interface class AuthRepository {
  Future<SessionTokens> login({
    required String account,
    required String password,
  });
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api);

  final AuthApi _api;

  @override
  Future<SessionTokens> login({
    required String account,
    required String password,
  }) async {
    try {
      final response = await _api.authLogin(
        loginDto: LoginDto(
          (builder) => builder
            ..account = account
            ..password = password,
        ),
        // Flutter 必须显式声明 mobile，不能依赖后端的 Web 兼容默认值。
        xClientPlatform: 'mobile',
      );
      final data = response.data?.data;
      final refreshToken = data?.refreshToken;
      if (data == null || refreshToken == null || refreshToken.isEmpty) {
        throw const ApiFailure(userMessage: '服务端没有返回移动端登录会话，请稍后重试。');
      }
      return SessionTokens(
        accessToken: data.accessToken,
        refreshToken: refreshToken,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(ref.watch(wenyouApiProvider).getAuthApi());
});
