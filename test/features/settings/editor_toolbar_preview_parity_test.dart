import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_preference.dart';
import 'package:wenyousite_mobile/core/media/audio_upload_policy.dart';
import 'package:wenyousite_mobile/features/editor/editor.dart';
import 'package:wenyousite_mobile/features/settings/presentation/editor_toolbar_settings_page.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/editor_toolbar_store.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final width in [320.0, 360.0]) {
    for (final enabled in [true, false]) {
      testWidgets('$width 能力$enabled 共用预览与实际编辑器顺序及几何一致', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        for (final layout in [
          const EditorToolbarLayout.defaults(),
          EditorToolbarLayout.custom(primary: EditorTool.values, expanded: []),
        ]) {
          final store = TestEditorToolbarStore()..saved = layout;
          final capabilities = WenyouEditorCapabilities.forAlignment(enabled);
          await tester.pumpWidget(
            ProviderScope(
              key: UniqueKey(),
              overrides: [
                appCapabilitiesProvider.overrideWithValue(
                  AppCapabilities(
                    stickers: enabled,
                    markdownAlignment: enabled,
                    audioUpload: enabled ? _audioPolicy : null,
                  ),
                ),
                editorToolbarPreferenceStoreProvider.overrideWithValue(store),
                initialEditorToolbarPreferenceProvider.overrideWithValue(
                  EditorToolbarPreferenceState(layout: layout),
                ),
              ],
              child: MaterialApp(
                theme: AppTheme.light,
                home: const EditorToolbarSettingsPage(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(store.writes, 0);
          final preview = _capture(tester, preview: true);
          final controller = QuillController.basic();
          await tester.pumpWidget(
            MaterialApp(
              key: UniqueKey(),
              theme: AppTheme.light,
              home: Scaffold(
                body: WenyouEditorToolbar(
                  controller: controller,
                  layout: layout,
                  capabilities: capabilities,
                  enabled: true,
                  onInsertImage: () async {},
                  onSaveDraft: () async {},
                  onInsertSticker: enabled ? (_) async {} : null,
                  onInsertAudio: enabled ? () async {} : null,
                  onSubmit: () {},
                ),
              ),
            ),
          );
          await tester.tap(find.byKey(const Key('editor-more')));
          await tester.pumpAndSettle();
          final actual = _capture(tester, preview: false);
          expect(preview.keys.toSet(), actual.keys.toSet());
          for (final entry in actual.entries) {
            final rect = preview[entry.key]!;
            expect(
              rect.left,
              closeTo(entry.value.left, 0.01),
              reason: '${entry.key} left',
            );
            expect(
              rect.top,
              closeTo(entry.value.top, 0.01),
              reason: '${entry.key} top',
            );
            expect(
              rect.width,
              closeTo(entry.value.width, 0.01),
              reason: '${entry.key} width',
            );
            expect(
              rect.height,
              closeTo(entry.value.height, 0.01),
              reason: '${entry.key} height',
            );
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          controller.dispose();
        }
      });
      testWidgets('$width 能力$enabled 主题和回复消费唯一偏好且不重写', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final layout = EditorToolbarLayout.custom(
          primary: EditorTool.values,
          expanded: [],
        );
        final store = TestEditorToolbarStore()..saved = layout;
        final container = ProviderContainer(
          overrides: [
            editorToolbarPreferenceStoreProvider.overrideWithValue(store),
            initialEditorToolbarPreferenceProvider.overrideWithValue(
              EditorToolbarPreferenceState(layout: layout),
            ),
          ],
        );
        addTearDown(container.dispose);
        final capabilities = WenyouEditorCapabilities.forAlignment(enabled);
        final available = capabilities.availableTools(
          stickerCallback: enabled,
          audioCallback: enabled,
        );
        for (final reply in [true, false]) {
          final controller = QuillController.basic();
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                key: UniqueKey(),
                theme: AppTheme.light,
                home: Scaffold(
                  body: Consumer(
                    builder: (context, ref, _) => WenyouEditorToolbar(
                      layout: ref.watch(editorToolbarLayoutProvider),
                      controller: controller,
                      capabilities: capabilities,
                      enabled: true,
                      onInsertImage: () async {},
                      onSaveDraft: () async {},
                      onInsertSticker: enabled ? (_) async {} : null,
                      onInsertAudio: enabled ? () async {} : null,
                      onSubmit: reply ? () {} : null,
                    ),
                  ),
                ),
              ),
            ),
          );
          final toolbar = tester.widget<WenyouEditorToolbar>(
            find.byType(WenyouEditorToolbar),
          );
          expect(toolbar.layout, same(layout));
          final row = find.byKey(const Key('editor-toolbar-primary'));
          final capacity =
              ((width - 2 * WenyouEditorContract.toolbarHorizontalPadding) /
                      WenyouEditorContract.minimumActionExtent)
                  .floor() -
              (reply ? 2 : 1);
          final expected = layout.primary
              .where(available.contains)
              .take(capacity)
              .toList();
          for (final tool in EditorTool.values) {
            final key = Key(
              'editor-${tool == EditorTool.drafts ? 'content-drafts' : tool.id}',
            );
            expect(
              find.descendant(of: row, matching: find.byKey(key)),
              expected.contains(tool) ? findsOneWidget : findsNothing,
            );
          }
          expect(
            find.byKey(const Key('editor-submit')),
            reply ? findsOneWidget : findsNothing,
          );
          expect(store.writes, 0);
          expect(store.saved, same(layout));
          await tester.pumpWidget(const SizedBox.shrink());
          controller.dispose();
        }
      });
    }
  }
}

