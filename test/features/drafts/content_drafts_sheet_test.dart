import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/drafts/application/content_drafts_controller.dart';
import 'package:wenyousite_mobile/features/drafts/data/content_draft_repository.dart';
import 'package:wenyousite_mobile/features/drafts/domain/content_draft_models.dart';
import 'package:wenyousite_mobile/features/drafts/presentation/content_drafts_sheet.dart';

void main() {
  testWidgets('360dp 窄屏完整展示用量和五个槽位且无横向溢出', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await _readyController([
      _draft(slot: 1),
      _draft(slot: 3),
    ]);

    await _pumpSheet(tester, controller, currentContent: '当前正文');

    expect(find.text('只保存当前正文 · 已用 2/5'), findsOneWidget);
    expect(find.byKey(const Key('content-draft-slot-1')), findsOneWidget);
    expect(find.byKey(const Key('content-draft-slot-2')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('content-draft-slot-5')));
    expect(find.byKey(const Key('content-draft-slot-5')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('保存到空槽并在面板内立即显示服务端结果', (tester) async {
    final repository = _FakeRepository([_draft(slot: 1)]);
    final controller = ContentDraftsController(repository, autoStart: false);
    await controller.load();
    await _pumpSheet(tester, controller, currentContent: '当前编辑器正文');
    final save = find.byKey(const Key('content-draft-save-2'));
    await tester.ensureVisible(save);

    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(repository.createdSlots, [2]);
    expect(controller.state.draftAt(2)?.content, '当前编辑器正文');
    expect(find.text('正文已保存到槽位 2。'), findsOneWidget);
  });

  testWidgets('槽位 1 已有内容时确认后开启并显示自动保存状态', (tester) async {
    final repository = _FakeRepository([_draft(slot: 1)]);
    final controller = ContentDraftsController(
      repository,
      autoStart: false,
      autoSaveDebounce: Duration.zero,
      requestIdFactory: () => _requestId,
    );
    await controller.load();
    await _pumpSheet(tester, controller, currentContent: '自动保存正文');

    await tester.tap(find.byKey(const Key('content-drafts-auto-save-switch')));
    await tester.pumpAndSettle();
    expect(find.text('开启自动保存？'), findsOneWidget);
    await tester.tap(find.text('开启'));
    await tester.pumpAndSettle();

    expect(repository.updateVersions, [3]);
    expect(controller.state.autoSaveEnabled, isTrue);
    expect(find.text('当前正文已自动保存'), findsOneWidget);
  });

  testWidgets('恢复最新版前明确确认，且回调只返回正文', (tester) async {
    final controller = await _readyController([_draft(slot: 1)]);
    String? restored;
    await _pumpSheet(
      tester,
      controller,
      currentContent: '本机未完成正文',
      onRestore: (content) => restored = content,
    );
    final restore = find.byKey(const Key('content-draft-restore-1'));
    await tester.ensureVisible(restore);

    await tester.tap(restore);
    await tester.pumpAndSettle();

    expect(find.text('恢复槽位 1？'), findsOneWidget);
    expect(restored, isNull);
    await tester.tap(find.text('覆盖并恢复'));
    await tester.pumpAndSettle();

    expect(restored, '云端最新版');
  });

  testWidgets('删除需要确认且不会修改当前编辑器正文', (tester) async {
    final repository = _FakeRepository([_draft(slot: 1)]);
    final controller = ContentDraftsController(repository, autoStart: false);
    await controller.load();
    var restored = false;
    await _pumpSheet(
      tester,
      controller,
      currentContent: '本机正文',
      onRestore: (_) => restored = true,
    );
    final delete = find.byKey(const Key('content-draft-delete-1'));
    await tester.ensureVisible(delete);

    await tester.tap(delete);
    await tester.pumpAndSettle();
    expect(find.text('删除槽位 1？'), findsOneWidget);
    await tester.tap(find.text('删除').last);
    await tester.pumpAndSettle();

    expect(repository.removedIds, ['draft-1']);
    expect(controller.state.drafts, isEmpty);
    expect(restored, isFalse);
  });

  testWidgets('版本冲突保留当前正文并要求基于最新版二次确认', (tester) async {
    final repository = _FakeRepository([_draft(slot: 1)], conflictOnce: true);
    final controller = ContentDraftsController(repository, autoStart: false);
    await controller.load();
    await _pumpSheet(tester, controller, currentContent: '本机待保存正文');
    final overwrite = find.byKey(const Key('content-draft-overwrite-1'));
    await tester.ensureVisible(overwrite);

    await tester.tap(overwrite);
    await tester.pumpAndSettle();
    await tester.tap(find.text('覆盖').last);
    await tester.pumpAndSettle();

    expect(repository.updateVersions, [3]);
    expect(
      find.byKey(const Key('content-drafts-retry-conflict')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('content-drafts-retry-conflict')));
    await tester.pumpAndSettle();
    expect(find.text('覆盖槽位 1 的最新版？'), findsOneWidget);
    expect(controller.state.conflict?.pendingContent, '本机待保存正文');

    await tester.tap(find.text('仍然覆盖'));
    await tester.pumpAndSettle();
    expect(repository.updateVersions, [3, 4]);
    expect(controller.state.draftAt(1)?.content, '本机待保存正文');
  });
}

Future<ContentDraftsController> _readyController(
  List<ContentDraft> drafts,
) async {
  final controller = ContentDraftsController(
    _FakeRepository(drafts),
    autoStart: false,
  );
  await controller.load();
  return controller;
}

Future<void> _pumpSheet(
  WidgetTester tester,
  ContentDraftsController controller, {
  required String currentContent,
  ValueChanged<String>? onRestore,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        contentDraftsControllerProvider.overrideWith(
          (ref, sessionKey) => controller,
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ContentDraftsSheet(
            draftSessionKey: _testDraftSessionKey,
            currentContent: currentContent,
            onRestore: onRestore ?? (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeRepository implements ContentDraftRepository {
  _FakeRepository(List<ContentDraft> drafts, {this.conflictOnce = false})
    : _drafts = [...drafts];

  final List<ContentDraft> _drafts;
  final bool conflictOnce;
  final List<int?> createdSlots = [];
  final List<String> removedIds = [];
  final List<int> removeVersions = [];
  final List<int> updateVersions = [];
  var _didConflict = false;

  @override
  Future<ContentDraft> create(
    String content, {
    int? slot,
    required String clientRequestId,
  }) async {
    createdSlots.add(slot);
    final selected = slot ?? 2;
    final saved = _draft(slot: selected, content: content, version: 1);
    _drafts.add(saved);
    return saved;
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
      version: current.version + 1,
      createdAt: current.createdAt,
      updatedAt: current.updatedAt.add(const Duration(minutes: 1)),
    );
    _drafts
      ..removeWhere((draft) => draft.id == id)
      ..add(fresh);
    return fresh;
  }

  @override
  Future<void> remove(String id, {required int version}) async {
    removedIds.add(id);
    removeVersions.add(version);
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
        userMessage: '内容已在其他位置修改',
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
    _drafts
      ..removeWhere((draft) => draft.id == id)
      ..add(saved);
    return saved;
  }
}

final Object _testDraftSessionKey = Object();
const _requestId = '11111111-1111-4111-8111-111111111111';

ContentDraft _draft({
  required int slot,
  String content = '云端旧正文',
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
