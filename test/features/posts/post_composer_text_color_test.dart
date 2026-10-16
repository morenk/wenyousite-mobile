import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/editor/application/editor_text_color_preferences_ports.dart';
import 'package:wenyousite_mobile/features/editor/data/editor_text_color_preferences_store.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';
import '../../support/deterministic_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('颜色保存拒绝后显示保留草稿提示且正文仍可编辑', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = PostRepliesPageTestFakePostRepository(
      onCreate: (_) async => throw const ApiFailure.textColorUnavailable(),
    );
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'author-1',
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
      ),
    );
    await postRepliesPageTestPumpUi(tester);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await tester.pumpAndSettle();
    await postRepliesPageTestReplaceComposerText(tester, '保留有色正文');
    final editor = tester.widget<QuillEditor>(
      find.byKey(const Key('post-composer-body')),
    );
    editor.controller.formatText(0, 6, const ColorAttribute('#123456'));
    await tester.pumpAndSettle();
    final before = editor.controller.document.toDelta();
    await tester.tap(find.byKey(const Key('editor-submit')));
    await tester.pumpAndSettle();
    expect(repository.createInputs, hasLength(1));
    expect(find.text('暂时无法保存文字颜色，草稿已保留。'), findsOneWidget);
    expect(editor.controller.document.toDelta(), before);
    expect(editor.controller.readOnly, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
  for (final scenario in [
    (width: 320, height: 800, keyboard: 220),
    (width: 360, height: 800, keyboard: 220),
    (width: 320, height: 568, keyboard: 320),
  ]) {
    final width = scenario.width;
    for (final dark in scenario.height == 800 ? [false, true] : [true]) {
      testWidgets(
        '${width}x${scenario.height} ${dark ? 'dark' : 'light'} 完整半屏正文T与RGB键盘',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(
            width.toDouble(),
            scenario.height.toDouble(),
          );
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetViewInsets);
          SharedPreferences.setMockInitialValues({
            SharedPreferencesEditorTextColorStore.storageKey('author-1'): [
              '#112233',
              '#567890',
              '#AABBCC',
              '#123ABC',
            ],
          });
          final container = await postRepliesPageTestPostContainer(
            PostRepliesPageTestFakePostRepository(),
            userId: 'author-1',
            extraOverrides: [
              appCapabilitiesProvider.overrideWithValue(
                const AppCapabilities(
                  textColorSupported: true,
                  textColorWriteEnabled: true,
                ),
              ),
              editorTextColorPreferenceStoreProvider.overrideWithValue(
                const SharedPreferencesEditorTextColorStore(),
              ),
            ],
          );
          addTearDown(container.dispose);
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                theme: dark ? AppTheme.dark : AppTheme.light,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(width == 320 ? 1.5 : 1),
                  ),
                  child: RepaintBoundary(
                    key: const Key('full-editor-color-preview'),
                    child: child!,
                  ),
                ),
                home: const PostRepliesPage(
                  threadId: 'thread',
                  rootPostId: 'root',
                ),
              ),
            ),
          );
          await postRepliesPageTestPumpUi(tester);
          await tester.tap(find.byKey(const Key('post-reply-compose')));
          await tester.pumpAndSettle();
          await postRepliesPageTestReplaceComposerText(
            tester,
            '中文输入与 emoji 😀 颜色预览',
          );
          await tester.pumpAndSettle();
          final editor = tester.widget<QuillEditor>(
            find.byKey(const Key('post-composer-body')),
          );
          const selection = TextSelection(baseOffset: 0, extentOffset: 4);
          editor.controller.updateSelection(selection, ChangeSource.local);
          await tester.pump();
          await tester.tap(find.byKey(const Key('editor-heading')));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('editor-color-default')), findsOneWidget);
          expect(find.byKey(const Key('editor-color-custom')), findsOneWidget);
          expect(
            find.byKey(const Key('editor-text-color-#D14343')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('editor-text-color-#112233')),
            findsOneWidget,
          );
          if (scenario.height == 800) {
            await expectLater(
              find.byKey(const Key('full-editor-color-preview')),
              matchesGoldenFile(
                'goldens/post_color_t_${width}_${dark ? 'dark' : 'light'}.png',
              ),
            );
          }
          final before = editor.controller.document.toDelta();
          await tester.tap(find.byKey(const Key('editor-color-custom')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('editor-color-r')));
          tester.view.viewInsets = FakeViewPadding(
            bottom: scenario.keyboard.toDouble(),
          );
          await tester.pumpAndSettle();
          if (scenario.height == 800) {
            await expectLater(
              find.byKey(const Key('full-editor-color-preview')),
              matchesGoldenFile(
                'goldens/post_color_rgb_keyboard_${width}_${dark ? 'dark' : 'light'}.png',
              ),
            );
          }
          expect(tester.takeException(), isNull);
          if (scenario.height == 568) {
            final available = (scenario.height - scenario.keyboard).toDouble();
            for (final key in [
              'editor-color-r',
              'editor-color-g',
              'editor-color-b',
              'editor-color-preview',
            ]) {
              final target = find.byKey(Key(key));
              await tester.ensureVisible(target);
              await tester.pumpAndSettle();
              final bounds = tester.getRect(target);
              expect(bounds.top, greaterThanOrEqualTo(0), reason: key);
              expect(bounds.bottom, lessThanOrEqualTo(available), reason: key);
            }
            final apply = tester.getRect(
              find.byKey(const Key('editor-color-apply')),
            );
            expect(apply.top, greaterThanOrEqualTo(0));
            expect(apply.bottom, lessThanOrEqualTo(available));
            for (final scrollable in tester.stateList<ScrollableState>(
              find.ancestor(
                of: find.byKey(const Key('editor-color-preview')),
                matching: find.byType(Scrollable),
              ),
            )) {
              if (scrollable.widget.physics is NeverScrollableScrollPhysics) {
                expect(
                  scrollable.position.pixels,
                  0,
                  reason: '不能依赖用户无法拖动的外层滚动',
                );
              }
            }
            await tester.drag(
              find.byKey(const Key('editor-color-scroll')),
              const Offset(0, -500),
            );
            await tester.pumpAndSettle();
            expect(
              tester
                  .getRect(find.byKey(const Key('editor-color-preview')))
                  .bottom,
              lessThanOrEqualTo(available),
            );
            await expectLater(
              find.byKey(const Key('full-editor-color-preview')),
              matchesGoldenFile(
                'goldens/post_color_rgb_keyboard_320x568_dark.png',
              ),
            );
          }
          await tester.ensureVisible(find.byKey(const Key('editor-color-r')));
          await tester.enterText(
            find.byKey(const Key('editor-color-r')),
            '255',
          );
          await tester.tap(find.text('取消'));
          tester.view.viewInsets = const FakeViewPadding();
          await tester.pumpAndSettle();
          expect(editor.controller.document.toDelta(), before);
          expect(editor.controller.selection, selection);
          expect(editor.focusNode.hasFocus, isTrue);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        },
      );
    }
  }
}
