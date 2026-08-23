import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/drafts/data/content_draft_repository.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      CreateDraftDto((builder) => builder.content = 'fallback'),
    );
    registerFallbackValue(
      UpdateDraftDto(
        (builder) => builder
          ..content = 'fallback'
          ..version = 1,
      ),
    );
  });

  test('草稿与槽位从同一原子快照映射为按槽位排序的领域模型', () async {
    final api = _MockDraftsApi();
    when(() => api.draftsState()).thenAnswer(
      (_) async => _stateResponse([
        _draftDto(slot: 3, id: 'draft-3'),
        _draftDto(slot: 1, id: 'draft-1'),
      ]),
    );

    final result = await ApiContentDraftRepository(api).fetchCollection();

    expect(result.drafts.map((draft) => draft.id), ['draft-1', 'draft-3']);
    expect(result.usage.usedSlots, 2);
    expect(result.usage.maxSlots, 5);
    expect(result.usage.occupiedSlots, {1, 3});
    verify(() => api.draftsState()).called(1);
  });

  test('创建、单条读取、版本更新和删除使用完整 API 载荷', () async {
    final api = _MockDraftsApi();
    when(
      () => api.draftsCreate(
        createDraftDto: any(named: 'createDraftDto'),
        extra: any(named: 'extra'),
      ),
    ).thenAnswer((_) async => _createResponse(_draftDto(slot: 2)));
    when(
      () => api.draftsFindById(id: 'draft-2'),
    ).thenAnswer((_) async => _findByIdResponse(_draftDto(slot: 2)));
    when(
      () => api.draftsUpdate(
        id: 'draft-2',
        updateDraftDto: any(named: 'updateDraftDto'),
      ),
    ).thenAnswer(
      (_) async =>
          _updateResponse(_draftDto(slot: 2, content: '新版正文', version: 4)),
    );
    when(
      () => api.draftsRemove(id: 'draft-2', version: 4),
    ).thenAnswer((_) async => _removeResponse());
    final repository = ApiContentDraftRepository(api);

    await repository.create('自动正文', clientRequestId: _requestIdOne);
    final created = await repository.create(
      '当前正文',
      slot: 2,
      clientRequestId: _requestIdTwo,
    );
    final fetched = await repository.fetchById('draft-2');
    final updated = await repository.update(
      id: 'draft-2',
      content: '新版正文',
      version: 3,
    );
    await repository.remove('draft-2', version: 4);

    final createPayloads = verify(
      () => api.draftsCreate(
        createDraftDto: captureAny(named: 'createDraftDto'),
        extra: any(named: 'extra'),
      ),
    ).captured.cast<CreateDraftDto>();
    final updatePayload =
        verify(
              () => api.draftsUpdate(
                id: 'draft-2',
                updateDraftDto: captureAny(named: 'updateDraftDto'),
              ),
            ).captured.single
            as UpdateDraftDto;
    expect(created.slot, 2);
    expect(fetched.id, 'draft-2');
    expect(updated.version, 4);
    expect(createPayloads, hasLength(2));
    expect(createPayloads.first.content, '自动正文');
    expect(createPayloads.first.clientRequestId, _requestIdOne);
    expect(createPayloads.first.slot, isNull);
    expect(createPayloads.last.content, '当前正文');
    expect(createPayloads.last.clientRequestId, _requestIdTwo);
    expect(createPayloads.last.slot, 2);
    expect(createPayloads.last.version, isNull);
    expect(updatePayload.content, '新版正文');
    expect(updatePayload.version, 3);
    verify(() => api.draftsRemove(id: 'draft-2', version: 4)).called(1);
  });

  test('空成功响应不会伪装成保存成功', () async {
    final api = _MockDraftsApi();
    when(
      () => api.draftsCreate(
        createDraftDto: any(named: 'createDraftDto'),
        extra: any(named: 'extra'),
      ),
    ).thenAnswer(
      (_) async => Response<DraftsCreate201Response>(
        requestOptions: RequestOptions(path: '/api/v1/drafts'),
      ),
    );

    await expectLater(
      ApiContentDraftRepository(
        api,
      ).create('当前正文', clientRequestId: _requestIdOne),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('保存失败'),
        ),
      ),
    );
  });
}

class _MockDraftsApi extends Mock implements DraftsApi {}

DraftResponseDto _draftDto({
  int slot = 2,
  String? id,
  String content = '云端正文',
  int version = 3,
}) {
  return DraftResponseDto(
    (builder) => builder
      ..id = id ?? 'draft-$slot'
      ..userId = 'user-one'
      ..slot = slot
      ..content = content
      ..version = version
      ..createdAt = DateTime.utc(2026, 8, 9)
      ..updatedAt = DateTime.utc(2026, 8, 10),
  );
}

Response<DraftsState200Response> _stateResponse(List<DraftResponseDto> drafts) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/drafts/state'),
    data: DraftsState200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (state) => state
            ..usedSlots = drafts.length
            ..maxSlots = 5
            ..slots.replace(drafts.map((draft) => draft.slot))
            ..drafts.replace(drafts),
        ),
    ),
  );
}

const _requestIdOne = '11111111-1111-4111-8111-111111111111';
const _requestIdTwo = '22222222-2222-4222-8222-222222222222';

Response<DraftsCreate201Response> _createResponse(DraftResponseDto draft) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/drafts'),
    data: DraftsCreate201Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(draft),
    ),
  );
}

Response<DraftsFindById200Response> _findByIdResponse(DraftResponseDto draft) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/drafts/${draft.id}'),
    data: DraftsFindById200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(draft),
    ),
  );
}

Response<DraftsUpdate200Response> _updateResponse(DraftResponseDto draft) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/drafts/${draft.id}'),
    data: DraftsUpdate200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(draft),
    ),
  );
}

Response<DraftsRemove200Response> _removeResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/drafts/draft-2'),
    data: DraftsRemove200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '草稿已删除'),
    ),
  );
}
