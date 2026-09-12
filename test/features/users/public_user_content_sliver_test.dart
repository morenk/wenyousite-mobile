import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/thread_feed/thread_feed_widgets.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/public_user_content.dart';

void main() {
  for (final isSelf in [false, true]) {
    for (final replies in [false, true]) {
      testWidgets(
        '${isSelf ? '本人' : '公开'}${replies ? '回复' : '主题'}千条内容仅构建视口附近行',
        (tester) async {
          final scroll = ScrollController();
          addTearDown(scroll.dispose);
          final state = PublicUserState(
            created: PublicUserContentSection(
              phase: PublicUserContentPhase.ready,
              items: List.generate(
                1000,
                (index) => PublicUserThreadModel(
                  id: 'row-$index',
                  title: '主题 $index',
                  status: PublicUserThreadStatus.recruiting,
                  ownerName: '用户',
                  ownerLevel: 1,
                  memberCount: 1,
                  postCount: 1,
                  createdAt: DateTime.utc(2026, 9, 7),
                ),
              ),
              cursor: 'opaque',
              hasMore: true,
            ),
            replies: PublicUserContentSection(
              phase: PublicUserContentPhase.ready,
              items: List.generate(
                1000,
                (index) => PublicUserReplyModel(
                  id: 'row-$index',
                  threadId: 'thread',
                  threadTitle: '主题 $index',
                  subthreadId: 'subthread',
                  subthreadTitle: '子贴',
                  preview: '回复正文',
                  createdAt: DateTime.utc(2026, 9, 7),
                ),
              ),
            ),
          );
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                theme: AppTheme.light,
                home: Scaffold(
                  body: CustomScrollView(
                    controller: scroll,
                    slivers: [
                      PublicUserContentSectionSliver(
                        tab: replies
                            ? PublicUserContentTab.replies
                            : PublicUserContentTab.created,
                        state: state,
                        isSelf: isSelf,
                        onRetry: () {},
                        onLoadMore: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byKey(const ValueKey('row-0')), findsOneWidget);
          expect(find.byKey(const ValueKey('row-999')), findsNothing);
          if (!replies) {
            expect(find.byType(ThreadFeedCard).evaluate().length, lessThan(15));
          }
          for (var attempt = 0; attempt < 5; attempt++) {
            scroll.jumpTo(scroll.position.maxScrollExtent);
            await tester.pumpAndSettle();
          }
          expect(find.byKey(const ValueKey('row-999')), findsOneWidget);
          expect(find.byKey(const ValueKey('row-0')), findsNothing);
          if (!replies) {
            expect(find.byType(ThreadFeedCard).evaluate().length, lessThan(15));
            expect(
              find
                  .byKey(const Key('public-user-created-load-more'))
                  .hitTestable(),
              findsOneWidget,
            );
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
