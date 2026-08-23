import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/drafts/domain/content_draft_models.dart';

abstract interface class ContentDraftRepository {
  Future<ContentDraftCollection> fetchCollection();

  Future<ContentDraft> fetchById(String id);

  Future<ContentDraft> create(
    String content, {
    int? slot,
    required String clientRequestId,
  });

  Future<ContentDraft> update({
    required String id,
    required String content,
    required int version,
  });

  Future<void> remove(String id, {required int version});
}

final contentDraftRepositoryProvider = Provider<ContentDraftRepository>((ref) {
  return const _UnboundContentDraftRepository();
});

class _UnboundContentDraftRepository implements ContentDraftRepository {
  const _UnboundContentDraftRepository();

  @override
  Future<ContentDraftCollection> fetchCollection() => Future.error(_error());

  @override
  Future<ContentDraft> fetchById(String id) => Future.error(_error());

  @override
  Future<ContentDraft> create(
    String content, {
    int? slot,
    required String clientRequestId,
  }) {
    return Future.error(_error());
  }

  @override
  Future<ContentDraft> update({
    required String id,
    required String content,
    required int version,
  }) {
    return Future.error(_error());
  }

  @override
  Future<void> remove(String id, {required int version}) =>
      Future.error(_error());
}

StateError _error() => StateError('正文草稿仓储尚未在应用组合根绑定。');
