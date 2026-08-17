import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart';
import 'package:wenyousite_mobile/features/users/data/profile_cover_mapper.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';

export 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart'
    show MeProfileRepository, meProfileRepositoryProvider;

class ApiMeProfileRepository implements MeProfileRepository {
  ApiMeProfileRepository(this._api);

  final UsersApi _api;

  @override
  Future<MeProfileModel> fetchMe() async {
    try {
      final response = await _api.usersGetMe();
      final envelope = response.data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '个人资料加载失败，请稍后重试。');
      }
      final dto = envelope.data;
      return MeProfileModel(
        id: dto.id,
        email: dto.email,
        username: dto.username,
        avatarUrl: _safeHttpUrl(dto.avatar),
        bio: _safeBio(dto.bio),
        profileCover: mapProfileCover(dto.profileCover),
        level: dto.level.toInt(),
        experience: dto.experience.toInt(),
        currentLevelExperience: dto.currentLevelExperience.toInt(),
        nextLevelExperience: dto.nextLevelExperience?.toInt(),
        receivedTipTotal: dto.receivedTipTotal,
        receivedTipCount: dto.receivedTipCount.toInt(),
        showRecentReplies: dto.showRecentReplies,
        showPlayedThreads: dto.showPlayerBadges,
        showBookmarks: dto.showBookmarks,
        followingCount: dto.count.following.toInt(),
        followerCount: dto.count.followers.toInt(),
        createdAt: dto.createdAt,
        updatedAt: dto.updatedAt,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<MeProfileUpdateResult> updateMe(MeProfilePatch patch) async {
    try {
      final response = await _api.usersUpdateMe(
        updateUserDto: UpdateUserDto(
          (dto) => dto
            ..username = patch.username
            ..bio = patch.bio
            ..showRecentReplies = patch.showRecentReplies
            ..showPlayerBadges = patch.showPlayedThreads
            ..showBookmarks = patch.showBookmarks,
        ),
      );
      final envelope = response.data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '资料保存失败，请重试。');
      }
      final dto = envelope.data;
      return MeProfileUpdateResult(
        email: dto.email,
        username: dto.username,
        avatarUrl: _safeHttpUrl(dto.avatar),
        bio: _safeBio(dto.bio),
        profileCover: mapProfileCover(dto.profileCover),
        level: dto.level.toInt(),
        experience: dto.experience.toInt(),
        currentLevelExperience: dto.currentLevelExperience.toInt(),
        nextLevelExperience: dto.nextLevelExperience?.toInt(),
        receivedTipTotal: dto.receivedTipTotal,
        receivedTipCount: dto.receivedTipCount.toInt(),
        showRecentReplies: dto.showRecentReplies,
        showPlayedThreads: dto.showPlayerBadges,
        showBookmarks: dto.showBookmarks,
        updatedAt: dto.updatedAt,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  String? _safeBio(String? value) {
    final bio = value?.trim();
    return bio == null || bio.isEmpty ? null : bio;
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

final apiMeProfileRepositoryProvider = Provider<MeProfileRepository>((ref) {
  return ApiMeProfileRepository(ref.watch(wenyouApiProvider).getUsersApi());
});
