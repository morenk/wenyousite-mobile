import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/editor/data/thread_compose_repository.dart';
import 'package:wenyousite_mobile/features/editor/domain/thread_compose_models.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeCreateThreadDto());
    registerFallbackValue(_FakeSaveThreadAggregateDto());
  });

  test('创建草稿和聚合发布传递规范化内容、幂等键与全部版本号', () async {
    final threadsApi = _MockThreadsApi();
    final createdDto = _threadDetail(
      published: false,
      version: 2,
      subthreadVersion: 3,
      bodyVersion: 4,
      content: '创建后的正文',
    );
    final publishedDto = _threadDetail(
      published: true,
      version: 8,
      subthreadVersion: 9,
      bodyVersion: 10,
      content: '发布后的正文',
    );
    when(
      () => threadsApi.threadsCreate(
        createThreadDto: any(named: 'createThreadDto'),
      ),
    ).thenAnswer((_) async => _createResponse(createdDto));
    when(
      () => threadsApi.threadsSaveAggregate(
        id: 'thread-one',
        saveThreadAggregateDto: any(named: 'saveThreadAggregateDto'),
      ),
    ).thenAnswer((_) async => _aggregateResponse(publishedDto));
    final repository = ApiThreadComposeRepository(
      threadsApi,
      _MockCategoriesApi(),
      _MockUsersApi(),
    );

    final created = await repository.createDraft(
      const ThreadCreatePayload(
        clientRequestId: '550e8400-e29b-41d4-a716-446655440000',
        title: '  测试主题  ',
        categorySlug: ' TRPG ',
        visibility: ThreadComposeVisibility.private,
        tags: [' 跑团 ', '跑团', '奇幻'],
        body: '第一行\r\n第二行',
      ),
    );
    final createRequest =
        verify(
              () => threadsApi.threadsCreate(
                createThreadDto: captureAny(named: 'createThreadDto'),
              ),
            ).captured.single
            as CreateThreadDto;

    expect(
      createRequest.clientRequestId,
      '550e8400-e29b-41d4-a716-446655440000',
    );
    expect(createRequest.title, '测试主题');
    expect(createRequest.category, 'TRPG');
    expect(createRequest.visibility, CreateThreadDtoVisibilityEnum.PRIVATE);
    expect(createRequest.tagNames!.toList(), ['跑团', '奇幻']);
    expect(createRequest.content, '第一行\n第二行');
    expect(created.version, 2);
    expect(created.defaultSubthreadVersion, 3);
    expect(created.bodyVersion, 4);

    final published = await repository.saveAggregate(
      remoteDraft: ThreadRemoteDraft(
        id: created.id,
        version: 7,
        defaultSubthreadId: created.defaultSubthreadId,
        defaultSubthreadVersion: 8,
        bodyVersion: 9,
        title: created.title,
        categorySlug: created.categorySlug,
        visibility: created.visibility,
        tags: created.tags,
        body: created.body,
      ),
      title: '  发布标题  ',
      categorySlug: ' TRPG ',
      visibility: ThreadComposeVisibility.public,
      tags: const ['奇幻'],
      body: '发布正文\r\n第二行',
      publish: true,
    );
    final aggregateRequest =
        verify(
              () => threadsApi.threadsSaveAggregate(
                id: 'thread-one',
                saveThreadAggregateDto: captureAny(
                  named: 'saveThreadAggregateDto',
                ),
              ),
            ).captured.single
            as SaveThreadAggregateDto;

    expect(aggregateRequest.version, 7);
    expect(aggregateRequest.defaultSubthreadVersion, 8);
    expect(aggregateRequest.bodyVersion, 9);
    expect(aggregateRequest.title, '发布标题');
    expect(aggregateRequest.category, 'TRPG');
    expect(
      aggregateRequest.visibility,
      SaveThreadAggregateDtoVisibilityEnum.PUBLIC,
    );
    expect(aggregateRequest.tagNames.toList(), ['奇幻']);
    expect(aggregateRequest.content, '发布正文\n第二行');
    expect(aggregateRequest.published, isTrue);
    expect(published.version, 8);
    expect(published.body, '发布后的正文');
  });

  test('账号和分类并发失败都被消费并统一映射为 API 错误', () async {
    final usersApi = _MockUsersApi();
    final categoriesApi = _MockCategoriesApi();
    when(
      () => usersApi.usersGetMe(),
    ).thenAnswer((_) async => throw _dioError('/api/v1/users/me'));
    when(
      () => categoriesApi.threadCategoriesList(),
    ).thenAnswer((_) async => throw _dioError('/api/v1/thread-categories'));

    final future = ApiThreadComposeRepository(
      _MockThreadsApi(),
      categoriesApi,
      usersApi,
    ).fetchBootstrap();

    await expectLater(future, throwsA(isA<ApiFailure>()));
    verify(() => usersApi.usersGetMe()).called(1);
    verify(() => categoriesApi.threadCategoriesList()).called(1);
  });
}

