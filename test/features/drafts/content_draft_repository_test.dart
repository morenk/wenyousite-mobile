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

  test('列表与槽位并发读取并映射为按槽位排序的领域模型', () async {
    final api = _MockDraftsApi();
    when(() => api.draftsFindAll()).thenAnswer(
      (_) async => _findAllResponse([
        _draftDto(slot: 3, id: 'draft-3'),
        _draftDto(slot: 1, id: 'draft-1'),
      ]),
    );
    when(
      () => api.draftsSlotUsage(),
    ).thenAnswer((_) async => _slotUsageResponse([1, 3]));

    final result = await ApiContentDraftRepository(api).fetchCollection();

    expect(result.drafts.map((draft) => draft.id), ['draft-1', 'draft-3']);
    expect(result.usage.usedSlots, 2);
    expect(result.usage.maxSlots, 5);
    expect(result.usage.occupiedSlots, {1, 3});
    verify(() => api.draftsFindAll()).called(1);
    verify(() => api.draftsSlotUsage()).called(1);
  });

  test('创建、单条读取、版本更新和删除使用完整 API 载荷', () async {
    final api = _MockDraftsApi();
    when(
      () => api.draftsCreate(createDraftDto: any(named: 'createDraftDto')),
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
      () => api.draftsRemove(id: 'draft-2'),
    ).thenAnswer((_) async => _removeResponse());
    final repository = ApiContentDraftRepository(api);

    await repository.create('自动正文');
    final created = await repository.create('当前正文', slot: 2);
    final fetched = await repository.fetchById('draft-2');
    final updated = await repository.update(
      id: 'draft-2',
      content: '新版正文',
      version: 3,
    );
    await repository.remove('draft-2');

    final createPayloads = verify(
      () =>
          api.draftsCreate(createDraftDto: captureAny(named: 'createDraftDto')),
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
    expect(createPayloads.first.slot, isNull);
    expect(createPayloads.last.content, '当前正文');
    expect(createPayloads.last.slot, 2);
    expect(createPayloads.last.version, isNull);
    expect(updatePayload.content, '新版正文');
    expect(updatePayload.version, 3);
    verify(() => api.draftsRemove(id: 'draft-2')).called(1);
  });

  test('空成功响应不会伪装成保存成功', () async {
    final api = _MockDraftsApi();
    when(
      () => api.draftsCreate(createDraftDto: any(named: 'createDraftDto')),
    ).thenAnswer(
      (_) async => Response<DraftsCreate201Response>(
        requestOptions: RequestOptions(path: '/api/v1/drafts'),
      ),
    );

    await expectLater(
      ApiContentDraftRepository(api).create('当前正文'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('重新加载确认'),
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

Response<DraftsFindAll200Response> _findAllResponse(
  List<DraftResponseDto> drafts,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/drafts'),
    data: DraftsFindAll200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(drafts),
    ),
  );
}

Response<DraftsSlotUsage200Response> _slotUsageResponse(List<int> slots) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/drafts/slots'),
    data: DraftsSlotUsage200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (usage) => usage
            ..usedSlots = slots.length
            ..maxSlots = 5
            ..slots.replace(slots),
        ),
    ),
  );
}

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
