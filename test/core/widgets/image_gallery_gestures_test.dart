import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_image_viewer_page.dart';

const _items = [
  WenyouImageViewerItem(
    id: 'a',
    url: 'https://example.test/a.png',
    semanticLabel: 'A',
  ),
  WenyouImageViewerItem(
    id: 'b',
    url: 'https://example.test/b.png',
    semanticLabel: 'B',
  ),
  WenyouImageViewerItem(
    id: 'c',
    url: 'https://example.test/c.png',
    semanticLabel: 'C',
  ),
];

Future<void> _open(
  WidgetTester tester, {
  List<WenyouImageViewerItem> items = _items,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(400, 700);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => WenyouImageViewerPage(
                  items: items,
                  imageBuilder: (_, index, current) => ColoredBox(
                    color: Colors.red,
                    child: Center(child: Text('image-$index')),
                  ),
                ),
              ),
            ),
            child: const Text('打开'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开'));
  await tester.pumpAndSettle();
}

TransformationController _transform(WidgetTester tester) => tester
    .widget<InteractiveViewer>(find.byType(InteractiveViewer).first)
    .transformationController!;

void main() {
  testWidgets('图集从单图补齐前序图片后画面立即保持点击图，不等待再次点按', (tester) async {
    var images = [_items[2]];
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return WenyouImageViewerPage(
              items: images,
              imageBuilder: (_, index, current) =>
                  Center(child: Text('画面-${images[index].semanticLabel}')),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('画面-C').hitTestable(), findsOneWidget);
    update(() => images = _items);
    await tester.pump();
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 2);
    expect(find.text('画面-C').hitTestable(), findsOneWidget);
    expect(find.text('画面-A').hitTestable(), findsNothing);
    await tester.tapAt(const Offset(400, 300));
    await tester.pumpAndSettle();
    expect(find.text('画面-C').hitTestable(), findsOneWidget);
  });

  testWidgets('按住横拖时前页返回，当前图保持且本手势不按旧序号跳转', (tester) async {
    var images = _items.sublist(1);
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return WenyouImageViewerPage(
              items: images,
              titleBuilder: (index, _) => images[index].semanticLabel,
              imageBuilder: (_, index, current) =>
                  const ColoredBox(color: Colors.red),
            );
          },
        ),
      ),
    );
    final gesture = await tester.startGesture(const Offset(500, 300));
    await gesture.moveBy(const Offset(-90, 0));
    await tester.pump();
    update(() => images = _items);
    await tester.pump();
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 1);
    await gesture.moveBy(const Offset(-100, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('B'), findsOneWidget);
    await tester.dragFrom(const Offset(500, 300), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('放大后前插页保持当前图片的缩放状态与实际页位置', (tester) async {
    var images = [_items[2]];
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return WenyouImageViewerPage(
              items: images,
              imageBuilder: (_, index, current) => const SizedBox.expand(),
            );
          },
        ),
      ),
    );
    await tester.tapAt(const Offset(100, 220));
    await tester.pump(const Duration(milliseconds: 70));
    await tester.tapAt(const Offset(100, 220));
    await tester.pumpAndSettle();
    final transform = _transform(tester);
    final before = transform.value.clone();
    expect(before.getMaxScaleOnAxis(), 2);
    update(() => images = _items);
    await tester.pumpAndSettle();
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 2);
    expect(_transform(tester), same(transform));
    expect(transform.value, before);
  });

  testWidgets('真实双指围绕中心放大，放大后拖动只平移，第二指松开不关闭', (tester) async {
    await _open(tester);
    final center = tester.getCenter(find.byType(InteractiveViewer).first);
    final first = await tester.startGesture(
      center - const Offset(50, 0),
      pointer: 1,
    );
    final second = await tester.startGesture(
      center + const Offset(50, 0),
      pointer: 2,
    );
    await tester.pump();
    await first.moveTo(center - const Offset(90, 0));
    await second.moveTo(center + const Offset(90, 0));
    await first.moveTo(center - const Offset(130, 0));
    await second.moveTo(center + const Offset(130, 0));
    await tester.pump();
    final transform = _transform(tester);
    expect(transform.value.getMaxScaleOnAxis(), greaterThan(1.4));
    expect(transform.value.storage[12], lessThan(0));
    await second.up();
    await first.moveBy(const Offset(0, 160));
    await first.up();
    await tester.pumpAndSettle();
    expect(find.byType(WenyouImageViewerPage), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    final before = transform.value.clone();
    await tester.dragFrom(center, const Offset(-120, 0));
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget);
    expect(transform.value, isNot(before));
  });

  testWidgets('双指保持1倍后松开一指继续横移不翻页，下一手势正常翻页', (tester) async {
    await _open(tester);
    final first = await tester.startGesture(const Offset(160, 300), pointer: 1);
    final second = await tester.startGesture(
      const Offset(240, 300),
      pointer: 2,
    );
    await tester.pump();
    await second.up();
    await first.moveBy(const Offset(-140, 0));
    await first.up();
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget);
    await tester.dragFrom(const Offset(300, 300), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('真实横拖跟手、首尾不循环，换图后复位，关闭保留原页面', (tester) async {
    await _open(tester);
    final gesture = await tester.startGesture(const Offset(300, 300));
    await gesture.moveBy(const Offset(-100, 0));
    await tester.pump();
    expect(
      tester.widget<PageView>(find.byType(PageView)).controller!.offset,
      greaterThan(50),
    );
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
    expect(_transform(tester).value.getMaxScaleOnAxis(), 1);
    await tester.dragFrom(const Offset(300, 300), const Offset(-200, 0));
    await tester.pumpAndSettle();
    await tester.dragFrom(const Offset(300, 300), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(find.text('3 / 3'), findsOneWidget);
    await tester.dragFrom(const Offset(200, 200), const Offset(0, 150));
    await tester.pumpAndSettle();
    expect(find.text('打开'), findsOneWidget);
  });

  testWidgets('双击以点击点为中心2倍，再次双击复位', (tester) async {
    await _open(tester);
    const tap = Offset(80, 220);
    await tester.tapAt(tap);
    await tester.pump(const Duration(milliseconds: 70));
    await tester.tapAt(tap);
    await tester.pumpAndSettle();
    expect(_transform(tester).value.getMaxScaleOnAxis(), 2);
    expect(_transform(tester).value.storage[12], closeTo(-80, 1));
    await tester.tapAt(tap);
    await tester.pump(const Duration(milliseconds: 70));
    await tester.tapAt(tap);
    await tester.pumpAndSettle();
    expect(_transform(tester).value.getMaxScaleOnAxis(), 1);
  });
}
