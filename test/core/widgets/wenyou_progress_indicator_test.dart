import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_progress_indicator.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_refresh_indicator.dart';

void main() {
  Widget app(Widget child, {bool reduced = true}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduced),
      child: Scaffold(body: child),
    ),
  );

  testWidgets('减少动画暂停不定进度，不伪造百分比；真实进度仍更新', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      app(
        const Column(
          children: [
            WenyouCircularProgressIndicator(semanticsLabel: '加载中'),
            WenyouLinearProgressIndicator(semanticsLabel: '加载内容'),
            WenyouLinearProgressIndicator(value: .42, semanticsLabel: '下载'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      isNull,
    );
    expect(
      tester
          .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .map((w) => w.value),
      [null, .42],
    );
    await tester.pumpWidget(
      app(const WenyouLinearProgressIndicator(value: .8)),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      .8,
    );
    semantics.dispose();
  });

  testWidgets('减少动画下拉刷新保留内容，等待真实请求完成后移除静态提示', (tester) async {
    final pending = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      app(
        WenyouRefreshIndicator(
          onRefresh: () {
            calls++;
            return pending.future;
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [SizedBox(height: 900, child: Text('已有内容'))],
          ),
        ),
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(calls, 1);
    expect(find.text('已有内容'), findsOneWidget);
    expect(find.byType(WenyouLinearProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(WenyouLinearProgressIndicator), findsOneWidget);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.byType(WenyouLinearProgressIndicator), findsNothing);
    expect(find.text('已有内容'), findsOneWidget);
  });
}
