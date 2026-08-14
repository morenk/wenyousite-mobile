import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/auth/application/auth_ports.dart';

export 'package:wenyousite_mobile/features/auth/application/auth_ports.dart'
    show
        EmailVerificationAccount,
        EmailVerificationRepository,
        emailVerificationRepositoryProvider;

class ApiEmailVerificationRepository implements EmailVerificationRepository {
  ApiEmailVerificationRepository(this._authApi, this._usersApi);

  final AuthApi _authApi;
  final UsersApi _usersApi;

  @override
  Future<EmailVerificationAccount> fetchAccount() async {
    try {
      final response = await _usersApi.usersGetMe();
      final account = response.data?.data;
      final email = account?.email.trim() ?? '';
      if (account == null || email.isEmpty) {
        throw const ApiFailure(userMessage: '账号邮箱状态返回不完整，请稍后重试。');
      }
      return EmailVerificationAccount(
        email: email,
        isVerified: account.emailVerified,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> resendCode({required String email}) async {
    try {
      final response = await _authApi.authResendVerification(
        resendVerificationDto: ResendVerificationDto(
          (builder) => builder.email = email.trim().toLowerCase(),
        ),
      );
      if ((response.data?.data.message.trim() ?? '').isEmpty) {
        throw const ApiFailure(userMessage: '验证码发送结果不完整，请稍后重试。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> verifyCode({required String code}) async {
    try {
      final response = await _authApi.authVerifyEmail(
        verifyEmailDto: VerifyEmailDto(
          (builder) => builder.token = code.trim(),
        ),
      );
      if ((response.data?.data.message.trim() ?? '').isEmpty) {
        throw const ApiFailure(userMessage: '邮箱验证结果不完整，请重新确认状态。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final apiEmailVerificationRepositoryProvider =
    Provider<EmailVerificationRepository>((ref) {
      final api = ref.watch(wenyouApiProvider);
      return ApiEmailVerificationRepository(
        api.getAuthApi(),
        api.getUsersApi(),
      );
    });
