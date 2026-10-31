import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_target_cover.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_target_loading.dart';

void main() {
  testWidgets('性能回归：定位进度动画不反复绘制静态骨架', (tester) async {
    var paints = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomPaint(
            foregroundPainter: _CountingPainter(() => paints++),
            child: const DiscussionTargetLoading(label: '正在定位目标楼层'),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 20));
    final initial = paints;
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(initial, greaterThan(0));
    expect(paints, initial);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('目标已读后移出有限窗口，不重新盖住正文或追回旧目标', (tester) async {
    final targetKey = GlobalKey();
    final itemListKey = GlobalKey();
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    var requests = 0;
    Widget app(bool present) => MaterialApp(
      home: Scaffold(
        body: DiscussionTargetCover(
          scope: 'same-target',
          targetId: 'target',
          loadingLabel: '正在定位目标楼层',
          revealedLabel: '已定位到目标楼层',
          targetKey: targetKey,
          itemListKey: itemListKey,
          scrollController: scrollController,
          targetIndex: present ? 0 : -1,
          itemCount: 3,
          canLocate: true,
          isLoadingPage: false,
          hasMore: true,
          onLoadMore: () => requests++,
          onRetry: () {},
          onBack: () {},
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverList.list(
                key: itemListKey,
                children: [
                  SizedBox(
                    key: present ? targetKey : null,
                    height: 200,
                    child: Text(present ? '目标' : '后来读到的内容'),
                  ),
                  const SizedBox(height: 500),
                  const SizedBox(height: 500),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpWidget(app(true));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('discussion-target-cover')), findsNothing);
    await tester.pumpWidget(app(false));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('discussion-target-cover')), findsNothing);
    expect(requests, 0);
    expect(find.text('后来读到的内容').hitTestable(), findsOneWidget);
  });

  testWidgets('遮罩隔离列表操作与读屏，跨加载阶段五秒显示返回', (tester) async {
    final semantics = tester.ensureSemantics();
    final targetKey = GlobalKey();
    final itemListKey = GlobalKey();
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    var returned = false;

    Widget app({required bool isLoadingPage}) => MaterialApp(
      home: Scaffold(
        body: DiscussionTargetCover(
          scope: 'same-target',
          targetId: 'target',
          loadingLabel: '正在定位目标楼层',
          revealedLabel: '已定位到目标楼层',
          targetKey: targetKey,
          itemListKey: itemListKey,
          scrollController: scrollController,
          targetIndex: -1,
          itemCount: 0,
          canLocate: false,
          isLoadingPage: isLoadingPage,
          hasMore: true,
          onLoadMore: () {},
          onRetry: () {},
          onBack: () => returned = true,
          child: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('被遮住的操作'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(app(isLoadingPage: true));
    expect(find.byKey(const Key('discussion-target-cover')), findsOneWidget);
    expect(find.text('被遮住的操作').hitTestable(), findsNothing);
    expect(find.bySemanticsLabel('被遮住的操作'), findsNothing);
    await tester.pump(const Duration(seconds: 4));
    expect(find.byKey(const Key('discussion-target-slow')), findsNothing);

    await tester.pumpWidget(app(isLoadingPage: false));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const Key('discussion-target-slow')), findsOneWidget);
    await tester.tap(find.byKey(const Key('discussion-target-return')));
    expect(returned, isTrue);
    semantics.dispose();
  });
}

class _CountingPainter extends CustomPainter {
  _CountingPainter(this.onPaint);
  final VoidCallback onPaint;
  @override
  void paint(Canvas canvas, Size size) {
    onPaint();
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _CountingPainter oldDelegate) => false;
}
