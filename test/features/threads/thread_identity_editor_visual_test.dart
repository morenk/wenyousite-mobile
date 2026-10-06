import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/thread_identity/presentation/thread_identity_editor_content.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final dark in [false, true]) {
    testWidgets('320dp身份表单视觉候选 $dark', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 760);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final nickname = TextEditingController(text: '白夜');
      addTearDown(nickname.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ThreadIdentityEditorContent(
                  nicknameController: nickname,
                  previewName: '白夜',
                  canEdit: true,
                  isBusy: false,
                  hasSavedIdentity: true,
                  maxNicknameLength: 24,
                  onSelectAvatar: () {},
                  onClearAvatar: () {},
                  onSave: () {},
                  onClear: () {},
                  onNicknameChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/rp_identity_editor_320_${dark ? 'dark' : 'light'}.png',
        ),
      );
    });
  }
}
