import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_member_management_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_member_management_models.dart';

export 'package:wenyousite_mobile/features/threads/application/thread_member_management_repository_ports.dart'
    show
        ThreadMemberManagementRepository,
        threadMemberManagementRepositoryProvider;

class ApiThreadMemberManagementRepository
    implements ThreadMemberManagementRepository {
  ApiThreadMemberManagementRepository(this._threadsApi);

  final ThreadsApi _threadsApi;

  @override
  Future<ThreadMemberManagementBootstrap> load(String threadId) async {
    try {
      final responses = await Future.wait<Object>([
        _threadsApi.threadsFindById(id: threadId),
        _threadsApi.threadMembersFindAll(threadId: threadId),
      ]);
      final detailEnvelope =
          (responses[0] as Response<ThreadsFindById200Response>).data;
      final membersEnvelope =
          (responses[1] as Response<ThreadMembersFindAll200Response>).data;
      if (detailEnvelope == null || membersEnvelope == null) {
        throw const ApiFailure(userMessage: '成员管理信息返回不完整，请稍后重试。');
      }
      final detail = detailEnvelope.data;
      final membershipRole = detail.currentMembership?.role;
      final canManage =
          detail.capabilities?.canManageMembers ??
          (membershipRole == CurrentThreadMembershipResponseDtoRoleEnum.OWNER ||
              membershipRole ==
                  CurrentThreadMembershipResponseDtoRoleEnum.COLLABORATOR);
      if (!canManage) {
        throw const ApiFailure(
          userMessage: '当前账号没有管理主题成员的权限。',
          httpStatus: 403,
          businessCode: 40300,
        );
      }
      final actorIsOwner =
          detail.capabilities?.isOwner ??
          membershipRole == CurrentThreadMembershipResponseDtoRoleEnum.OWNER;
      return ThreadMemberManagementBootstrap(
        threadId: detail.id,
        threadTitle: detail.title?.trim().isNotEmpty == true
            ? detail.title!.trim()
            : '未命名主题',
        actorIsOwner: actorIsOwner,
        members: List.unmodifiable(membersEnvelope.data.map(_mapMember)),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<ThreadMemberManagementMember> updateMember({
    required String threadId,
    required String userId,
    ThreadMemberManagementRole? role,
    bool? playerMarked,
  }) async {
    if (role == null && playerMarked == null) {
      throw const ApiFailure(userMessage: '没有可提交的成员修改。');
    }
    if (role == ThreadMemberManagementRole.owner ||
        role == ThreadMemberManagementRole.unknown) {
      throw const ApiFailure(userMessage: '不能把成员修改为这个身份。');
    }
    try {
      final response = await _threadsApi.threadMembersUpdateMember(
        threadId: threadId,
        userId: userId,
        threadMembersUpdateMemberRequest: ThreadMembersUpdateMemberRequest((
          builder,
        ) {
          if (role != null) {
            builder.role = role == ThreadMemberManagementRole.collaborator
                ? ThreadMembersUpdateMemberRequestRoleEnum.COLLABORATOR
                : ThreadMembersUpdateMemberRequestRoleEnum.PARTICIPANT;
          }
          builder.playerMarked = playerMarked;
        }),
      );
      final dto = response.data?.data;
      if (dto == null || dto.threadId != threadId || dto.userId != userId) {
        throw const ApiFailure(userMessage: '成员修改结果不完整，请重新加载确认。');
      }
      return _mapMember(dto);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> exitPlayer(String threadId) async {
    try {
      final response = await _threadsApi.threadMembersExitMember(
        threadId: threadId,
      );
      if (response.data == null) {
        throw const ApiFailure(userMessage: '服务端没有确认已退出玩家身份，请重新加载确认。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  ThreadMemberManagementMember _mapMember(ThreadMemberResponseDto dto) {
    return ThreadMemberManagementMember(
      id: dto.id,
      userId: dto.userId,
      username: dto.user.username,
      level: dto.user.level.toInt(),
      avatarUrl: dto.user.avatar,
      role: switch (dto.role) {
        ThreadMemberResponseDtoRoleEnum.OWNER =>
          ThreadMemberManagementRole.owner,
        ThreadMemberResponseDtoRoleEnum.COLLABORATOR =>
          ThreadMemberManagementRole.collaborator,
        ThreadMemberResponseDtoRoleEnum.PARTICIPANT =>
          ThreadMemberManagementRole.participant,
        _ => ThreadMemberManagementRole.unknown,
      },
      playerMarked: dto.playerMarked,
      joinedAt: dto.joinedAt,
    );
  }
}

final apiThreadMemberManagementRepositoryProvider =
    Provider<ThreadMemberManagementRepository>((ref) {
      return ApiThreadMemberManagementRepository(
        ref.watch(wenyouApiProvider).getThreadsApi(),
      );
    });
