import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/application/remote_thread_drafts_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_compose_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';

void main() {
  test('云端草稿箱加载并仅在删除确认后移除权威记录', () async {
    final repository = _FakeRepository(drafts: [_summary('draft-one')]);
    final controller = RemoteThreadDraftsController(
      repository,
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.load();
    expect(controller.state.phase, RemoteThreadDraftsPhase.ready);
    expect(controller.state.drafts.single.id, 'draft-one');

    expect(await controller.remove(controller.state.drafts.single), isTrue);
    expect(repository.removedIds, ['draft-one']);
    expect(controller.state.drafts, isEmpty);
  });

  test('草稿删除失败保留原列表、稳定错误与请求 ID', () async {
    final repository = _FakeRepository(
      drafts: [_summary('draft-one')],
      removeFailure: const ApiFailure(
        userMessage: '删除失败',
        requestId: 'request-one',
      ),
    );
    final controller = RemoteThreadDraftsController(
      repository,
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.load();

    expect(await controller.remove(controller.state.drafts.single), isFalse);
    expect(controller.state.drafts.single.id, 'draft-one');
    expect(controller.state.removeFailure?.requestId, 'request-one');
  });
}

ThreadRemoteDraftSummary _summary(String id) {
  return ThreadRemoteDraftSummary(
    id: id,
    title: '草稿 $id',
    categorySlug: 'TRPG',
    visibility: ThreadComposeVisibility.public,
    tags: const ['跑团'],
    createdAt: DateTime.utc(2026, 8, 9),
    updatedAt: DateTime.utc(2026, 8, 10),
    subthreadCount: 1,
    postCount: 2,
  );
}

class _FakeRepository implements ThreadComposeRepository {
  _FakeRepository({required this.drafts, this.removeFailure});

  final List<ThreadRemoteDraftSummary> drafts;
  final ApiFailure? removeFailure;
  final List<String> removedIds = [];

  @override
  Future<List<ThreadRemoteDraftSummary>> fetchDrafts() async => drafts;

  @override
  Future<void> removeDraft(String id) async {
    final failure = removeFailure;
    if (failure != null) throw failure;
    removedIds.add(id);
  }

  @override
  Future<ThreadComposeBootstrap> fetchBootstrap() => throw UnimplementedError();

  @override
  Future<ThreadRemoteDraft> fetchDraft({
    required String id,
    required String ownerId,
  }) => throw UnimplementedError();

  @override
  Future<ThreadRemoteDraft> createDraft(ThreadCreatePayload payload) =>
      throw UnimplementedError();

  @override
  Future<ThreadRemoteDraft> saveAggregate({
    required ThreadRemoteDraft remoteDraft,
    required String title,
    required String? categorySlug,
    required ThreadComposeVisibility visibility,
    required List<String> tags,
    required String body,
    required bool publish,
  }) => throw UnimplementedError();
}
