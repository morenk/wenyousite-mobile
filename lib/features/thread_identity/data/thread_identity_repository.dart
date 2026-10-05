import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/thread_identity/data/rp_identity_mapper.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';

class ApiThreadIdentityRepository implements ThreadIdentityRepository {
  ApiThreadIdentityRepository(this._api, {this.legacySingleIdentity = false});
  final bool legacySingleIdentity;
  final ThreadsApi _api;

  @override
  Future<ThreadIdentityCollection> list(String threadId) async {
    if (legacySingleIdentity) {
      final state = await mine(threadId);
      final roles = [if (state.identityId != null) state];
      return ThreadIdentityCollection(
        account: ThreadIdentityState(
          threadId: state.threadId,
          userId: state.userId,
          enabled: state.enabled,
          eligible: state.eligible,
          canEdit: state.canEdit,
          accountName: state.accountName,
          accountAvatarUrl: state.accountAvatarUrl,
        ),
        identities: roles,
        // 旧接口没有原子新增/归档，仅保留已有身份维护。
        limit: roles.length,
        compatibilityIdentityId: state.identityId,
      );
    }
    try {
      final dto = (await _api.rpIdentitiesList(threadId: threadId)).data?.data;
      if (dto == null ||
          dto.threadId != threadId ||
          dto.account.id != dto.userId ||
          dto.activeCount != dto.identities.length) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'rp_collection_scope_invalid',
        );
      }
      final identities = dto.identities
          .map((role) => _mapRole(threadId, role))
          .toList(growable: false);
      if (identities.any((role) => role.userId != dto.userId || role.deleted) ||
          identities.map((role) => role.identityId).toSet().length !=
              identities.length) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'rp_collection_roles_invalid',
        );
      }
      return ThreadIdentityCollection(
        account: ThreadIdentityState(
          threadId: threadId,
          userId: dto.userId,
          enabled: dto.enabled,
          eligible: dto.eligible,
          canEdit: dto.canEdit,
          accountName: dto.account.username,
          accountAvatarUrl: dto.account.avatar,
        ),
        identities: identities,
        compatibilityIdentityId: dto.compatibilityIdentityId,
        defaultIdentityId: dto.defaultIdentityId,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<ThreadIdentityState> find(String threadId, String identityId) =>
      legacySingleIdentity
      ? _legacyRole(threadId, identityId)
      : _roleRead(
          threadId,
          () async => (await _api.rpIdentitiesFind(
            threadId: threadId,
            identityId: identityId,
          )).data?.data,
          identityId: identityId,
        );

  @override
  Future<ThreadIdentityState> create(
    String threadId,
    ThreadIdentityUpdate input,
  ) => legacySingleIdentity
      ? Future.error(const ApiFailure(userMessage: '暂时无法添加身份。'))
      : _roleRead(
          threadId,
          () async => (await _api.rpIdentitiesCreate(
            threadId: threadId,
            extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
            createRpIdentityDto: CreateRpIdentityDto(
              (b) => b
                ..nickname = input.nickname
                ..avatarMediaId = input.avatarMediaId,
            ),
          )).data?.data,
        );

  @override
  Future<ThreadIdentityState> updateRole(
    String threadId,
    String identityId,
    ThreadIdentityUpdate input,
  ) => legacySingleIdentity
      ? _updateLegacyRole(threadId, identityId, input)
      : _roleRead(
          threadId,
          () async => (await _api.rpIdentitiesUpdate(
            threadId: threadId,
            identityId: identityId,
            extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
            updateRpIdentityDto: UpdateRpIdentityDto(
              (b) => b
                ..nickname = input.nickname
                ..avatarMediaId = input.avatarMediaId
                ..clearNickname = input.clearNickname
                ..clearAvatar = input.clearAvatar
                ..version = input.version,
            ),
          )).data?.data,
          identityId: identityId,
        );

  @override
  Future<ThreadIdentityState> remove(
    String threadId,
    String identityId,
    int version,
  ) => legacySingleIdentity
      ? Future.error(const ApiFailure(userMessage: '暂时无法删除身份。'))
      : _roleRead(
          threadId,
          () async => (await _api.rpIdentitiesRemove(
            threadId: threadId,
            identityId: identityId,
            extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
            deleteRpIdentityDto: DeleteRpIdentityDto(
              (b) => b.version = version,
            ),
          )).data?.data,
          identityId: identityId,
        );

  Future<ThreadIdentityState> _legacyRole(
    String threadId,
    String identityId,
  ) async {
    final state = await mine(threadId);
    if (state.identityId != identityId) {
      throw const ApiFailure(userMessage: '该身份已变化，请重新选择。');
    }
    return state;
  }

  Future<ThreadIdentityState> _updateLegacyRole(
    String threadId,
    String identityId,
    ThreadIdentityUpdate input,
  ) async {
    final state = await _legacyRole(threadId, identityId);
    if (input.version == null || input.version != state.version) {
      throw const ApiFailure(userMessage: '资料已变化，请重新打开后编辑。');
    }
    return update(threadId, input);
  }

  Future<ThreadIdentityState> _roleRead(
    String threadId,
    Future<RpIdentityStateDto?> Function() request, {
    String? identityId,
  }) async {
    try {
      final dto = await request();
      if (dto == null || (identityId != null && dto.identityId != identityId)) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'rp_identity_target_invalid',
        );
      }
      return _mapRole(threadId, dto);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  ThreadIdentityState _mapRole(String threadId, RpIdentityStateDto dto) {
    if (dto.threadId != threadId ||
        dto.account.id != dto.userId ||
        (dto.identity != null && dto.identity!.id != dto.identityId) ||
        (dto.display != null && dto.display!.id != dto.identityId)) {
      throw const ApiFailure.invalidResponse(
        diagnosticCode: 'rp_identity_scope_invalid',
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
      identityId: dto.identityId,
      nickname: dto.identity?.nickname,
      avatarMediaId: dto.identity?.avatarMediaId,
      version: dto.identity?.version.toInt(),
      display: dto.enabled && !dto.deleted ? mapRpIdentity(dto.display) : null,
      identityToken: dto.identityToken,
      deleted: dto.deleted,
      canDelete: dto.canDelete,
      compatibilityIdentity: dto.compatibilityIdentity,
    );
  }

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
  (ref) => ApiThreadIdentityRepository(
    ref.watch(wenyouApiProvider).getThreadsApi(),
    legacySingleIdentity: ref
        .watch(appCapabilitiesProvider)
        .legacySingleThreadIdentity,
  ),
);
