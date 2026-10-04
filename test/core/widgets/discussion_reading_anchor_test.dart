import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_sliver_list.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';

void main() {
  testWidgets('变高条目前插与裁剪保留可见 ID 和条目内位置', (tester) async {
    final key = GlobalKey<_HarnessState>();
    await tester.pumpWidget(MaterialApp(home: _Harness(key: key)));
    final state = key.currentState!;
    state.scroll.jumpTo(1300);
    await tester.pumpAndSettle();
    final bookmark = state.quick.captureBookmark()!;
    state.prepend();
    await tester.pumpAndSettle();
    final prepended = state.quick.captureBookmark()!;
    expect(prepended.id, bookmark.id);
    expect(prepended.offset, closeTo(bookmark.offset, 1));
    state.trim();
    await tester.pumpAndSettle();
    final trimmed = state.quick.captureBookmark()!;
    expect(trimmed.id, bookmark.id);
    expect(trimmed.offset, closeTo(bookmark.offset, 1));
    state.growBeforeCurrent();
    await tester.pumpAndSettle();
    expect(state.quick.captureBookmark()!.id, bookmark.id);
    expect(state.quick.captureBookmark()!.offset, closeTo(bookmark.offset, 1));
    state.scroll.jumpTo(state.scroll.offset + 120);
    await tester.pumpAndSettle();
    expect(state.quick.captureBookmark()!.offset, isNot(bookmark.offset));
  });
}

class _Harness extends StatefulWidget {
  const _Harness({super.key});

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  final scroll = ScrollController();
  late final quick = ReadingQuickScrollController(
    scrollController: scroll,
    onUserNavigation: () {},
  );
  var rows = List.generate(30, (index) => index + 21);
  var growth = 0.0;

  void growBeforeCurrent() {
    quick.preserveVisiblePosition();
    setState(() => growth = 300);
  }

  void prepend() {
    quick.preserveVisiblePosition();
    setState(() => rows = [...List.generate(20, (i) => i + 1), ...rows]);
  }

  void trim() {
    quick.preserveVisiblePosition();
    setState(() => rows = rows.skip(20).toList());
  }

  @override
  void dispose() {
    quick.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    quick.synchronize(scope: 'test', enabled: true, contentRevision: rows);
    return Scaffold(
      body: ReadingProgressViewport(
        controller: quick,
        child: CustomScrollView(
          controller: scroll,
          physics: ReadingQuickScrollPhysics(controller: quick),
          slivers: [
            DiscussionSliverList(
              scope: 'test',
              delegate: SliverChildBuilderDelegate(
                childCount: rows.length,
                findChildIndexCallback: (key) =>
                    rows.indexOf((key as ValueKey<int>).value),
                (context, index) {
                  final number = rows[index];
                  return ReadingPositionAnchor(
                    key: ValueKey(number),
                    controller: quick,
                    label: '#$number',
                    number: number,
                    postId: 'post-$number',
                    child: SizedBox(
                      height:
                          (number.isEven ? 95 : 340) +
                          (number == 25 ? growth : 0),
                      child: Text('条目 $number'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
