import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/tags/data/tag_repository.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(CreateTagDto((builder) => builder.name = '测试'));
    registerFallbackValue(AddThreadTagDto((builder) => builder.name = '测试'));
  });

  test('公开标签页并发读取标签、分类和 tagId 精确主题流', () async {
    final tagsApi = _MockTagsApi();
    final threadsApi = _MockThreadsApi();
    final categoriesApi = _MockCategoriesApi();
    when(
      () => tagsApi.tagsGetById(id: 'tag-1'),
    ).thenAnswer((_) async => _tagDetailResponse());
    when(
      () => categoriesApi.threadCategoriesList(extra: const {'skipAuth': true}),
    ).thenAnswer((_) async => _categoriesResponse());
    when(
      () => threadsApi.threadsFindAll(tagId: 'tag-1'),
    ).thenAnswer((_) async => _threadsResponse());

    final result = await ApiTagRepository(
      tagsApi,
      threadsApi,
      categoriesApi,
    ).loadTagThreads('tag-1');

    expect(result.tag.name, '太空歌剧');
    expect(result.categories.single.slug, 'RPG');
    expect(result.page.items, isEmpty);
    verify(() => threadsApi.threadsFindAll(tagId: 'tag-1')).called(1);
  });

  test('管理页校验 capability、主题关联并加载全局候选', () async {
    final tagsApi = _MockTagsApi();
    final threadsApi = _MockThreadsApi();
    when(
      () => threadsApi.threadsFindById(id: 'thread-1'),
    ).thenAnswer((_) async => _threadResponse());
    when(
      () => threadsApi.threadTagsFindAll(threadId: 'thread-1'),
    ).thenAnswer((_) async => _relationsResponse());
    when(
      () => tagsApi.tagsSearch(),
    ).thenAnswer((_) async => _tagSearchResponse());

    final result = await ApiTagRepository(
      tagsApi,
      threadsApi,
      _MockCategoriesApi(),
    ).loadManagement('thread-1');

    expect(result.threadTitle, '星海旅团');
    expect(result.tags.single.id, 'tag-1');
    expect(result.suggestions.map((item) => item.id), ['tag-1', 'tag-2']);
  });

  test('搜索、详情、创建、添加和移除严格发送规范化载荷', () async {
    final tagsApi = _MockTagsApi();
    final threadsApi = _MockThreadsApi();
    when(
      () => tagsApi.tagsSearch(q: '太空'),
    ).thenAnswer((_) async => _tagSearchResponse());
    when(
      () => tagsApi.tagsGetById(id: 'tag-1'),
    ).thenAnswer((_) async => _tagDetailResponse());
    when(
      () => tagsApi.tagsCreate(createTagDto: any(named: 'createTagDto')),
    ).thenAnswer((invocation) async {
      final payload = invocation.namedArguments[#createTagDto] as CreateTagDto;
      return _tagCreateResponse(_tag(id: 'tag-created', name: payload.name));
    });
    when(
      () => threadsApi.threadTagsAdd(
        threadId: 'thread-1',
        addThreadTagDto: any(named: 'addThreadTagDto'),
      ),
    ).thenAnswer((_) async => _tagAddResponse());
    when(
      () => threadsApi.threadTagsRemove(threadId: 'thread-1', tagId: 'tag-1'),
    ).thenAnswer((_) async => _tagRemoveResponse());
    final repository = ApiTagRepository(
      tagsApi,
      threadsApi,
      _MockCategoriesApi(),
    );

    expect((await repository.search('  太空  ')).length, 2);
    expect((await repository.findById('tag-1')).id, 'tag-1');
    expect((await repository.create(' 新标签 ')).name, '新标签');
    expect(
      (await repository.addToThread(threadId: 'thread-1', name: ' 太空歌剧 ')).id,
      'tag-1',
    );
    await repository.removeFromThread(threadId: 'thread-1', tagId: 'tag-1');

    final createPayload =
        verify(
              () => tagsApi.tagsCreate(
                createTagDto: captureAny(named: 'createTagDto'),
              ),
            ).captured.single
            as CreateTagDto;
    final addPayload =
        verify(
              () => threadsApi.threadTagsAdd(
                threadId: 'thread-1',
                addThreadTagDto: captureAny(named: 'addThreadTagDto'),
              ),
            ).captured.single
            as AddThreadTagDto;
    expect(createPayload.name, '新标签');
    expect(addPayload.name, '太空歌剧');
  });

  test('关联所属主题不匹配时拒绝展示', () async {
    final tagsApi = _MockTagsApi();
    final threadsApi = _MockThreadsApi();
    when(
      () => threadsApi.threadsFindById(id: 'thread-1'),
    ).thenAnswer((_) async => _threadResponse());
    when(
      () => threadsApi.threadTagsFindAll(threadId: 'thread-1'),
    ).thenAnswer((_) async => _relationsResponse(threadId: 'other-thread'));
    when(
      () => tagsApi.tagsSearch(),
    ).thenAnswer((_) async => _tagSearchResponse());

    await expectLater(
      ApiTagRepository(
        tagsApi,
        threadsApi,
        _MockCategoriesApi(),
      ).loadManagement('thread-1'),
      throwsA(isA<ApiFailure>()),
    );
  });

  test('删除空响应不能伪装成功', () async {
    final threadsApi = _MockThreadsApi();
    when(
      () => threadsApi.threadTagsRemove(threadId: 'thread-1', tagId: 'tag-1'),
    ).thenAnswer(
      (_) async => Response<ThreadTagsRemove200Response>(
        requestOptions: RequestOptions(path: '/api/v1/threads/thread-1/tags'),
      ),
    );

    await expectLater(
      ApiTagRepository(
        _MockTagsApi(),
        threadsApi,
        _MockCategoriesApi(),
      ).removeFromThread(threadId: 'thread-1', tagId: 'tag-1'),
      throwsA(isA<ApiFailure>()),
    );
  });
}

