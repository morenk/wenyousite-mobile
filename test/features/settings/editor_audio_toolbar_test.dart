import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_preference.dart';
import 'package:wenyousite_mobile/core/media/audio_upload_policy.dart';
import 'package:wenyousite_mobile/features/settings/presentation/editor_toolbar_settings_page.dart';

import '../../support/audio_test_fonts.dart';
import '../../support/editor_toolbar_store.dart';

final _policy = AudioUploadPolicy.parse({
  'version': 1,
  'maxBytes': 31457280,
  'maxDurationMs': 600000,
  'contentTypes': ['audio/mpeg'],
  'outputContentType': 'audio/mpeg',
})!;

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final width in [320, 360]) {
    for (final dark in [false, true]) {
      testWidgets('$width ${dark ? 'dark' : 'light'} 音频默认展开，可拖入主栏并在关闭能力时保留偏好', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width.toDouble(), 640);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final store = TestEditorToolbarStore();
        await tester.pumpWidget(_app(store, dark: dark));
        await tester.pumpAndSettle();
        final audio = find.byKey(const ValueKey('toolbar-drag-audio'));
        final expanded = find.byKey(const Key('toolbar-layout-expanded'));
        final primary = find.byKey(const Key('toolbar-layout-primary'));
        expect(find.descendant(of: expanded, matching: audio), findsOneWidget);
        expect(find.descendant(of: primary, matching: audio), findsNothing);
        expect(store.writes, 0);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            'goldens/editor_audio_${width}_${dark ? 'dark' : 'light'}.png',
          ),
        );
        final gesture = await tester.startGesture(tester.getCenter(audio));
        await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
        await gesture.moveTo(
          tester.getCenter(
            find.byKey(const ValueKey('toolbar-drop-primary-0')),
          ),
        );
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();
        expect(store.saved.primary.first, EditorTool.audio);
        expect(find.descendant(of: primary, matching: audio), findsOneWidget);
        final saved = store.saved;
        final writes = store.writes;
        await tester.pumpWidget(_app(store, dark: dark, enabled: false));
        await tester.pumpAndSettle();
        expect(audio, findsNothing);
        expect(store.saved, saved);
        expect(store.writes, writes);
        await tester.pumpWidget(_app(store, dark: dark));
        await tester.pumpAndSettle();
        expect(find.descendant(of: primary, matching: audio), findsOneWidget);
      });
    }
  }
}

Widget _app(
  TestEditorToolbarStore store, {
  bool dark = false,
  bool enabled = true,
}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    appCapabilitiesProvider.overrideWithValue(
      AppCapabilities(
        stickers: true,
        markdownAlignment: true,
        audioUpload: enabled ? _policy : null,
      ),
    ),
    editorToolbarPreferenceStoreProvider.overrideWithValue(store),
    initialEditorToolbarPreferenceProvider.overrideWithValue(
      EditorToolbarPreferenceState(layout: store.saved),
    ),
  ],
  child: MaterialApp(
    theme: dark ? AppTheme.dark : AppTheme.light,
    home: const EditorToolbarSettingsPage(),
  ),
);
