import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_invitation_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_invitation_models.dart';

export 'package:wenyousite_mobile/features/threads/application/thread_invitation_repository_ports.dart'
    show ThreadInvitationRepository, threadInvitationRepositoryProvider;

class ApiThreadInvitationRepository implements ThreadInvitationRepository {
  ApiThreadInvitationRepository(this._threadsApi, this._webOrigin);

  static final _tokenPattern = RegExp(r'^[A-Za-z0-9_-]{16}$');

  final ThreadsApi _threadsApi;
  final String _webOrigin;

  @override
  Future<ThreadInvitationLink> generateLink(String threadId) async {
    try {
      final response = await _threadsApi.threadsCreateInviteLink(id: threadId);
      final dto = response.data?.data;
      if (dto == null ||
          dto.threadId != threadId ||
          !_tokenPattern.hasMatch(dto.token)) {
        throw const ApiFailure(userMessage: '邀请链接生成结果不完整，请重新生成。');
      }
      return ThreadInvitationLink(
        id: dto.id,
        threadId: dto.threadId,
        token: dto.token,
        url: Uri.parse(_webOrigin).resolve('/join/${dto.token}'),
        createdAt: dto.createdAt,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<ThreadInvitationPreview> preview(String token) async {
    _validateToken(token);
    try {
      final response = await _threadsApi.threadsPreviewInviteLink(token: token);
      final dto = response.data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '邀请信息返回不完整，请稍后重试。');
      }
      final thread = dto.thread;
      return ThreadInvitationPreview(
        threadId: thread.id,
        title: thread.title.trim().isEmpty ? '未命名主题' : thread.title.trim(),
        categorySlug: thread.category,
        status: switch (thread.status) {
          InviteThreadPreviewResponseDtoStatusEnum.RECRUITING =>
            ThreadInvitationStatus.recruiting,
          InviteThreadPreviewResponseDtoStatusEnum.CLOSED =>
            ThreadInvitationStatus.closed,
          InviteThreadPreviewResponseDtoStatusEnum.FINISHED =>
            ThreadInvitationStatus.finished,
          _ => ThreadInvitationStatus.unknown,
        },
        ownerId: thread.owner.id,
        ownerName: thread.owner.username,
        ownerAvatarUrl: thread.owner.avatar,
        memberCount: thread.memberCount.toInt(),
        createdAt: thread.createdAt,
        alreadyJoined: dto.alreadyJoined,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<ThreadInvitationJoinResult> join(String token) async {
    _validateToken(token);
    try {
      final response = await _threadsApi.threadsJoinByInviteLink(token: token);
      final dto = response.data?.data;
      if (dto == null || dto.threadId != dto.thread.id) {
        throw const ApiFailure(userMessage: '加入结果不完整，请重新打开邀请确认。');
      }
      return ThreadInvitationJoinResult(
        memberId: dto.id,
        threadId: dto.threadId,
        threadTitle: dto.thread.title?.trim().isNotEmpty == true
            ? dto.thread.title!.trim()
            : '未命名主题',
        userId: dto.userId,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  void _validateToken(String token) {
    if (!_tokenPattern.hasMatch(token)) {
      throw const ApiFailure(
        userMessage: '邀请链接无效或已失效。',
        httpStatus: 404,
        businessCode: 40408,
      );
    }
  }
}

final apiThreadInvitationRepositoryProvider =
    Provider<ThreadInvitationRepository>((ref) {
      return ApiThreadInvitationRepository(
        ref.watch(wenyouApiProvider).getThreadsApi(),
        ref.watch(appEnvironmentProvider).apiOrigin,
      );
    });
