import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/core/application/thread_font_preference.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_rich_text_style_spec.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';

import '../posts/post_replies_page_test_support.dart';
import '../threads/thread_detail_page_test_support.dart';

void main() {
  testWidgets('主题正文、主楼层与内嵌楼中楼统一变化，页面标题不变', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(ThreadDetailPage));
    final container = ProviderScope.containerOf(context);
    final title = Theme.of(context).textTheme.wenyouPageTitle;
    expect(find.byType(WenyouMarkdown), findsAtLeastNWidgets(3));
    _expectSizes(tester, 16);
    await container
        .read(threadFontPreferenceControllerProvider.notifier)
        .select(ThreadFontPreference.largest);
    await tester.pumpAndSettle();
    _expectSizes(tester, 22);
    expect(Theme.of(context).textTheme.wenyouPageTitle, title);
    expect(tester.takeException(), isNull);
  });

  testWidgets('独立讨论原楼层与全部回复统一变化', (tester) async {
    final container = await postRepliesPageTestPostContainer(
      PostRepliesPageTestFakePostRepository(),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await tester.pumpAndSettle();
    expect(find.byType(WenyouMarkdown), findsAtLeastNWidgets(2));
    _expectSizes(tester, 16);
    await container
        .read(threadFontPreferenceControllerProvider.notifier)
        .select(ThreadFontPreference.small);
    await tester.pumpAndSettle();
    _expectSizes(tester, 14);
  });

  testWidgets('设置不改变其他 Markdown、编辑器基准和系统缩放；富文本保持层级', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container
        .read(threadFontPreferenceControllerProvider.notifier)
        .select(ThreadFontPreference.largest);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: Consumer(
                builder: (context, ref, _) => Column(
                  children: [
                    const WenyouMarkdown(
                      key: Key('other-content'),
                      data: '动态正文',
                    ),
                    WenyouMarkdown(
                      key: const Key('reading-content'),
                      data: '# 标题\n\n正文\n\n> 引用',
                      bodyFontSize: ref.watch(threadBodyFontSizeProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<WenyouMarkdown>(find.byKey(const Key('other-content')))
          .bodyFontSize,
      17,
    );
    final context = tester.element(find.byKey(const Key('reading-content')));
    expect(MediaQuery.textScalerOf(context).scale(22), 44);
    final spec = WenyouRichTextStyleSpec.resolve(context, bodyFontSize: 22);
    expect(spec.body.fontSize, 22);
    expect(spec.quote.fontSize, 22);
    expect(spec.h1.fontSize, greaterThan(spec.body.fontSize!));
    expect(WenyouRichTextStyleSpec.resolve(context).body.fontSize, 17);
  });
}

void _expectSizes(WidgetTester tester, double size) {
  for (final widget in tester.widgetList<WenyouMarkdown>(
    find.byType(WenyouMarkdown),
  )) {
    expect(widget.bodyFontSize, size);
  }
}
