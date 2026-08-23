import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_content_action_menu.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('复制失败保留当前任务并可显式重试', (tester) async {
    var shouldFail = true;
    var attempts = 0;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method != 'Clipboard.setData') return null;
      attempts += 1;
      if (shouldFail) {
        throw PlatformException(code: 'clipboard-unavailable');
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () =>
                  unawaited(copyPostCardValue(context, '正文', '已复制')),
              child: const Text('复制'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('复制'));
    await tester.pumpAndSettle();
    expect(attempts, 1);
    expect(find.text('复制失败'), findsOneWidget);
    expect(find.byKey(const Key('copy-failure-retry')), findsOneWidget);

    shouldFail = false;
    await tester.tap(find.byKey(const Key('copy-failure-retry')));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('复制失败'), findsNothing);
    expect(find.text('已复制'), findsOneWidget);
  });

  testWidgets('帖子操作只保留长按所需动作且不再重复提供回复', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PostCardActionMenu(
            canCopyText: true,
            canEdit: true,
            canDelete: true,
            canReport: true,
            pending: false,
            semanticLabel: '楼层操作',
            actionKeyPrefix: 'content-action-test',
            onSelected: (_) {},
            anchorBuilder: (context, handle) => FilledButton(
              key: const Key('content-action-trigger'),
              onPressed: handle.open,
              child: const Text('打开操作'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('content-action-trigger')));
    await tester.pump();

    expect(find.text('复制内容'), findsOneWidget);
    expect(find.text('复制链接'), findsOneWidget);
    expect(find.text('编辑'), findsOneWidget);
    expect(find.text('删除'), findsOneWidget);
    expect(find.text('举报'), findsOneWidget);
    expect(find.text('回复'), findsNothing);
    expect(find.byKey(const Key('content-action-test-reply')), findsNothing);
  });
}
