import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/drafts/application/content_draft_repository_ports.dart';
import 'package:wenyousite_mobile/features/drafts/domain/content_draft_models.dart';

export 'package:wenyousite_mobile/features/drafts/application/content_draft_repository_ports.dart'
    show ContentDraftRepository, contentDraftRepositoryProvider;

class ApiContentDraftRepository implements ContentDraftRepository {
  ApiContentDraftRepository(this._api);

  final DraftsApi _api;

  @override
  Future<ContentDraftCollection> fetchCollection() async {
    try {
      final results = await Future.wait<Object>([
        _api.draftsFindAll(),
        _api.draftsSlotUsage(),
      ]);
      final draftsResponse = results[0] as Response<DraftsFindAll200Response>;
      final usageResponse = results[1] as Response<DraftsSlotUsage200Response>;
      final drafts = draftsResponse.data?.data;
      final usage = usageResponse.data?.data;
      if (drafts == null || usage == null) {
        throw const ApiFailure(userMessage: '正文草稿加载失败，请稍后重试。');
      }
      final mappedDrafts = drafts.map(_mapDraft).toList(growable: false)
        ..sort((left, right) => left.slot.compareTo(right.slot));
      return ContentDraftCollection(
        drafts: List.unmodifiable(mappedDrafts),
        usage: ContentDraftSlotUsage(
          usedSlots: usage.usedSlots.toInt(),
          maxSlots: usage.maxSlots.toInt(),
          occupiedSlots: usage.slots.map((slot) => slot.toInt()).toSet(),
        ),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<ContentDraft> fetchById(String id) async {
    try {
      final data = (await _api.draftsFindById(id: id)).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '正文草稿加载失败，请重新加载。');
      }
      return _mapDraft(data);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<ContentDraft> create(String content, {int? slot}) async {
    try {
      final payload = CreateDraftDto((builder) {
        builder.content = content;
        if (slot != null) builder.slot = slot;
      });
      final data = (await _api.draftsCreate(
        createDraftDto: payload,
      )).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '正文草稿保存失败，请重试。');
      }
      return _mapDraft(data);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<ContentDraft> update({
    required String id,
    required String content,
    required int version,
  }) async {
    try {
      final payload = UpdateDraftDto(
        (builder) => builder
          ..content = content
          ..version = version,
      );
      final data = (await _api.draftsUpdate(
        id: id,
        updateDraftDto: payload,
      )).data?.data;
      if (data == null) {
        throw const ApiFailure(userMessage: '正文草稿更新失败，请重试。');
      }
      return _mapDraft(data);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<void> remove(String id) async {
    try {
      final data = (await _api.draftsRemove(id: id)).data?.data;
      if (data == null || data.message.trim().isEmpty) {
        throw const ApiFailure(userMessage: '正文草稿删除失败，请重试。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  ContentDraft _mapDraft(DraftResponseDto dto) {
    return ContentDraft(
      id: dto.id,
      userId: dto.userId,
      slot: dto.slot.toInt(),
      content: dto.content,
      version: dto.version.toInt(),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}

final apiContentDraftRepositoryProvider = Provider<ContentDraftRepository>((
  ref,
) {
  return ApiContentDraftRepository(ref.watch(wenyouApiProvider).getDraftsApi());
});
