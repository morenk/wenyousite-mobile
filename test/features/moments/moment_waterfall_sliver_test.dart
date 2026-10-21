import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_pagination.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_waterfall_sliver.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final columns in [1, 2]) {
    testWidgets('$columns 列重排保留条目状态、回调和跨列 footer', (tester) async {
      var ids = ['a', 'b', 'c'];
      String? selected;
      Future<void> pump() => tester.pumpWidget(
        _app(
          MomentWaterfallSliver(
            columns: columns,
            itemKeys: [for (final id in ids) ValueKey(id)],
            itemBuilder: (context, index) => _StatefulCard(
              id: ids[index],
              onTap: () => selected = ids[index],
            ),
            footerKey: const Key('footer'),
            footer: const SizedBox(height: 60, child: Text('已经到底了')),
          ),
        ),
      );
      await pump();
      await tester.tap(find.text('b:0'));
      await tester.pump();
      expect(selected, 'b');
      expect(find.text('b:1'), findsOneWidget);
      ids = ['c', 'b', 'a', 'd'];
      await pump();
      await tester.pumpAndSettle();
      expect(find.text('b:1'), findsOneWidget);
      expect(find.text('c:0'), findsOneWidget);
      final first = tester.getRect(find.byKey(const ValueKey('c')));
      final second = tester.getRect(find.byKey(const ValueKey('b')));
      final footer = tester.getRect(find.byKey(const Key('footer')));
      expect(footer.left, first.left);
      expect(
        footer.width,
        closeTo(columns == 1 ? first.width : first.width * 2 + 8, 0.1),
      );
      expect(
        columns == 1 ? second.top > first.bottom : second.left > first.right,
        isTrue,
      );
      for (final id in ids) {
        expect(
          footer.top,
          greaterThanOrEqualTo(
            tester.getBottomRight(find.byKey(ValueKey(id))).dy,
          ),
        );
      }
      ids = ['b', 'a'];
      await pump();
      expect(find.text('b:1'), findsOneWidget);
      expect(find.text('c:0'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [320, 360]) {
    for (final dark in [false, true]) {
      final name = '${width}_${dark ? 'dark' : 'light'}';
      testWidgets('瀑布流 $name 双列大字号分页与加载骨架', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width.toDouble(), 900);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          _app(
            MomentWaterfallSliver(
              itemKeys: const [Key('a'), Key('b')],
              itemBuilder: (context, index) =>
                  _StatefulCard(id: index == 0 ? '动态甲' : '动态乙', onTap: () {}),
              footerKey: const Key('footer'),
              footer: WenyouPaginationFooter(
                hasMore: true,
                isLoading: false,
                failure: const ApiFailure(userMessage: '加载失败，请稍后重试。'),
                onLoadMore: () {},
              ),
            ),
            dark: dark,
            scale: 2,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byKey(const Key('preview')),
          matchesGoldenFile('goldens/waterfall_retry_$name.png'),
        );
        await tester.pumpWidget(
          _app(
            const MomentWaterfallLoadingSliver(label: '正在加载动态收藏'),
            dark: dark,
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.bySemanticsLabel('正在加载动态收藏'), findsNWidgets(4));
        await expectLater(
          find.byKey(const Key('preview')),
          matchesGoldenFile('goldens/waterfall_loading_$name.png'),
        );
      });
    }
  }
}

Widget _app(Widget sliver, {bool dark = false, double scale = 1}) =>
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: RepaintBoundary(
        key: const Key('preview'),
        child: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: CustomScrollView(slivers: [sliver]),
          ),
        ),
      ),
    );

class _StatefulCard extends StatefulWidget {
  const _StatefulCard({required this.id, required this.onTap});
  final String id;
  final VoidCallback onTap;
  @override
  State<_StatefulCard> createState() => _StatefulCardState();
}

class _StatefulCardState extends State<_StatefulCard> {
  var count = 0;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: TextButton(
        onPressed: () {
          setState(() => count++);
          widget.onTap();
        },
        child: Text('${widget.id}:$count'),
      ),
    ),
  );
}
