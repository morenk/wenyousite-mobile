import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';

abstract interface class UserRelationRepository {
  Future<void> follow(String userId);

  Future<void> unfollow(String userId);

  Future<void> block(String userId);

  Future<void> unblock(String userId);
}

class ApiUserRelationRepository implements UserRelationRepository {
  ApiUserRelationRepository(this._api);

  final UsersApi _api;

  @override
  Future<void> follow(String userId) =>
      _run(() => _api.usersFollowFollow(id: userId), '关注结果返回不完整，请重新加载确认。');

  @override
  Future<void> unfollow(String userId) =>
      _run(() => _api.usersFollowUnfollow(id: userId), '取消关注结果返回不完整，请重新加载确认。');

  @override
  Future<void> block(String userId) =>
      _run(() => _api.usersFollowBlock(id: userId), '拉黑结果返回不完整，请重新加载确认。');

  @override
  Future<void> unblock(String userId) =>
      _run(() => _api.usersFollowUnblock(id: userId), '取消拉黑结果返回不完整，请重新加载确认。');

  Future<void> _run(
    Future<Response<Object?>> Function() request,
    String incompleteMessage,
  ) async {
    try {
      final response = await request();
      if (response.data == null) {
        throw ApiFailure(userMessage: incompleteMessage);
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final userRelationRepositoryProvider = Provider<UserRelationRepository>((ref) {
  return ApiUserRelationRepository(ref.watch(wenyouApiProvider).getUsersApi());
});
