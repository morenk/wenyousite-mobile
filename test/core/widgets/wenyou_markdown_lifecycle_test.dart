import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph, ScrollCacheExtent;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_scroll_policy.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('纯文字正文绕过 Markdown 语法树但仍可选择和点击', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouMarkdown(
            data: '第一段纯文字\n仍是纯文字',
            onTapText: () => taps += 1,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('wenyou-markdown-plain-text')), findsOneWidget);
    expect(find.byType(MarkdownBody), findsNothing);
    expect(find.byType(SelectionArea), findsOneWidget);
    await tester.tap(find.text('第一段纯文字\n仍是纯文字'));
    expect(taps, 1);
  });

  testWidgets('格式、提及、骰子和图片保持完整 Markdown 解析路径', (tester) async {
    for (final data in const [
      '**加粗正文**',
      '[@温柔测试员](/users/user-1)',
      '[[dice:v1:00000000-0000-4000-8000-000000000001:1d6]]',
      '![图片](data:text/plain,blocked)',
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: WenyouMarkdown(data: data)),
        ),
      );

      expect(find.byType(MarkdownBody), findsOneWidget, reason: data);
      expect(
        tester.widget<MarkdownBody>(find.byType(MarkdownBody)).selectable,
        isFalse,
        reason: data,
      );
      expect(find.byType(SelectionArea), findsOneWidget, reason: data);
      expect(
        find.byKey(const Key('wenyou-markdown-plain-text')),
        findsNothing,
        reason: data,
      );
    }
  });

  testWidgets('父组件刷新时复用已构建 Markdown 且回调保持最新', (tester) async {
    late StateSetter rebuildHost;
    var callbackVersion = 1;
    var tappedVersion = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuildHost = setState;
              return WenyouMarkdown(
                data: '**已解析正文**',
                onTapText: () => tappedVersion = callbackVersion,
              );
            },
          ),
        ),
      ),
    );

    final firstBody = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    rebuildHost(() => callbackVersion = 2);
    await tester.pump();
    final secondBody = tester.widget<MarkdownBody>(find.byType(MarkdownBody));

    expect(identical(firstBody, secondBody), isTrue);
    await tester.tap(find.text('已解析正文'));
    expect(tappedVersion, 2);
  });

  testWidgets('纯文字与格式正文区域的纵向拖动交给父滚动页', (tester) async {
    final fixtures = [
      List.filled(36, '纯文字正文用于验证纵向拖动。').join('\n\n'),
      List.filled(36, '**格式正文用于验证纵向拖动。**').join('\n\n'),
    ];

    for (final data in fixtures) {
      final controller = ScrollController(keepScrollOffset: false);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ListView(
              controller: controller,
              children: [
                WenyouMarkdown(
                  key: const Key('scrollable-markdown-body'),
                  data: data,
                ),
                const SizedBox(height: 800),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      final start =
          tester.getTopLeft(find.byKey(const Key('scrollable-markdown-body'))) +
          const Offset(80, 120);
      await tester.dragFrom(start, const Offset(0, -180));
      await tester.pumpAndSettle();

      expect(controller.offset, greaterThan(0), reason: data);
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    }
  });

  testWidgets('长按拖动选择可跨越纯文字与格式正文段落', (tester) async {
    for (final data in const [
      'First paragraph words\n\nSecond paragraph words',
      '**First paragraph words**\n\nSecond paragraph words',
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: WenyouMarkdown(data: data)),
        ),
      );
      await tester.pumpAndSettle();

      final paragraphs = tester
          .renderObjectList<RenderParagraph>(
            find.descendant(
              of: find.byType(WenyouMarkdown),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is RichText &&
                    (widget.text.toPlainText().startsWith('First') ||
                        widget.text.toPlainText().startsWith('Second')),
              ),
            ),
          )
          .toList();
      expect(paragraphs, hasLength(2), reason: data);
      final gesture = await tester.startGesture(
        _textOffsetToPosition(paragraphs.first, 8),
      );
      addTearDown(gesture.removePointer);
      await tester.pump(const Duration(milliseconds: 600));

      expect(paragraphs.first.selections, isNotEmpty, reason: data);
      await gesture.moveTo(_textOffsetToPosition(paragraphs.last, 8));
      await tester.pump();

      expect(
        paragraphs.first.selections.single.isCollapsed,
        isFalse,
        reason: data,
      );
      expect(
        paragraphs.last.selections.single.isCollapsed,
        isFalse,
        reason: data,
      );
      await gesture.up();
    }
  });

  testWidgets('长讨论楼层滑出缓存邻域后仍驻留且回来不重建', (tester) async {
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
            scrollCacheExtent: const ScrollCacheExtent.viewport(2.0),
            itemExtent: 160,
            itemCount: 60,
            itemBuilder: (context, index) => DiscussionKeepAlive(
              child: _LifecycleProbe(
                key: ValueKey('markdown-$index'),
                index: index,
                onBuild: () => builds.update(
                  index,
                  (count) => count + 1,
                  ifAbsent: () => 1,
                ),
                onDispose: () => disposals.add(index),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('markdown-0')), findsOneWidget);

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();

    expect(disposals, isNot(contains(0)));
    expect(
      find.byKey(const ValueKey('markdown-0'), skipOffstage: false),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('markdown-59')), findsOneWidget);

    controller.jumpTo(0);
    await tester.pump();

    expect(find.byKey(const ValueKey('markdown-0')), findsOneWidget);
    expect(builds[0], 1);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(disposals, contains(0));
  });
}

Offset _textOffsetToPosition(RenderParagraph paragraph, int offset) {
  const caret = Rect.fromLTWH(0, 0, 2, 20);
  final localOffset =
      paragraph.getOffsetForCaret(TextPosition(offset: offset), caret) +
      Offset(0, paragraph.preferredLineHeight - 2);
  return paragraph.localToGlobal(localOffset);
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
