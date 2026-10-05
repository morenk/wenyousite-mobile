import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
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
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: ThreadIdentityPicker(
              accountName: '站内用户',
              identities: identities,
              unconfiguredIdentityIds: unconfigured,
              selectedIdentityId: null,
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
    );
    await tester.tap(find.byKey(const Key('post-composer-identity-mode')));
    await tester.pumpAndSettle();
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