class _MockTagsApi extends Mock implements TagsApi {}

class _MockThreadsApi extends Mock implements ThreadsApi {}

class _MockCategoriesApi extends Mock implements ThreadCategoriesApi {}

TagResponseDto _tag({String id = 'tag-1', String name = '太空歌剧'}) {
  final now = DateTime.utc(2026, 8, 10);
  return TagResponseDto(
    (builder) => builder
      ..id = id
      ..name = name
      ..color = '#704C65'
      ..description = '星际冒险与群像故事'
      ..sortOrder = id == 'tag-1' ? 1 : 2
      ..isActive = true
      ..createdAt = now
      ..updatedAt = now,
  );
}

ThreadTagResponseDto _threadTag() {
  return ThreadTagResponseDto(
    (builder) => builder
      ..id = 'tag-1'
      ..name = '太空歌剧'
      ..color = '#704C65'
      ..description = '星际冒险与群像故事'
      ..sortOrder = 1
      ..isActive = true,
  );
}

Response<TagsGetById200Response> _tagDetailResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/tags/tag-1'),
    data: TagsGetById200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(_tag()),
    ),
  );
}

Response<TagsSearch200Response> _tagSearchResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/tags'),
    data: TagsSearch200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.addAll([_tag(), _tag(id: 'tag-2', name: '群像')]),
    ),
  );
}

Response<TagsCreate200Response> _tagCreateResponse(TagResponseDto tag) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/tags'),
    data: TagsCreate200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(tag),
    ),
  );
}

Response<ThreadTagsAdd201Response> _tagAddResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads/thread-1/tags'),
    data: ThreadTagsAdd201Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(_threadTag()),
    ),
  );
}

Response<ThreadTagsRemove200Response> _tagRemoveResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads/thread-1/tags/tag-1'),
    data: ThreadTagsRemove200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '标签已移除'),
    ),
  );
}

Response<ThreadTagsFindAll200Response> _relationsResponse({
  String threadId = 'thread-1',
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads/thread-1/tags'),
    data: ThreadTagsFindAll200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.add(
          ThreadTagRelationResponseDto(
            (relation) => relation
              ..id = 'relation-1'
              ..threadId = threadId
              ..tagId = 'tag-1'
              ..tag.replace(_threadTag()),
          ),
        ),
    ),
  );
}

Response<ThreadsFindById200Response> _threadResponse() {
  final now = DateTime.utc(2026, 8, 10);
  final thread = ThreadDetailResponseDto(
    (builder) => builder
      ..id = 'thread-1'
      ..title = '星海旅团'
      ..ownerId = 'owner-1'
      ..category = 'RPG'
      ..status = ThreadDetailResponseDtoStatusEnum.RECRUITING
      ..visibility = ThreadDetailResponseDtoVisibilityEnum.PUBLIC
      ..published = true
      ..pinned = false
      ..viewCount = 0
      ..version = 1
      ..likeCount = 0
      ..tipTotal = '0'
      ..createdAt = now
      ..updatedAt = now
      ..owner.update(
        (owner) => owner
          ..id = 'owner-1'
          ..username = '楼主'
          ..level = 1,
      )
      ..count.update(
        (count) => count
          ..members = 1
          ..players = 0
          ..posts = 0,
      )
      ..currentMembership.update(
        (membership) => membership
          ..id = 'membership-1'
          ..userId = 'owner-1'
          ..role = CurrentThreadMembershipResponseDtoRoleEnum.OWNER
          ..playerMarked = false,
      )
      ..capabilities.update(
        (capabilities) => capabilities
          ..canManageThread = true
          ..canManageMembers = true
          ..isOwner = true,
      ),
  );
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads/thread-1'),
    data: ThreadsFindById200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(thread),
    ),
  );
}

Response<ThreadCategoriesList200Response> _categoriesResponse() {
  final now = DateTime.utc(2026, 8, 10);
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/thread-categories'),
    data: ThreadCategoriesList200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.add(
          ThreadCategoryResponseDto(
            (category) => category
              ..id = 'category-1'
              ..slug = 'RPG'
              ..name = '角色扮演'
              ..sortOrder = 1
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now,
          ),
        ),
    ),
  );
}

Response<ThreadsFindAll200Response> _threadsResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads'),
    data: ThreadsFindAll200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..meta.update((meta) => meta..hasMore = false),
    ),
  );
}
