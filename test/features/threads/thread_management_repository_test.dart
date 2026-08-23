import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      SaveThreadAggregateDto(
        (builder) => builder
          ..version = 1
          ..defaultSubthreadVersion = 1
          ..content = '正文'
          ..tagNames.replace(const <String>[]),
      ),
    );
  });

  test('加载主题权限与动态分区，并保留当前已停用分区', () async {
    final threadsApi = _MockThreadsApi();
    final categoriesApi = _MockCategoriesApi();
    when(
      () => threadsApi.threadsFindById(id: 'thread-1'),
    ).thenAnswer((_) async => _findResponse(_detail(category: 'ARCHIVED')));
    when(
      categoriesApi.threadCategoriesList,
    ).thenAnswer((_) async => _categoryResponse());

    final result = await ApiThreadManagementRepository(
      threadsApi,
      categoriesApi,
    ).load('thread-1');

    expect(result.thread.version, 7);
    expect(result.thread.canManage, isTrue);
    expect(result.thread.isOwner, isFalse);
    expect(result.thread.status, ThreadManagementStatus.recruiting);
    expect(result.categories.map((item) => item.slug), ['ARCHIVED', 'RPG']);
    expect(result.categories.first.isSelectable, isFalse);
    expect(result.categories.first.name, '历史分类');
    expect(result.categories.first.name, isNot('ARCHIVED'));
  });

  test('协作者更新只发送已变化字段与当前 version', () async {
    final threadsApi = _MockThreadsApi();
    final categoriesApi = _MockCategoriesApi();
    when(
      () => threadsApi.threadsSaveAggregate(
        id: 'thread-1',
        saveThreadAggregateDto: any(named: 'saveThreadAggregateDto'),
      ),
    ).thenAnswer(
      (_) async => _aggregateResponse(
        _detail(title: '新标题', status: ThreadDetailResponseDtoStatusEnum.CLOSED),
      ),
    );
    final repository = ApiThreadManagementRepository(threadsApi, categoriesApi);

    final updated = await repository.update(
      current: _snapshot(isOwner: false),
      draft: const ThreadManagementDraft(
        title: '  新标题  ',
        categorySlug: 'RPG',
        status: ThreadManagementStatus.closed,
        visibility: ThreadManagementVisibility.public,
        body: '主正文',
        tagNames: ['跑团'],
      ),
    );

    final captured =
        verify(
              () => threadsApi.threadsSaveAggregate(
                id: 'thread-1',
                saveThreadAggregateDto: captureAny(
                  named: 'saveThreadAggregateDto',
                ),
              ),
            ).captured.single
            as SaveThreadAggregateDto;
    expect(captured.version, 7);
    expect(captured.defaultSubthreadVersion, 3);
    expect(captured.bodyVersion, 4);
    expect(captured.content, '主正文');
    expect(captured.tagNames.toList(), ['跑团']);
    expect(captured.title, '新标题');
    expect(captured.category, isNull);
    expect(captured.status, SaveThreadAggregateDtoStatusEnum.CLOSED);
    expect(captured.visibility, isNull);
    expect(captured.published, isNull);
    expect(updated.title, '新标题');
  });

  test('协作者在客户端不能夹带可见性修改', () async {
    final threadsApi = _MockThreadsApi();
    final repository = ApiThreadManagementRepository(
      threadsApi,
      _MockCategoriesApi(),
    );

    await expectLater(
      repository.update(
        current: _snapshot(isOwner: false),
        draft: const ThreadManagementDraft(
          title: '原主题',
          categorySlug: 'RPG',
          status: ThreadManagementStatus.recruiting,
          visibility: ThreadManagementVisibility.private,
        ),
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.businessCode,
          'businessCode',
          40301,
        ),
      ),
    );
    verifyNever(
      () => threadsApi.threadsSaveAggregate(
        id: any(named: 'id'),
        saveThreadAggregateDto: any(named: 'saveThreadAggregateDto'),
      ),
    );
  });

  test('删除必须得到非空服务端确认', () async {
    final threadsApi = _MockThreadsApi();
    when(() => threadsApi.threadsRemove(id: 'thread-1')).thenAnswer(
      (_) async => Response<ThreadsRemove200Response>(
        requestOptions: RequestOptions(path: '/api/v1/threads/thread-1'),
      ),
    );
    final repository = ApiThreadManagementRepository(
      threadsApi,
      _MockCategoriesApi(),
    );

    await expectLater(
      repository.remove('thread-1'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'userMessage',
          contains('删除失败'),
        ),
      ),
    );
  });
}

