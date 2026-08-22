import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_controls.dart';

enum _Order { oldest, newest }

void main() {
  testWidgets('讨论设置先保留草稿并在应用时一次提交', (tester) async {
    WenyouDiscussionSelection<_Order>? applied;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouDiscussionControls<_Order>(
            countLabel: '12 条回复',
            order: _Order.oldest,
            defaultOrder: _Order.oldest,
            orderOptions: const [
              WenyouDiscussionOrderOption(value: _Order.oldest, label: '最早在前'),
              WenyouDiscussionOrderOption(value: _Order.newest, label: '最新在前'),
            ],
            authorId: null,
            authors: const [
              WenyouDiscussionAuthorOption(id: 'author-1', label: '小温'),
            ],
            settingsKey: const Key('open-settings'),
            sheetKey: const Key('settings-sheet'),
            onApply: (value) => applied = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-sheet')), findsOneWidget);
    expect(find.byKey(const Key('discussion-settings-reset')), findsNothing);

    await tester.tap(find.text('最新在前').last);
    await tester.pump();
    await tester.tap(find.text('小温'));
    await tester.pump();
    expect(applied, isNull);
    expect(find.byKey(const Key('discussion-settings-reset')), findsOneWidget);

    await tester.tap(find.byKey(const Key('discussion-settings-apply')));
    await tester.pumpAndSettle();
    expect(applied?.order, _Order.newest);
    expect(applied?.authorId, 'author-1');
  });

  testWidgets('作者候选失败不影响顺序设置，并可单独重试', (tester) async {
    var retries = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouDiscussionControls<_Order>(
            countLabel: '12 条回复',
            order: _Order.oldest,
            defaultOrder: _Order.oldest,
            orderOptions: const [
              WenyouDiscussionOrderOption(value: _Order.oldest, label: '最早在前'),
              WenyouDiscussionOrderOption(value: _Order.newest, label: '最新在前'),
            ],
            authorId: null,
            authors: const [],
            authorsFailure: const ApiFailure(userMessage: '作者暂时不可用'),
            onRetryAuthors: () => retries += 1,
            settingsKey: const Key('open-failed-settings'),
            onApply: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-failed-settings')));
    await tester.pumpAndSettle();
    expect(find.text('作者暂时不可用'), findsOneWidget);
    expect(find.text('最早在前'), findsNWidgets(2));

    await tester.tap(find.text('重新加载作者'));
    await tester.pumpAndSettle();

    expect(retries, 1);
    expect(find.text('讨论设置'), findsNothing);
  });
}
