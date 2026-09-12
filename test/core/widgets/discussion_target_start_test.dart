import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_scroll_policy.dart';

void main() {
  for (final pinnedHeight in [0.0, 48.0]) {
    for (final targetHeight in [80.0, 600.0, 1800.0]) {
      for (final tailHeight in [0.0, 1200.0]) {
        testWidgets('目标开头对齐：吸顶 $pinnedHeight，正文 $targetHeight，后续 $tailHeight', (
          tester,
        ) async {
          final key = GlobalKey<_StartHarnessState>();
          await tester.pumpWidget(
            MaterialApp(
              home: _StartHarness(
                key: key,
                pinnedHeight: pinnedHeight,
                targetHeight: targetHeight,
                tailHeight: tailHeight,
              ),
            ),
          );
          await tester.pumpAndSettle();

          final state = key.currentState!;
          final viewport = tester.getRect(find.byType(CustomScrollView));
          final target = tester.getRect(find.byKey(state.targetKey));
          final readingTop = viewport.top + pinnedHeight;
          final fitsAtEnd =
              targetHeight + tailHeight < viewport.height - pinnedHeight;
          if (fitsAtEnd) {
            // 最后一层很短时保留自然列表底部，不制造额外尾部空白。
            expect(target.top, greaterThanOrEqualTo(readingTop));
            expect(target.bottom, closeTo(viewport.bottom, 1));
            expect(
              state.controller.offset,
              closeTo(state.controller.position.maxScrollExtent, 1),
            );
          } else {
            expect(target.top, closeTo(readingTop, 1));
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('整页不足一屏时不强行滚动', (tester) async {
    final key = GlobalKey<_StartHarnessState>();
    await tester.pumpWidget(
      MaterialApp(
        home: _StartHarness(key: key, beforeHeight: 80, targetHeight: 80),
      ),
    );
    await tester.pumpAndSettle();
    expect(key.currentState!.controller.offset, 0);
    expect(tester.getRect(find.byKey(key.currentState!.targetKey)).top, 80);
  });

  testWidgets('图片撑高目标及前方内容、窗口缩放后仍从开头阅读', (tester) async {
    final key = GlobalKey<_StartHarnessState>();
    await tester.pumpWidget(
      MaterialApp(
        home: _StartHarness(key: key, targetHeight: 80, tailHeight: 1200),
      ),
    );
    await tester.pumpAndSettle();
    key.currentState!.growContent();
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(key.currentState!.targetKey)).top, 0);
    await tester.binding.setSurfaceSize(const Size(360, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(key.currentState!.targetKey)).top, 0);
  });
}

class _StartHarness extends StatefulWidget {
  const _StartHarness({
    super.key,
    this.beforeHeight = 1200,
    this.pinnedHeight = 0,
    this.targetHeight = 80,
    this.tailHeight = 0,
  });

  final double beforeHeight;
  final double pinnedHeight;
  final double targetHeight;
  final double tailHeight;

  @override
  State<_StartHarness> createState() => _StartHarnessState();
}

class _StartHarnessState extends State<_StartHarness> {
  final controller = ScrollController();
  final targetKey = GlobalKey();
  final itemListKey = GlobalKey();
  final reveal = DiscussionTargetRevealCoordinator();
  double growth = 0;

  void growContent() => setState(() => growth = 1600);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    reveal.schedule(
      targetId: 'target',
      scopeSignature: 'scope',
      contentSignature: 'content',
      targetIndex: 1,
      itemCount: 3,
      ready: true,
      targetKey: targetKey,
      itemListKey: itemListKey,
      scrollController: controller,
      isMounted: () => mounted,
      requestRebuild: () => setState(() {}),
    );
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: reveal.handleUserScroll,
        child: NotificationListener<ScrollMetricsNotification>(
          onNotification: (_) => reveal.handleLayoutChange(
            isMounted: () => mounted,
            requestRebuild: () => setState(() {}),
          ),
          child: CustomScrollView(
            controller: controller,
            slivers: [
              if (widget.pinnedHeight > 0)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedHeader(widget.pinnedHeight),
                ),
              SliverList.list(
                key: itemListKey,
                children: [
                  SizedBox(height: widget.beforeHeight + growth),
                  SizedBox(
                    key: targetKey,
                    height: widget.targetHeight + growth,
                    child: const Align(
                      alignment: Alignment.topLeft,
                      child: Text('作者 · 楼层号\n正文开头'),
                    ),
                  ),
                  SizedBox(height: widget.tailHeight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinnedHeader extends SliverPersistentHeaderDelegate {
  _PinnedHeader(this.height);

  final double height;
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => const SizedBox.expand(
    child: ColoredBox(color: Colors.white, child: Text('子贴选择器')),
  );
  @override
  bool shouldRebuild(_PinnedHeader oldDelegate) => oldDelegate.height != height;
}
