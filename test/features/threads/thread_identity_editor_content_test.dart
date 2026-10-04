import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/presentation/thread_identity_editor_content.dart';

void main() {
  test('昵称按Unicode字符计数并拒绝结构化提及分隔和控制字符', () {
    expect(validateThreadIdentityNickname('😀' * 24), isNull);
    expect(validateThreadIdentityNickname('😀' * 25), isNotNull);
    expect(validateThreadIdentityNickname('白 鸦·归来'), isNull);
    for (final name in ['白[鸦', '白\\鸦', '白<鸦', '白\u200b鸦']) {
      expect(validateThreadIdentityNickname(name), isNotNull);
    }
  });
  for (final dark in [false, true]) {
    testWidgets('窄屏大字表单保留输入并禁用失去资格后的保存 $dark', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 700);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final controller = TextEditingController(text: '来自遥远群山的白鸦与尚未抵达的漫长旅程');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ThreadIdentityEditorContent(
                  nicknameController: controller,
                  accountName: '站内用户名',
                  previewName: controller.text,
                  canEdit: false,
                  isBusy: false,
                  hasSavedIdentity: true,
                  hasCustomAvatar: true,
                  maxNicknameLength: 24,
                  errorMessage: '资格已变化，已保留输入。',
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
      expect(tester.takeException(), isNull);
      expect(controller.text, '来自遥远群山的白鸦与尚未抵达的漫长旅程');
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('thread-identity-save')))
            .onPressed,
        isNull,
      );
      expect(find.text('资格已变化，已保留输入。'), findsOneWidget);
    });
  }
}
