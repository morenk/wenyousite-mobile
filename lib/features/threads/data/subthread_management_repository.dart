import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';

abstract interface class SubthreadManagementRepository {
  Future<SubthreadManagementBootstrap> load(String threadId);

  Future<SubthreadManagementItem> findById({
    required String threadId,
    required String subthreadId,
    required bool isDefault,
  });

  Future<SubthreadManagementItem> create({
    required String threadId,
    required SubthreadManagementDraft draft,
    required String clientRequestId,
  });

  Future<SubthreadManagementItem> update({
    required SubthreadManagementItem current,
    required SubthreadManagementDraft draft,
  });

  Future<void> remove(SubthreadManagementItem item);

  Future<List<SubthreadManagementItem>> reorder({
    required String threadId,
    required List<SubthreadManagementItem> items,
  });
}

class ApiSubthreadManagementRepository
    implements SubthreadManagementRepository {
  ApiSubthreadManagementRepository(this._threadsApi, this._subthreadsApi);

  final ThreadsApi _threadsApi;
  final SubthreadsApi _subthreadsApi;

  @override
  Future<SubthreadManagementBootstrap> load(String threadId) async {
    try {
      final responses = await Future.wait<Object>([
        _threadsApi.threadsFindById(id: threadId),
        _subthreadsApi.subthreadsFindAll(threadId: threadId),
      ]);
      final threadEnvelope =
          (responses[0] as Response<ThreadsFindById200Response>).data;
      final listEnvelope =
          (responses[1] as Response<SubthreadsFindAll200Response>).data;
      if (threadEnvelope == null || listEnvelope == null) {
        throw const ApiFailure(userMessage: '子贴管理信息返回不完整，请稍后重试。');
      }
      final thread = threadEnvelope.data;
      if (thread.id != threadId) {
        throw const ApiFailure(userMessage: '服务端返回了不匹配的主题，请重新加载。');
      }
      final membershipRole = thread.currentMembership?.role;
      final canManage =
          thread.capabilities?.canManageThread ??
          (membershipRole == CurrentThreadMembershipResponseDtoRoleEnum.OWNER ||
              membershipRole ==
                  CurrentThreadMembershipResponseDtoRoleEnum.COLLABORATOR);
      if (!canManage) {
        throw const ApiFailure(
          userMessage: '当前账号没有管理这个主题子贴的权限。',
          httpStatus: 403,
          businessCode: 40300,
        );
      }
      final defaultId = thread.defaultSubthreadId;
      final items = listEnvelope.data
          .map(
            (dto) => _mapItem(
              dto,
              expectedThreadId: threadId,
              isDefault: dto.id == defaultId,
            ),
          )
          .toList();
      if (items.map((item) => item.id).toSet().length != items.length) {
        throw const ApiFailure(userMessage: '服务端返回了重复的子贴，请重新加载。');
      }
      items.sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
      if (items.isNotEmpty &&
          (defaultId == null || !items.any((item) => item.isDefault))) {
        throw const ApiFailure(userMessage: '服务端没有返回有效的默认子贴，请稍后重试。');
      }
      if (items.isNotEmpty && !items.first.isDefault) {
        throw const ApiFailure(userMessage: '默认子贴排序异常，请稍后重试。');
      }
      return SubthreadManagementBootstrap(
        threadId: threadId,
        threadTitle: thread.title?.trim().isNotEmpty == true
            ? thread.title!.trim()
            : '未命名主题',
        items: List.unmodifiable(items),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<SubthreadManagementItem> findById({
    required String threadId,
    required String subthreadId,
    required bool isDefault,
  }) async {
    try {
      final envelope = (await _subthreadsApi.subthreadsFindById(
        id: subthreadId,
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '子贴详情返回为空，请重新加载。');
      }
      return _mapItem(
        envelope.data,
        expectedThreadId: threadId,
        expectedId: subthreadId,
        isDefault: isDefault,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<SubthreadManagementItem> create({
    required String threadId,
    required SubthreadManagementDraft draft,
    required String clientRequestId,
  }) async {
    try {
      final envelope = (await _subthreadsApi.subthreadsCreate(
        threadId: threadId,
        extra: ApiRequestPolicy.idempotentCreate.extra,
        createSubthreadDto: CreateSubthreadDto((builder) {
          builder
            ..clientRequestId = clientRequestId
            ..title = draft.normalizedTitle
            ..postingPolicy = _mapCreatePolicy(draft.postingPolicy);
        }),
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '子贴创建结果不明确，请保留当前表单后重试。');
      }
      return _mapItem(
        envelope.data,
        expectedThreadId: threadId,
        isDefault: false,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<SubthreadManagementItem> update({
    required SubthreadManagementItem current,
    required SubthreadManagementDraft draft,
  }) async {
    if (!draft.differsFrom(current)) return current;
    try {
      final envelope = (await _subthreadsApi.subthreadsUpdate(
        id: current.id,
        updateSubthreadDto: UpdateSubthreadDto((builder) {
          builder.version = current.version;
          if (draft.normalizedTitle != current.title) {
            builder.title = draft.normalizedTitle;
          }
          if (draft.postingPolicy != current.postingPolicy) {
            builder.postingPolicy = _mapUpdatePolicy(draft.postingPolicy);
          }
        }),
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '子贴更新结果不完整，请重新加载确认。');
      }
      return _mapItem(
        envelope.data,
        expectedThreadId: current.threadId,
        expectedId: current.id,
        isDefault: current.isDefault,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> remove(SubthreadManagementItem item) async {
    if (item.isDefault) {
      throw const ApiFailure(userMessage: '默认子贴不能单独删除。');
    }
    try {
      final envelope = (await _subthreadsApi.subthreadsRemove(
        id: item.id,
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '服务端没有确认子贴已删除，请重新加载确认。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<List<SubthreadManagementItem>> reorder({
    required String threadId,
    required List<SubthreadManagementItem> items,
  }) async {
    if (items.isEmpty || !items.first.isDefault) {
      throw const ApiFailure(userMessage: '默认子贴必须保持在第一位。');
    }
    try {
      final envelope = (await _subthreadsApi.subthreadsReorder(
        threadId: threadId,
        reorderSubthreadsDto: ReorderSubthreadsDto(
          (builder) => builder.ids.addAll(items.map((item) => item.id)),
        ),
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '子贴排序结果不完整，请重新加载确认。');
      }
      final currentById = {for (final item in items) item.id: item};
      final seen = <String>{};
      final reordered = <SubthreadManagementItem>[];
      for (final dto in envelope.data) {
        final current = currentById[dto.id];
        if (current == null || !seen.add(dto.id)) {
          throw const ApiFailure(userMessage: '服务端返回了不匹配的子贴排序，请重新加载。');
        }
        reordered.add(
          current.copyWith(title: dto.title, sortOrder: dto.sortOrder.toInt()),
        );
      }
      reordered.sort(
        (left, right) => left.sortOrder.compareTo(right.sortOrder),
      );
      if (reordered.length != items.length ||
          reordered.isEmpty ||
          !reordered.first.isDefault) {
        throw const ApiFailure(userMessage: '服务端返回的子贴排序不完整，请重新加载。');
      }
      return List.unmodifiable(reordered);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  SubthreadManagementItem _mapItem(
    SubthreadResponseDto dto, {
    required String expectedThreadId,
    String? expectedId,
    required bool isDefault,
  }) {
    if (dto.threadId != expectedThreadId ||
        (expectedId != null && dto.id != expectedId)) {
      throw const ApiFailure(userMessage: '服务端返回了不匹配的子贴，请重新加载。');
    }
    return SubthreadManagementItem(
      id: dto.id,
      threadId: dto.threadId,
      title: dto.title.trim(),
      sortOrder: dto.sortOrder.toInt(),
      postingPolicy: switch (dto.postingPolicy) {
        SubthreadResponseDtoPostingPolicyEnum.COLLABORATORS =>
          SubthreadPostingPolicy.collaborators,
        SubthreadResponseDtoPostingPolicyEnum.PLAYERS =>
          SubthreadPostingPolicy.players,
        _ => SubthreadPostingPolicy.participants,
      },
      version: dto.version.toInt(),
      postCount: dto.count.posts.toInt(),
      isDefault: isDefault,
    );
  }

  CreateSubthreadDtoPostingPolicyEnum _mapCreatePolicy(
    SubthreadPostingPolicy policy,
  ) {
    return switch (policy) {
      SubthreadPostingPolicy.participants =>
        CreateSubthreadDtoPostingPolicyEnum.PARTICIPANTS,
      SubthreadPostingPolicy.collaborators =>
        CreateSubthreadDtoPostingPolicyEnum.COLLABORATORS,
      SubthreadPostingPolicy.players =>
        CreateSubthreadDtoPostingPolicyEnum.PLAYERS,
    };
  }

  UpdateSubthreadDtoPostingPolicyEnum _mapUpdatePolicy(
    SubthreadPostingPolicy policy,
  ) {
    return switch (policy) {
      SubthreadPostingPolicy.participants =>
        UpdateSubthreadDtoPostingPolicyEnum.PARTICIPANTS,
      SubthreadPostingPolicy.collaborators =>
        UpdateSubthreadDtoPostingPolicyEnum.COLLABORATORS,
      SubthreadPostingPolicy.players =>
        UpdateSubthreadDtoPostingPolicyEnum.PLAYERS,
    };
  }
}

final subthreadManagementRepositoryProvider =
    Provider<SubthreadManagementRepository>((ref) {
      final api = ref.watch(wenyouApiProvider);
      return ApiSubthreadManagementRepository(
        api.getThreadsApi(),
        api.getSubthreadsApi(),
      );
    });
