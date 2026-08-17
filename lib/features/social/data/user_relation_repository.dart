import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_models.dart';

export 'package:wenyousite_mobile/features/social/application/user_relation_repository_ports.dart'
    show
        UserRelationProjectionReader,
        UserRelationRepository,
        userRelationRepositoryProvider;

class ApiUserRelationRepository
    implements UserRelationRepository, UserRelationProjectionReader {
  ApiUserRelationRepository(this._api);

  final UsersApi _api;

  @override
  Future<UserRelationProjection> fetchRelation(String userId) async {
    try {
      final data = (await _api.usersGetUser(id: userId)).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '关系状态加载失败，请稍后刷新查看。');
      }
      final followerCount = data.count?.followers.toInt() ?? 0;
      if (followerCount < 0) {
        throw const ApiFailure(userMessage: '关系状态加载失败，请稍后刷新查看。');
      }
      return UserRelationProjection(
        isFollowing: data.isFollowing ?? false,
        isBlocked: data.isBlocked ?? false,
        isBlockedBy: data.isBlockedBy ?? false,
        followerCount: followerCount,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> follow(String userId) =>
      _run(() => _api.usersFollowFollow(id: userId), '关注失败，请重新加载。');

  @override
  Future<void> unfollow(String userId) =>
      _run(() => _api.usersFollowUnfollow(id: userId), '取消关注失败，请重新加载。');

  @override
  Future<void> block(String userId) =>
      _run(() => _api.usersFollowBlock(id: userId), '拉黑失败，请重新加载。');

  @override
  Future<void> unblock(String userId) =>
      _run(() => _api.usersFollowUnblock(id: userId), '取消拉黑失败，请重新加载。');

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

final apiUserRelationRepositoryProvider = Provider<UserRelationRepository>((
  ref,
) {
  return ApiUserRelationRepository(ref.watch(wenyouApiProvider).getUsersApi());
});
