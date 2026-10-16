import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';
import '../../support/deterministic_test_fonts.dart';
import 'thread_compose_page_fixtures.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('主题颜色保存拒绝后展示准确提示并保留完整正文', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = _ColorRequestStore();
    final repository = _RejectedColorRepository();
    final controller = await threadComposePageTestReadyController(
      store,
      repository: repository,
    );
    const source = '<span data-wenyou-color-v1="#123456">有色正文</span>';
    controller
      ..updateTitle('颜色主题')
      ..updateCategory('TRPG')
      ..updateBody(source);
    await threadComposePageTestPumpPage(tester, controller, textColor: true);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('compose-publish')));
    await tester.pumpAndSettle();
    expect(repository.createCalls, 1);
    expect(find.text('暂时无法保存文字颜色，草稿已保留。'), findsOneWidget);
    expect(controller.state.body, source);
    expect(store.snapshot?.body, source);
    expect(
      store.states,
      isNot(contains(PendingOperationState.awaitingConfirmation)),
    );
    expect(store.pending, isNull);
    final editor = tester.widget<QuillEditor>(
      find.byKey(const Key('compose-body')),
    );
    expect(
      editor.controller.document
          .toDelta()
          .operations
          .first
          .attributes?['color'],
      '#123456',
    );
    expect(editor.controller.readOnly, isFalse);
    editor.controller.replaceText(4, 0, '继续编辑', null);
    await tester.pumpAndSettle();
    expect(controller.state.body, contains('继续编辑'));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
  testWidgets('主题正文320x568大字RGB数字键盘控件可达', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    SharedPreferences.setMockInitialValues({});
    final controller = await threadComposePageTestReadyController(
      ThreadComposePageTestMemorySnapshotStore(),
    );
    controller.updateTitle('主题颜色');
    controller.updateBody('中文输入与 emoji 😀 颜色预览');
    await threadComposePageTestPumpPage(
      tester,
      controller,
      textColor: true,
      theme: AppTheme.dark,
      textScale: 1.5,
    );
    await tester.pumpAndSettle();
    final editor = tester.widget<QuillEditor>(
      find.byKey(const Key('compose-body')),
    );
    const selection = TextSelection(baseOffset: 0, extentOffset: 4);
    editor.controller.updateSelection(selection, ChangeSource.local);
    await tester.pump();
    await tester.tap(find.byKey(const Key('editor-heading')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editor-color-custom')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editor-color-r')));
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byKey(const Key('editor-color-scroll')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    for (final key in [
      'editor-color-r',
      'editor-color-g',
      'editor-color-b',
      'editor-color-preview',
      'editor-color-apply',
    ]) {
      final bounds = tester.getRect(find.byKey(Key(key)));
      expect(bounds.top, greaterThanOrEqualTo(56), reason: key);
      expect(bounds.bottom, lessThanOrEqualTo(248), reason: key);
    }
    await expectLater(
      find.byKey(const Key('compose-text-first-visual')),
      matchesGoldenFile('goldens/thread_color_rgb_keyboard_320x568_dark.png'),
    );
    final before = editor.controller.document.toDelta();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(editor.focusNode.hasFocus, isTrue);
    tester.view.viewInsets = const FakeViewPadding();
    await tester.pumpAndSettle();
    expect(editor.controller.document.toDelta(), before);
    expect(editor.controller.selection, selection);
    expect(editor.focusNode.hasFocus, isTrue);
    expect(find.byKey(const Key('compose-title')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

class _RejectedColorRepository extends ThreadComposePageTestFakeRepository {
  @override
  Future<ThreadRemoteDraft> createDraft(ThreadCreatePayload payload) async {
    createCalls += 1;
    createPayload = payload;
    throw const ApiFailure.textColorUnavailable();
  }
}

class _ColorRequestStore extends ThreadComposePageTestMemorySnapshotStore {
  final states = <PendingOperationState>[];
  PendingCreateOperation? pending;
  @override
  Future<void> savePendingCreate(PendingCreateOperation operation) async {
    pending = operation;
    states.add(operation.state);
  }

  @override
  Future<void> deletePendingCreate(String clientRequestId) async {
    pending = null;
  }
}
