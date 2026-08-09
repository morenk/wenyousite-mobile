import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/settings/domain/login_session_models.dart';

abstract interface class LoginSessionRepository {
  Future<List<LoginSessionModel>> fetchSessions();

  Future<void> revokeSession(String sessionId);
}

class ApiLoginSessionRepository implements LoginSessionRepository {
  ApiLoginSessionRepository(this._api);

  final AuthApi _api;

  @override
  Future<List<LoginSessionModel>> fetchSessions() async {
    try {
      final envelope = (await _api.authListSessions()).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '登录终端响应为空，请稍后重试。');
      }
      final sessions = envelope.data.map(_mapSession).toList(growable: false);
      sessions.sort((left, right) {
        if (left.isCurrent != right.isCurrent) return left.isCurrent ? -1 : 1;
        return right.lastActiveAt.compareTo(left.lastActiveAt);
      });
      return List.unmodifiable(sessions);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    try {
      final result = (await _api.authRevokeSession(id: sessionId)).data?.data;
      if (result == null) {
        throw const ApiFailure(userMessage: '终端退出结果不完整，请重新加载确认。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  LoginSessionModel _mapSession(SessionResponseDto dto) {
    final id = dto.id.trim();
    if (id.isEmpty) {
      throw const ApiFailure(userMessage: '登录终端缺少管理 ID，请稍后重试。');
    }
    return LoginSessionModel(
      id: id,
      platform: switch (dto.platform) {
        SessionResponseDtoPlatformEnum.web => LoginSessionPlatform.web,
        SessionResponseDtoPlatformEnum.mobile => LoginSessionPlatform.mobile,
        _ => LoginSessionPlatform.unknown,
      },
      isCurrent: dto.isCurrent,
      signedInAt: dto.signedInAt,
      lastActiveAt: dto.lastActiveAt,
      expiresAt: dto.expiresAt,
    );
  }
}

final loginSessionRepositoryProvider = Provider<LoginSessionRepository>((ref) {
  return ApiLoginSessionRepository(ref.watch(wenyouApiProvider).getAuthApi());
});
