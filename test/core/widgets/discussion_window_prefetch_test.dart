import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_window_prefetch.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';

class _Reading extends ReadingQuickScrollController {
  _Reading(ScrollController controller)
    : super(scrollController: controller, onUserNavigation: () {});

  var dragging = false;
  String? visibleId;

  @override
  bool get isDragging => dragging;

  @override
  ReadingBookmark? get visibleBookmark => visibleId == null
      ? null
      : ReadingBookmark(id: visibleId!, number: 1, offset: 0, scope: 'test');

  void changed() => notifyListeners();
}

void main() {
  testWidgets('远离窗口边缘不预取；靠近边缘一次只请求相邻页', (tester) async {
    final scroll = ScrollController();
    final reading = _Reading(scroll);
    final prefetch = DiscussionWindowPrefetch(
      reading: reading,
      isMounted: () => true,
    );
    addTearDown(prefetch.dispose);
    addTearDown(reading.dispose);
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ListView.builder(
          controller: scroll,
          itemExtent: 100,
          itemCount: 100,
          itemBuilder: (_, index) => Text('$index'),
        ),
      ),
    );
    final requests = <bool>[];
    void configure({required bool ready}) => prefetch.update(
      ids: List.generate(100, (index) => '$index'),
      ready: ready,
      hasBefore: true,
      hasAfter: true,
      load: (before) async {
        requests.add(before);
        configure(ready: false);
      },
    );
    reading.visibleId = '50';
    configure(ready: true);
    await tester.pump();
    expect(requests, isEmpty);
    reading.visibleId = '98';
    reading.changed();
    await tester.pump();
    await tester.pump();
    expect(requests, [false]);
    reading.visibleId = '3';
    configure(ready: true);
    await tester.pump();
    await tester.pump();
    expect(requests, [false, true]);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('选字或编辑保护期间暂停预取，解除保护可恢复', (tester) async {
    final scroll = ScrollController();
    final reading = _Reading(scroll)..visibleId = '99';
    var protected = true;
    final prefetch = DiscussionWindowPrefetch(
      reading: reading,
      isMounted: () => true,
      canMutate: () => !protected,
    );
    addTearDown(prefetch.dispose);
    addTearDown(reading.dispose);
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ListView.builder(
          controller: scroll,
          itemExtent: 100,
          itemCount: 100,
          itemBuilder: (_, index) => Text('$index'),
        ),
      ),
    );
    var requests = 0;
    prefetch.update(
      ids: List.generate(100, (index) => '$index'),
      ready: true,
      hasBefore: false,
      hasAfter: true,
      load: (_) async {
        requests++;
      },
    );
    await tester.pump();
    expect(requests, 0);
    expect(prefetch.canApply, isFalse);
    protected = false;
    prefetch.resume();
    await tester.pump();
    expect(requests, 1);
    expect(prefetch.canApply, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('可见条目保护拒绝裁剪时不循环请求同一页', (tester) async {
    final scroll = ScrollController();
    final reading = _Reading(scroll)..visibleId = '99';
    final prefetch = DiscussionWindowPrefetch(
      reading: reading,
      isMounted: () => true,
    );
    addTearDown(prefetch.dispose);
    addTearDown(reading.dispose);
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ListView.builder(
          controller: scroll,
          itemExtent: 100,
          itemCount: 100,
          itemBuilder: (_, index) => Text('$index'),
        ),
      ),
    );
    var count = 0;
    void update() => prefetch.update(
      ids: List.generate(100, (index) => '$index'),
      ready: true,
      hasBefore: false,
      hasAfter: true,
      load: (_) async {
        count++;
      },
    );
    update();
    await tester.pump();
    await tester.pump();
    update();
    await tester.pump();
    await tester.pump();
    expect(count, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('按住滑块冻结预取和迟到窗口应用，松手后恢复', (tester) async {
    final scroll = ScrollController();
    final reading = _Reading(scroll)..dragging = true;
    final prefetch = DiscussionWindowPrefetch(
      reading: reading,
      isMounted: () => true,
    );
    addTearDown(prefetch.dispose);
    addTearDown(reading.dispose);
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ListView.builder(
          controller: scroll,
          itemExtent: 100,
          itemCount: 100,
          itemBuilder: (_, index) => Text('$index'),
        ),
      ),
    );
    var requests = 0;
    reading.visibleId = '99';
    prefetch.update(
      ids: List.generate(100, (index) => '$index'),
      ready: true,
      hasBefore: false,
      hasAfter: true,
      load: (_) async {
        requests++;
      },
    );
    await tester.pump();
    expect(requests, 0);
    expect(prefetch.canApply, isFalse);
    reading.dragging = false;
    reading.changed();
    await tester.pump();
    expect(requests, 1);
    expect(prefetch.canApply, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
