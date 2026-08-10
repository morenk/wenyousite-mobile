import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/features/threads/data/subthread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(CreateSubthreadDto((builder) => builder.title = 'x'));
    registerFallbackValue(UpdateSubthreadDto((builder) => builder.version = 1));
    registerFallbackValue(
      ReorderSubthreadsDto((builder) => builder.ids.add('sub-default')),
    );
  });

  test('并发读取主题权限和完整子贴列表并识别默认子贴', () async {
    final threadsApi = _MockThreadsApi();
    final subthreadsApi = _MockSubthreadsApi();
    when(
      () => threadsApi.threadsFindById(id: 'thread-1'),
    ).thenAnswer((_) async => _threadResponse());
    when(
      () => subthreadsApi.subthreadsFindAll(threadId: 'thread-1'),
    ).thenAnswer(
      (_) async => _listResponse([
        _subthread(id: 'sub-second', title: '剧情区', sortOrder: 1),
        _subthread(id: 'sub-default', title: '主贴', sortOrder: 0),
      ]),
    );

    final result = await ApiSubthreadManagementRepository(
      threadsApi,
      subthreadsApi,
    ).load('thread-1');

    expect(result.threadTitle, '星海旅团');
    expect(result.items.map((item) => item.id), ['sub-default', 'sub-second']);
    expect(result.items.first.isDefault, isTrue);
    expect(
      result.items.last.postingPolicy,
      SubthreadPostingPolicy.participants,
    );
  });

  test('缺少管理 capability 时拒绝工作台', () async {
    final threadsApi = _MockThreadsApi();
    final subthreadsApi = _MockSubthreadsApi();
    when(
      () => threadsApi.threadsFindById(id: 'thread-1'),
    ).thenAnswer((_) async => _threadResponse(canManage: false));
    when(
      () => subthreadsApi.subthreadsFindAll(threadId: 'thread-1'),
    ).thenAnswer((_) async => _listResponse([]));

    await expectLater(
      ApiSubthreadManagementRepository(
        threadsApi,
        subthreadsApi,
      ).load('thread-1'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.businessCode,
          'businessCode',
          40300,
        ),
      ),
    );
  });

  test('详情读取校验所属主题', () async {
    final api = _MockSubthreadsApi();
    when(
      () => api.subthreadsFindById(id: 'sub-second'),
    ).thenAnswer((_) async => _detailResponse(_subthread(threadId: 'other')));

    await expectLater(
      ApiSubthreadManagementRepository(_MockThreadsApi(), api).findById(
        threadId: 'thread-1',
        subthreadId: 'sub-second',
        isDefault: false,
      ),
      throwsA(isA<ApiFailure>()),
    );
  });

  test('创建复用稳定幂等键并发送标题和发帖权限', () async {
    final api = _MockSubthreadsApi();
    when(
      () => api.subthreadsCreate(
        threadId: 'thread-1',
        extra: ApiRequestPolicy.idempotentCreate.extra,
        createSubthreadDto: any(named: 'createSubthreadDto'),
      ),
    ).thenAnswer(
      (_) async => _createResponse(
        _subthread(
          id: 'sub-new',
          title: '玩家区',
          sortOrder: 2,
          policy: SubthreadResponseDtoPostingPolicyEnum.PLAYERS,
        ),
      ),
    );

    await ApiSubthreadManagementRepository(_MockThreadsApi(), api).create(
      threadId: 'thread-1',
      draft: const SubthreadManagementDraft(
        title: ' 玩家区 ',
        postingPolicy: SubthreadPostingPolicy.players,
      ),
      clientRequestId: '11111111-1111-4111-8111-111111111111',
    );

    final payload =
        verify(
              () => api.subthreadsCreate(
                threadId: 'thread-1',
                extra: ApiRequestPolicy.idempotentCreate.extra,
                createSubthreadDto: captureAny(named: 'createSubthreadDto'),
              ),
            ).captured.single
            as CreateSubthreadDto;
    expect(payload.clientRequestId, '11111111-1111-4111-8111-111111111111');
    expect(payload.title, '玩家区');
    expect(payload.postingPolicy, CreateSubthreadDtoPostingPolicyEnum.PLAYERS);
    expect(payload.sortOrder, isNull);
  });

  test('更新只发送变化字段和当前版本', () async {
    final api = _MockSubthreadsApi();
    when(
      () => api.subthreadsUpdate(
        id: 'sub-second',
        updateSubthreadDto: any(named: 'updateSubthreadDto'),
      ),
    ).thenAnswer(
      (_) async => _updateResponse(
        _subthread(
          title: '新剧情区',
          version: 4,
          policy: SubthreadResponseDtoPostingPolicyEnum.COLLABORATORS,
        ),
      ),
    );
    final current = _item();

    await ApiSubthreadManagementRepository(_MockThreadsApi(), api).update(
      current: current,
      draft: const SubthreadManagementDraft(
        title: '新剧情区',
        postingPolicy: SubthreadPostingPolicy.collaborators,
      ),
    );

    final payload =
        verify(
              () => api.subthreadsUpdate(
                id: 'sub-second',
                updateSubthreadDto: captureAny(named: 'updateSubthreadDto'),
              ),
            ).captured.single
            as UpdateSubthreadDto;
    expect(payload.version, 3);
    expect(payload.title, '新剧情区');
    expect(
      payload.postingPolicy,
      UpdateSubthreadDtoPostingPolicyEnum.COLLABORATORS,
    );
    expect(payload.sortOrder, isNull);
  });

  test('更新响应必须匹配请求子贴', () async {
    final api = _MockSubthreadsApi();
    when(
      () => api.subthreadsUpdate(
        id: 'sub-second',
        updateSubthreadDto: any(named: 'updateSubthreadDto'),
      ),
    ).thenAnswer(
      (_) async => _updateResponse(
        _subthread(id: 'sub-other', title: '错误目标', version: 4),
      ),
    );

    await expectLater(
      ApiSubthreadManagementRepository(_MockThreadsApi(), api).update(
        current: _item(),
        draft: const SubthreadManagementDraft(
          title: '新剧情区',
          postingPolicy: SubthreadPostingPolicy.participants,
        ),
      ),
      throwsA(isA<ApiFailure>()),
    );
  });

  test('删除必须得到非空确认且默认子贴在本地被拒绝', () async {
    final api = _MockSubthreadsApi();
    when(() => api.subthreadsRemove(id: 'sub-second')).thenAnswer(
      (_) async => Response<SubthreadsRemove200Response>(
        requestOptions: RequestOptions(path: '/api/v1/subthreads/sub-second'),
      ),
    );
    final repository = ApiSubthreadManagementRepository(_MockThreadsApi(), api);

    await expectLater(repository.remove(_item()), throwsA(isA<ApiFailure>()));
    await expectLater(
      repository.remove(_item(isDefault: true)),
      throwsA(isA<ApiFailure>()),
    );
  });

  test('重排发送包含默认子贴的完整集合并采用服务端顺序', () async {
    final api = _MockSubthreadsApi();
    when(
      () => api.subthreadsReorder(
        threadId: 'thread-1',
        reorderSubthreadsDto: any(named: 'reorderSubthreadsDto'),
      ),
    ).thenAnswer(
      (_) async => _reorderResponse([
        ('sub-default', '主贴', 0),
        ('sub-third', '闲聊区', 1),
        ('sub-second', '剧情区', 2),
      ]),
    );
    final items = [
      _item(id: 'sub-default', title: '主贴', sortOrder: 0, isDefault: true),
      _item(id: 'sub-third', title: '闲聊区', sortOrder: 2),
      _item(),
    ];

    final result = await ApiSubthreadManagementRepository(
      _MockThreadsApi(),
      api,
    ).reorder(threadId: 'thread-1', items: items);

    final payload =
        verify(
              () => api.subthreadsReorder(
                threadId: 'thread-1',
                reorderSubthreadsDto: captureAny(named: 'reorderSubthreadsDto'),
              ),
            ).captured.single
            as ReorderSubthreadsDto;
    expect(payload.ids, ['sub-default', 'sub-third', 'sub-second']);
    expect(result.map((item) => item.id), payload.ids);
    expect(result.first.isDefault, isTrue);
  });
}

