import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_composer_dock.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 输入框独占首行且操作保持 48dp', (tester) async {
      await _pumpDock(tester, width: width);

      final fieldRect = tester.getRect(find.byKey(_fieldKey));
      final dockRect = tester.getRect(find.byKey(_dockKey));
      final imageRect = tester.getRect(find.byKey(_imageKey));
      final stickerRect = tester.getRect(find.byKey(_stickerKey));
      final submitRect = tester.getRect(find.byKey(_submitKey));

      expect(fieldRect.width, closeTo(dockRect.width, 0.01));
      expect(fieldRect.bottom, lessThanOrEqualTo(imageRect.top));
      expect(stickerRect.top, closeTo(imageRect.top, 0.01));
      expect(submitRect.top, closeTo(imageRect.top, 4));
      for (final rect in [imageRect, stickerRect, submitRect]) {
        expect(rect.width, greaterThanOrEqualTo(48));
        expect(rect.height, greaterThanOrEqualTo(48));
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('360dp 默认字号连续十二个中文字符不提前换行', (tester) async {
    await _pumpDock(tester, width: 360);
    final field = find.byKey(_fieldKey);
    final initialHeight = tester.getSize(field).height;

    await tester.enterText(field, '私聊动态回复输入保持单行');
    await tester.pump();

    expect(tester.getSize(field).height, closeTo(initialHeight, 0.01));
  });

  testWidgets('320dp 两倍字号连续八个中文字符不提前换行', (tester) async {
    await _pumpDock(tester, width: 320, textScale: 2);
    final field = find.byKey(_fieldKey);
    final initialHeight = tester.getSize(field).height;

    await tester.enterText(field, '输入保持单行测试');
    await tester.pump();

    expect(tester.getSize(field).height, closeTo(initialHeight, 0.01));
    expect(find.byKey(_countKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const _fieldKey = Key('test-composer-field');
const _dockKey = Key('test-composer-dock');
const _imageKey = Key('test-composer-image');
const _stickerKey = Key('test-composer-sticker');
const _submitKey = Key('test-composer-submit');
const _countKey = Key('test-composer-count');

Future<void> _pumpDock(
  WidgetTester tester, {
  required double width,
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 720);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final controller = TextEditingController();
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: WenyouInlineComposerDock(
            controller: controller,
            fieldKey: _fieldKey,
            dockKey: _dockKey,
            placeholder: '输入消息…',
            maxLength: 500,
            onChanged: (_) {},
            leadingActions: [
              IconButton(
                key: _imageKey,
                onPressed: () {},
                tooltip: '添加图片',
                icon: const WenyouIcon(WenyouIconIds.actionAddImage),
              ),
            ],
            trailingActions: [
              IconButton(
                key: _stickerKey,
                onPressed: () {},
                tooltip: '添加表情',
                icon: const WenyouIcon(WenyouIconIds.actionAddReaction),
              ),
            ],
            submitAction: WenyouComposerSubmitButton(
              key: _submitKey,
              enabled: true,
              loading: false,
              label: '发送',
              onPressed: () {},
            ),
            characterCountText: '0/500',
            characterCountKey: _countKey,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
