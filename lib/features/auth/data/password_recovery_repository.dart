import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';

abstract interface class PasswordRecoveryRepository {
  Future<void> requestCode({required String email});

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}

class ApiPasswordRecoveryRepository implements PasswordRecoveryRepository {
  ApiPasswordRecoveryRepository(this._api);

  final AuthApi _api;

  @override
  Future<void> requestCode({required String email}) async {
    try {
      final data = (await _api.authForgotPassword(
        forgotPasswordDto: ForgotPasswordDto(
          (builder) => builder.email = email,
        ),
      )).data?.data;
      if (data == null || data.message.trim().isEmpty) {
        throw const ApiFailure(userMessage: '重置验证码发送结果不完整，请稍后重试。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final data = (await _api.authResetPassword(
        resetPasswordDto: ResetPasswordDto(
          (builder) => builder
            ..email = email
            ..token = code
            ..newPassword = newPassword,
        ),
      )).data?.data;
      if (data == null || data.message.trim().isEmpty) {
        throw const ApiFailure(userMessage: '密码重置结果不完整，请稍后重新登录确认。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final passwordRecoveryRepositoryProvider = Provider<PasswordRecoveryRepository>(
  (ref) {
    return ApiPasswordRecoveryRepository(
      ref.watch(wenyouApiProvider).getAuthApi(),
    );
  },
);