class _MockThreadsApi extends Mock implements ThreadsApi {}

class _MockSubthreadsApi extends Mock implements SubthreadsApi {}

Response<ThreadsFindById200Response> _threadResponse({bool canManage = true}) {
  final now = DateTime.utc(2026, 8, 10);
  final dto = ThreadDetailResponseDto(
    (thread) => thread
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
      ..defaultSubthreadId = 'sub-default'
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
          ..posts = 2
          ..players = 0,
      )
      ..currentMembership.update(
        (membership) => membership
          ..id = 'membership-1'
          ..userId = 'owner-1'
          ..role = canManage
              ? CurrentThreadMembershipResponseDtoRoleEnum.OWNER
              : CurrentThreadMembershipResponseDtoRoleEnum.PARTICIPANT
          ..playerMarked = false,
      )
      ..capabilities.update(
        (capabilities) => capabilities
          ..canManageThread = canManage
          ..canManageMembers = canManage
          ..isOwner = canManage,
      ),
  );
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads/thread-1'),
    data: ThreadsFindById200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(dto),
    ),
  );
}

SubthreadResponseDto _subthread({
  String id = 'sub-second',
  String threadId = 'thread-1',
  String title = '剧情区',
  int sortOrder = 1,
  int version = 3,
  SubthreadResponseDtoPostingPolicyEnum policy =
      SubthreadResponseDtoPostingPolicyEnum.PARTICIPANTS,
}) {
  return SubthreadResponseDto(
    (subthread) => subthread
      ..id = id
      ..threadId = threadId
      ..title = title
      ..sortOrder = sortOrder
      ..postingPolicy = policy
      ..version = version
      ..createdAt = DateTime.utc(2026, 8, 10)
      ..count.update((count) => count.posts = 2),
  );
}

