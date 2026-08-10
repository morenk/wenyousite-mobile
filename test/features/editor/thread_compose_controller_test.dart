import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/editor/application/thread_compose_controller.dart';
import 'package:wenyousite_mobile/features/editor/data/editor_snapshot_store.dart';
import 'package:wenyousite_mobile/features/editor/data/thread_compose_repository.dart';
import 'package:wenyousite_mobile/features/editor/domain/thread_compose_models.dart';

void main() {
  test('按 JWT 用户隔离恢复本地快照并异步补齐分类与邮箱状态', () async {
    final store = _MemorySnapshotStore();
    store.snapshot = LocalEditorSnapshot(
      id: DatabaseEditorSnapshotStore.threadSnapshotId('user-one'),
      contextType: EditorContextType.thread,
      body: '恢复正文',
      metadataJson: const ThreadSnapshotMetadata(
        ownerId: 'user-one',
        title: '恢复标题',
        categorySlug: 'TRPG',
        visibility: ThreadComposeVisibility.public,
        tags: ['跑团'],
      ).toJson(),
      clientRequestId: _requestId,
      updatedAt: DateTime.utc(2026, 8, 10),
    );
    final controller = ThreadComposeController(
      _FakeRepository(),
      store,
      knownOwnerId: 'user-one',
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.load();
    await _waitUntil(() => !controller.state.bootstrapLoading);

    expect(controller.state.phase, ThreadComposePhase.ready);
    expect(controller.state.restoredFromLocal, isTrue);
    expect(controller.state.title, '恢复标题');
    expect(controller.state.body, '恢复正文');
    expect(controller.state.categories.single.slug, 'TRPG');
    expect(controller.state.emailVerified, isTrue);
  });

  test('字段变化防抖写完整 Markdown 快照且不会保存 Delta', () async {
    final store = _MemorySnapshotStore();
    final controller = ThreadComposeController(
      _FakeRepository(),
      store,
      knownOwnerId: 'user-one',
      createRequestId: () => _requestId,
      snapshotDebounce: const Duration(milliseconds: 5),
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.load();

    controller.updateTitle('新标题');
    controller.updateBody('**完整 Markdown**');
    await _waitUntil(
      () => controller.state.localSnapshotStatus == LocalSnapshotStatus.saved,
    );

    expect(store.snapshot?.body, '**完整 Markdown**');
    expect(store.snapshot?.clientRequestId, _requestId);
    expect(
      ThreadSnapshotMetadata.fromJson(store.snapshot!.metadataJson)?.title,
      '新标题',
    );
  });

  test('首次发布严格执行待确认记录、创建草稿、聚合发布与本地清理', () async {
    final store = _MemorySnapshotStore();
    final repository = _FakeRepository();
    final controller = ThreadComposeController(
      repository,
      store,
      knownOwnerId: 'user-one',
      createRequestId: () => _requestId,
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.load();
    await _waitUntil(() => !controller.state.bootstrapLoading);
    _fillPublishable(controller);

    final threadId = await controller.publish();

    expect(threadId, 'thread-one');
    expect(repository.createPayloads.single.clientRequestId, _requestId);
    expect(repository.aggregateCalls.single.publish, isTrue);
    expect(store.savedPendingStates, [PendingOperationState.sending]);
    expect(store.pending, isNull);
    expect(store.snapshot, isNull);
    expect(controller.state.phase, ThreadComposePhase.published);
  });

  test('创建响应不确定时保留原载荷，编辑后先用原幂等键确认再聚合当前内容', () async {
    final store = _MemorySnapshotStore();
    var attempt = 0;
    final repository = _FakeRepository(
      onCreate: (payload) async {
        attempt += 1;
        if (attempt == 1) {
          throw const ApiFailure(userMessage: '连接超时');
        }
        return _remote(body: payload.body, title: payload.title);
      },
    );
    final controller = ThreadComposeController(
      repository,
      store,
      knownOwnerId: 'user-one',
      createRequestId: () => _requestId,
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.load();
    await _waitUntil(() => !controller.state.bootstrapLoading);
    _fillPublishable(controller, body: '第一版正文');

    expect(await controller.publish(), isNull);
    expect(store.pending?.state, PendingOperationState.awaitingConfirmation);
    controller.updateBody('第二版正文');

    expect(await controller.publish(), 'thread-one');
    expect(repository.createPayloads, hasLength(2));
    expect(repository.createPayloads[1].body, '第一版正文');
    expect(repository.createPayloads[1].clientRequestId, _requestId);
    expect(repository.aggregateCalls.single.body, '第二版正文');
  });

  test('发布前验证标题、启用分类、可见正文和邮箱，不发送伪成功请求', () async {
    final repository = _FakeRepository();
    final controller = ThreadComposeController(
      repository,
      _MemorySnapshotStore(),
      knownOwnerId: 'user-one',
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.load();
    await _waitUntil(() => !controller.state.bootstrapLoading);

    expect(await controller.publish(), isNull);
    expect(controller.state.actionFailure?.userMessage, '请填写主题标题。');
    expect(repository.createPayloads, isEmpty);
  });

  test('恢复正文草稿只替换正文并触发本地 Markdown 快照', () async {
    final store = _MemorySnapshotStore();
    final controller = ThreadComposeController(
      _FakeRepository(),
      store,
      knownOwnerId: 'user-one',
      snapshotDebounce: const Duration(milliseconds: 5),
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.load();
    await _waitUntil(() => !controller.state.bootstrapLoading);
    controller
      ..updateTitle('保留标题')
      ..updateCategory('TRPG')
      ..updateTags(const ['保留标签'])
      ..restoreContentDraft('云端\r\n**正文**');

    await _waitUntil(
      () => controller.state.localSnapshotStatus == LocalSnapshotStatus.saved,
    );

    expect(controller.state.title, '保留标题');
    expect(controller.state.categorySlug, 'TRPG');
    expect(controller.state.tags, ['保留标签']);
    expect(controller.state.body, '云端\n**正文**');
    expect(controller.state.documentRevision, greaterThan(1));
    expect(store.snapshot?.body, '云端\n**正文**');
  });

  test('显式打开服务端草稿会先保存本机内容再采用云端完整版本', () async {
    final store = _MemorySnapshotStore();
    final repository = _FakeRepository(
      onFetchDraft: (id, ownerId) async => ThreadRemoteDraft(
        id: id,
        version: 7,
        defaultSubthreadId: 'subthread-cloud',
        defaultSubthreadVersion: 8,
        bodyVersion: 9,
        title: '跨设备草稿',
        categorySlug: 'TRPG',
        visibility: ThreadComposeVisibility.private,
        tags: const ['云端'],
        body: '服务端最新版正文',
      ),
    );
    final controller = ThreadComposeController(
      repository,
      store,
      knownOwnerId: 'user-one',
      createRequestId: () => _requestId,
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.load();
    await _waitUntil(() => !controller.state.bootstrapLoading);
    controller
      ..updateTitle('本机未同步标题')
      ..updateBody('本机未同步正文');

    expect(await controller.openRemoteDraft('thread-cloud'), isTrue);

    expect(repository.fetchDraftCalls, [('thread-cloud', 'user-one')]);
    expect(controller.state.remoteDraft?.id, 'thread-cloud');
    expect(controller.state.title, '跨设备草稿');
    expect(controller.state.body, '服务端最新版正文');
    expect(controller.state.visibility, ThreadComposeVisibility.private);
    expect(controller.state.documentRevision, greaterThan(1));
    expect(store.snapshot?.contextId, 'thread-cloud');
    expect(store.snapshot?.body, '服务端最新版正文');
  });
}

void _fillPublishable(
  ThreadComposeController controller, {
  String body = '主题正文',
}) {
  controller
    ..updateTitle('测试主题')
    ..updateCategory('TRPG')
    ..updateTags(const ['跑团', '奇幻'])
    ..updateBody(body);
}

Future<void> _waitUntil(bool Function() predicate) async {
  for (var i = 0; i < 100 && !predicate(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
  expect(predicate(), isTrue);
}

const _requestId = '550e8400-e29b-41d4-a716-446655440000';

ThreadRemoteDraft _remote({String body = '主题正文', String title = '测试主题'}) {
  return ThreadRemoteDraft(
    id: 'thread-one',
    version: 1,
    defaultSubthreadId: 'subthread-one',
    defaultSubthreadVersion: 1,
    bodyVersion: body.isEmpty ? null : 1,
    title: title,
    categorySlug: 'TRPG',
    visibility: ThreadComposeVisibility.public,
    tags: const ['跑团', '奇幻'],
    body: body,
  );
}

class _AggregateCall {
  const _AggregateCall({required this.body, required this.publish});

  final String body;
  final bool publish;
}

class _FakeRepository implements ThreadComposeRepository {
  _FakeRepository({this.onCreate, this.onFetchDraft});

  final Future<ThreadRemoteDraft> Function(ThreadCreatePayload payload)?
  onCreate;
  final Future<ThreadRemoteDraft> Function(String id, String ownerId)?
  onFetchDraft;
  final List<ThreadCreatePayload> createPayloads = [];
  final List<_AggregateCall> aggregateCalls = [];
  final List<(String, String)> fetchDraftCalls = [];

  @override
  Future<List<ThreadRemoteDraftSummary>> fetchDrafts() async => const [];

  @override
  Future<ThreadRemoteDraft> fetchDraft({
    required String id,
    required String ownerId,
  }) async {
    fetchDraftCalls.add((id, ownerId));
    return onFetchDraft?.call(id, ownerId) ?? _remote();
  }

  @override
  Future<void> removeDraft(String id) async {}

  @override
  Future<ThreadComposeBootstrap> fetchBootstrap() async {
    return const ThreadComposeBootstrap(
      userId: 'user-one',
      emailVerified: true,
      categories: [
        ThreadComposeCategory(slug: 'TRPG', name: '跑团', sortOrder: 1),
      ],
    );
  }

  @override
  Future<ThreadRemoteDraft> createDraft(ThreadCreatePayload payload) async {
    createPayloads.add(payload);
    return onCreate?.call(payload) ??
        _remote(body: payload.body, title: payload.title);
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
  }) async {
    aggregateCalls.add(_AggregateCall(body: body, publish: publish));
    return ThreadRemoteDraft(
      id: remoteDraft.id,
      version: remoteDraft.version + 1,
      defaultSubthreadId: remoteDraft.defaultSubthreadId,
      defaultSubthreadVersion: remoteDraft.defaultSubthreadVersion + 1,
      bodyVersion: (remoteDraft.bodyVersion ?? 0) + 1,
      title: title,
      categorySlug: categorySlug,
      visibility: visibility,
      tags: tags,
      body: body,
    );
  }
}

class _MemorySnapshotStore implements EditorSnapshotStore {
  LocalEditorSnapshot? snapshot;
  PendingCreateOperation? pending;
  final List<PendingOperationState> savedPendingStates = [];

  @override
  Future<void> deletePendingCreate(String clientRequestId) async {
    if (pending?.clientRequestId == clientRequestId) pending = null;
  }

  @override
  Future<void> deleteThreadSnapshot(String ownerId) async {
    snapshot = null;
  }

  @override
  Future<PendingCreateOperation?> findPendingCreate(
    String clientRequestId,
  ) async {
    return pending?.clientRequestId == clientRequestId ? pending : null;
  }

  @override
  Future<LocalEditorSnapshot?> findThreadSnapshot(String ownerId) async {
    return snapshot;
  }

  @override
  Future<void> savePendingCreate(PendingCreateOperation operation) async {
    pending = operation;
    savedPendingStates.add(operation.state);
  }

  @override
  Future<void> saveThreadSnapshot(LocalEditorSnapshot value) async {
    snapshot = value;
  }
}
