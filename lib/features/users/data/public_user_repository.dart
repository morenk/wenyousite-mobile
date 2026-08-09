import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';

abstract interface class PublicUserRepository {
  Future<PublicUserProfileModel> fetchUser(String userId);
}

class ApiPublicUserRepository implements PublicUserRepository {
  ApiPublicUserRepository(this._api);

  final UsersApi _api;

  @override
  Future<PublicUserProfileModel> fetchUser(String userId) async {
    try {
      final response = await _api.usersGetUser(id: userId);
      final dto = response.data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '用户资料返回不完整，请稍后重试。');
      }
      final bio = dto.bio?.trim();
      return PublicUserProfileModel(
        id: dto.id,
        username: dto.username,
        avatarUrl: _safeHttpUrl(dto.avatar),
        bio: bio == null || bio.isEmpty ? null : bio,
        level: dto.level?.toInt() ?? 0,
        followingCount: dto.count?.following.toInt() ?? 0,
        followerCount: dto.count?.followers.toInt() ?? 0,
        receivedTipTotal: dto.receivedTipTotal ?? '0',
        receivedTipCount: dto.receivedTipCount?.toInt() ?? 0,
        isFollowing: dto.isFollowing ?? false,
        isFollowedBy: dto.isFollowedBy ?? false,
        isBlocked: dto.isBlocked ?? false,
        isBlockedBy: dto.isBlockedBy ?? false,
        isDeactivated: dto.isDeactivated ?? false,
        createdAt: dto.createdAt,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  String? _safeHttpUrl(String? value) {
    if (value == null) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      return null;
    }
    return value;
  }
}

final publicUserRepositoryProvider = Provider<PublicUserRepository>((ref) {
  return ApiPublicUserRepository(ref.watch(wenyouApiProvider).getUsersApi());
});
