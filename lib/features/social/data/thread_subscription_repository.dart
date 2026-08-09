import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';

abstract interface class ThreadSubscriptionRepository {
  Future<List<ThreadSubscriptionRecord>> fetchSubscriptions(String threadId);

  Future<List<ThreadSubscriptionCandidate>> fetchCandidates(
    String threadId, {
    String? viewerUserId,
  });

  Future<ThreadSubscriptionRecord> create({
    required String threadId,
    required ThreadSubscriptionType type,
    String? targetUserId,
  });

  Future<void> remove(String subscriptionId);
}

class ApiThreadSubscriptionRepository implements ThreadSubscriptionRepository {
  ApiThreadSubscriptionRepository(this._subscriptionsApi, this._threadsApi);

  final SubscriptionsApi _subscriptionsApi;
  final ThreadsApi _threadsApi;

  @override
  Future<List<ThreadSubscriptionRecord>> fetchSubscriptions(
    String threadId,
  ) async {
    try {
      final envelope = (await _subscriptionsApi.subscriptionsFindAll()).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '订阅列表响应为空，请稍后重试。');
      }
      return envelope.data
          .where((item) => item.threadId == threadId)
          .map(_mapSubscription)
          .whereType<ThreadSubscriptionRecord>()
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<List<ThreadSubscriptionCandidate>> fetchCandidates(
    String threadId, {
    String? viewerUserId,
  }) async {
    try {
      final envelope = (await _threadsApi.threadMembersFindAll(
        threadId: threadId,
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '玩家候选响应为空，请稍后重试。');
      }
      return envelope.data
          .where(
            (member) =>
                member.role == ThreadMemberResponseDtoRoleEnum.PARTICIPANT &&
                member.playerMarked &&
                member.userId != viewerUserId,
          )
          .map(
            (member) => ThreadSubscriptionCandidate(
              userId: member.userId,
              username: member.user.username,
              avatarUrl: member.user.avatar,
              level: member.user.level.toInt(),
            ),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<ThreadSubscriptionRecord> create({
    required String threadId,
    required ThreadSubscriptionType type,
    String? targetUserId,
  }) async {
    try {
      final dto = CreateSubscriptionDto(
        (builder) => builder
          ..threadId = threadId
          ..type = switch (type) {
            ThreadSubscriptionType.thread =>
              CreateSubscriptionDtoTypeEnum.THREAD,
            ThreadSubscriptionType.user => CreateSubscriptionDtoTypeEnum.USER,
          }
          ..targetUserId = targetUserId,
      );
      final data = (await _subscriptionsApi.subscriptionsCreate(
        createSubscriptionDto: dto,
      )).data?.data;
      final record = data == null ? null : _mapSubscription(data);
      if (record == null || record.id.trim().isEmpty) {
        throw const ApiFailure(userMessage: '创建订阅结果不完整，请重新加载确认。');
      }
      return record;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> remove(String subscriptionId) async {
    try {
      final data = (await _subscriptionsApi.subscriptionsRemove(
        id: subscriptionId,
      )).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '取消订阅结果不完整，请重新加载确认。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  ThreadSubscriptionRecord? _mapSubscription(SubscriptionResponseDto dto) {
    final type = switch (dto.type) {
      SubscriptionResponseDtoTypeEnum.THREAD => ThreadSubscriptionType.thread,
      SubscriptionResponseDtoTypeEnum.USER => ThreadSubscriptionType.user,
      _ => null,
    };
    if (type == null) return null;
    return ThreadSubscriptionRecord(
      id: dto.id,
      threadId: dto.threadId,
      type: type,
      targetUserId: dto.targetUserId,
      createdAt: dto.createdAt,
    );
  }
}

final threadSubscriptionRepositoryProvider =
    Provider<ThreadSubscriptionRepository>((ref) {
      final api = ref.watch(wenyouApiProvider);
      return ApiThreadSubscriptionRepository(
        api.getSubscriptionsApi(),
        api.getThreadsApi(),
      );
    });
