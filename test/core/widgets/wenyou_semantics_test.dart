import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_feed_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_feed_card.dart';

void main() {
  testWidgets('主题卡片向 TalkBack 暴露单一可操作描述', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: HomeThreadCard(
            thread: HomeThreadCardModel(
              id: 'thread-1',
              title: '海边旅店',
              status: HomeThreadStatus.recruiting,
              isPinned: false,
              ownerId: 'owner-1',
              ownerName: '小温',
              ownerLevel: 3,
              tags: const [],
              coverImageUrls: const [],
              memberCount: 2,
              playerCount: 1,
              postCount: 4,
              tipTotal: '0',
              lastActivityAt: DateTime(2026, 8, 11),
            ),
            categoryName: '现代',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('打开主题：海边旅店，作者 小温'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('空状态标题保留标题语义并暴露说明', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouEmptyState(
            icon: Icons.forum_outlined,
            title: '暂无主题',
            message: '创建第一个主题开始交流。',
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('暂无主题'), findsOneWidget);
    expect(find.bySemanticsLabel('创建第一个主题开始交流。'), findsOneWidget);
    semantics.dispose();
  });
}