Map<String, Rect> _capture(WidgetTester tester, {required bool preview}) {
  final primary = find.byKey(
    Key(preview ? 'toolbar-layout-primary' : 'editor-toolbar-primary'),
  );
  final expanded = find.byKey(
    Key(preview ? 'toolbar-layout-expanded' : 'editor-more-tray'),
  );
  final result = <String, Rect>{};
  final toolbarOrigin = tester.getTopLeft(expanded);
  for (final (group, area) in [('primary', primary), ('expanded', expanded)]) {
    final origin = toolbarOrigin;
    result['$group bounds'] = tester.getRect(area).shift(-origin);
    for (final tool in EditorTool.values) {
      final key = preview
          ? 'toolbar-drag-${tool.id}'
          : 'editor-${tool == EditorTool.drafts ? 'content-drafts' : tool.id}';
      final item = find.descendant(
        of: area,
        matching: find.byKey(ValueKey(key)),
      );
      if (item.evaluate().isNotEmpty) {
        result['$group ${tool.id}'] = tester.getRect(item).shift(-origin);
      }
    }
    if (group == 'primary') {
      for (final action in ['more', 'submit']) {
        final item = find.byKey(
          Key(preview ? 'toolbar-layout-fixed-$action' : 'editor-$action'),
        );
        if (item.evaluate().isNotEmpty) {
          result[action] = tester.getRect(item).shift(-origin);
        }
      }
    }
  }
  final draft = find.byKey(
    Key(preview ? 'toolbar-preview-dedicated-draft' : 'editor-content-drafts'),
  );
  if (preview
      ? draft.evaluate().isNotEmpty
      : find.descendant(of: primary, matching: draft).evaluate().isEmpty &&
            find.descendant(of: expanded, matching: draft).evaluate().isEmpty &&
            draft.evaluate().isNotEmpty) {
    final button = preview
        ? find.descendant(of: draft, matching: find.byType(OutlinedButton))
        : draft;
    result['dedicated draft'] = tester.getRect(button).shift(-toolbarOrigin);
  }
  return result;
}

final _audioPolicy = AudioUploadPolicy.parse({
  'version': 1,
  'maxBytes': 31457280,
  'maxDurationMs': 600000,
  'contentTypes': ['audio/mpeg'],
  'outputContentType': 'audio/mpeg',
})!;
