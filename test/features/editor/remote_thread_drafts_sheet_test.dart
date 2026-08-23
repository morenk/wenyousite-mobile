import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/thread_category_catalog.dart';
import 'package:wenyousite_mobile/features/threads/application/remote_thread_drafts_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_compose_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/remote_thread_drafts_sheet.dart';

import '../../support/fake_thread_category_catalog.dart';

void main() {
  testWidgets('360dp 草稿箱展示当前项并二次确认删除其他云端草稿', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _FakeRepository([
      _summary('draft-current', '当前草稿'),
      _summary('draft-other', '其他设备草稿'),
    ]);
    final controller = RemoteThreadDraftsController(
      repository,
      autoStart: false,
    );
    await controller.load();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          remoteThreadDraftsControllerProvider.overrideWith(
            (ref) => controller,
          ),
          threadCategoryCatalogRepositoryProvider.overrideWithValue(
            FakeThreadCategoryCatalogRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: RemoteThreadDraftsSheet(currentDraftId: 'draft-current'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前草稿'), findsOneWidget);
    expect(find.textContaining('演绎'), findsNWidgets(2));
    expect(find.textContaining('DEDUCTION'), findsNothing);
    expect(find.text('正在编辑'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const Key('remote-draft-remove-draft-current')),
          )
          .onPressed,
      isNull,
    );

    final remove = find.byKey(const Key('remote-draft-remove-draft-other'));
    await tester.ensureVisible(remove);
    await tester.tap(remove);
    await tester.pumpAndSettle();
    expect(find.text('删除云端草稿？'), findsOneWidget);
    expect(find.text('“其他设备草稿”删除后无法恢复，其他设备也将无法继续编辑。'), findsOneWidget);

    await tester.tap(find.text('确认删除'));
    await tester.pumpAndSettle();

    expect(repository.removedIds, ['draft-other']);
    expect(find.text('其他设备草稿'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

ThreadRemoteDraftSummary _summary(String id, String title) {
  return ThreadRemoteDraftSummary(
    id: id,
    title: title,
    categorySlug: 'DEDUCTION',
    visibility: ThreadComposeVisibility.private,
    tags: const ['跑团', '奇幻'],
    createdAt: DateTime.utc(2026, 8, 9),
    updatedAt: DateTime.utc(2026, 8, 10, 12, 30),
    subthreadCount: 1,
    postCount: 2,
  );
}

class _FakeRepository implements ThreadComposeRepository {
  _FakeRepository(this.drafts);

  final List<ThreadRemoteDraftSummary> drafts;
  final List<String> removedIds = [];

  @override
  Future<List<ThreadRemoteDraftSummary>> fetchDrafts() async => drafts;

  @override
  Future<void> removeDraft(String id) async => removedIds.add(id);

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
