import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/drafts/application/content_drafts_controller.dart';
import 'package:wenyousite_mobile/features/drafts/data/content_draft_repository.dart';
import 'package:wenyousite_mobile/features/drafts/domain/content_draft_models.dart';

void main() {
  test('加载、指定空槽创建和版本更新同步本地槽位状态', () async {
    final repository = _FakeRepository(drafts: [_draft(slot: 1)]);
    final controller = ContentDraftsController(repository, autoStart: false);
    addTearDown(controller.dispose);

    await controller.load();
    expect(controller.state.usage.usedSlots, 1);

    expect(await controller.createAtSlot('第二条正文', 2), isTrue);
    expect(repository.createSlots, [2]);
    expect(controller.state.draftAt(2)?.content, '第二条正文');

    final first = controller.state.draftAt(1)!;
    expect(await controller.overwrite(first, '覆盖正文'), isTrue);
    expect(repository.updateVersions, [first.version]);
    expect(controller.state.draftAt(1)?.content, '覆盖正文');
    expect(controller.state.draftAt(1)?.version, first.version + 1);
  });

  test('五槽已满时阻止自动保存且不发送创建请求', () async {
    final repository = _FakeRepository(
      drafts: [for (var slot = 1; slot <= 5; slot++) _draft(slot: slot)],
    );
    final controller = ContentDraftsController(repository, autoStart: false);
    addTearDown(controller.dispose);
    await controller.load();

    expect(await controller.saveToNextSlot('不会发送'), isFalse);
    expect(repository.createSlots, isEmpty);
    expect(controller.state.actionFailure?.userMessage, contains('5 个'));
  });

  test('版本冲突读取最新版并保留待覆盖正文，用户确认后才重试', () async {
    final repository = _FakeRepository(
      drafts: [_draft(slot: 1)],
      conflictOnce: true,
    );
    final controller = ContentDraftsController(repository, autoStart: false);
    addTearDown(controller.dispose);
    await controller.load();

    expect(
      await controller.overwrite(controller.state.drafts.single, '本机待保存正文'),
      isFalse,
    );
    expect(controller.state.conflict?.pendingContent, '本机待保存正文');
    expect(controller.state.conflict?.latest.version, 9);
    expect(repository.updateVersions, [3]);

    expect(await controller.retryConflict(), isTrue);
    expect(repository.updateVersions, [3, 9]);
    expect(controller.state.drafts.single.content, '本机待保存正文');
  });

  test('恢复前读取单条最新版，删除后仅移除目标槽位', () async {
    final repository = _FakeRepository(
      drafts: [_draft(slot: 1), _draft(slot: 3)],
    );
    final controller = ContentDraftsController(repository, autoStart: false);
    addTearDown(controller.dispose);
    await controller.load();

    final fresh = await controller.fetchFreshForRestore('draft-1');
    expect(fresh?.content, '云端最新版');

    expect(await controller.remove(controller.state.draftAt(3)!), isTrue);
    expect(repository.removedIds, ['draft-3']);
    expect(controller.state.drafts.map((draft) => draft.slot), [1]);
  });
}

class _FakeRepository implements ContentDraftRepository {
  _FakeRepository({
    required List<ContentDraft> drafts,
    this.conflictOnce = false,
  }) : _drafts = [...drafts];

  final List<ContentDraft> _drafts;
  final bool conflictOnce;
  final List<int?> createSlots = [];
  final List<int> updateVersions = [];
  final List<String> removedIds = [];
  var _didConflict = false;

  @override
  Future<ContentDraft> create(String content, {int? slot}) async {
    createSlots.add(slot);
    final selected =
        slot ??
        [1, 2, 3, 4, 5].firstWhere(
          (candidate) => !_drafts.any((draft) => draft.slot == candidate),
        );
    final draft = _draft(slot: selected, content: content, version: 1);
    _drafts.add(draft);
    return draft;
  }

  @override
  Future<ContentDraftCollection> fetchCollection() async {
    return ContentDraftCollection(
      drafts: [..._drafts],
      usage: ContentDraftSlotUsage(
        usedSlots: _drafts.length,
        maxSlots: 5,
        occupiedSlots: _drafts.map((draft) => draft.slot).toSet(),
      ),
    );
  }

  @override
  Future<ContentDraft> fetchById(String id) async {
    final current = _drafts.singleWhere((draft) => draft.id == id);
    final fresh = ContentDraft(
      id: current.id,
      userId: current.userId,
      slot: current.slot,
      content: '云端最新版',
      version: conflictOnce ? 9 : current.version,
      createdAt: current.createdAt,
      updatedAt: current.updatedAt.add(const Duration(minutes: 1)),
    );
    _replace(fresh);
    return fresh;
  }

  @override
  Future<void> remove(String id) async {
    removedIds.add(id);
    _drafts.removeWhere((draft) => draft.id == id);
  }

  @override
  Future<ContentDraft> update({
    required String id,
    required String content,
    required int version,
  }) async {
    updateVersions.add(version);
    if (conflictOnce && !_didConflict) {
      _didConflict = true;
      throw const ApiFailure(
        userMessage: '草稿已在其他位置修改，请刷新后重试',
        httpStatus: 409,
        businessCode: 40002,
      );
    }
    final current = _drafts.singleWhere((draft) => draft.id == id);
    final saved = ContentDraft(
      id: current.id,
      userId: current.userId,
      slot: current.slot,
      content: content,
      version: version + 1,
      createdAt: current.createdAt,
      updatedAt: current.updatedAt.add(const Duration(minutes: 1)),
    );
    _replace(saved);
    return saved;
  }

  void _replace(ContentDraft draft) {
    _drafts
      ..removeWhere((item) => item.id == draft.id)
      ..add(draft);
  }
}

ContentDraft _draft({
  required int slot,
  String content = '旧正文',
  int version = 3,
}) {
  return ContentDraft(
    id: 'draft-$slot',
    userId: 'user-one',
    slot: slot,
    content: content,
    version: version,
    createdAt: DateTime.utc(2026, 8, 9),
    updatedAt: DateTime.utc(2026, 8, 10),
  );
}
