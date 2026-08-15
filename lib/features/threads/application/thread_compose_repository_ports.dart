import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';

abstract interface class ThreadComposeRepository {
  Future<ThreadComposeBootstrap> fetchBootstrap();

  Future<List<ThreadRemoteDraftSummary>> fetchDrafts();

  Future<ThreadRemoteDraft> fetchDraft({
    required String id,
    required String ownerId,
  });

  Future<void> removeDraft(String id);

  Future<ThreadRemoteDraft> createDraft(ThreadCreatePayload payload);

  Future<ThreadRemoteDraft> saveAggregate({
    required ThreadRemoteDraft remoteDraft,
    required String title,
    required String? categorySlug,
    required ThreadComposeVisibility visibility,
    required List<String> tags,
    required String body,
    required bool publish,
  });
}

final threadComposeRepositoryProvider = Provider<ThreadComposeRepository>((
  ref,
) {
  return const _UnboundThreadComposeRepository();
});

class _UnboundThreadComposeRepository implements ThreadComposeRepository {
  const _UnboundThreadComposeRepository();

  @override
  Future<ThreadComposeBootstrap> fetchBootstrap() => Future.error(_error());

  @override
  Future<List<ThreadRemoteDraftSummary>> fetchDrafts() {
    return Future.error(_error());
  }

  @override
  Future<ThreadRemoteDraft> fetchDraft({
    required String id,
    required String ownerId,
  }) {
    return Future.error(_error());
  }

  @override
  Future<void> removeDraft(String id) => Future.error(_error());

  @override
  Future<ThreadRemoteDraft> createDraft(ThreadCreatePayload payload) {
    return Future.error(_error());
  }

  @override
  Future<ThreadRemoteDraft> saveAggregate({
    required ThreadRemoteDraft remoteDraft,
    required String title,
    required String? categorySlug,
    required ThreadComposeVisibility visibility,
    required List<String> tags,
    required String body,
    required bool publish,
  }) {
    return Future.error(_error());
  }
}

StateError _error() => StateError('主题创作仓储尚未在应用组合根绑定。');
