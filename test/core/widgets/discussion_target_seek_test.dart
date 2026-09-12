import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_scroll_policy.dart';

void main() {
  for (final headerHeight in [0.0, 12000.0]) {
    testWidgets('长短混排跨越多屏并往返缓存目标，前置正文 $headerHeight', (tester) async {
      final key = GlobalKey<_SeekHarnessState>();
      await tester.pumpWidget(
        MaterialApp(
          home: _SeekHarness(key: key, headerHeight: headerHeight),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(key.currentState!.targetKey)).top, 0);

      key.currentState!.select(5);
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(key.currentState!.targetKey)).top, 0);

      key.currentState!.select(95);
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(key.currentState!.targetKey)).top, 0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('远处目标尚未显露时用户拖动可停止定位', (tester) async {
    final key = GlobalKey<_SeekHarnessState>();
    await tester.pumpWidget(MaterialApp(home: _SeekHarness(key: key)));
    await tester.pump();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -100));
    await tester.pumpAndSettle();
    final offset = key.currentState!.controller.offset;
    key.currentState!.rebuild();
    await tester.pumpAndSettle();
    expect(key.currentState!.controller.offset, offset);
    expect(find.byKey(key.currentState!.targetKey), findsNothing);
  });
}

class _SeekHarness extends StatefulWidget {
  const _SeekHarness({super.key, this.headerHeight = 0});

  final double headerHeight;

  @override
  State<_SeekHarness> createState() => _SeekHarnessState();
}

class _SeekHarnessState extends State<_SeekHarness> {
  final controller = ScrollController();
  final targetKey = GlobalKey();
  final listKey = GlobalKey();
  final reveal = DiscussionTargetRevealCoordinator();
  var target = 95;

  void select(int index) => setState(() => target = index);
  void rebuild() => setState(() {});

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    reveal.schedule(
      targetId: '$target',
      scopeSignature: '$target',
      contentSignature: '100',
      targetIndex: target,
      itemCount: 100,
      ready: true,
      targetKey: targetKey,
      itemListKey: listKey,
      scrollController: controller,
      isMounted: () => mounted,
      requestRebuild: rebuild,
    );
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: reveal.handleUserScroll,
        child: NotificationListener<ScrollMetricsNotification>(
          onNotification: (_) => reveal.handleLayoutChange(
            isMounted: () => mounted,
            requestRebuild: rebuild,
          ),
          child: CustomScrollView(
            controller: controller,
            scrollCacheExtent: discussionScrollCacheExtent,
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: widget.headerHeight)),
              SliverList.builder(
                key: listKey,
                itemCount: 100,
                itemBuilder: (context, index) => DiscussionKeepAlive(
                  key: ValueKey(index),
                  child: SizedBox(
                    key: index == target ? targetKey : null,
                    height: index % 3 == 0 ? 2400 : 80,
                    child: Text('作者 $index\n正文'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
