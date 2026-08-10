import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(UpdateThreadDto((builder) => builder.version = 1));
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
  });

  test('协作者更新只发送已变化字段与当前 version', () async {
    final threadsApi = _MockThreadsApi();
    final categoriesApi = _MockCategoriesApi();
    when(
      () => threadsApi.threadsUpdate(
        id: 'thread-1',
        updateThreadDto: any(named: 'updateThreadDto'),
      ),
    ).thenAnswer(
      (_) async => _updateResponse(
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
      ),
    );

    final captured =
        verify(
              () => threadsApi.threadsUpdate(
                id: 'thread-1',
                updateThreadDto: captureAny(named: 'updateThreadDto'),
              ),
            ).captured.single
            as UpdateThreadDto;
    expect(captured.version, 7);
    expect(captured.title, '新标题');
    expect(captured.category, isNull);
    expect(captured.status, UpdateThreadDtoStatusEnum.CLOSED);
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
      () => threadsApi.threadsUpdate(
        id: any(named: 'id'),
        updateThreadDto: any(named: 'updateThreadDto'),
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
          contains('没有确认'),
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

Response<ThreadsUpdate200Response> _updateResponse(
  ThreadDetailResponseDto detail,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads/thread-1'),
    data: ThreadsUpdate200Response(
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
      ),
  );
}
