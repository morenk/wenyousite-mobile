import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/editor/domain/thread_compose_models.dart';

abstract interface class ThreadComposeRepository {
  Future<ThreadComposeBootstrap> fetchBootstrap();

  Future<ThreadRemoteDraft> createDraft(ThreadCreatePayload payload);

  Future<ThreadRemoteDraft> saveAggregate({
    required ThreadRemoteDraft remoteDraft,
    required String title,
    required String? categorySlug,
    required ThreadComposeVisibility visibility,
    required List<String> tags,
    required String body,
    required bool publish,
  });
}

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
        throw const ApiFailure(userMessage: '创建主题所需信息返回不完整，请稍后重试。');
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
        emailVerified: me.emailVerified,
        categories: List.unmodifiable(categories),
      );
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
        throw const ApiFailure(userMessage: '主题草稿创建结果不完整，请重试确认。');
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
          userMessage: publish
              ? '服务端没有确认主题已发布，请保留草稿并重试。'
              : '主题草稿保存结果不完整，请重新加载确认。',
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
      visibility:
          dto.visibility == ThreadDetailResponseDtoVisibilityEnum.PRIVATE
          ? ThreadComposeVisibility.private
          : ThreadComposeVisibility.public,
      tags: dto.topicTags
          .map((relation) => relation.tag.name)
          .toList(growable: false),
      body: bodyPost?.content ?? '',
    );
  }
}

final threadComposeRepositoryProvider = Provider<ThreadComposeRepository>((
  ref,
) {
  final api = ref.watch(wenyouApiProvider);
  return ApiThreadComposeRepository(
    api.getThreadsApi(),
    api.getThreadCategoriesApi(),
    api.getUsersApi(),
  );
});
