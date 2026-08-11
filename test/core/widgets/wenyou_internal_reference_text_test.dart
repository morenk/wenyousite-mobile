import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
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

    expect(find.text('参见 设定 A。', findRichText: true), findsOneWidget);
    final selectable = tester.widget<SelectableText>(
      find.byType(SelectableText),
    );
    final portal = selectable.textSpan!.children!
        .whereType<TextSpan>()
        .singleWhere((span) => span.text == '设定 A');
    (portal.recognizer! as TapGestureRecognizer).onTap!();
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

    expect(find.text(source, findRichText: true), findsOneWidget);
    final text = tester.widget<Text>(find.byType(Text));
    final rootSpan = text.textSpan! as TextSpan;
    expect(
      rootSpan.children!.whereType<TextSpan>().every(
        (span) => span.recognizer == null,
      ),
      isTrue,
    );
  });
}
