import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';

abstract interface class AccountDeletionRepository {
  Future<void> deleteAccount();
}

class ApiAccountDeletionRepository implements AccountDeletionRepository {
  ApiAccountDeletionRepository(this._api);

  final UsersApi _api;

  @override
  Future<void> deleteAccount() async {
    try {
      final response = await _api.usersDeleteMe();
      if ((response.data?.data.message.trim() ?? '').isEmpty) {
        throw const ApiFailure(userMessage: '账号注销结果不完整，请重新确认账号状态。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final accountDeletionRepositoryProvider = Provider<AccountDeletionRepository>((
  ref,
) {
  return ApiAccountDeletionRepository(
    ref.watch(wenyouApiProvider).getUsersApi(),
  );
});
