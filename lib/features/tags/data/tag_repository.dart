import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/models/thread_category_presentation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/tags/application/tag_repository_ports.dart';
import 'package:wenyousite_mobile/features/tags/domain/tag_models.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_feed_mapper.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_feed_models.dart';

export 'package:wenyousite_mobile/features/tags/application/tag_repository_ports.dart'
    show TagRepository, tagRepositoryProvider;

class ApiTagRepository implements TagRepository {
  ApiTagRepository(this._tagsApi, this._threadsApi, this._categoriesApi);

  final TagsApi _tagsApi;
  final ThreadsApi _threadsApi;
  final ThreadCategoriesApi _categoriesApi;

  @override
  Future<TagThreadsBootstrap> loadTagThreads(String tagId) async {
    try {
      final responses = await Future.wait<Object>([
        _tagsApi.tagsGetById(id: tagId),
        _categoriesApi.threadCategoriesList(
          extra: ApiRequestPolicy.public.extra,
        ),
        _threadsApi.threadsFindAll(tagId: tagId),
      ]);
      final tagEnvelope =
          (responses[0] as Response<TagsGetById200Response>).data;
      final categoryEnvelope =
          (responses[1] as Response<ThreadCategoriesList200Response>).data;
      final threadEnvelope =
          (responses[2] as Response<ThreadsFindAll200Response>).data;
      if (tagEnvelope == null ||
          categoryEnvelope == null ||
          threadEnvelope == null) {
        throw const ApiFailure(userMessage: '标签主题加载失败，请稍后重试。');
      }
      final tag = _mapTag(tagEnvelope.data);
      if (tag.id != tagId) {
        throw const ApiFailure(userMessage: '标签已经发生变化，请重新打开。');
      }
      return TagThreadsBootstrap(
        tag: tag,
        categories: _mapCategories(categoryEnvelope.data),
        page: _mapThreadPage(threadEnvelope),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<CursorPage<HomeThreadCardModel>> fetchTagThreads({
    required String tagId,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final envelope = (await _threadsApi.threadsFindAll(
        tagId: tagId,
        cursor: cursor,
        limit: limit,
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '标签主题加载失败，请稍后重试。');
      }
      return _mapThreadPage(envelope);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<ThreadTagManagementBootstrap> loadManagement(String threadId) async {
    try {
      final responses = await Future.wait<Object>([
        _threadsApi.threadsFindById(id: threadId),
        _threadsApi.threadTagsFindAll(threadId: threadId),
        _tagsApi.tagsSearch(),
      ]);
      final threadEnvelope =
          (responses[0] as Response<ThreadsFindById200Response>).data;
      final relationEnvelope =
          (responses[1] as Response<ThreadTagsFindAll200Response>).data;
      final suggestionEnvelope =
          (responses[2] as Response<TagsSearch200Response>).data;
      if (threadEnvelope == null ||
          relationEnvelope == null ||
          suggestionEnvelope == null) {
        throw const ApiFailure(userMessage: '主题标签加载失败，请稍后重试。');
      }
      final thread = threadEnvelope.data;
      if (thread.id != threadId) {
        throw const ApiFailure(userMessage: '主题已经发生变化，请重新加载。');
      }
      final membershipRole = thread.currentMembership?.role;
      final canManage =
          thread.capabilities?.canManageThread ??
          (membershipRole == CurrentThreadMembershipResponseDtoRoleEnum.OWNER ||
              membershipRole ==
                  CurrentThreadMembershipResponseDtoRoleEnum.COLLABORATOR);
      if (!canManage) {
        throw const ApiFailure(
          userMessage: '当前账号没有管理这个主题标签的权限。',
          httpStatus: 403,
          businessCode: 40300,
        );
      }
      final tags = _mapRelations(relationEnvelope.data, threadId);
      final suggestions = _mapTagList(suggestionEnvelope.data);
      return ThreadTagManagementBootstrap(
        threadId: threadId,
        threadTitle: _requiredText(thread.title, '主题标题'),
        tags: tags,
        suggestions: suggestions,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<List<TopicTagModel>> search(String query) async {
    try {
      final normalized = normalizeTagName(query);
      final envelope = (await _tagsApi.tagsSearch(
        q: normalized.isEmpty ? null : normalized,
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '标签搜索失败，请重试。');
      }
      return _mapTagList(envelope.data);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<TopicTagModel> findById(String tagId) async {
    try {
      final envelope = (await _tagsApi.tagsGetById(id: tagId)).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '标签加载失败，请重试。');
      }
      final tag = _mapTag(envelope.data);
      if (tag.id != tagId) {
        throw const ApiFailure(userMessage: '标签已经发生变化，请重新搜索。');
      }
      return tag;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<TopicTagModel> create(String name) async {
    final normalized = normalizeTagName(name);
    final validation = validateTagName(normalized);
    if (validation != null) throw ApiFailure(userMessage: validation);
    try {
      final envelope = (await _tagsApi.tagsCreate(
        createTagDto: CreateTagDto((builder) => builder.name = normalized),
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '创建失败，请重新搜索。');
      }
      final tag = _mapTag(envelope.data);
      if (tag.name != normalized) {
        throw const ApiFailure(userMessage: '标签已经发生变化，请重新搜索。');
      }
      return tag;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<TopicTagModel> addToThread({
    required String threadId,
    required String name,
  }) async {
    final normalized = normalizeTagName(name);
    final validation = validateTagName(normalized);
    if (validation != null) throw ApiFailure(userMessage: validation);
    try {
      final envelope = (await _threadsApi.threadTagsAdd(
        threadId: threadId,
        addThreadTagDto: AddThreadTagDto(
          (builder) => builder.name = normalized,
        ),
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '添加失败，请重新加载。');
      }
      final tag = _mapThreadTag(envelope.data);
      if (tag.name != normalized) {
        throw const ApiFailure(userMessage: '标签已经发生变化，请重新加载。');
      }
      return tag;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> removeFromThread({
    required String threadId,
    required String tagId,
  }) async {
    try {
      final envelope = (await _threadsApi.threadTagsRemove(
        threadId: threadId,
        tagId: tagId,
      )).data;
      if (envelope == null || envelope.data.message.trim().isEmpty) {
        throw const ApiFailure(userMessage: '移除失败，请重新加载。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  CursorPage<HomeThreadCardModel> _mapThreadPage(
    ThreadsFindAll200Response envelope,
  ) {
    final ids = <String>{};
    final items = envelope.data
        .map(mapHomeThreadCardResponse)
        .where((item) {
          if (item.id.trim().isEmpty) {
            throw const ApiFailure(userMessage: '主题列表包含无效条目，请稍后重试。');
          }
          return ids.add(item.id);
        })
        .toList(growable: false);
    return CursorPage(
      items: items,
      cursor: envelope.meta.cursor,
      hasMore: envelope.meta.hasMore,
    );
  }

  List<HomeCategory> _mapCategories(
    Iterable<ThreadCategoryResponseDto> values,
  ) {
    final ids = <String>{};
    final categories = values.where((item) => item.isActive).map((item) {
      if (!ids.add(item.id)) {
        throw const ApiFailure(userMessage: '主题分类暂时无法显示，请稍后重试。');
      }
      final slug = _requiredText(item.slug, '分类标识');
      return HomeCategory(
        id: _requiredText(item.id, '分类 ID'),
        slug: slug,
        name: ThreadCategoryPresentation.catalog(
          slug: slug,
          label: _requiredText(item.name, '分类名称'),
        ).label,
        description: _optionalText(item.description),
        sortOrder: item.sortOrder.toInt(),
      );
    }).toList();
    categories.sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    return List.unmodifiable(categories);
  }

  List<TopicTagModel> _mapRelations(
    Iterable<ThreadTagRelationResponseDto> values,
    String threadId,
  ) {
    final ids = <String>{};
    final tags = values.map((relation) {
      if (relation.threadId != threadId || relation.tagId != relation.tag.id) {
        throw const ApiFailure(userMessage: '主题标签已经发生变化，请重新加载。');
      }
      final tag = _mapThreadTag(relation.tag);
      if (!ids.add(tag.id)) {
        throw const ApiFailure(userMessage: '主题标签暂时无法显示，请重新加载。');
      }
      return tag;
    }).toList();
    tags.sort(_compareTags);
    return List.unmodifiable(tags);
  }

  List<TopicTagModel> _mapTagList(Iterable<TagResponseDto> values) {
    final ids = <String>{};
    final tags = values.where((item) => item.isActive).map((item) {
      final tag = _mapTag(item);
      if (!ids.add(tag.id)) {
        throw const ApiFailure(userMessage: '标签暂时无法显示，请重新搜索。');
      }
      return tag;
    }).toList();
    tags.sort(_compareTags);
    return List.unmodifiable(tags);
  }

  TopicTagModel _mapTag(TagResponseDto dto) {
    return _validatedTag(
      id: dto.id,
      name: dto.name,
      color: dto.color,
      description: dto.description,
      sortOrder: dto.sortOrder.toInt(),
      isActive: dto.isActive,
    );
  }

  TopicTagModel _mapThreadTag(ThreadTagResponseDto dto) {
    return _validatedTag(
      id: dto.id,
      name: dto.name,
      color: dto.color,
      description: dto.description,
      sortOrder: dto.sortOrder.toInt(),
      isActive: dto.isActive,
    );
  }

  TopicTagModel _validatedTag({
    required String id,
    required String name,
    required String? color,
    required String? description,
    required int sortOrder,
    required bool isActive,
  }) {
    final normalizedName = normalizeTagName(name);
    if (_requiredText(id, '标签 ID').isEmpty ||
        validateTagName(normalizedName) != null ||
        !isActive) {
      throw const ApiFailure(userMessage: '标签信息格式异常，请重新加载。');
    }
    final normalizedColor = _optionalText(color);
    if (normalizedColor != null &&
        !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(normalizedColor)) {
      throw const ApiFailure(userMessage: '标签颜色格式异常，请重新加载。');
    }
    return TopicTagModel(
      id: id,
      name: normalizedName,
      color: normalizedColor,
      description: _optionalText(description),
      sortOrder: sortOrder,
      isActive: isActive,
    );
  }

  int _compareTags(TopicTagModel left, TopicTagModel right) {
    final byOrder = left.sortOrder.compareTo(right.sortOrder);
    return byOrder != 0 ? byOrder : left.name.compareTo(right.name);
  }

  String _requiredText(String? value, String field) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      throw ApiFailure(userMessage: '$field暂时无法显示，请重新加载。');
    }
    return normalized;
  }

  String? _optionalText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}

final apiTagRepositoryProvider = Provider<TagRepository>((ref) {
  final api = ref.watch(wenyouApiProvider);
  return ApiTagRepository(
    api.getTagsApi(),
    api.getThreadsApi(),
    api.getThreadCategoriesApi(),
  );
});
