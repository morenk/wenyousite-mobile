import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_management_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';

void main() {
  test('409 后读取最新版、保留本机修改并用新 version 显式覆盖', () async {
    final repository = _FakeRepository(
      initial: _bootstrap(version: 3),
      latest: _bootstrap(version: 4),
      conflictOnce: true,
    );
    final controller = ThreadManagementController('thread-1', repository);
    addTearDown(controller.dispose);
    await _settle();

    const pending = ThreadManagementDraft(
      title: '本机标题',
      categorySlug: 'RPG',
      status: ThreadManagementStatus.closed,
      visibility: ThreadManagementVisibility.public,
    );
    expect(await controller.save(pending), isFalse);
    expect(controller.state.conflict?.pending.title, '本机标题');
    expect(controller.state.conflict?.latest.thread.version, 4);
    expect(controller.state.bootstrap?.thread.version, 3);

    expect(await controller.overwriteConflict(), isTrue);
    expect(repository.updateVersions, [3, 4]);
    expect(controller.state.bootstrap?.thread.title, '本机标题');
    expect(controller.state.failure, isNull);
  });

  test('采用云端最新版会丢弃待覆盖内容并清除冲突', () async {
    final repository = _FakeRepository(
      initial: _bootstrap(version: 3),
      latest: _bootstrap(version: 9, title: '云端标题'),
      conflictOnce: true,
    );
    final controller = ThreadManagementController('thread-1', repository);
    addTearDown(controller.dispose);
    await _settle();

    await controller.save(
      const ThreadManagementDraft(
        title: '本机标题',
        categorySlug: 'RPG',
        status: ThreadManagementStatus.recruiting,
        visibility: ThreadManagementVisibility.public,
      ),
    );
    controller.adoptLatest();

    expect(controller.state.bootstrap?.thread.version, 9);
    expect(controller.state.bootstrap?.thread.title, '云端标题');
    expect(controller.state.conflict, isNull);
    expect(controller.state.failure, isNull);
  });

  test('非楼主不会发起删除请求', () async {
    final repository = _FakeRepository(
      initial: _bootstrap(version: 1, isOwner: false),
    );
    final controller = ThreadManagementController('thread-1', repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.remove(), isFalse);
    expect(repository.removeCalls, 0);
  });

  test('删除失败恢复按钮状态并保留请求 ID', () async {
    final repository = _FakeRepository(
      initial: _bootstrap(version: 1),
      removeFailure: const ApiFailure(
        userMessage: '删除失败',
        requestId: 'remove-request-id',
      ),
    );
    final controller = ThreadManagementController('thread-1', repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.remove(), isFalse);
    expect(controller.state.isDeleting, isFalse);
    expect(controller.state.failure?.requestId, 'remove-request-id');
  });
}

Future<void> _settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _FakeRepository implements ThreadManagementRepository {
  _FakeRepository({
    required this.initial,
    ThreadManagementBootstrap? latest,
    this.conflictOnce = false,
    this.removeFailure,
  }) : latest = latest ?? initial;

  final ThreadManagementBootstrap initial;
  final ThreadManagementBootstrap latest;
  final bool conflictOnce;
  final ApiFailure? removeFailure;
  int loadCalls = 0;
  int removeCalls = 0;
  bool _didConflict = false;
  final List<int> updateVersions = [];

  @override
  Future<ThreadManagementBootstrap> load(String threadId) async {
    loadCalls += 1;
    return loadCalls == 1 ? initial : latest;
  }

  @override
  Future<void> remove(String threadId) async {
    removeCalls += 1;
    if (removeFailure != null) throw removeFailure!;
  }

  @override
  Future<ThreadManagementSnapshot> update({
    required ThreadManagementSnapshot current,
    required ThreadManagementDraft draft,
  }) async {
    updateVersions.add(current.version);
    if (conflictOnce && !_didConflict) {
      _didConflict = true;
      throw const ApiFailure(
        userMessage: '内容已在其他位置修改',
        httpStatus: 409,
        businessCode: 40002,
      );
    }
    return ThreadManagementSnapshot(
      id: current.id,
      title: draft.title,
      categorySlug: draft.categorySlug,
      status: draft.status,
      visibility: draft.visibility,
      version: current.version + 1,
      published: current.published,
      canManage: current.canManage,
      isOwner: current.isOwner,
    );
  }
}

ThreadManagementBootstrap _bootstrap({
  required int version,
  String title = '原主题',
  bool isOwner = true,
}) {
  return ThreadManagementBootstrap(
    thread: ThreadManagementSnapshot(
      id: 'thread-1',
      title: title,
      categorySlug: 'RPG',
      status: ThreadManagementStatus.recruiting,
      visibility: ThreadManagementVisibility.public,
      version: version,
      published: true,
      canManage: true,
      isOwner: isOwner,
    ),
    categories: const [
      ThreadManagementCategory(slug: 'RPG', name: '角色扮演', sortOrder: 1),
    ],
  );
}
