import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_scroll_policy.dart';

void main() {
  testWidgets('目标前继续加载内容后仍保持目标可见', (tester) async {
    final harnessKey = GlobalKey<_RevealHarnessState>();
    await tester.pumpWidget(MaterialApp(home: _RevealHarness(key: harnessKey)));
    await tester.pumpAndSettle();

    final target = find.byKey(const Key('reveal-target'));
    final initialTop = tester.getTopLeft(target).dy;

    harnessKey.currentState!.insertBeforeTarget();
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(target).dy, closeTo(initialTop, 1));
  });

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
  final _controller = ScrollController();
  final _targetKey = GlobalKey();
  final _reveal = DiscussionTargetRevealCoordinator();
  final _items = [
    for (var index = 0; index < 45; index += 1) 'item-$index',
    'target',
    for (var index = 45; index < 59; index += 1) 'item-$index',
  ];
  var _scope = 1;

  double get offset => _controller.offset;

  void relayout() => setState(() => _items.add('tail-${_items.length}'));

  void insertBeforeTarget() => setState(() {
    _items.insertAll(_items.indexOf('target'), [
      for (var index = 0; index < 20; index += 1) 'inserted-$index',
    ]);
  });

  void changeScope() => setState(() => _scope += 1);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetIndex = _items.indexOf('target');
    _reveal.schedule(
      targetId: 'target',
      scopeSignature: 'scope-$_scope',
      contentSignature: 'items-${_items.length}:$targetIndex',
      targetIndex: targetIndex,
      itemCount: _items.length,
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
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final id = _items[index];
              final isTarget = id == 'target';
              return DiscussionKeepAlive(
                key: ValueKey('reveal-item-$id'),
                child: SizedBox(
                  key: isTarget ? _targetKey : null,
                  child: Text(
                    '第 $index 项',
                    key: isTarget ? const Key('reveal-target') : null,
                  ),
                ),
              );
            },
            findChildIndexCallback: (key) {
              final value = key is ValueKey<String> ? key.value : null;
              if (value == null || !value.startsWith('reveal-item-')) {
                return null;
              }
              final index = _items.indexOf(value.substring(12));
              return index < 0 ? null : index;
            },
          ),
        ),
      ),
    );
  }
}
