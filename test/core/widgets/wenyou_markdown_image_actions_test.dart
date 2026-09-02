import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('正文图片保持纯净并从原图页按需收藏表情', (tester) async {
    const url = 'https://cdn.example.com/story.png';
    var saveCalls = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: WenyouMarkdown(
              data: '![雾港地图]($url)',
              onAddImageToStickers: (uri) async {
                expect(uri.toString(), url);
                saveCalls += 1;
                return '已添加到表情收藏。';
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final image = find.byKey(const ValueKey('markdown-image-$url'));
    expect(image, findsOneWidget);
    expect(find.byTooltip('添加到表情收藏'), findsNothing);
    expect(find.byKey(const Key('content-image-actions')), findsNothing);
    expect(
      find.ancestor(of: image, matching: find.byType(Stack)),
      findsNothing,
    );

    await tester.tap(image);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('content-image-viewer')), findsOneWidget);
    expect(find.text('雾港地图'), findsOneWidget);
    expect(find.byKey(const Key('content-image-actions')), findsOneWidget);
    await tester.tap(find.byKey(const Key('content-image-actions')));
    await tester.pumpAndSettle();
    expect(find.text('添加到表情收藏'), findsOneWidget);

    await tester.tap(find.text('添加到表情收藏'));
    await tester.pumpAndSettle();

    expect(saveCalls, 1);
    expect(find.text('已添加到表情收藏。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('纯文本点击回调不吞图片自身交互', (tester) async {
    const url = 'https://cdn.example.com/story.png';
    var textTapCalls = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: WenyouMarkdown(
              data: '点击正文\n\n![雾港地图]($url)',
              onTapText: () => textTapCalls += 1,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.textContaining('点击正文', findRichText: true));
    await tester.pump();
    expect(textTapCalls, 1);

    await tester.tap(find.byKey(const ValueKey('markdown-image-$url')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('content-image-viewer')), findsOneWidget);
    expect(textTapCalls, 1);
  });

  testWidgets('游客正文图片仍可查看原图且没有收藏入口', (tester) async {
    const url = 'https://cdn.example.com/story.png';
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: WenyouMarkdown(data: '![雾港地图]($url)')),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('markdown-image-$url')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('content-image-viewer')), findsOneWidget);
    expect(find.byKey(const Key('content-image-actions')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
