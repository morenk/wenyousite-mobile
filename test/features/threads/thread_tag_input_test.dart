import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_chip.dart';

import '../../support/deterministic_test_fonts.dart';
import 'thread_management_test_support.dart';

final _input = find.byKey(const Key('thread-management-tag-input'));
final _done = find.byKey(const Key('thread-management-tag-done'));

TextField _field(WidgetTester tester) => tester.widget<TextField>(_input);

Future<ThreadManagementTestRepository> _open(
  WidgetTester tester, {
  List<String> tags = const [],
  bool dark = false,
}) async {
  final repository = ThreadManagementTestRepository(
    initial: threadManagementTestBootstrap(tagNames: tags),
  );
  await pumpThreadManagementTestPage(tester, repository, dark: dark);
  await tester.tap(find.byKey(const Key('thread-management-edit-tags')));
  await tester.pumpAndSettle();
  return repository;
}

void _editing(WidgetTester tester, String text, {TextRange? composing}) {
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: composing ?? TextRange.empty,
    ),
  );
}

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('空格确认标签且继续输入不丢焦点', (tester) async {
    await _open(tester);
    await tester.enterText(_input, '新标签 ');
    await tester.pump();
    expect(find.widgetWithText(WenyouTagChip, '#新标签'), findsOneWidget);
    expect(_field(tester).controller!.text, isEmpty);
    expect(_field(tester).focusNode!.hasFocus, isTrue);
    await tester.enterText(_input, '下一项 ');
    await tester.pump();
    expect(find.text('已选 2/5'), findsOneWidget);
    expect(_field(tester).focusNode!.hasFocus, isTrue);
    expect(_field(tester).decoration?.suffixIcon, isNull);
    expect(_field(tester).decoration?.hintText, '标签由空格或回车分隔');
  });

  testWidgets('软键盘完成确认一个标签且保留焦点供连续录入', (tester) async {
    await _open(tester);
    await tester.enterText(_input, '回车标签');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('已选 1/5'), findsOneWidget);
    expect(_field(tester).controller!.text, isEmpty);
    expect(_field(tester).focusNode!.hasFocus, isTrue);
    await tester.enterText(_input, '第二项');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('已选 2/5'), findsOneWidget);
  });

  testWidgets('硬件Enter确认标签并保留连续输入焦点', (tester) async {
    await _open(tester);
    await tester.enterText(_input, '硬件回车');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(find.widgetWithText(WenyouTagChip, '#硬件回车'), findsOneWidget);
    expect(_field(tester).controller!.text, isEmpty);
    expect(_field(tester).focusNode!.hasFocus, isTrue);
  });

  testWidgets('小键盘回车确认且重复与松开事件不重复提交', (tester) async {
    await _open(tester);
    await tester.enterText(_input, '小键盘');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.numpadEnter);
    await tester.pump();
    expect(find.text('已选 1/5'), findsOneWidget);
    await tester.enterText(_input, '待确认');
    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.numpadEnter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.numpadEnter);
    await tester.pump();
    expect(find.text('已选 1/5'), findsOneWidget);
    expect(_field(tester).controller!.text, '待确认');
    expect(_field(tester).focusNode!.hasFocus, isTrue);
  });

  testWidgets('硬件回车不确认组合中及刚结束选词的内容', (tester) async {
    await _open(tester);
    _editing(tester, 'zhong', composing: const TextRange(start: 0, end: 5));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(find.text('已选 0/5'), findsOneWidget);
    _editing(tester, '中文');
    await tester.idle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(find.text('已选 0/5'), findsOneWidget);
    expect(_field(tester).controller!.text, '中文');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(find.widgetWithText(WenyouTagChip, '#中文'), findsOneWidget);
    expect(_field(tester).focusNode!.hasFocus, isTrue);
  });

  testWidgets('普通全角空白与回车粘贴按边界确认且保留尾部', (tester) async {
    final repository = await _open(tester);
    await tester.enterText(_input, '  甲\u3000\t乙\n丙 尾部');
    await tester.pump();
    expect(find.text('已选 3/5'), findsOneWidget);
    expect(_field(tester).controller!.text, '尾部');
    expect(repository.updateCalls, 0);
    await tester.tap(_done);
    await tester.pumpAndSettle();
    expect(repository.lastDraft?.tagNames, ['甲', '乙', '丙', '尾部']);
  });

  testWidgets('空白分隔和空回车不添加空标签', (tester) async {
    await _open(tester);
    await tester.enterText(_input, ' \u3000\t\n ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('已选 0/5'), findsOneWidget);
    expect(_field(tester).controller!.text, isEmpty);
    expect(_field(tester).decoration?.errorText, isNull);
  });

  testWidgets('恰好20字符可用空格确认，21字符保留并报错', (tester) async {
    await _open(tester);
    final valid = '字' * 20;
    final invalid = '长' * 21;
    await tester.enterText(_input, '$valid ');
    await tester.pump();
    expect(find.text('已选 1/5'), findsOneWidget);
    expect(_field(tester).controller!.text, isEmpty);
    await tester.enterText(_input, '$invalid ');
    await tester.pump();
    expect(find.text('已选 1/5'), findsOneWidget);
    expect(_field(tester).controller!.text, '$invalid ');
    expect(find.text('标签名称不能超过 20 个字符'), findsOneWidget);
  });

  for (final scenario in [
    ('重复', ['已有'], '有效 已有 后续 ', '已有 后续 ', '这个标签已经添加'),
    ('非法', <String>[], '有效 不合法! 后续 ', '不合法! 后续 ', '只能使用中英文、数字、下划线和 #'),
    ('超限', ['一', '二', '三', '四'], '第五 第六 尾部', '第六 尾部', '最多添加 5 个标签'),
  ]) {
    testWidgets('粘贴${scenario.$1}保留失败项和余下文本，完成不丢输入', (tester) async {
      final repository = await _open(tester, tags: scenario.$2);
      await tester.enterText(_input, scenario.$3);
      await tester.pump();
      expect(_field(tester).controller!.text, scenario.$4);
      expect(find.text(scenario.$5), findsOneWidget);
      await tester.tap(_done);
      await tester.pump();
      expect(find.text('编辑主题标签'), findsOneWidget);
      expect(repository.updateCalls, 0);
      expect(_field(tester).controller!.text, scenario.$4);
    });
  }

  testWidgets('中文组合中的空格与回车不提交拼音，选词结束也不提交', (tester) async {
    await _open(tester);
    _editing(
      tester,
      'zhong wen ',
      composing: const TextRange(start: 0, end: 10),
    );
    await tester.pump();
    expect(find.text('已选 0/5'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('已选 0/5'), findsOneWidget);
    _editing(tester, '中文 ', composing: const TextRange(start: 0, end: 3));
    await tester.pump();
    _editing(tester, '中文 ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(find.text('已选 0/5'), findsOneWidget);
    await tester.pump();
    expect(_field(tester).controller!.text, '中文 ');
    await tester.enterText(_input, '中文  ');
    await tester.pump();
    expect(find.text('已选 1/5'), findsOneWidget);
    expect(find.widgetWithText(WenyouTagChip, '#中文'), findsOneWidget);
  });

  testWidgets('composition结束同帧更新选区不确认也不永久阻止下一次回车', (tester) async {
    await _open(tester);
    _editing(tester, '选词', composing: const TextRange(start: 0, end: 2));
    await tester.pump();
    _editing(tester, '选词');
    await tester.idle();
    _field(tester).controller!.selection = const TextSelection.collapsed(
      offset: 1,
    );
    await tester.pump();
    expect(find.text('已选 0/5'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('已选 1/5'), findsOneWidget);
  });

  testWidgets('达到五个禁用空输入，移除后可继续，取消不保存暂存标签', (tester) async {
    final repository = await _open(tester, tags: ['一', '二', '三', '四']);
    await tester.enterText(_input, '五 ');
    await tester.pump();
    expect(_field(tester).enabled, isFalse);
    await tester.tap(find.byTooltip('移除 #一'));
    await tester.pump();
    expect(_field(tester).enabled, isTrue);
    await tester.enterText(_input, '新一 ');
    await tester.pump();
    expect(find.text('已选 5/5'), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-management-tag-cancel')));
    await tester.pumpAndSettle();
    expect(repository.updateCalls, 0);
    expect(find.text('#一'), findsOneWidget);
    expect(find.text('#新一'), findsNothing);
  });

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      final variant = '${dark ? 'dark' : 'light'}_${scale.toInt()}x';
      testWidgets('标签录入320dp候选 $variant', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 800);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await _open(tester, tags: ['角色扮演', '世界观设定'], dark: dark);
        await tester.enterText(_input, '新故事 ');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Overlay).first,
          matchesGoldenFile('goldens/thread_tag_input_320_$variant.png'),
        );
      });
    }
  }
}
