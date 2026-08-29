import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/user_activity_summary_panel.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('创作概览保留单层卡片并使用紧凑二乘二统计', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 260);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: const [
              UserActivitySummaryPanel(
                key: Key('activity-summary'),
                state: PublicUserState(
                  activityPhase: PublicUserActivityPhase.ready,
                  activitySummary: PublicUserActivitySummary(
                    momentCount: 12000,
                    createdThreadCount: 7,
                    playedThreadCount: null,
                    replyCount: 36,
                  ),
                ),
                onRetry: _noop,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Card), findsOneWidget);
    expect(find.text('短内容'), findsNothing);
    expect(find.text('担任楼主'), findsNothing);
    expect(find.text('玩家身份'), findsNothing);
    expect(find.text('楼层讨论'), findsNothing);
    expect(find.text('未公开'), findsOneWidget);
    expect(
      tester.getCenter(find.text('发布动态')).dy,
      closeTo(tester.getCenter(find.text('创建主题')).dy, 3),
    );
    expect(
      tester.getCenter(find.text('参与主题')).dy,
      closeTo(tester.getCenter(find.text('累计回复')).dy, 6),
    );
    expect(
      tester.getCenter(find.text('参与主题')).dy,
      greaterThan(tester.getCenter(find.text('发布动态')).dy),
    );
    final panelCenter = tester.getCenter(
      find.byKey(const Key('activity-summary')),
    );
    final firstColumnCenter =
        (tester.getCenter(find.text('发布动态')).dx +
            tester.getCenter(find.text('创建主题')).dx) /
        2;
    final secondColumnCenter =
        (tester.getCenter(find.text('参与主题')).dx +
            tester.getCenter(find.text('累计回复')).dx) /
        2;
    expect(firstColumnCenter, greaterThan(panelCenter.dx + 8));
    expect(firstColumnCenter, lessThan(panelCenter.dx + 24));
    expect(secondColumnCenter, closeTo(firstColumnCenter, 6));
    expect(
      tester.getSize(find.byKey(const Key('activity-summary'))).height,
      lessThan(180),
    );

    await expectLater(
      find.byKey(const Key('activity-summary')),
      matchesGoldenFile('goldens/user_activity_summary_compact_360.png'),
    );
  });

  testWidgets('创作概览的可见统计可点击且未公开项保持只读', (tester) async {
    final opened = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: UserActivitySummaryPanel(
            keyPrefix: 'activity-entry',
            state: const PublicUserState(
              activityPhase: PublicUserActivityPhase.ready,
              activitySummary: PublicUserActivitySummary(
                momentCount: 7,
                createdThreadCount: 3,
                playedThreadCount: null,
                replyCount: 28,
              ),
            ),
            onRetry: _noop,
            onMomentsPressed: () => opened.add('moments'),
            onCreatedThreadsPressed: () => opened.add('created'),
            onPlayedThreadsPressed: () => opened.add('played'),
            onRepliesPressed: () => opened.add('replies'),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('查看发布动态，7'), findsOneWidget);
    expect(find.bySemanticsLabel('查看创建主题，3'), findsOneWidget);
    expect(find.bySemanticsLabel('参与主题，未公开'), findsOneWidget);
    expect(find.bySemanticsLabel('查看参与主题，未公开'), findsNothing);
    expect(find.bySemanticsLabel('查看累计回复，28'), findsOneWidget);

    await tester.tap(find.byKey(const Key('activity-entry-moments')));
    await tester.tap(find.byKey(const Key('activity-entry-created-threads')));
    await tester.tap(find.byKey(const Key('activity-entry-replies')));

    expect(opened, ['moments', 'created', 'replies']);
  });

  testWidgets('创作概览失败保留问题编号和原地重试', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: UserActivitySummaryPanel(
            state: const PublicUserState(
              activityPhase: PublicUserActivityPhase.failed,
              activityFailure: ApiFailure(
                userMessage: '创作概览加载失败。',
                requestId: 'activity-request',
              ),
            ),
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('问题编号：activity-request'), findsOneWidget);
    await tester.tap(find.text('重试'));
    expect(retried, isTrue);
  });
}

void _noop() {}
