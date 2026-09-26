import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_page.dart';

import '../../support/deterministic_test_fonts.dart';
import 'moment_pages_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('动态 $width dp 双倍字快滑唤醒并避让发表，快翻不加载全部评论', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = _ReadingRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [momentRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            theme: width == 320 ? AppTheme.dark : AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 800),
                textScaler: const TextScaler.linear(2),
              ),
              child: const MomentDetailPage(momentId: 'moment-1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final quick = tester
          .widget<ReadingProgressViewport>(find.byType(ReadingProgressViewport))
          .controller;
      await tester.timedDrag(
        find.byKey(const PageStorageKey('moment-detail-scroll')),
        const Offset(0, -200),
        const Duration(milliseconds: 160),
      );
      await tester.pumpAndSettle();
      expect(quick.isOpen, isTrue);
      final rail = tester.getRect(
        find.byKey(const Key('reading-quick-scroll-rail')),
      );
      expect(
        rail.bottom,
        lessThanOrEqualTo(
          tester.getRect(find.byKey(const Key('moment-comment-dock'))).top,
        ),
      );
      quick.beginDrag(0.55);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('reading-quick-scroll-location')),
        findsOneWidget,
      );
      expect(quick.location, contains('回复附近'));
      expect(find.textContaining('已加载范围'), findsOneWidget);
      expect(repository.commentCalls, 1);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/moment_reading_scroll_${width.toInt()}.png'),
      );
      quick.updateDrag(1);
      await tester.pumpAndSettle();
      quick.endDrag(1);
      await tester.pumpAndSettle();
      expect(repository.commentCalls, 1);
      expect(quick.scrollController.position.extentAfter, lessThanOrEqualTo(1));
      expect(
        find.byKey(const Key('moment-comments-load-more')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('moment-comments-load-more')));
      await tester.pumpAndSettle();
      expect(repository.commentCalls, 2);
      expect(tester.takeException(), isNull);
    });
  }
}

class _ReadingRepository extends MomentPagesTestPageRepository {
  int commentCalls = 0;

  @override
  Future<CursorPage<MomentRootComment>> fetchComments({
    required String momentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  }) async {
    commentCalls++;
    return CursorPage(
      items: [
        for (var i = 0; i < 12; i++)
          MomentRootComment(
            id: '${cursor ?? 'first'}-$i',
            momentId: momentId,
            author: momentPagesTestAuthor(),
            content: List.filled(3, '评论 $i 的实际阅读正文').join('\n'),
            deleted: false,
            canDelete: false,
            createdAt: DateTime.utc(2026, 8, 10, 13, i),
            replyCount: 0,
            replies: const [],
          ),
      ],
      cursor: cursor == null ? 'page-2' : null,
      hasMore: cursor == null,
    );
  }
}
