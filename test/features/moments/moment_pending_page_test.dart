import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_page.dart';

import '../../support/foundation_test_fonts.dart';
import '../../support/moment_test_draft_store.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('发布超时锁定表单，离开后仅恢复原操作且不自动重试', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = MemoryMomentDraftStore();
    final repository = _TimeoutRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentDraftStoreProvider.overrideWithValue(store),
          momentComposerOwnerResolverProvider.overrideWithValue(
            () async => 'user-1',
          ),
          momentRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => const MomentComposePage()),
                ),
                child: const Text('开始发布'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('开始发布'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('moment-compose-title')),
      '原始标题',
    );
    await tester.tap(find.byKey(const Key('moment-compose-submit')));
    await tester.pumpAndSettle();
    expect(repository.requests, hasLength(1));
    expect(find.byKey(const Key('moment-compose-pending')), findsOneWidget);
    expect(find.text('重试确认'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const Key('moment-compose-title')),
              matching: find.byType(TextField),
            ),
          )
          .readOnly,
      isTrue,
    );
    expect(
      tester
          .widget<QuillEditor>(find.byKey(const Key('moment-compose-content')))
          .controller
          .readOnly,
      isTrue,
    );
    expect(find.byKey(const Key('moment-draft-reset')), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moment-leave-discard')), findsNothing);
    await tester.tap(find.text('保留并退出'));
    await tester.pumpAndSettle();
    expect(store.draft?.pendingCreate, isNotNull);
    await tester.tap(find.text('开始发布'));
    await tester.pumpAndSettle();
    expect(repository.requests, hasLength(1));
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('moment-compose-title')))
          .controller
          ?.text,
      '原始标题',
    );
    expect(find.text('重试确认'), findsOneWidget);
    await tester.tap(find.text('重试确认'));
    await tester.pumpAndSettle();
    expect(repository.requests, hasLength(2));
    expect(repository.requests.last, repository.requests.first);
    expect(tester.takeException(), isNull);
  });
}

class _TimeoutRepository extends Fake implements MomentRepository {
  final requests = <(String, String)>[];

  @override
  Future<MomentDetail> create(
    MomentDraftInput input, {
    required String clientRequestId,
  }) async {
    requests.add((clientRequestId, input.title));
    throw const ApiFailure(httpStatus: 503);
  }
}
