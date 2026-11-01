import 'dart:async';
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
  testWidgets('同一可见楼层像素抖动不重下已拒绝的相邻页', (tester) async {
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
    prefetch.update(
      ids: List.generate(100, (i) => '$i'),
      ready: true,
      hasBefore: false,
      hasAfter: true,
      load: (_) async {
        count++;
      },
    );
    await tester.pump();
    for (var i = 1; i <= 10; i++) {
      scroll.jumpTo(i.toDouble());
      reading.changed();
      await tester.pump();
    }
    expect(count, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('两侧都接近时按阅读方向，折返拒绝迟到页', (tester) async {
    final scroll = ScrollController();
    final reading = _Reading(scroll)..visibleId = '3';
    var now = Duration.zero;
    final prefetch = DiscussionWindowPrefetch(
      reading: reading,
      isMounted: () => true,
      clock: () => now,
    );
    addTearDown(prefetch.dispose);
    addTearDown(reading.dispose);
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ListView.builder(
          controller: scroll,
          itemExtent: 100,
          itemCount: 20,
          itemBuilder: (_, index) => Text('$index'),
        ),
      ),
    );
    scroll.jumpTo(900);
    reading.changed();
    now += const Duration(milliseconds: 100);
    scroll.jumpTo(1000);
    reading.changed();
    final pending = Completer<void>();
    final requests = <bool>[];
    bool? applied;
    prefetch.update(
      ids: List.generate(20, (i) => '$i'),
      ready: true,
      hasBefore: true,
      hasAfter: true,
      load: (before) async {
        requests.add(before);
        await pending.future;
        applied = prefetch.canApply;
      },
    );
    await tester.pump();
    expect(requests, [false]);
    now += const Duration(milliseconds: 100);
    scroll.jumpTo(800);
    reading.changed();
    expect(prefetch.canApply, isFalse);
    // 主动定位接管后不再调度下一次相邻读取。
    prefetch.update(
      ids: List.generate(20, (i) => '$i'),
      ready: false,
      hasBefore: true,
      hasAfter: true,
      load: (_) async {},
    );
    pending.complete();
    await tester.pump();
    expect(applied, isFalse);
    expect(requests, [false]);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('快速阅读提前到四屏但不越界，慢响应退回两屏', (tester) async {
    final scroll = ScrollController();
    final reading = _Reading(scroll)..visibleId = '60';
    var now = Duration.zero;
    final prefetch = DiscussionWindowPrefetch(
      reading: reading,
      isMounted: () => true,
      clock: () => now,
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
    final pending = Completer<void>();
    prefetch.update(
      ids: List.generate(100, (i) => '$i'),
      ready: true,
      hasBefore: false,
      hasAfter: true,
      load: (_) async {
        count++;
        await pending.future;
      },
    );
    await tester.pump();
    scroll.jumpTo(6500);
    reading.changed();
    now += const Duration(milliseconds: 50);
    scroll.jumpTo(6999);
    reading.changed();
    await tester.pump();
    expect(count, 0);
    now += const Duration(microseconds: 100);
    scroll.jumpTo(7000);
    reading.changed();
    await tester.pump();
    expect(count, 1);
    now += const Duration(seconds: 3);
    pending.complete();
    await tester.pump();
    reading.visibleId = '61';
    now += const Duration(milliseconds: 50);
    scroll.jumpTo(7100);
    reading.changed();
    await tester.pump();
    expect(count, 1);
    now += const Duration(milliseconds: 50);
    scroll.jumpTo(8200);
    reading.changed();
    await tester.pump();
    expect(count, 2);
    await tester.pumpWidget(const SizedBox.shrink());
  });
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