class _MockThreadsApi extends Mock implements ThreadsApi {}

class _MockCategoriesApi extends Mock implements ThreadCategoriesApi {}

class _MockUsersApi extends Mock implements UsersApi {}

class _MockCreateEnvelope extends Mock implements ThreadsCreate201Response {}

class _MockAggregateEnvelope extends Mock
    implements ThreadsSaveAggregate200Response {}

class _MockThreadDetail extends Mock implements ThreadDetailResponseDto {}

class _MockSubthread extends Mock implements ThreadSubthreadResponseDto {}

class _MockBodyPost extends Mock implements ThreadBodyPostResponseDto {}

class _FakeCreateThreadDto extends Fake implements CreateThreadDto {}

class _FakeSaveThreadAggregateDto extends Fake
    implements SaveThreadAggregateDto {}

DioException _dioError(String path) {
  return DioException.connectionError(
    requestOptions: RequestOptions(path: path),
    reason: 'offline',
  );
}

Response<ThreadsCreate201Response> _createResponse(
  ThreadDetailResponseDto dto,
) {
  final envelope = _MockCreateEnvelope();
  when(() => envelope.data).thenReturn(dto);
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads'),
    data: envelope,
  );
}

Response<ThreadsSaveAggregate200Response> _aggregateResponse(
  ThreadDetailResponseDto dto,
) {
  final envelope = _MockAggregateEnvelope();
  when(() => envelope.data).thenReturn(dto);
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/threads/thread-one/aggregate',
    ),
    data: envelope,
  );
}

ThreadDetailResponseDto _threadDetail({
  required bool published,
  required int version,
  required int subthreadVersion,
  required int bodyVersion,
  required String content,
}) {
  final body = _MockBodyPost();
  when(() => body.version).thenReturn(bodyVersion);
  when(() => body.content).thenReturn(content);
  final subthread = _MockSubthread();
  when(() => subthread.id).thenReturn('subthread-one');
  when(() => subthread.version).thenReturn(subthreadVersion);
  when(() => subthread.bodyPost).thenReturn(body);
  final dto = _MockThreadDetail();
  when(() => dto.id).thenReturn('thread-one');
  when(() => dto.version).thenReturn(version);
  when(() => dto.title).thenReturn('服务端主题');
  when(() => dto.category).thenReturn('TRPG');
  when(() => dto.visibility).thenReturn(
    published
        ? ThreadDetailResponseDtoVisibilityEnum.PUBLIC
        : ThreadDetailResponseDtoVisibilityEnum.PRIVATE,
  );
  when(() => dto.published).thenReturn(published);
  when(() => dto.defaultSubthreadId).thenReturn('subthread-one');
  when(() => dto.subthreads).thenReturn(BuiltList([subthread]));
  when(() => dto.topicTags).thenReturn(BuiltList());
  return dto;
}
