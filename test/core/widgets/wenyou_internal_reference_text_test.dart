import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';

void main() {
  testWidgets('详情纯文本只激活站内传送门并交给应用路由', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(
            body: WenyouInternalReferenceText(
              content:
                  '参见 [设定 A](/threads/cmsewdo0h000x7qv6aa77ll1v?post=cmsewdqcr001a7qv6cy0y38bd)。',
              selectable: true,
            ),
          ),
        ),
        GoRoute(
          path: '/threads/:threadId',
          builder: (_, state) => Scaffold(
            body: Text(
              '目标=${state.pathParameters['threadId']}/${state.uri.queryParameters['post']}',
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.text('参见 '), findsOneWidget);
    expect(find.text('设定 A'), findsOneWidget);
    expect(find.text('。'), findsOneWidget);
    expect(find.byType(SelectionArea), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('站内传送门：设定 A')), findsOneWidget);
    final portal = find.byKey(const ValueKey('wenyou-internal-reference-0'));
    expect(tester.getSize(portal).width, greaterThanOrEqualTo(48));
    expect(tester.getSize(portal).height, greaterThanOrEqualTo(48));
    final icon = tester.widget<WenyouIcon>(
      find.descendant(of: portal, matching: find.byType(WenyouIcon)),
    );
    expect(icon.semanticId, WenyouIconIds.contentInternalReference);
    final label = tester.widget<Text>(find.text('设定 A'));
    expect(label.style?.fontWeight, FontWeight.w600);
    expect(label.style?.decoration, TextDecoration.none);
    final surface = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('wenyou-internal-reference-surface-0')),
    );
    expect(
      (surface.decoration! as BoxDecoration).color,
      tester.element(portal).wenyouTokens.accentedBackground,
    );
    final semantics = tester.getSemantics(portal);
    expect(semantics.getSemanticsData().flagsCollection.isLink, isTrue);

    await tester.tap(portal);
    await tester.pumpAndSettle();

    expect(
      find.text('目标=cmsewdo0h000x7qv6aa77ll1v/cmsewdqcr001a7qv6cy0y38bd'),
      findsOneWidget,
    );
  });

  testWidgets('普通 Markdown 和外链保持完整字面文本', (tester) async {
    const source = '**不是粗体**，外链 [官网](https://example.com)。';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouInternalReferenceText(content: source),
        ),
      ),
    );

    expect(find.text(source), findsOneWidget);
    expect(find.byType(WenyouInternalReferenceChip), findsNothing);
  });

  testWidgets('长传送门在窄屏换行且不截断', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SizedBox(
            width: 160,
            child: WenyouInternalReferenceText(
              content: '[这是一个不会被省略的长传送门名称](/threads/cmsewdo0h000x7qv6aa77ll1v)',
            ),
          ),
        ),
      ),
    );

    final portal = find.byKey(const ValueKey('wenyou-internal-reference-0'));
    expect(tester.getSize(portal).width, lessThanOrEqualTo(160));
    final label = tester.widget<Text>(find.text('这是一个不会被省略的长传送门名称'));
    expect(label.maxLines, isNull);
    expect(label.overflow, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('评论文字同行右侧空白长按转交评论操作', (tester) async {
    var longPresses = 0;
    const text = '短评论';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: WenyouInternalReferenceText(
              content: text,
              selectable: true,
              onLongPressNonText: () => longPresses += 1,
            ),
          ),
        ),
      ),
    );

    final paragraph = tester.renderObject<RenderParagraph>(
      find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText() == text,
      ),
    );
    final area = tester.getRect(find.byType(SelectionArea));
    await tester.longPressAt(
      Offset(
        area.right - 12,
        paragraph.localToGlobal(Offset.zero).dy +
            paragraph.preferredLineHeight / 2,
      ),
    );
    await tester.pump();

    expect(longPresses, 1);
    expect(paragraph.selections, isEmpty);
  });
}
