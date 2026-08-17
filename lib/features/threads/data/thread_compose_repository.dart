import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_compose_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';

export 'package:wenyousite_mobile/features/threads/application/thread_compose_repository_ports.dart'
    show ThreadComposeRepository, threadComposeRepositoryProvider;

class ApiThreadComposeRepository implements ThreadComposeRepository {
  ApiThreadComposeRepository(
    this._threadsApi,
    this._categoriesApi,
    this._usersApi,
  );

  final ThreadsApi _threadsApi;
  final ThreadCategoriesApi _categoriesApi;
  final UsersApi _usersApi;

  @override
  Future<ThreadComposeBootstrap> fetchBootstrap() async {
    try {
      final meRequest = _usersApi.usersGetMe();
      final categoryRequest = _categoriesApi.threadCategoriesList();
      final responses = await Future.wait<Object>([meRequest, categoryRequest]);
      final meEnvelope = (responses[0] as Response<UsersGetMe200Response>).data;
      final categoryEnvelope =
          (responses[1] as Response<ThreadCategoriesList200Response>).data;
      if (meEnvelope == null || categoryEnvelope == null) {
        throw const ApiFailure(userMessage: '创建主题所需信息加载失败，请稍后重试。');
      }
      final me = meEnvelope.data;
      final categories =
          categoryEnvelope.data
              .where((category) => category.isActive)
              .map(
                (category) => ThreadComposeCategory(
                  slug: category.slug,
                  name: category.name,
                  description: category.description,
                  sortOrder: category.sortOrder.toInt(),
                ),
              )
              .toList()
            ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
      return ThreadComposeBootstrap(
        userId: me.id,
        categories: List.unmodifiable(categories),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<List<ThreadRemoteDraftSummary>> fetchDrafts() async {
    try {
      final envelope = (await _threadsApi.threadsFindDrafts()).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '云端草稿加载失败，请稍后重试。');
      }
      final seenIds = <String>{};
      final drafts = <ThreadRemoteDraftSummary>[];
      for (final dto in envelope.data) {
        final id = dto.id.trim();
        final subthreadCount = dto.count.subthreads.toInt();
        final postCount = dto.count.posts.toInt();
        if (id.isEmpty ||
            !seenIds.add(id) ||
            dto.published ||
            dto.deletedAt != null ||
            subthreadCount < 0 ||
            postCount < 0 ||
            dto.count.subthreads != subthreadCount ||
            dto.count.posts != postCount) {
          throw const ApiFailure(userMessage: '部分云端草稿暂时无法打开。');
        }
        final tags = <String>[];
        for (final relation in dto.topicTags) {
          final tag = relation.tag.name.trim();
          if (relation.threadId != id || tag.isEmpty) {
            throw const ApiFailure(userMessage: '云端草稿的标签加载失败。');
          }
          if (!tags.contains(tag)) tags.add(tag);
        }
        drafts.add(
          ThreadRemoteDraftSummary(
            id: id,
            title: dto.title.trim(),
            categorySlug: _normalizedOptional(dto.category),
            visibility: _mapDraftVisibility(dto.visibility),
            tags: List.unmodifiable(tags),
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
            subthreadCount: subthreadCount,
            postCount: postCount,
          ),
        );
      }
      return List.unmodifiable(drafts);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<ThreadRemoteDraft> fetchDraft({
    required String id,
    required String ownerId,
  }) async {
    final normalizedId = id.trim();
    final normalizedOwnerId = ownerId.trim();
    if (normalizedId.isEmpty || normalizedOwnerId.isEmpty) {
      throw const ApiFailure(userMessage: '草稿加载失败，无法继续编辑。');
    }
    try {
      final dto = (await _threadsApi.threadsFindById(
        id: normalizedId,
      )).data?.data;
      if (dto == null ||
          dto.id.trim() != normalizedId ||
          dto.ownerId.trim() != normalizedOwnerId ||
          dto.published ||
          dto.deletedAt != null) {
        throw const ApiFailure(userMessage: '云端草稿已经发生变化，请重新打开。');
      }
      return _mapRemoteDraft(dto);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> removeDraft(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      throw const ApiFailure(userMessage: '草稿加载失败，无法删除。');
    }
    try {
      if ((await _threadsApi.threadsRemove(id: normalizedId)).data == null) {
        throw const ApiFailure(userMessage: '删除失败，请重新加载。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<ThreadRemoteDraft> createDraft(ThreadCreatePayload payload) async {
    try {
      final title = payload.title.trim();
      final category = payload.categorySlug?.trim();
      final body = MarkdownContent.normalize(payload.body);
      final response = await _threadsApi.threadsCreate(
        extra: ApiRequestPolicy.idempotentCreate.extra,
        createThreadDto: CreateThreadDto((builder) {
          builder
            ..clientRequestId = payload.clientRequestId
            ..visibility = payload.visibility == ThreadComposeVisibility.private
                ? CreateThreadDtoVisibilityEnum.PRIVATE
                : CreateThreadDtoVisibilityEnum.PUBLIC
            ..tagNames.replace(normalizeTagNames(payload.tags));
          if (title.isNotEmpty) builder.title = title;
          if (category != null && category.isNotEmpty) {
            builder.category = category;
          }
          if (body.isNotEmpty) builder.content = body;
        }),
      );
      final dto = response.data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '主题草稿创建失败，请重试确认。');
      }
      return _mapRemoteDraft(dto);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<ThreadRemoteDraft> saveAggregate({
    required ThreadRemoteDraft remoteDraft,
    required String title,
    required String? categorySlug,
    required ThreadComposeVisibility visibility,
    required List<String> tags,
    required String body,
    required bool publish,
  }) async {
    try {
      final normalizedTitle = title.trim();
      final normalizedCategory = categorySlug?.trim();
      final response = await _threadsApi.threadsSaveAggregate(
        id: remoteDraft.id,
        saveThreadAggregateDto: SaveThreadAggregateDto((builder) {
          builder
            ..version = remoteDraft.version
            ..defaultSubthreadVersion = remoteDraft.defaultSubthreadVersion
            ..bodyVersion = remoteDraft.bodyVersion
            ..content = MarkdownContent.normalize(body)
            ..tagNames.replace(normalizeTagNames(tags))
            ..visibility = visibility == ThreadComposeVisibility.private
                ? SaveThreadAggregateDtoVisibilityEnum.PRIVATE
                : SaveThreadAggregateDtoVisibilityEnum.PUBLIC;
          if (normalizedTitle.isNotEmpty) builder.title = normalizedTitle;
          if (normalizedCategory != null && normalizedCategory.isNotEmpty) {
            builder.category = normalizedCategory;
          }
          if (publish) builder.published = true;
        }),
      );
      final dto = response.data?.data;
      if (dto == null || (publish && !dto.published)) {
        throw ApiFailure(
          userMessage: publish ? '发布失败，请保留草稿并重试。' : '主题草稿保存失败，请重试。',
        );
      }
      return _mapRemoteDraft(dto);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  ThreadRemoteDraft _mapRemoteDraft(ThreadDetailResponseDto dto) {
    final defaultId = dto.defaultSubthreadId;
    final subthreads = dto.subthreads;
    ThreadSubthreadResponseDto? defaultSubthread;
    for (final subthread in subthreads) {
      if (subthread.id == defaultId) {
        defaultSubthread = subthread;
        break;
      }
    }
    if (defaultSubthread == null && subthreads.isNotEmpty) {
      defaultSubthread = subthreads.first;
    }
    if (defaultSubthread == null) {
      throw const ApiFailure(userMessage: '主题草稿缺少默认子贴，无法安全继续编辑。');
    }
    final bodyPost = defaultSubthread.bodyPost;
    return ThreadRemoteDraft(
      id: dto.id,
      version: dto.version.toInt(),
      defaultSubthreadId: defaultSubthread.id,
      defaultSubthreadVersion: defaultSubthread.version.toInt(),
      bodyVersion: bodyPost?.version.toInt(),
      title: dto.title?.trim() ?? '',
      categorySlug: dto.category,
      visibility: switch (dto.visibility) {
        ThreadDetailResponseDtoVisibilityEnum.PUBLIC =>
          ThreadComposeVisibility.public,
        ThreadDetailResponseDtoVisibilityEnum.PRIVATE =>
          ThreadComposeVisibility.private,
        _ => throw const ApiFailure(userMessage: '暂时无法使用这个可见范围。'),
      },
      tags: dto.topicTags
          .map((relation) => relation.tag.name)
          .toList(growable: false),
      body: bodyPost?.content ?? '',
    );
  }

  ThreadComposeVisibility _mapDraftVisibility(
    DraftThreadResponseDtoVisibilityEnum visibility,
  ) {
    return switch (visibility) {
      DraftThreadResponseDtoVisibilityEnum.PUBLIC =>
        ThreadComposeVisibility.public,
      DraftThreadResponseDtoVisibilityEnum.PRIVATE =>
        ThreadComposeVisibility.private,
      _ => throw const ApiFailure(userMessage: '暂时无法使用这个可见范围。'),
    };
  }

  String? _normalizedOptional(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}

final apiThreadComposeRepositoryProvider = Provider<ThreadComposeRepository>((
  ref,
) {
  final api = ref.watch(wenyouApiProvider);
  return ApiThreadComposeRepository(
    api.getThreadsApi(),
    api.getThreadCategoriesApi(),
    api.getUsersApi(),
  );
});
