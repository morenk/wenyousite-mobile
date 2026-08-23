import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('长讨论只保留视口邻域 Markdown，返回时可重新构建', (tester) async {
    final controller = ScrollController();
    final builds = <int, int>{};
    final disposals = <int>{};
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ListView.builder(
            controller: controller,
            itemExtent: 160,
            itemCount: 60,
            itemBuilder: (context, index) => _LifecycleProbe(
              key: ValueKey('markdown-$index'),
              index: index,
              onBuild: () =>
                  builds.update(index, (count) => count + 1, ifAbsent: () => 1),
              onDispose: () => disposals.add(index),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('markdown-0')), findsOneWidget);

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();

    expect(disposals, contains(0));
    expect(
      find.byKey(const ValueKey('markdown-0'), skipOffstage: false),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('markdown-59')), findsOneWidget);

    controller.jumpTo(0);
    await tester.pump();

    expect(find.byKey(const ValueKey('markdown-0')), findsOneWidget);
    expect(builds[0], 2);
  });
}

class _LifecycleProbe extends StatefulWidget {
  const _LifecycleProbe({
    required this.index,
    required this.onBuild,
    required this.onDispose,
    super.key,
  });

  final int index;
  final VoidCallback onBuild;
  final VoidCallback onDispose;

  @override
  State<_LifecycleProbe> createState() => _LifecycleProbeState();
}

class _LifecycleProbeState extends State<_LifecycleProbe> {
  @override
  void initState() {
    super.initState();
    widget.onBuild();
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      WenyouMarkdown(data: '第 ${widget.index + 1} 条纯文字正文，用于验证长讨论的懒构建生命周期。');
}
