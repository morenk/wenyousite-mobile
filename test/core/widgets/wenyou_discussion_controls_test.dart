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

  testWidgets('直接讨论控件分别切换顺序和作者', (tester) async {
    var order = _Order.oldest;
    String? authorId;
    var orderChanges = 0;
    var authorChanges = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) =>
                WenyouDiscussionListControls<_Order>(
                  countLabel: '12 条回复',
                  order: order,
                  orderOptions: const [
                    WenyouDiscussionOrderOption(
                      value: _Order.oldest,
                      label: '最早在前',
                    ),
                    WenyouDiscussionOrderOption(
                      value: _Order.newest,
                      label: '最新在前',
                    ),
                  ],
                  authorId: authorId,
                  authors: const [
                    WenyouDiscussionAuthorOption(
                      id: 'author-1',
                      label: '小温',
                      supportingLabel: '玩家',
                    ),
                  ],
                  authorKey: const Key('direct-author'),
                  orderKey: const Key('direct-order'),
                  onOrderChanged: (value) => setState(() {
                    orderChanges += 1;
                    order = value;
                  }),
                  onAuthorChanged: (value) => setState(() {
                    authorChanges += 1;
                    authorId = value;
                  }),
                ),
          ),
        ),
      ),
    );

    expect(find.text('最早在前'), findsOneWidget);
    expect(find.text('所有人'), findsOneWidget);
    await tester.tap(find.byKey(const Key('direct-order')));
    await tester.pumpAndSettle();
    expect(order, _Order.newest);
    expect(orderChanges, 1);
    expect(find.text('最新在前'), findsOneWidget);

    await tester.tap(find.byKey(const Key('direct-author')));
    await tester.pumpAndSettle();
    expect(find.text('玩家'), findsOneWidget);
    await tester.tap(find.text('小温').last);
    await tester.pumpAndSettle();
    expect(authorId, 'author-1');
    expect(authorChanges, 1);
    expect(find.text('小温'), findsOneWidget);
    expect(find.text('讨论设置'), findsNothing);
  });

  testWidgets('直接讨论控件可只保留与主题帖一致的顺序按钮', (tester) async {
    var order = _Order.newest;
    var changes = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) =>
                WenyouDiscussionListControls<_Order>.orderOnly(
                  countLabel: '12 条评论',
                  order: order,
                  orderOptions: const [
                    WenyouDiscussionOrderOption(
                      value: _Order.oldest,
                      label: '最早在前',
                    ),
                    WenyouDiscussionOrderOption(
                      value: _Order.newest,
                      label: '最新在前',
                    ),
                  ],
                  orderKey: const Key('order-only'),
                  onOrderChanged: (value) => setState(() {
                    changes += 1;
                    order = value;
                  }),
                ),
          ),
        ),
      ),
    );

    expect(find.text('12 条评论'), findsOneWidget);
    expect(find.text('最新在前'), findsOneWidget);
    expect(find.text('暂无可筛选作者'), findsNothing);
    expect(find.text('讨论设置'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('order-only'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSemantics(find.byKey(const Key('order-only'))).label,
      contains('当前最新在前，点击切换为最早在前'),
    );

    await tester.tap(find.byKey(const Key('order-only')));
    await tester.pump();

    expect(changes, 1);
    expect(order, _Order.oldest);
    expect(find.text('最早在前'), findsOneWidget);
  });

  testWidgets('直接讨论控件在作者失败和窄屏大字号下保持可操作', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var retries = 0;
    var order = _Order.oldest;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) =>
                WenyouDiscussionListControls<_Order>(
                  countLabel: '12 条回复',
                  order: order,
                  orderOptions: const [
                    WenyouDiscussionOrderOption(
                      value: _Order.oldest,
                      label: '最早在前',
                    ),
                    WenyouDiscussionOrderOption(
                      value: _Order.newest,
                      label: '最新在前',
                    ),
                  ],
                  authorId: null,
                  authors: const [],
                  authorsFailure: const ApiFailure(userMessage: '作者暂时不可用'),
                  onRetryAuthors: () => retries += 1,
                  authorKey: const Key('failed-author'),
                  orderKey: const Key('failed-order'),
                  onOrderChanged: (value) => setState(() => order = value),
                  onAuthorChanged: (_) {},
                ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byKey(const Key('failed-author'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.byKey(const Key('failed-order'))).height,
      greaterThanOrEqualTo(48),
    );
    await tester.tap(find.byKey(const Key('failed-order')));
    await tester.pump();
    expect(order, _Order.newest);
    await tester.tap(find.byKey(const Key('failed-author')));
    await tester.pump();
    expect(retries, 1);
    expect(tester.takeException(), isNull);
  });
}
