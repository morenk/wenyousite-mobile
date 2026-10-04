import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/thread_identity/data/rp_identity_mapper.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';

class ApiThreadIdentityRepository implements ThreadIdentityRepository {
  ApiThreadIdentityRepository(this._api);
  final ThreadsApi _api;

  @override
  Future<ThreadIdentityState> mine(String threadId) => _read(
    threadId,
    () async =>
        (await _api.threadIdentitiesMine(threadId: threadId)).data?.data,
  );

  @override
  Future<ThreadIdentityState> findUser(String threadId, String userId) => _read(
    threadId,
    () async => (await _api.threadIdentitiesFindUser(
      threadId: threadId,
      userId: userId,
    )).data?.data,
    userId: userId,
  );

  @override
  Future<ThreadIdentityState> update(
    String threadId,
    ThreadIdentityUpdate input,
  ) => _read(
    threadId,
    () async => (await _api.threadIdentitiesUpdate(
      threadId: threadId,
      extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
      updateThreadIdentityDto: UpdateThreadIdentityDto(
        (b) => b
          ..nickname = input.nickname
          ..avatarMediaId = input.avatarMediaId
          ..clearNickname = input.clearNickname
          ..clearAvatar = input.clearAvatar
          ..version = input.version,
      ),
    )).data?.data,
  );

  @override
  Future<ThreadIdentityState> clear(String threadId) => _read(
    threadId,
    () async => (await _api.threadIdentitiesClear(
      threadId: threadId,
      extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
    )).data?.data,
  );

  @override
  Future<void> setEnabled(String threadId, {required bool enabled}) async {
    try {
      final value = (await _api.threadIdentitiesSetEnabled(
        threadId: threadId,
        extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
        setThreadIdentityEnabledDto: SetThreadIdentityEnabledDto(
          (b) => b.enabled = enabled,
        ),
      )).data?.data;
      if (value == null || value.enabled != enabled) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'thread_identity_settings_invalid',
        );
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<ThreadIdentityState> _read(
    String threadId,
    Future<ThreadIdentityStateDto?> Function() request, {
    String? userId,
  }) async {
    try {
      final dto = await request();
      if (dto == null ||
          dto.threadId != threadId ||
          dto.account.id != dto.userId ||
          (userId != null && dto.userId != userId)) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'thread_identity_scope_invalid',
        );
      }
      return ThreadIdentityState(
        threadId: dto.threadId,
        userId: dto.userId,
        enabled: dto.enabled,
        eligible: dto.eligible,
        canEdit: dto.canEdit,
        accountName: dto.account.username,
        accountAvatarUrl: dto.account.avatar,
        identityId: dto.identity?.id,
        nickname: dto.identity?.nickname,
        avatarMediaId: dto.identity?.avatarMediaId,
        version: dto.identity?.version.toInt(),
        display: dto.enabled ? mapRpIdentity(dto.display) : null,
        identityToken: dto.identityToken,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final apiThreadIdentityRepositoryProvider = Provider<ThreadIdentityRepository>(
  (ref) =>
      ApiThreadIdentityRepository(ref.watch(wenyouApiProvider).getThreadsApi()),
);
