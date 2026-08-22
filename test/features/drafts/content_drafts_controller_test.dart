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

  test('正文草稿的新建路径覆盖 0、20、21 个骰子边界', () async {
    final repository = _FakeRepository(drafts: []);
    final controller = ContentDraftsController(repository, autoStart: false);
    addTearDown(controller.dispose);
    await controller.load();

    expect(await controller.saveToNextSlot(''), isFalse);
    expect(controller.state.actionFailure?.userMessage, '当前正文为空，先写一点内容再保存。');
    expect(repository.createSlots, isEmpty);

    expect(await controller.saveToNextSlot(_diceMarkdown(20)), isTrue);
    expect(repository.createdContents.single, _diceMarkdown(20));

    expect(await controller.saveToNextSlot(_diceMarkdown(21)), isFalse);
    expect(
      controller.state.actionFailure?.userMessage,
      '当前正文最多可插入 20 个骰子，请删除一个后再保存。',
    );
    expect(repository.createSlots, hasLength(1));
  });

  test('草稿覆盖路径允许纯骰子和 20 个边界，第 21 个不请求仓储', () async {
    final repository = _FakeRepository(drafts: [_draft(slot: 1)]);
    final controller = ContentDraftsController(repository, autoStart: false);
    addTearDown(controller.dispose);
    await controller.load();

    var current = controller.state.draftAt(1)!;
    expect(await controller.overwrite(current, _diceMarkdown(1)), isTrue);
    expect(repository.updatedContents.single, _diceMarkdown(1));

    current = controller.state.draftAt(1)!;
    expect(await controller.overwrite(current, _diceMarkdown(20)), isTrue);
    expect(repository.updatedContents.last, _diceMarkdown(20));

    current = controller.state.draftAt(1)!;
    expect(await controller.overwrite(current, _diceMarkdown(21)), isFalse);
    expect(
      controller.state.actionFailure?.userMessage,
      '当前正文最多可插入 20 个骰子，请删除一个后再保存。',
    );
    expect(repository.updateVersions, hasLength(2));
  });

  test('两份独立草稿可各自保存 20 个骰子，不跨槽位聚合', () async {
    final repository = _FakeRepository(drafts: []);
    final controller = ContentDraftsController(repository, autoStart: false);
    addTearDown(controller.dispose);
    await controller.load();

    expect(
      await controller.createAtSlot(_diceMarkdown(20, namespace: 0), 1),
      isTrue,
    );
    expect(
      await controller.createAtSlot(_diceMarkdown(20, namespace: 1), 2),
      isTrue,
    );
    expect(repository.createSlots, [1, 2]);
    expect(repository.createdContents, hasLength(2));
  });

  test('代码、行内代码、转义和非法协议中的伪骰子不占用草稿上限', () async {
    final repository = _FakeRepository(drafts: []);
    final controller = ContentDraftsController(repository, autoStart: false);
    addTearDown(controller.dispose);
    await controller.load();
    final content =
        '${_ignoredDiceMarkdown()}\n${_diceMarkdown(20, namespace: 5)}';

    expect(await controller.saveToNextSlot(content), isTrue);
    expect(repository.createdContents.single, content);
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

String _diceMarkdown(int count, {int namespace = 0}) =>
    List.generate(count, (index) {
      final suffix = (namespace * 100 + index).toString().padLeft(12, '0');
      return '[[dice:v1:00000000-0000-4000-8000-$suffix:1d6]]';
    }).join(' ');

String _ignoredDiceMarkdown() {
  return [
    '草稿文字',
    '~~~text',
    _diceMarkdown(21),
    '~~~',
    '`${_diceMarkdown(1)}`',
    r'\[[dice:v1:00000000-0000-4000-8000-000000000099:1d6]]',
    '[[dice:v1:not-a-uuid:1d6]]',
    '[[dice:v1:00000000-0000-4000-8000-000000000098:101d6]]',
  ].join('\n');
}

class _FakeRepository implements ContentDraftRepository {
  _FakeRepository({
    required List<ContentDraft> drafts,
    this.conflictOnce = false,
  }) : _drafts = [...drafts];

  final List<ContentDraft> _drafts;
  final bool conflictOnce;
  final List<int?> createSlots = [];
  final List<String> createdContents = [];
  final List<int> updateVersions = [];
  final List<String> updatedContents = [];
  final List<String> removedIds = [];
  var _didConflict = false;

  @override
  Future<ContentDraft> create(String content, {int? slot}) async {
    createSlots.add(slot);
    createdContents.add(content);
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
    updatedContents.add(content);
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
