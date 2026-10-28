import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';

import '../../support/deterministic_test_fonts.dart';
import 'thread_compose_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final scenario in [
    (const Size(360, 720), 360.0, 1.0, false),
    (const Size(320, 568), 280.0, 1.5, true),
    (const Size(320, 568), 320.0, 2.0, false),
  ]) {
    testWidgets('标题在高键盘下保持可见、焦点和输入 $scenario', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = scenario.$1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);
      final controller = await threadComposePageTestReadyController(
        ThreadComposePageTestMemorySnapshotStore(),
      );
      controller.updateBody('已写好的正文');
      await threadComposePageTestPumpPage(
        tester,
        controller,
        theme: scenario.$4 ? AppTheme.dark : AppTheme.light,
        textScale: scenario.$3,
      );
      final title = find.byKey(const Key('compose-title'));
      await tester.tap(title);
      await tester.pumpAndSettle();
      final editable = tester.widget<EditableText>(
        find.descendant(of: title, matching: find.byType(EditableText)),
      );
      expect(editable.focusNode.hasFocus, isTrue);
      tester.view.viewInsets = FakeViewPadding(bottom: scenario.$2);
      await tester.pumpAndSettle();
      expect(title, findsOneWidget);
      expect(editable.focusNode.hasFocus, isTrue);
      await tester.enterText(title, '键盘打开后继续写标题');
      await tester.pumpAndSettle();
      expect(controller.state.title, '键盘打开后继续写标题');
      expect(
        tester.getRect(title).bottom,
        lessThan(scenario.$1.height - scenario.$2),
      );
      await expectLater(
        find.byKey(const Key('compose-text-first-visual')),
        matchesGoldenFile(
          'goldens/compose-title-keyboard-${scenario.$1.width.toInt()}-${scenario.$3}-${scenario.$4 ? 'dark' : 'light'}.png',
        ),
      );

      tester.view.viewInsets = const FakeViewPadding();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('标签'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = FakeViewPadding(bottom: scenario.$2);
      await tester.pumpAndSettle();
      final tags = find.byKey(const Key('compose-tags'));
      await tester.ensureVisible(tags);
      await tester.pumpAndSettle();
      await tester.enterText(tags, '标签甲 标签乙');
      expect(controller.state.tags, ['标签甲', '标签乙']);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      final editor = tester.widget<QuillEditor>(
        find.byKey(const Key('compose-body')),
      );
      expect(editor.focusNode.hasFocus, isTrue);
      // 正文键盘仍在时，标题入口仍可滚动到并重新编辑。
      await tester.ensureVisible(title);
      await tester.tap(title);
      await tester.pumpAndSettle();
      expect(editable.focusNode.hasFocus, isTrue);
      expect(editor.controller.document.toPlainText(), contains('已写好的正文'));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  testWidgets('恢复草稿后分类仍在加载，标题在键盘中继续编辑并保留正文', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 720);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    final store = ThreadComposePageTestMemorySnapshotStore();
    final original = await threadComposePageTestReadyController(store);
    original.updateTitle('恢复的标题');
    original.updateBody('恢复的正文');
    await original.flushLocalSnapshot();
    original.dispose();
    final repository = _SlowBootstrapRepository();
    final restored = await threadComposePageTestReadyController(
      store,
      repository: repository,
    );
    await threadComposePageTestPumpPage(tester, restored);
    expect(restored.state.bootstrapLoading, true);
    final title = find.byKey(const Key('compose-title'));
    await tester.ensureVisible(title);
    await tester.tap(title);
    tester.view.viewInsets = const FakeViewPadding(bottom: 360);
    await tester.pumpAndSettle();
    await tester.enterText(title, '分类未就绪也能继续输入');
    expect(restored.state.title, '分类未就绪也能继续输入');
    expect(restored.state.body, '恢复的正文');
    repository.result.complete(
      await ThreadComposePageTestFakeRepository().fetchBootstrap(),
    );
    await tester.pumpAndSettle();
    expect(restored.state.bootstrapLoading, false);
    expect(restored.state.title, '分类未就绪也能继续输入');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

class _SlowBootstrapRepository extends ThreadComposePageTestFakeRepository {
  final result = Completer<ThreadComposeBootstrap>();
  @override
  Future<ThreadComposeBootstrap> fetchBootstrap() => result.future;
}
