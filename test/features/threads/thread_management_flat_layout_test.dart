import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_chip.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';
import '../../support/deterministic_test_fonts.dart';
import 'thread_management_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  const tags = [
    '角色扮演',
    '角色扮演世界观设定与慢热长篇故事交流',
    'Worldbuilding_2026',
    '日常',
    '慢热长篇',
  ];
  for (final dark in [false, true]) {
    testWidgets('可见范围简短选项候选 ${dark ? 'dark_2x' : 'light_1x'}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 800);
      tester.platformDispatcher.textScaleFactorTestValue = dark ? 2 : 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpThreadManagementTestPage(
        tester,
        ThreadManagementTestRepository(
          initial: threadManagementTestBootstrap(),
        ),
        dark: dark,
      );
      final visibility = find.byKey(const Key('thread-management-visibility'));
      await tester.ensureVisible(visibility);
      await tester.tap(visibility);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Overlay).first,
        matchesGoldenFile(
          'goldens/thread_management_visibility_320_${dark ? 'dark_2x' : 'light_1x'}.png',
        ),
      );
    });
  }
  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        final variant =
            '${width.toInt()}_${dark ? 'dark' : 'light'}_${scale.toInt()}x';
        testWidgets('扁平主题设置完整标签与操作 $variant', (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 1000);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await pumpThreadManagementTestPage(
            tester,
            ThreadManagementTestRepository(
              initial: threadManagementTestBootstrap(
                title: '雾海来信：漫长旅途的起点',
                tagNames: tags,
                visibility: ThreadManagementVisibility.private,
              ),
            ),
            dark: dark,
            invitationRepository: ThreadManagementTestInvitationRepository(),
          );
          expect(tester.takeException(), isNull);
          expect(find.text('添加标签'), findsNothing);
          expect(find.byType(Card), findsNothing);
          expect(find.text('私密邀请'), findsNothing);
          for (final tag in tags) {
            final label = tester.widget<Text>(find.text('#$tag'));
            expect(label.maxLines, isNull);
            expect(label.overflow, isNot(TextOverflow.ellipsis));
          }
          final summary = tester.getRect(
            find.byKey(const Key('thread-management-tag-summary')),
          );
          final category = tester.getRect(
            find.byKey(const Key('thread-management-category')),
          );
          expect(summary.left, category.left);
          expect(summary.width, category.width);
          await expectLater(
            find.byType(Scaffold).last,
            matchesGoldenFile('goldens/thread_management_flat_$variant.png'),
          );
          await tester.ensureVisible(
            find.byKey(const Key('thread-management-delete')),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          for (final key in [
            'thread-management-export',
            'thread-management-delete',
            'thread-invite-link-copy',
          ]) {
            final row = find.byKey(Key(key));
            final tile = tester.widget<ListTile>(
              find.descendant(of: row, matching: find.byType(ListTile)),
            );
            expect(tile.leading, isNull);
            if (key == 'thread-management-delete') {
              final context = tester.element(row);
              expect(
                (tile.title! as Text).style?.color,
                Theme.of(context).colorScheme.error,
              );
            }
            expect(tile.titleTextStyle?.fontWeight, FontWeight.w400);
            expect(tester.getSize(row).height, greaterThanOrEqualTo(56));
          }
          if (scale == 2) {
            await expectLater(
              find.byType(Scaffold).last,
              matchesGoldenFile(
                'goldens/thread_management_flat_${variant}_actions.png',
              ),
            );
          }
        });
      }
    }
  }
  testWidgets('空标签只有添加入口，编辑复用共享Chip并保留数量', (tester) async {
    await pumpThreadManagementTestPage(
      tester,
      ThreadManagementTestRepository(initial: threadManagementTestBootstrap()),
    );
    expect(find.text('添加标签'), findsOneWidget);
    expect(
      find.byKey(const Key('thread-management-tag-summary')),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('thread-management-edit-tags')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('thread-management-tag-input')),
      '新标签',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.byType(WenyouTagChip), findsOneWidget);
    expect(find.text('已选 1/5'), findsOneWidget);
    expect(find.text('标签工作台占位'), findsNothing);
  });

  testWidgets('标签编辑实际移除、拒绝重复并在五个标签时禁用继续添加', (tester) async {
    final repository = ThreadManagementTestRepository(
      initial: threadManagementTestBootstrap(tagNames: const ['原标签', '保留']),
    );
    await pumpThreadManagementTestPage(tester, repository);
    await tester.tap(find.text('#原标签'));
    await tester.pumpAndSettle();
    final input = find.byKey(const Key('thread-management-tag-input'));
    await tester.enterText(input, '原标签');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('这个标签已经添加'), findsOneWidget);
    expect(find.text('已选 2/5'), findsOneWidget);
    await tester.tap(find.byTooltip('移除 #原标签'));
    await tester.pump();
    expect(find.text('已选 1/5'), findsOneWidget);
    for (final tag in ['新的甲', '新的乙', '新的丙', '新的丁']) {
      await tester.enterText(input, tag);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
    }
    expect(find.text('已选 5/5'), findsOneWidget);
    expect(tester.widget<TextField>(input).enabled, isFalse);
    expect(find.byKey(const Key('thread-management-tag-add')), findsNothing);
    await tester.pump();
    expect(find.byType(WenyouTagChip), findsNWidgets(5));
    expect(repository.updateCalls, 0);
    await tester.tap(find.byKey(const Key('thread-management-tag-done')));
    await tester.pumpAndSettle();
    expect(repository.lastDraft?.tagNames, ['保留', '新的甲', '新的乙', '新的丙', '新的丁']);
    expect(find.text('#原标签'), findsNothing);
  });
}
