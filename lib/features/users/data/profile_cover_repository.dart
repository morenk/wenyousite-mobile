import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart';
import 'package:wenyousite_mobile/features/users/data/profile_cover_mapper.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';

class ApiProfileCoverRepository implements ProfileCoverRepository {
  ApiProfileCoverRepository(this._api);

  final UsersApi _api;

  @override
  Future<ProfileCoverUpdateResult> setProfileCover({
    required String webMediaId,
    required String mobileMediaId,
  }) async {
    try {
      final response = await _api.usersSetProfileCover(
        setProfileCoverDto: SetProfileCoverDto(
          (builder) => builder
            ..mediaId = webMediaId
            ..mobileMediaId = mobileMediaId,
        ),
      );
      final user = response.data?.data;
      final cover = mapProfileCover(user?.profileCover);
      if (user == null || cover == null || cover.mobile == null) {
        throw const ApiFailure(userMessage: '背景图设置失败，请重新加载资料确认。');
      }
      return ProfileCoverUpdateResult(
        profileCover: cover,
        updatedAt: user.updatedAt,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<ProfileCoverUpdateResult> removeProfileCover() async {
    try {
      final response = await _api.usersRemoveProfileCover();
      final user = response.data?.data;
      if (user == null || user.profileCover != null) {
        throw const ApiFailure(userMessage: '背景图移除失败，请重新加载资料确认。');
      }
      return ProfileCoverUpdateResult(
        profileCover: null,
        updatedAt: user.updatedAt,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final apiProfileCoverRepositoryProvider = Provider<ProfileCoverRepository>((
  ref,
) {
  return ApiProfileCoverRepository(ref.watch(wenyouApiProvider).getUsersApi());
});
