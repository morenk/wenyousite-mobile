import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';

void main() {
  test('分类按服务端顺序映射且过滤停用项', () async {
    final threadsApi = _MockThreadsApi();
    final categoriesApi = _MockThreadCategoriesApi();
    when(
      () => categoriesApi.threadCategoriesList(extra: const {'skipAuth': true}),
    ).thenAnswer((_) async => _categoriesResponse());

    final categories = await ApiHomeRepository(
      threadsApi,
      categoriesApi,
    ).fetchCategories();

    expect(categories.map((item) => item.slug), ['RPG', 'DEDUCTION']);
    expect(categories.first.name, '角色扮演');
    expect(categories.first.description, '角色扮演主题');
  });

  test('主题查询传递筛选与 cursor 并映射卡片字段', () async {
    final threadsApi = _MockThreadsApi();
    final categoriesApi = _MockThreadCategoriesApi();
    when(
      () => threadsApi.threadsFindAll(
        cursor: 'cursor-1',
        limit: 20,
        filter: 'all',
        category: 'RPG',
        sort: 'active',
        status: 'FINISHED',
        tagId: 'tag-1',
      ),
    ).thenAnswer((_) async => _threadsResponse());

    final page = await ApiHomeRepository(threadsApi, categoriesApi)
        .fetchThreads(
          query: const HomeFeedQuery(
            categorySlug: 'RPG',
            tagId: 'tag-1',
            sort: HomeFeedSort.active,
            status: HomeThreadStatusFilter.finished,
          ),
          cursor: 'cursor-1',
        );

    expect(page.cursor, 'cursor-2');
    expect(page.hasMore, isTrue);
    final item = page.items.single;
    expect(item.title, '星海旅团');
    expect(item.status, HomeThreadStatus.finished);
    expect(item.ownerName, '温柔测试员');
    expect(item.ownerLevel, 3);
    expect(item.preview, '向星海出发');
    expect(item.tags.single.name, '太空歌剧');
    expect(item.coverImageUrls, ['https://cdn.example.com/cover.jpg']);
    expect(item.memberCount, 5);
    expect(item.postCount, 12);
    expect(item.tipTotal, '8');
  });
}

class _MockThreadsApi extends Mock implements ThreadsApi {}

class _MockThreadCategoriesApi extends Mock implements ThreadCategoriesApi {}

Response<ThreadCategoriesList200Response> _categoriesResponse() {
  final now = DateTime.utc(2026, 8, 9);
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/thread-categories'),
    data: ThreadCategoriesList200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.addAll([
          ThreadCategoryResponseDto(
            (category) => category
              ..id = 'deduction'
              ..slug = 'DEDUCTION'
              ..name = '演绎'
              ..sortOrder = 20
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now,
          ),
          ThreadCategoryResponseDto(
            (category) => category
              ..id = 'rpg'
              ..slug = 'RPG'
              ..name = '角色扮演'
              ..description = '角色扮演主题'
              ..sortOrder = 10
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now,
          ),
          ThreadCategoryResponseDto(
            (category) => category
              ..id = 'inactive'
              ..slug = 'INACTIVE'
              ..name = '已停用'
              ..sortOrder = 0
              ..isActive = false
              ..createdAt = now
              ..updatedAt = now,
          ),
        ]),
    ),
  );
}

Response<ThreadsFindAll200Response> _threadsResponse() {
  final now = DateTime.utc(2026, 8, 9, 12);
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads'),
    data: ThreadsFindAll200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..meta.update(
          (meta) => meta
            ..cursor = 'cursor-2'
            ..hasMore = true,
        )
        ..data.add(
          HomeThreadListItemResponseDto(
            (thread) => thread
              ..id = 'thread-1'
              ..title = '星海旅团'
              ..category = 'RPG'
              ..status = HomeThreadListItemResponseDtoStatusEnum.FINISHED
              ..visibility = HomeThreadListItemResponseDtoVisibilityEnum.PUBLIC
              ..published = true
              ..pinned = false
              ..tipTotal = '8'
              ..createdAt = now.subtract(const Duration(days: 2))
              ..updatedAt = now
              ..owner.update(
                (owner) => owner
                  ..id = 'user-1'
                  ..username = '温柔测试员'
                  ..level = 3,
              )
              ..defaultSubthread.update(
                (subthread) => subthread
                  ..id = 'subthread-1'
                  ..title = '主线'
                  ..lastPostAt = now,
              )
              ..topicTags.add(
                ThreadTagRelationResponseDto(
                  (relation) => relation
                    ..id = 'relation-1'
                    ..threadId = 'thread-1'
                    ..tagId = 'tag-1'
                    ..tag.update(
                      (tag) => tag
                        ..id = 'tag-1'
                        ..name = '太空歌剧'
                        ..sortOrder = 1
                        ..isActive = true,
                    ),
                ),
              )
              ..count.update(
                (count) => count
                  ..members = 5
                  ..players = 2
                  ..posts = 12,
              )
              ..preview = '  向星海出发  '
              ..coverImages.addAll([
                'https://cdn.example.com/cover.jpg',
                'javascript:alert(1)',
              ]),
          ),
        ),
    ),
  );
}
