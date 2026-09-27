import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_target_cover.dart';

void main() {
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
