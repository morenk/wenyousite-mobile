import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';

Future<ReadingScrollHarnessState> mountReadingScroll(
  WidgetTester tester, {
  double width = 360,
  double scale = 1,
  int initialCount = 0,
  bool dark = false,
  bool accessible = false,
  bool reducedMotion = false,
  EdgeInsets gestureInsets = EdgeInsets.zero,
  double height = 800,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final key = GlobalKey<ReadingScrollHarnessState>();
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, height),
          textScaler: TextScaler.linear(scale),
          systemGestureInsets: gestureInsets,
          accessibleNavigation: accessible,
          disableAnimations: reducedMotion,
        ),
        child: ReadingScrollHarness(key: key, initialCount: initialCount),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return key.currentState!;
}

class ReadingScrollHarness extends StatefulWidget {
  const ReadingScrollHarness({super.key, this.initialCount = 0});
  final int initialCount;
  @override
  State<ReadingScrollHarness> createState() => ReadingScrollHarnessState();
}

class ReadingScrollHarnessState extends State<ReadingScrollHarness> {
  final scroll = ScrollController();
  late final quick = ReadingQuickScrollController(
    scrollController: scroll,
    onUserNavigation: () => navigationCount++,
  );
  int navigationCount = 0;
  int buildCount = 0;
  int taps = 0;
  int retries = 0;
  int scope = 0;
  late int count = widget.initialCount;
  double bodyHeight = 7000;
  bool hasMore = false;
  bool loading = false;
  bool failed = false;
  bool imeOpen = false;
  bool carousel = false;

  void openIme() => setState(() => imeOpen = true);
  void showCarousel() => setState(() => carousel = true);
  void shorten() => setState(() {
    bodyHeight = 30;
    count = 0;
  });

  void append() => setState(() => count += 20);
  void growBody() => setState(() => bodyHeight += 3000);
  void changeScope() => setState(() => scope++);
  void setLoading() => setState(() {
    hasMore = true;
    loading = true;
  });
  void failLoading() => setState(() {
    loading = false;
    failed = true;
  });

  @override
  void dispose() {
    quick.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    buildCount++;
    quick.synchronize(scope: scope, enabled: !imeOpen, contentRevision: count);
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(viewInsets: EdgeInsets.only(bottom: imeOpen ? 250 : 0)),
      child: Scaffold(
        appBar: AppBar(),
        body: SizedBox.expand(
          key: const Key('reading-body'),
          child: ReadingProgressViewport(
            controller: quick,
            hasMore: hasMore,
            loading: loading,
            loadFailed: failed,
            child: ListView(
              controller: scroll,
              physics: ReadingQuickScrollPhysics(controller: quick),
              children: [
                if (carousel)
                  SizedBox(
                    height: 150,
                    child: PageView(
                      key: const Key('reading-carousel'),
                      children: const [
                        ColoredBox(color: Colors.blue),
                        ColoredBox(color: Colors.green),
                      ],
                    ),
                  ),
                ReadingPositionAnchor(
                  controller: quick,
                  label: '第 128 楼附近',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => taps++,
                    child: SizedBox(
                      height: bodyHeight,
                      child: const Text('超长楼层正文'),
                    ),
                  ),
                ),
                for (var i = 0; i < count; i++)
                  ReadingPositionAnchor(
                    controller: quick,
                    label: '第 ${300 + i} 楼附近',
                    child: SizedBox(height: 80, child: Text('楼层 $i')),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
