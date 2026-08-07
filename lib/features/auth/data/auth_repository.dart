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

  Future<RegistrationCodeInfo> requestRegistrationCode({required String email});

  Future<SessionTokens> completeRegistration({
    required String email,
    required String code,
    required String username,
    required String password,
  });
}

class RegistrationCodeInfo {
  const RegistrationCodeInfo({required this.expiresIn});

  final Duration expiresIn;
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
      return _mobileTokens(response.data?.data, '服务端没有返回移动端登录会话，请稍后重试。');
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<RegistrationCodeInfo> requestRegistrationCode({
    required String email,
  }) async {
    try {
      final response = await _api.authRequestCode(
        requestCodeDto: RequestCodeDto((builder) => builder.email = email),
      );
      final data = response.data?.data;
      final expiresInSeconds = data?.codeExpiresIn.toInt() ?? 0;
      if (data == null || !data.emailSent || expiresInSeconds <= 0) {
        throw const ApiFailure(userMessage: '验证码没有成功发送，请稍后重试。');
      }
      return RegistrationCodeInfo(
        expiresIn: Duration(seconds: expiresInSeconds),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<SessionTokens> completeRegistration({
    required String email,
    required String code,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _api.authVerifyAndComplete(
        verifyAndCompleteDto: VerifyAndCompleteDto(
          (builder) => builder
            ..email = email
            ..code = code
            ..username = username
            ..password = password,
        ),
        // 完成注册会创建登录终端，原生客户端必须显式声明 mobile。
        xClientPlatform: 'mobile',
      );
      return _mobileTokens(response.data?.data, '服务端没有返回移动端注册会话，请直接登录。');
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  SessionTokens _mobileTokens(AuthResponseDto? data, String failureMessage) {
    final refreshToken = data?.refreshToken;
    if (data == null ||
        data.accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw ApiFailure(userMessage: failureMessage);
    }
    return SessionTokens(
      accessToken: data.accessToken,
      refreshToken: refreshToken,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(ref.watch(wenyouApiProvider).getAuthApi());
});
