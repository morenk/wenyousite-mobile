import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';

abstract interface class CredentialSecurityRepository {
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<void> requestEmailChangeCode({
    required String newEmail,
    required String oldPassword,
  });

  Future<void> verifyEmailChange({
    required String newEmail,
    required String code,
  });
}

class ApiCredentialSecurityRepository implements CredentialSecurityRepository {
  ApiCredentialSecurityRepository(this._api);

  final AuthApi _api;

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final data = (await _api.authChangePassword(
        changePasswordDto: ChangePasswordDto(
          (dto) => dto
            ..oldPassword = oldPassword
            ..newPassword = newPassword,
        ),
      )).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '密码修改结果不完整，请重新登录确认。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> requestEmailChangeCode({
    required String newEmail,
    required String oldPassword,
  }) async {
    try {
      final data = (await _api.authRequestChangeEmailCode(
        changeEmailRequestDto: ChangeEmailRequestDto(
          (dto) => dto
            ..newEmail = newEmail
            ..oldPassword = oldPassword,
        ),
      )).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '验证码发送结果不完整，请稍后重试。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> verifyEmailChange({
    required String newEmail,
    required String code,
  }) async {
    try {
      final data = (await _api.authVerifyChangeEmail(
        changeEmailVerifyDto: ChangeEmailVerifyDto(
          (dto) => dto
            ..newEmail = newEmail
            ..code = code,
        ),
      )).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '邮箱更换结果不完整，请重新登录确认。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final credentialSecurityRepositoryProvider =
    Provider<CredentialSecurityRepository>((ref) {
      return ApiCredentialSecurityRepository(
        ref.watch(wenyouApiProvider).getAuthApi(),
      );
    });
