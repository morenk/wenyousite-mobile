import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selection_menu.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_widgets.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  Future<void> pumpPicker(
    WidgetTester tester, {
    required List<RpIdentity> identities,
    ValueChanged<String?>? onSelected,
    ValueChanged<String>? onEdit,
    VoidCallback? onCreate,
    Set<String> unconfigured = const {},
    bool dark = false,
    String? selectedId,
    Alignment alignment = Alignment.topLeft,
    double bottomSpace = 0,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: Scaffold(
          body: Align(
            alignment: alignment,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomSpace),
              child: ThreadIdentityPicker(
                accountName: '站内用户',
                identities: identities,
                unconfiguredIdentityIds: unconfigured,
                selectedIdentityId: selectedId,
                canEdit: true,
                limit: 10,
                enabled: true,
                onSelected: onSelected ?? (_) {},
                onEdit: onEdit ?? (_) {},
                onCreate: onCreate ?? () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('post-composer-identity-mode')));
    await tester.pumpAndSettle();
  }

  testWidgets('四字昵称不换行，选中背景止于编辑按钮之前', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 720);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await pumpPicker(
      tester,
      identities: const [RpIdentity(id: 'one', nickname: '又如何呢')],
      selectedId: 'one',
    );
    final option = find.byKey(const Key('post-identity-option-rp-one'));
    final name = find.descendant(of: option, matching: find.text('又如何呢'));
    final text = tester.widget<Text>(name);
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
    final paragraph = tester.renderObject<RenderParagraph>(name);
    expect(paragraph.didExceedMaxLines, isFalse);
    final edit = find.byKey(const Key('thread-identity-edit-one'));
    final row = find.descendant(
      of: option,
      matching: find.byType(WenyouSelectionRow),
    );
    expect(
      tester.getRect(row).right,
      lessThanOrEqualTo(tester.getRect(edit).left),
    );
    expect(tester.getSize(edit).shortestSide, greaterThanOrEqualTo(48));
    expect(find.ancestor(of: edit, matching: find.byType(Ink)), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets('键盘上方十个身份可滑动到底 ${dark ? '深色' : '浅色'}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 720);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);
      final selections = <String?>[];
      await pumpPicker(
        tester,
        dark: dark,
        alignment: Alignment.bottomLeft,
        bottomSpace: 180,
        identities: [
          for (var i = 0; i < 10; i++)
            RpIdentity(id: 'role-$i', nickname: '来自远方的第$i位漫长旅途中的角色'),
        ],
        onSelected: selections.add,
      );
      final scroll = find.byType(SingleChildScrollView).last;
      final anchor = find.byKey(const Key('post-composer-identity-mode'));
      expect(
        tester.getRect(scroll).top,
        greaterThan(tester.getRect(anchor).bottom),
      );
      expect(tester.getRect(scroll).bottom, lessThanOrEqualTo(420));
      expect(find.byType(Scrollbar), findsOneWidget);
      await tester.drag(scroll, const Offset(0, -600));
      await tester.pumpAndSettle();
      final last = find.byKey(const Key('post-identity-option-rp-role-9'));
      expect(last.hitTestable(), findsOneWidget);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/rp_identity_keyboard_320_${dark ? 'dark' : 'light'}.png',
        ),
      );
      await tester.tap(last);
      await tester.pumpAndSettle();
      expect(selections, ['role-9']);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('同名角色按ID选择，原行尾编辑不切换发表身份', (tester) async {
    final selections = <String?>[];
    final edits = <String>[];
    const identities = [
      RpIdentity(id: 'first', nickname: '白夜'),
      RpIdentity(id: 'second', nickname: '白夜'),
    ];
    await pumpPicker(
      tester,
      identities: identities,
      onSelected: selections.add,
      onEdit: edits.add,
    );
    await tester.tap(find.byKey(const Key('thread-identity-edit-second')));
    await tester.pumpAndSettle();
    expect(edits, ['second']);
    expect(selections, isEmpty);
    await tester.tap(find.byKey(const Key('post-composer-identity-mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('post-identity-option-rp-second')));
    await tester.pumpAndSettle();
    expect(selections, ['second']);
  });

  for (final count in [0, 9, 10]) {
    testWidgets('$count个身份的新增边界与末项可达', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 720);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      var created = 0;
      final selections = <String?>[];
      await pumpPicker(
        tester,
        identities: [
          for (var index = 0; index < count; index++)
            RpIdentity(id: 'rp-$index', nickname: '白夜 $index'),
        ],
        onSelected: selections.add,
        onCreate: () => created++,
      );
      final create = find.byKey(const Key('post-identity-option-settings'));
      if (count < 10) {
        await tester.ensureVisible(create);
        await tester.pumpAndSettle();
        await tester.tap(create);
        await tester.pumpAndSettle();
        expect(created, 1);
        expect(selections, isEmpty);
      } else {
        expect(create, findsNothing);
        final last = find.byKey(const Key('post-identity-option-rp-rp-9'));
        await tester.ensureVisible(last);
        await tester.pumpAndSettle();
        await tester.tap(last);
        await tester.pumpAndSettle();
        expect(selections, ['rp-9']);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('清空资料的原角色仍能配置且计入上限，不被选中发表', (tester) async {
    final selections = <String?>[];
    final edits = <String>[];
    await pumpPicker(
      tester,
      identities: [
        const RpIdentity(id: 'empty', nickname: '未设置'),
        for (var index = 1; index < 10; index++)
          RpIdentity(id: 'rp-$index', nickname: '白夜 $index'),
      ],
      unconfigured: {'empty'},
      onSelected: selections.add,
      onEdit: edits.add,
    );
    expect(
      find.byKey(const Key('post-identity-option-settings')),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('post-identity-option-rp-empty')));
    await tester.pumpAndSettle();
    expect(edits, ['empty']);
    expect(selections, isEmpty);
  });

  for (final dark in [false, true]) {
    testWidgets('320dp多身份菜单${dark ? '深色' : '浅色'}视觉候选', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 720);
      tester.platformDispatcher.textScaleFactorTestValue = dark ? 2 : 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpPicker(
        tester,
        dark: dark,
        selectedId: 'one',
        identities: const [
          RpIdentity(id: 'one', nickname: '白夜'),
          RpIdentity(id: 'two', nickname: '夜渡'),
          RpIdentity(id: 'three', nickname: '来自群山的白夜与尚未抵达的漫长旅程以及新的故事'),
        ],
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/rp_identity_picker_320_${dark ? 'dark' : 'light'}.png',
        ),
      );
      await tester.ensureVisible(
        find.byKey(const Key('post-identity-option-settings')),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
