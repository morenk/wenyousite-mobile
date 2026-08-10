import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/application/subthread_management_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/subthread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';

void main() {
  test('创建失败重试复用幂等键，表单变化后换新键', () async {
    final repository = _FakeRepository(
      bootstrap: _bootstrap(),
      createFailureOnce: const ApiFailure(userMessage: '创建结果不明确'),
    );
    var id = 0;
    final controller = SubthreadManagementController(
      'thread-1',
      repository,
      createRequestId: () => 'request-${++id}',
    );
    addTearDown(controller.dispose);
    await _settle();
    const draft = SubthreadManagementDraft(
      title: '玩家区',
      postingPolicy: SubthreadPostingPolicy.players,
    );

    expect(await controller.create(draft), isFalse);
    expect(await controller.create(draft), isTrue);
    expect(repository.createRequestIds, ['request-1', 'request-1']);

    expect(
      await controller.create(
        const SubthreadManagementDraft(
          title: '幕后区',
          postingPolicy: SubthreadPostingPolicy.collaborators,
        ),
      ),
      isTrue,
    );
    expect(repository.createRequestIds.last, 'request-2');
  });

  test('幂等键冲突后同一表单生成新键', () async {
    final repository = _FakeRepository(
      bootstrap: _bootstrap(),
      createFailureOnce: const ApiFailure(
        userMessage: '幂等键已用于其他请求',
        businessCode: 40912,
      ),
    );
    var id = 0;
    final controller = SubthreadManagementController(
      'thread-1',
      repository,
      createRequestId: () => 'request-${++id}',
    );
    addTearDown(controller.dispose);
    await _settle();
    const draft = SubthreadManagementDraft(
      title: '玩家区',
      postingPolicy: SubthreadPostingPolicy.players,
    );

    expect(await controller.create(draft), isFalse);
    expect(await controller.create(draft), isTrue);
    expect(repository.createRequestIds, ['request-1', 'request-2']);
  });

  test('编辑前读取单条详情并用详情版本更新目标', () async {
    final repository = _FakeRepository(bootstrap: _bootstrap());
    final controller = SubthreadManagementController('thread-1', repository);
    addTearDown(controller.dispose);
    await _settle();
    final item = controller.state.bootstrap!.items.last;

    final latest = await controller.prepareEdit(item);
    expect(latest?.version, 4);
    expect(repository.findCalls, 1);
    expect(
      await controller.update(
        latest!,
        const SubthreadManagementDraft(
          title: '新剧情区',
          postingPolicy: SubthreadPostingPolicy.collaborators,
        ),
      ),
      isTrue,
    );
    expect(repository.updatedVersions, [4]);
    expect(controller.state.bootstrap!.items.last.title, '新剧情区');
    expect(controller.state.bootstrap!.items.last.version, 5);
  });

  test('409 更新冲突重读列表并保留冲突提示', () async {
    final latest = _bootstrap(
      items: [
        _defaultItem,
        _secondary.copyWith(title: '云端标题', version: 8),
      ],
    );
    final repository = _FakeRepository(
      bootstrap: _bootstrap(),
      reloadBootstrap: latest,
      updateFailure: const ApiFailure(
        userMessage: '子贴已被修改，请刷新后重试',
        httpStatus: 409,
        businessCode: 40002,
      ),
    );
    final controller = SubthreadManagementController('thread-1', repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(
      await controller.update(
        _secondary,
        const SubthreadManagementDraft(
          title: '本机标题',
          postingPolicy: SubthreadPostingPolicy.participants,
        ),
      ),
      isFalse,
    );
    expect(controller.state.bootstrap!.items.last.title, '云端标题');
    expect(controller.state.failure?.businessCode, 40002);
    expect(repository.loadCalls, 2);
  });

  test('默认子贴不能编辑删除或下移，非默认子贴删除后原地移除', () async {
    final repository = _FakeRepository(bootstrap: _bootstrap());
    final controller = SubthreadManagementController('thread-1', repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.prepareEdit(_defaultItem), isNull);
    expect(await controller.remove(_defaultItem), isFalse);
    expect(await controller.move(_defaultItem.id, 1), isFalse);
    expect(repository.removeCalls, 0);

    expect(await controller.remove(_secondary), isTrue);
    expect(controller.state.bootstrap!.items.map((item) => item.id), [
      'sub-default',
    ]);
  });

  test('上下移动提交完整集合，失败时保留原列表', () async {
    final third = _secondary.copyWith(title: '闲聊区', sortOrder: 2);
    final thirdWithId = SubthreadManagementItem(
      id: 'sub-third',
      threadId: third.threadId,
      title: third.title,
      sortOrder: third.sortOrder,
      postingPolicy: third.postingPolicy,
      version: third.version,
      postCount: third.postCount,
      isDefault: false,
    );
    final repository = _FakeRepository(
      bootstrap: _bootstrap(items: [_defaultItem, _secondary, thirdWithId]),
    );
    final controller = SubthreadManagementController('thread-1', repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.move('sub-third', -1), isTrue);
    expect(repository.reorderIds.single, [
      'sub-default',
      'sub-third',
      'sub-second',
    ]);
    expect(controller.state.bootstrap!.items[1].id, 'sub-third');

    repository.reorderFailure = const ApiFailure(userMessage: '排序失败');
    final before = controller.state.bootstrap!.items
        .map((item) => item.id)
        .toList();
    expect(await controller.move('sub-third', 1), isFalse);
    expect(controller.state.bootstrap!.items.map((item) => item.id), before);
  });

  test('连续刷新只采用最后一次结果', () async {
    final first = Completer<SubthreadManagementBootstrap>();
    final second = Completer<SubthreadManagementBootstrap>();
    final controller = SubthreadManagementController(
      'thread-1',
      _QueuedLoadRepository([first.future, second.future]),
    );
    addTearDown(controller.dispose);
    await _settle();

    final refresh = controller.load();
    second.complete(_bootstrap(threadTitle: '最新目录'));
    await refresh;
    first.complete(_bootstrap(threadTitle: '过期目录'));
    await _settle();

    expect(controller.state.bootstrap?.threadTitle, '最新目录');
  });
}

Future<void> _settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _FakeRepository implements SubthreadManagementRepository {
  _FakeRepository({
    required this.bootstrap,
    this.reloadBootstrap,
    this.createFailureOnce,
    this.updateFailure,
  });

  SubthreadManagementBootstrap bootstrap;
  final SubthreadManagementBootstrap? reloadBootstrap;
  ApiFailure? createFailureOnce;
  final ApiFailure? updateFailure;
  ApiFailure? reorderFailure;
  int loadCalls = 0;
  int findCalls = 0;
  int removeCalls = 0;
  final List<String> createRequestIds = [];
  final List<int> updatedVersions = [];
  final List<List<String>> reorderIds = [];

  @override
  Future<SubthreadManagementBootstrap> load(String threadId) async {
    loadCalls += 1;
    if (loadCalls > 1 && reloadBootstrap != null) return reloadBootstrap!;
    return bootstrap;
  }

  @override
  Future<SubthreadManagementItem> findById({
    required String threadId,
    required String subthreadId,
    required bool isDefault,
  }) async {
    findCalls += 1;
    return bootstrap.items
        .firstWhere((item) => item.id == subthreadId)
        .copyWith(version: 4);
  }

  @override
  Future<SubthreadManagementItem> create({
    required String threadId,
    required SubthreadManagementDraft draft,
    required String clientRequestId,
  }) async {
    createRequestIds.add(clientRequestId);
    final failure = createFailureOnce;
    createFailureOnce = null;
    if (failure != null) throw failure;
    return SubthreadManagementItem(
      id: 'created-${createRequestIds.length}',
      threadId: threadId,
      title: draft.normalizedTitle,
      sortOrder: bootstrap.items.length + createRequestIds.length,
      postingPolicy: draft.postingPolicy,
      version: 1,
      postCount: 0,
      isDefault: false,
    );
  }

  @override
  Future<SubthreadManagementItem> update({
    required SubthreadManagementItem current,
    required SubthreadManagementDraft draft,
  }) async {
    if (updateFailure != null) throw updateFailure!;
    updatedVersions.add(current.version);
    return current.copyWith(
      title: draft.normalizedTitle,
      postingPolicy: draft.postingPolicy,
      version: current.version + 1,
    );
  }

  @override
  Future<void> remove(SubthreadManagementItem item) async {
    removeCalls += 1;
  }

  @override
  Future<List<SubthreadManagementItem>> reorder({
    required String threadId,
    required List<SubthreadManagementItem> items,
  }) async {
    reorderIds.add(items.map((item) => item.id).toList());
    if (reorderFailure != null) throw reorderFailure!;
    return [
      for (var index = 0; index < items.length; index++)
        items[index].copyWith(sortOrder: index),
    ];
  }
}

class _QueuedLoadRepository implements SubthreadManagementRepository {
  _QueuedLoadRepository(this.loads);

  final List<Future<SubthreadManagementBootstrap>> loads;
  var index = 0;

  @override
  Future<SubthreadManagementBootstrap> load(String threadId) {
    return loads[index++];
  }

  @override
  Future<SubthreadManagementItem> create({
    required String threadId,
    required SubthreadManagementDraft draft,
    required String clientRequestId,
  }) => throw UnimplementedError();

  @override
  Future<SubthreadManagementItem> findById({
    required String threadId,
    required String subthreadId,
    required bool isDefault,
  }) => throw UnimplementedError();

  @override
  Future<void> remove(SubthreadManagementItem item) =>
      throw UnimplementedError();

  @override
  Future<List<SubthreadManagementItem>> reorder({
    required String threadId,
    required List<SubthreadManagementItem> items,
  }) => throw UnimplementedError();

  @override
  Future<SubthreadManagementItem> update({
    required SubthreadManagementItem current,
    required SubthreadManagementDraft draft,
  }) => throw UnimplementedError();
}

SubthreadManagementBootstrap _bootstrap({
  String threadTitle = '星海旅团',
  List<SubthreadManagementItem>? items,
}) {
  return SubthreadManagementBootstrap(
    threadId: 'thread-1',
    threadTitle: threadTitle,
    items: items ?? [_defaultItem, _secondary],
  );
}

const _defaultItem = SubthreadManagementItem(
  id: 'sub-default',
  threadId: 'thread-1',
  title: '主贴',
  sortOrder: 0,
  postingPolicy: SubthreadPostingPolicy.participants,
  version: 2,
  postCount: 1,
  isDefault: true,
);

const _secondary = SubthreadManagementItem(
  id: 'sub-second',
  threadId: 'thread-1',
  title: '剧情区',
  sortOrder: 1,
  postingPolicy: SubthreadPostingPolicy.participants,
  version: 3,
  postCount: 2,
  isDefault: false,
);
