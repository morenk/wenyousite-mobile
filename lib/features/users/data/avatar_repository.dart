import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';

export 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart'
    show AvatarRepository, avatarRepositoryProvider;

class ApiAvatarRepository implements AvatarRepository {
  ApiAvatarRepository(this._api);

  final UsersApi _api;

  @override
  Future<AvatarUpdateResult> setAvatar(String mediaId) async {
    try {
      final response = await _api.usersSetAvatar(
        setAvatarDto: SetAvatarDto((builder) => builder.mediaId = mediaId),
      );
      final user = response.data?.data;
      if (user == null) {
        throw const ApiFailure(userMessage: '头像设置失败，请重新加载资料确认。');
      }
      final avatarUrl = _safeHttpUrl(user.avatar);
      if (avatarUrl == null) {
        throw const ApiFailure(userMessage: '头像设置结果缺少安全图片地址，请重新加载资料确认。');
      }
      return AvatarUpdateResult(
        avatarUrl: avatarUrl,
        updatedAt: user.updatedAt,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<AvatarUpdateResult> removeAvatar() async {
    try {
      final response = await _api.usersRemoveAvatar();
      final user = response.data?.data;
      if (user == null || user.avatar != null) {
        throw const ApiFailure(userMessage: '头像移除失败，请重新加载资料确认。');
      }
      return AvatarUpdateResult(avatarUrl: null, updatedAt: user.updatedAt);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  String? _safeHttpUrl(String? value) {
    if (value == null) return null;
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return null;
    }
    return value;
  }
}

final apiAvatarRepositoryProvider = Provider<AvatarRepository>((ref) {
  return ApiAvatarRepository(ref.watch(wenyouApiProvider).getUsersApi());
});