Response<SubthreadsFindAll200Response> _listResponse(
  List<SubthreadResponseDto> items,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads/thread-1/subthreads'),
    data: SubthreadsFindAll200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.addAll(items),
    ),
  );
}

Response<SubthreadsFindById200Response> _detailResponse(
  SubthreadResponseDto item,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/subthreads/${item.id}'),
    data: SubthreadsFindById200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(item),
    ),
  );
}

Response<SubthreadsCreate201Response> _createResponse(
  SubthreadResponseDto item,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/subthreads'),
    data: SubthreadsCreate201Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(item),
    ),
  );
}

Response<SubthreadsUpdate200Response> _updateResponse(
  SubthreadResponseDto item,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/subthreads/${item.id}'),
    data: SubthreadsUpdate200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(item),
    ),
  );
}

Response<SubthreadsReorder200Response> _reorderResponse(
  List<(String, String, int)> items,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/subthreads/reorder'),
    data: SubthreadsReorder200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.addAll(
          items.map(
            (item) => ReorderedSubthreadResponseDto(
              (dto) => dto
                ..id = item.$1
                ..title = item.$2
                ..sortOrder = item.$3,
            ),
          ),
        ),
    ),
  );
}

SubthreadManagementItem _item({
  String id = 'sub-second',
  String title = '剧情区',
  int sortOrder = 2,
  bool isDefault = false,
}) {
  return SubthreadManagementItem(
    id: id,
    threadId: 'thread-1',
    title: title,
    sortOrder: sortOrder,
    postingPolicy: SubthreadPostingPolicy.participants,
    version: 3,
    postCount: 2,
    isDefault: isDefault,
  );
}
