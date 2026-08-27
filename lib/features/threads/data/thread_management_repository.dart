import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/models/thread_category_presentation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_management_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';

export 'package:wenyousite_mobile/features/threads/application/thread_management_repository_ports.dart'
    show ThreadManagementRepository, threadManagementRepositoryProvider;

class ApiThreadManagementRepository implements ThreadManagementRepository {
  ApiThreadManagementRepository(this._threadsApi, this._categoriesApi);

  final ThreadsApi _threadsApi;
  final ThreadCategoriesApi _categoriesApi;

  @override
  Future<ThreadManagementBootstrap> load(String threadId) async {
    try {
      final responses = await Future.wait<Object>([
        _threadsApi.threadsFindById(id: threadId),
        _categoriesApi.threadCategoriesList(),
      ]);
      final threadEnvelope =
          (responses[0] as Response<ThreadsFindById200Response>).data;
      final categoryEnvelope =
          (responses[1] as Response<ThreadCategoriesList200Response>).data;
      if (threadEnvelope == null || categoryEnvelope == null) {
        throw const ApiFailure(userMessage: '主题管理信息加载失败，请稍后重试。');
      }
      final thread = _mapThread(threadEnvelope.data);
      if (!thread.canManage) {
        throw const ApiFailure(
          userMessage: '当前账号没有管理这个主题的权限。',
          httpStatus: 403,
          businessCode: 40300,
        );
      }
      final categories =
          categoryEnvelope.data
              .where((item) => item.isActive)
              .map(
                (item) => ThreadManagementCategory(
                  slug: item.slug,
                  name: ThreadCategoryPresentation.catalog(
                    slug: item.slug,
                    label: item.name,
                  ).label,
                  description: item.description,
                  sortOrder: item.sortOrder.toInt(),
                ),
              )
              .toList()
            ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
      final currentCategory = thread.categorySlug;
      if (currentCategory != null &&
          !categories.any((item) => item.slug == currentCategory)) {
        categories.insert(
          0,
          ThreadManagementCategory(
            slug: currentCategory,
            name: '历史分类',
            sortOrder: -1,
            isSelectable: false,
          ),
        );
      }
      return ThreadManagementBootstrap(
        thread: thread,
        categories: List.unmodifiable(categories),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<ThreadManagementSnapshot> update({
    required ThreadManagementSnapshot current,
    required ThreadManagementDraft draft,
  }) async {
    try {
      final normalizedTitle = draft.title.trim();
      if (current.defaultSubthreadId == null ||
          current.defaultSubthreadVersion <= 0) {
        throw const ApiFailure(userMessage: '主题正文暂时无法保存，请重新加载后重试。');
      }
      final response = await _threadsApi.threadsSaveAggregate(
        id: current.id,
        saveThreadAggregateDto: SaveThreadAggregateDto((builder) {
          builder
            ..version = current.version
            ..defaultSubthreadVersion = current.defaultSubthreadVersion
            ..content = MarkdownContent.normalize(current.body)
            ..tagNames.replace(draft.normalizedTagNames);
          if (current.bodyVersion != null) {
            builder.bodyVersion = current.bodyVersion;
          }
          if (normalizedTitle != current.title) builder.title = normalizedTitle;
          if (draft.categorySlug != current.categorySlug) {
            builder.category = draft.categorySlug;
          }
          if (draft.status != current.status) {
            builder.status = _mapSaveStatus(draft.status);
          }
          if (draft.visibility != current.visibility) {
            if (!current.isOwner) {
              throw const ApiFailure(
                userMessage: '只有主题楼主可以修改可见性。',
                httpStatus: 403,
                businessCode: 40301,
              );
            }
            builder.visibility =
                draft.visibility == ThreadManagementVisibility.private
                ? SaveThreadAggregateDtoVisibilityEnum.PRIVATE
                : SaveThreadAggregateDtoVisibilityEnum.PUBLIC;
          }
        }),
      );
      final envelope = response.data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '主题更新失败，请重试。');
      }
      return _mapThread(envelope.data);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> remove(String threadId) async {
    try {
      final response = await _threadsApi.threadsRemove(id: threadId);
      if (response.data == null) {
        throw const ApiFailure(userMessage: '删除失败，请重新加载。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  ThreadManagementSnapshot _mapThread(ThreadDetailResponseDto dto) {
    final membershipRole = dto.currentMembership?.role;
    final canManage =
        dto.capabilities?.canManageThread ??
        (membershipRole == CurrentThreadMembershipResponseDtoRoleEnum.OWNER ||
            membershipRole ==
                CurrentThreadMembershipResponseDtoRoleEnum.COLLABORATOR);
    final isOwner =
        dto.capabilities?.isOwner ??
        (membershipRole == CurrentThreadMembershipResponseDtoRoleEnum.OWNER);
    final defaultSubthread = dto.defaultSubthreadId == null
        ? null
        : dto.subthreads
              .where((item) => item.id == dto.defaultSubthreadId)
              .firstOrNull;
    if (defaultSubthread == null) {
      throw const ApiFailure(userMessage: '主题正文加载失败，请稍后重新加载。');
    }
    final body = defaultSubthread.bodyPost;
    return ThreadManagementSnapshot(
      id: dto.id,
      title: dto.title?.trim() ?? '',
      categorySlug: dto.category,
      status: switch (dto.status) {
        ThreadDetailResponseDtoStatusEnum.CLOSED =>
          ThreadManagementStatus.closed,
        ThreadDetailResponseDtoStatusEnum.FINISHED =>
          ThreadManagementStatus.finished,
        _ => ThreadManagementStatus.recruiting,
      },
      visibility:
          dto.visibility == ThreadDetailResponseDtoVisibilityEnum.PRIVATE
          ? ThreadManagementVisibility.private
          : ThreadManagementVisibility.public,
      version: dto.version.toInt(),
      published: dto.published,
      canManage: canManage,
      isOwner: isOwner,
      defaultSubthreadId: defaultSubthread.id,
      defaultSubthreadVersion: defaultSubthread.version.toInt(),
      bodyPostId: body?.id,
      bodyVersion: body?.version.toInt(),
      body: MarkdownContent.normalize(body?.content ?? ''),
      tagNames: List.unmodifiable(
        dto.topicTags.map((relation) => relation.tag.name.trim()),
      ),
    );
  }

  SaveThreadAggregateDtoStatusEnum _mapSaveStatus(
    ThreadManagementStatus status,
  ) {
    return switch (status) {
      ThreadManagementStatus.recruiting =>
        SaveThreadAggregateDtoStatusEnum.RECRUITING,
      ThreadManagementStatus.closed => SaveThreadAggregateDtoStatusEnum.CLOSED,
      ThreadManagementStatus.finished =>
        SaveThreadAggregateDtoStatusEnum.FINISHED,
    };
  }
}

final apiThreadManagementRepositoryProvider =
    Provider<ThreadManagementRepository>((ref) {
      final api = ref.watch(wenyouApiProvider);
      return ApiThreadManagementRepository(
        api.getThreadsApi(),
        api.getThreadCategoriesApi(),
      );
    });
