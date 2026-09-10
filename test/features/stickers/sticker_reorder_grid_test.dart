import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_collection_page.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_reorder_grid.dart';

import '../../support/foundation_test_fonts.dart';
import 'sticker_reorder_test_support.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('真实页面长按跨行让位动画，落位乐观保持且成功静默', (tester) async {
    final repository = await _pumpPage(tester);
    final beforeB = tester.getTopLeft(_tile('b'));
    final beforeA = tester.getTopLeft(_tile('a'));
    final imageB = tester.widget<StickerGridImage>(
      find.descendant(of: _tile('b'), matching: find.byType(StickerGridImage)),
    );
    final target = tester.getCenter(_tile('f'));
    final gesture = await _lift(tester, 'a');
    await gesture.moveTo(target);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final movingB = tester.getTopLeft(_tile('b'));
    expect(movingB.dx, lessThan(beforeB.dx));
    expect(movingB.dx, greaterThan(beforeA.dx));
    expect(
      tester.widget<StickerGridImage>(
        find.descendant(
          of: _tile('b'),
          matching: find.byType(StickerGridImage),
        ),
      ),
      same(imageB),
    );
    expect(repository.writes, isEmpty);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(repository.writes.single.ids, [
      'b',
      'c',
      'd',
      'e',
      'f',
      'a',
      'g',
      'h',
      'i',
      'j',
      'k',
      'l',
    ]);
    final dropped = tester.getTopLeft(_tile('a'));
    repository.complete(0);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(_tile('a')), dropped);
    expect(find.text('表情顺序已更新。'), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('保存等待期间继续拖动，失败才回退并显示错误', (tester) async {
    final repository = await _pumpPage(tester);
    await _dragTo(tester, 'a', 'f');
    expect(repository.writes, hasLength(1));
    await _dragTo(tester, 'b', 'h');
    expect(repository.writes, hasLength(1));
    repository.writes[0].result.completeError(
      const ApiFailure(userMessage: '操作失败，请重试。'),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('stickers-action-failure')), findsOneWidget);
    expect(_visualOrder(tester), 'abcdefghijkl'.split(''));
    expect(repository.writes, hasLength(1));
  });

  testWidgets('取消拖动、原位放下与普通滑动均不保存', (tester) async {
    final repository = await _pumpPage(tester);
    var gesture = await _lift(tester, 'a');
    await gesture.moveTo(tester.getCenter(_tile('g')));
    await tester.pump(const Duration(milliseconds: 200));
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(_visualOrder(tester), 'abcdefghijkl'.split(''));
    gesture = await _lift(tester, 'a');
    await gesture.up();
    await tester.pumpAndSettle();
    await tester.drag(_tile('a'), const Offset(0, -30));
    await tester.pumpAndSettle();
    expect(repository.writes, isEmpty);
  });

  testWidgets('拖到边缘自动滚动，离屏图片有界，取消释放滚动任务', (tester) async {
    final repository = await _pumpPage(tester, count: 200);
    expect(find.byType(StickerGridImage).evaluate().length, lessThan(100));
    final grid = tester.widget<StickerReorderGrid>(
      find.byType(StickerReorderGrid),
    );
    final gesture = await _lift(tester, 'a');
    await gesture.moveTo(const Offset(175, 748));
    for (var i = 0; i < 90; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(grid.scrollController.offset, greaterThan(200));
    expect(find.byType(StickerGridImage).evaluate().length, lessThan(140));
    await gesture.cancel();
    await tester.pumpAndSettle();
    final stoppedAt = grid.scrollController.offset;
    await tester.pump(const Duration(seconds: 1));
    expect(grid.scrollController.offset, stoppedAt);
    expect(repository.writes, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('减少动态效果保留排序能力但取消抬起和位移动画', (tester) async {
    final repository = await _pumpPage(tester, reducedMotion: true);
    final target = tester.getCenter(_tile('d'));
    final gesture = await _lift(tester, 'a');
    await gesture.moveTo(target);
    await tester.pump();
    expect(
      tester
          .widgetList<AnimatedPositioned>(find.byType(AnimatedPositioned))
          .every((widget) => widget.duration == Duration.zero),
      isTrue,
    );
    final models = tester.widgetList<PhysicalModel>(
      find.descendant(
        of: find.byType(StickerReorderGrid),
        matching: find.byType(PhysicalModel),
      ),
    );
    expect(models, isNotEmpty);
    expect(models.every((widget) => widget.elevation == 0), isTrue);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(repository.writes.single.ids[3], 'a');
    repository.complete(0);
    await tester.pumpAndSettle();
  });

  testWidgets('拖动中退出页面不会遗留 ticker 或回调已销毁页面', (tester) async {
    final repository = await _pumpPage(tester);
    final gesture = await _lift(tester, 'a');
    await tester.pumpWidget(const SizedBox());
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(repository.writes, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('长按停在中间时不持续调度空帧', (tester) async {
    final repository = await _pumpPage(tester);
    final gesture = await _lift(tester, 'a');
    await tester.pumpAndSettle(
      const Duration(milliseconds: 20),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 1),
    );
    expect(tester.binding.hasScheduledFrame, isFalse);
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(repository.writes, isEmpty);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 紧凑网格视觉基线', (tester) async {
      await _pumpPage(tester, width: width);
      expect(
        tester.getTopLeft(_tile('a')).dy,
        tester.getTopLeft(_tile('b')).dy,
      );
      expect(find.byType(ReorderableListView), findsNothing);
      expect(find.text('静态表情'), findsNothing);
      expect(find.text('96 × 96'), findsNothing);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/sticker_grid_${width.toInt()}.png'),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('黑夜与大字管理模式布局和移除命中区', (tester) async {
    await _pumpPage(tester, dark: true, textScale: 2);
    expect(find.byKey(const ValueKey('sticker-remove-a')), findsNothing);
    await tester.tap(find.byKey(const Key('stickers-manage')));
    await tester.pumpAndSettle();
    expect(
      tester
          .getSize(find.byKey(const ValueKey('sticker-remove-a')))
          .shortestSide,
      greaterThanOrEqualTo(48),
    );
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/sticker_grid_dark_manage.png'),
    );
    await tester.tap(find.byKey(const ValueKey('sticker-remove-a')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('stickers-remove-confirm')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Finder _tile(String id) => find.byKey(ValueKey('sticker-drag-$id'));

Future<TestGesture> _lift(WidgetTester tester, String id) async {
  final gesture = await tester.startGesture(tester.getCenter(_tile(id)));
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 20));
  await tester.pump(const Duration(milliseconds: 200));
  return gesture;
}

Future<void> _dragTo(WidgetTester tester, String id, String targetId) async {
  final target = tester.getCenter(_tile(targetId));
  final gesture = await _lift(tester, id);
  await gesture.moveTo(target);
  await tester.pump(const Duration(milliseconds: 200));
  await gesture.up();
  await tester.pumpAndSettle();
}

List<String> _visualOrder(WidgetTester tester) {
  final ids = 'abcdefghijkl'.split('');
  ids.sort((a, b) {
    final pa = tester.getTopLeft(_tile(a));
    final pb = tester.getTopLeft(_tile(b));
    return pa.dy == pb.dy ? pa.dx.compareTo(pb.dx) : pa.dy.compareTo(pb.dy);
  });
  return ids;
}

Future<ReorderTestRepository> _pumpPage(
  WidgetTester tester, {
  int count = 12,
  double width = 360,
  bool reducedMotion = false,
  bool dark = false,
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 760);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final repository = ReorderTestRepository()
    ..current = stickerCollection(
      order: [for (var i = 0; i < count; i++) String.fromCharCode(97 + i)],
    );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        stickersEnabledProvider.overrideWithValue(true),
        stickerCollectionControllerProvider.overrideWith(
          (ref) => StickerCollectionController(
            repository,
            pollInterval: Duration.zero,
          ),
        ),
      ],
      child: MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: reducedMotion,
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
        home: const StickerCollectionPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}