class _MockThreadsApi extends Mock implements ThreadsApi {}

class _MockCategoriesApi extends Mock implements ThreadCategoriesApi {}

ThreadManagementSnapshot _snapshot({required bool isOwner}) {
  return ThreadManagementSnapshot(
    id: 'thread-1',
    title: '原主题',
    categorySlug: 'RPG',
    status: ThreadManagementStatus.recruiting,
    visibility: ThreadManagementVisibility.public,
    version: 7,
    published: true,
    canManage: true,
    isOwner: isOwner,
    defaultSubthreadId: 'subthread-1',
    defaultSubthreadVersion: 3,
    bodyPostId: 'body-1',
    bodyVersion: 4,
    body: '主正文',
    tagNames: const ['跑团'],
  );
}

Response<ThreadsFindById200Response> _findResponse(
  ThreadDetailResponseDto detail,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads/thread-1'),
    data: ThreadsFindById200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(detail),
    ),
  );
}

Response<ThreadsSaveAggregate200Response> _aggregateResponse(
  ThreadDetailResponseDto detail,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads/thread-1'),
    data: ThreadsSaveAggregate200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(detail),
    ),
  );
}

Response<ThreadCategoriesList200Response> _categoryResponse() {
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
              ..id = 'category-rpg'
              ..slug = 'RPG'
              ..name = '角色扮演'
              ..sortOrder = 2
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now,
          ),
        ),
    ),
  );
}

ThreadDetailResponseDto _detail({
  String title = '原主题',
  String category = 'RPG',
  ThreadDetailResponseDtoStatusEnum status =
      ThreadDetailResponseDtoStatusEnum.RECRUITING,
}) {
  final now = DateTime.utc(2026, 8, 10);
  return ThreadDetailResponseDto(
    (thread) => thread
      ..id = 'thread-1'
      ..title = title
      ..ownerId = 'owner-1'
      ..category = category
      ..status = status
      ..visibility = ThreadDetailResponseDtoVisibilityEnum.PUBLIC
      ..published = true
      ..pinned = false
      ..viewCount = 0
      ..version = 7
      ..likeCount = 0
      ..tipTotal = '0'
      ..defaultSubthreadId = 'subthread-1'
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
          ..posts = 0
          ..players = 0,
      )
      ..currentMembership.update(
        (membership) => membership
          ..id = 'membership-1'
          ..userId = 'collaborator-1'
          ..role = CurrentThreadMembershipResponseDtoRoleEnum.COLLABORATOR
          ..playerMarked = false,
      )
      ..capabilities.update(
        (capabilities) => capabilities
          ..canManageThread = true
          ..canManageMembers = true
          ..isOwner = false,
      )
      ..subthreads.add(
        ThreadSubthreadResponseDto(
          (subthread) => subthread
            ..id = 'subthread-1'
            ..threadId = 'thread-1'
            ..title = title
            ..sortOrder = 0
            ..postingPolicy =
                ThreadSubthreadResponseDtoPostingPolicyEnum.PARTICIPANTS
            ..version = 3
            ..createdAt = now
            ..bodyPost.update(
              (body) => body
                ..id = 'body-1'
                ..content = '主正文'
                ..version = 4,
            )
            ..count.update((count) => count.posts = 0),
        ),
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
                ..name = '跑团'
                ..sortOrder = 1
                ..isActive = true,
            ),
        ),
      ),
  );
}
