import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/settings/application/settings_repository_ports.dart';

export 'package:wenyousite_mobile/features/settings/application/settings_repository_ports.dart'
    show CredentialSecurityRepository, credentialSecurityRepositoryProvider;

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
        throw const ApiFailure(userMessage: '密码修改失败，请重新登录确认。');
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
        extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
        changeEmailRequestDto: ChangeEmailRequestDto(
          (dto) => dto
            ..newEmail = newEmail
            ..oldPassword = oldPassword,
        ),
      )).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '验证码发送失败，请稍后重试。');
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
        throw const ApiFailure(userMessage: '邮箱更换失败，请重新登录确认。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final apiCredentialSecurityRepositoryProvider =
    Provider<CredentialSecurityRepository>((ref) {
      return ApiCredentialSecurityRepository(
        ref.watch(wenyouApiProvider).getAuthApi(),
      );
    });
