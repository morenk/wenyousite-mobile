import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_scroll_policy.dart';

void main() {
  testWidgets('离开长段落后字号变化，返回书签恢复同一字符', (tester) async {
    final key = GlobalKey<_ArticleState>();
    await tester.pumpWidget(MaterialApp(home: _Article(key: key)));
    final state = key.currentState!;
    state.scroll.jumpTo(900);
    await tester.pumpAndSettle();
    final bookmark = state.quick.captureBookmark()!;
    final position = bookmark.textAnchor!.position;
    double caretY() => state.paragraph
        .localToGlobal(state.paragraph.getOffsetForCaret(position, Rect.zero))
        .dy;
    final before = caretY();
    state.scroll.jumpTo(2000);
    await tester.pumpAndSettle();
    state.change(fontChange: true);
    await tester.pumpAndSettle();
    alignDiscussionTarget(
      state.anchorKey.currentContext!,
      state.scroll,
      offset: state.quick.offsetForBookmark(bookmark),
    );
    await tester.pumpAndSettle();
    expect(caretY(), closeTo(before, 1));
    expect(tester.takeException(), isNull);
  });

  for (final fontChange in [false, true]) {
    testWidgets('长楼层自动保留可见字符，fontChange=$fontChange', (tester) async {
      final key = GlobalKey<_ArticleState>();
      await tester.pumpWidget(MaterialApp(home: _Article(key: key)));
      final state = key.currentState!;
      state.scroll.jumpTo(900);
      await tester.pumpAndSettle();
      final paragraph = state.paragraph;
      final viewport = tester.getTopLeft(find.byKey(state.viewportKey));
      final position = paragraph.getPositionForOffset(
        paragraph.globalToLocal(viewport + const Offset(1, 10)),
      );
      double caretY() => paragraph
          .localToGlobal(paragraph.getOffsetForCaret(position, Rect.zero))
          .dy;
      final before = caretY();
      state.change(fontChange: fontChange);
      await tester.pumpAndSettle();
      expect(caretY(), closeTo(before, 1));
      expect(state.quick.captureBookmark()?.id, 'long-floor');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('手指拖动时布局变化不会抢回旧阅读位置', (tester) async {
    final key = GlobalKey<_ArticleState>();
    await tester.pumpWidget(MaterialApp(home: _Article(key: key)));
    final state = key.currentState!;
    state.scroll.jumpTo(900);
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(const Offset(150, 350));
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();
    final dragged = state.scroll.offset;
    state.change(fontChange: false);
    await tester.pump();
    expect(state.scroll.offset, closeTo(dragged, 1));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

class _Article extends StatefulWidget {
  const _Article({super.key});
  @override
  State<_Article> createState() => _ArticleState();
}

class _ArticleState extends State<_Article> {
  final scroll = ScrollController();
  final textKey = GlobalKey();
  final anchorKey = GlobalKey();
  final viewportKey = GlobalKey();
  late final quick = ReadingQuickScrollController(
    scrollController: scroll,
    onUserNavigation: () {},
  );
  var imageHeight = 100.0;
  var fontSize = 14.0;
  RenderParagraph get paragraph =>
      textKey.currentContext!.findRenderObject()! as RenderParagraph;
  void change({required bool fontChange}) => setState(() {
    if (fontChange) {
      fontSize = 20;
    } else {
      imageHeight = 400;
    }
  });
  @override
  void dispose() {
    quick.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    quick.synchronize(
      scope: 'article',
      enabled: true,
      contentRevision: 'same-source',
    );
    return Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          key: viewportKey,
          width: 360,
          height: 500,
          child: ReadingProgressViewport(
            controller: quick,
            child: SingleChildScrollView(
              controller: scroll,
              physics: ReadingQuickScrollPhysics(controller: quick),
              child: ReadingPositionAnchor(
                key: anchorKey,
                controller: quick,
                postId: 'long-floor',
                number: 1,
                label: '#1',
                child: Column(
                  children: [
                    SizedBox(height: imageHeight),
                    Text(
                      List.generate(800, (i) => '段内编号$i 保留正在阅读的字符。').join(' '),
                      key: textKey,
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
