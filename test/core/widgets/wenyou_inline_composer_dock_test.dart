import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_atomic_text_editor.dart';
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
    final controller = await _pumpDock(tester, width: 360);
    final initialHeight = tester.getSize(find.byKey(_fieldKey)).height;

    _replaceDocument(controller, '私聊动态回复输入保持单行');
    await tester.pump();

    expect(
      tester.getSize(find.byKey(_fieldKey)).height,
      closeTo(initialHeight, 0.01),
    );
  });

  testWidgets('320dp 两倍字号连续八个中文字符不提前换行且不显示字数', (tester) async {
    final controller = await _pumpDock(tester, width: 320, textScale: 2);
    final initialHeight = tester.getSize(find.byKey(_fieldKey)).height;

    _replaceDocument(controller, '输入保持单行测试');
    await tester.pump();

    expect(
      tester.getSize(find.byKey(_fieldKey)).height,
      closeTo(initialHeight, 0.01),
    );
    expect(find.byKey(_countKey), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('站内链接进入文档成为一个可整粒删除的传送门原子', (tester) async {
    const url = 'https://wenyou.site/join/AbCdEfGh_123-XYZ';
    final controller = await _pumpDock(tester, width: 360);

    _insert(controller, url);
    await tester.pump();

    expect(find.byKey(const Key('atomic-editor-internal-reference')), findsOne);
    expect(find.bySemanticsLabel('站内传送门：传送门'), findsOneWidget);
    expect(controller.markdown, '[传送门](/join/AbCdEfGh_123-XYZ)');
    expect(controller.documentLength, 1);
    expect(controller.selection, const TextSelection.collapsed(offset: 1));
    expect(
      controller.quillController.document
          .toDelta()
          .operations
          .firstWhere((operation) => operation.data is Map)
          .data,
      isA<Map>().having(
        (value) => value[MarkdownDeltaCodec.internalReferenceEmbed],
        '传送门 embed',
        isA<Map>(),
      ),
    );

    controller.quillController.replaceText(
      0,
      1,
      '',
      const TextSelection.collapsed(offset: 0),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('atomic-editor-internal-reference')),
      findsNothing,
    );
    expect(controller.markdown, isEmpty);
  });

  testWidgets('长按系统菜单粘贴链接时保持焦点并插入传送门原子', (tester) async {
    const url = 'https://wenyou.site/join/AbCdEfGh_123-XYZ';
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.getData') return {'text': url};
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    final controller = await _pumpDock(tester, width: 360);
    controller.focusNode.requestFocus();
    await tester.pump();

    await tester.longPress(find.byKey(_fieldKey));
    await tester.pumpAndSettle();
    final paste = find.byWidgetPredicate(
      (widget) =>
          widget is Text && (widget.data == 'Paste' || widget.data == '粘贴'),
    );
    expect(paste, findsOneWidget);

    await tester.tap(paste);
    await tester.pumpAndSettle();

    expect(controller.focusNode.hasFocus, isTrue);
    expect(find.byKey(const Key('atomic-editor-internal-reference')), findsOne);
    expect(controller.markdown, '[传送门](/join/AbCdEfGh_123-XYZ)');
  });

  testWidgets('传送门与普通文字混排并保持一个文档位置', (tester) async {
    const url = 'https://wenyou.site/threads/cmsewdo0h000x7qv6aa77ll1v';
    final controller = await _pumpDock(tester, width: 360);

    _insert(controller, '前文');
    _insert(controller, url);
    _insert(controller, '后文');
    await tester.pump();

    expect(find.byKey(const Key('atomic-editor-internal-reference')), findsOne);
    expect(controller.documentLength, 5);
    expect(
      controller.markdown,
      '前文[传送门](/threads/cmsewdo0h000x7qv6aa77ll1v)后文',
    );
  });

  testWidgets('复制和粘贴传送门仍保留原子与目标', (tester) async {
    const url = 'https://wenyou.site/join/AbCdEfGh_123-XYZ';
    final controller = await _pumpDock(tester, width: 360);
    _insert(controller, url);
    controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 1),
    );

    expect(
      controller.captureSelectionForTesting(),
      '[传送门](/join/AbCdEfGh_123-XYZ)',
    );

    controller.updateSelection(const TextSelection.collapsed(offset: 1));
    expect(controller.pasteText('[传送门](/join/AbCdEfGh_123-XYZ)'), isTrue);
    await tester.pump();

    expect(
      find.byKey(const Key('atomic-editor-internal-reference')),
      findsNWidgets(2),
    );
    expect(
      controller.markdown,
      '[传送门](/join/AbCdEfGh_123-XYZ)'
      '[传送门](/join/AbCdEfGh_123-XYZ)',
    );
  });

  testWidgets('站外链接、非法邀请和混合剪贴板保持普通文字', (tester) async {
    final controller = await _pumpDock(tester, width: 360);

    for (final value in const [
      'https://example.com/join/AbCdEfGh_123-XYZ',
      'https://wenyou.site/join/too-short',
      '入口 https://wenyou.site/join/AbCdEfGh_123-XYZ',
    ]) {
      controller.clear();
      _insert(controller, value);
      await tester.pump();
      expect(
        find.byKey(const Key('atomic-editor-internal-reference')),
        findsNothing,
        reason: value,
      );
      expect(controller.markdown, value);
    }
  });

  testWidgets('360dp 原子传送门视觉基线', (tester) async {
    final controller = await _pumpDock(tester, width: 360);
    _insert(controller, '发送给你：');
    _insert(controller, 'https://wenyou.site/join/AbCdEfGh_123-XYZ');
    await tester.pump();

    await expectLater(
      find.byKey(_dockKey),
      matchesGoldenFile('goldens/inline_composer_portal_draft_360.png'),
    );
  });
}

const _fieldKey = Key('test-composer-field');
const _dockKey = Key('test-composer-dock');
const _imageKey = Key('test-composer-image');
const _stickerKey = Key('test-composer-sticker');
const _submitKey = Key('test-composer-submit');
const _countKey = Key('test-composer-count');

void _replaceDocument(WenyouAtomicTextController controller, String value) {
  controller.applyMarkdown(
    value,
    selection: WenyouAtomicTextSelectionPlacement.end,
  );
}

void _insert(WenyouAtomicTextController controller, String value) {
  final offset = controller.selection.end;
  controller.quillController.replaceText(
    offset,
    0,
    value,
    TextSelection.collapsed(offset: offset + value.length),
  );
}

Future<WenyouAtomicTextController> _pumpDock(
  WidgetTester tester, {
  required double width,
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 720);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final controller = WenyouAtomicTextController(
    initialMarkdown: '',
    maximumMarkdownLength: 500,
  );
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
            editor: WenyouAtomicTextEditor(
              controller: controller,
              editorKey: _fieldKey,
              placeholder: '输入消息…',
              semanticLabel: '输入消息',
            ),
            dockKey: _dockKey,
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
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}
