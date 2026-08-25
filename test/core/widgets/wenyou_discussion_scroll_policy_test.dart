import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_scroll_policy.dart';

void main() {
  testWidgets('懒列表目标可自动显露，用户拖动后布局变化不再拉回', (tester) async {
    final harnessKey = GlobalKey<_RevealHarnessState>();
    await tester.pumpWidget(MaterialApp(home: _RevealHarness(key: harnessKey)));
    await tester.pumpAndSettle();

    final target = find.byKey(const Key('reveal-target'));
    expect(target, findsOneWidget);
    expect(tester.getRect(target).top, lessThan(600));
    final locatedOffset = harnessKey.currentState!.offset;
    expect(locatedOffset, greaterThan(1000));

    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    final userOffset = harnessKey.currentState!.offset;
    expect(userOffset, lessThan(locatedOffset));

    harnessKey.currentState!.relayout();
    await tester.pumpAndSettle();
    expect(harnessKey.currentState!.offset, closeTo(userOffset, 1));

    harnessKey.currentState!.changeScope();
    await tester.pumpAndSettle();
    expect(target, findsOneWidget);
    expect(tester.getRect(target).top, lessThan(600));
  });
}

class _RevealHarness extends StatefulWidget {
  const _RevealHarness({super.key});

  @override
  State<_RevealHarness> createState() => _RevealHarnessState();
}

class _RevealHarnessState extends State<_RevealHarness> {
  static const _targetIndex = 45;
  final _controller = ScrollController();
  final _targetKey = GlobalKey();
  final _reveal = DiscussionTargetRevealCoordinator();
  var _itemCount = 60;
  var _scope = 1;

  double get offset => _controller.offset;

  void relayout() => setState(() => _itemCount += 1);

  void changeScope() => setState(() => _scope += 1);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _reveal.schedule(
      targetId: 'item-$_targetIndex',
      scopeSignature: 'scope-$_scope',
      contentSignature: 'items-$_itemCount',
      targetIndex: _targetIndex,
      itemCount: _itemCount,
      ready: true,
      targetKey: _targetKey,
      scrollController: _controller,
      isMounted: () => mounted,
      requestRebuild: () => setState(() {}),
    );
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: _reveal.handleUserScroll,
        child: NotificationListener<ScrollMetricsNotification>(
          onNotification: (_) => _reveal.handleLayoutChange(
            isMounted: () => mounted,
            requestRebuild: () => setState(() {}),
          ),
          child: ListView.builder(
            controller: _controller,
            itemExtent: 80,
            itemCount: _itemCount,
            itemBuilder: (context, index) => SizedBox(
              key: index == _targetIndex ? _targetKey : null,
              child: Text(
                '第 $index 项',
                key: index == _targetIndex ? const Key('reveal-target') : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
