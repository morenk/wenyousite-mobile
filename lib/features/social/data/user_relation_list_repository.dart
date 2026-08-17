import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_list_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/user_relation_list_models.dart';

export 'package:wenyousite_mobile/features/social/application/user_relation_list_repository_ports.dart'
    show UserRelationListRepository, userRelationListRepositoryProvider;

class ApiUserRelationListRepository implements UserRelationListRepository {
  ApiUserRelationListRepository(this._api);

  final UsersApi _api;

  @override
  Future<List<UserRelationListItem>> fetchFollowing({String? userId}) async {
    try {
      final records = userId == null
          ? (await _api.usersFollowFollowing()).data?.data
          : (await _api.usersFollowUserFollowing(id: userId)).data?.data;
      if (records == null) {
        throw const ApiFailure(userMessage: '关注列表加载失败，请稍后重试。');
      }
      return List.unmodifiable(
        records
            .where((record) => record.following != null)
            .map((record) => _mapAuthor(record.following!, record.createdAt)),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<List<UserRelationListItem>> fetchFollowers({String? userId}) async {
    try {
      final records = userId == null
          ? (await _api.usersFollowFollowers()).data?.data
          : (await _api.usersFollowUserFollowers(id: userId)).data?.data;
      if (records == null) {
        throw const ApiFailure(userMessage: '粉丝列表加载失败，请稍后重试。');
      }
      return List.unmodifiable(
        records
            .where((record) => record.follower != null)
            .map((record) => _mapAuthor(record.follower!, record.createdAt)),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<List<UserRelationListItem>> fetchBlocks() async {
    try {
      final records = (await _api.usersFollowBlocks()).data?.data;
      if (records == null) {
        throw const ApiFailure(userMessage: '黑名单加载失败，请稍后重试。');
      }
      return List.unmodifiable(
        records.map((record) => _mapAuthor(record.blocked, record.createdAt)),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  UserRelationListItem _mapAuthor(
    PostAuthorResponseDto author,
    DateTime relatedAt,
  ) {
    return UserRelationListItem(
      userId: author.id,
      username: author.username,
      avatarUrl: _safeHttpUrl(author.avatar),
      level: author.level.toInt(),
      relatedAt: relatedAt,
    );
  }

  String? _safeHttpUrl(String? value) {
    if (value == null) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasAuthority) return null;
    if (uri.scheme != 'https' && uri.scheme != 'http') return null;
    return uri.toString();
  }
}

final apiUserRelationListRepositoryProvider =
    Provider<UserRelationListRepository>((ref) {
      return ApiUserRelationListRepository(
        ref.watch(wenyouApiProvider).getUsersApi(),
      );
    });
