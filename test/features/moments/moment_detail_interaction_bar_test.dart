import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_interaction_bar.dart';

import '../../support/foundation_icon_finder.dart';
import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('360dp 动态详情将四项互动统一为图标与数字', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final semantics = tester.ensureSemantics();
    var commentTapCount = 0;
    final card = _card(
      likeCount: 12345,
      commentCount: 89,
      bookmarkCount: 67,
      tipTotal: '123000',
      viewerLiked: true,
      viewerBookmarked: true,
    );

    await _pumpBar(
      tester,
      card: card,
      onComment: () => commentTapCount += 1,
      onTip: _noop,
    );

    final strip = find.byKey(const Key('moment-detail-actions'));
    final actionFinders = [
      find.byKey(const Key('moment-detail-like')),
      find.byKey(const Key('moment-detail-bookmark')),
      find.byKey(const Key('moment-detail-comments')),
      find.byKey(const Key('moment-detail-tip')),
    ];
    final firstSize = tester.getSize(actionFinders.first);
    for (final action in actionFinders) {
      final size = tester.getSize(action);
      expect(size.width, closeTo(firstSize.width, 0.1));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(
        tester.getCenter(action).dy,
        closeTo(tester.getCenter(actionFinders.first).dy, 0.1),
      );
    }
    expect(
      find.descendant(of: strip, matching: find.text('1.2万')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: strip, matching: find.text('67')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: strip, matching: find.text('89')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: strip, matching: find.text('12.3万')),
      findsOneWidget,
    );
    for (final label in ['点赞', '收藏', '评论', '加油', '已获得', '升']) {
      expect(
        find.descendant(of: strip, matching: find.textContaining(label)),
        findsNothing,
      );
    }
    for (final action in actionFinders) {
      final text = tester.widget<Text>(
        find.descendant(of: action, matching: find.byType(Text)),
      );
      expect(text.style?.fontFamily, WenyouFoundationTypography.utility);
      expect(text.style?.fontWeight, FontWeight.w400);
      expect(text.style?.fontSize, 12);
    }
    expect(
      find.descendant(
        of: actionFinders[0],
        matching: findFoundationIcon(WenyouIconIds.actionLike),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<WenyouIcon>(
            find.descendant(
              of: actionFinders[0],
              matching: find.byType(WenyouIcon),
            ),
          )
          .variant,
      WenyouIconVariant.filled,
    );
    expect(
      find.descendant(
        of: actionFinders[1],
        matching: findFoundationIcon(WenyouIconIds.actionBookmark),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<WenyouIcon>(
            find.descendant(
              of: actionFinders[1],
              matching: find.byType(WenyouIcon),
            ),
          )
          .variant,
      WenyouIconVariant.filled,
    );
    expect(
      find.descendant(
        of: actionFinders[2],
        matching: findFoundationIcon(WenyouIconIds.metricComments),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: actionFinders[3],
        matching: findFoundationIcon(WenyouIconIds.actionTip),
      ),
      findsOneWidget,
    );

    final likeSemantics = tester.getSemantics(actionFinders[0]);
    expect(likeSemantics.label, '取消点赞，12345 次点赞');
    expect(likeSemantics.getSemanticsData().flagsCollection.isButton, isTrue);
    final commentSemantics = tester.getSemantics(actionFinders[2]);
    expect(commentSemantics.label, '发表评论，89 条评论');
    expect(
      commentSemantics.getSemanticsData().flagsCollection.isButton,
      isTrue,
    );
    expect(
      commentSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );
    await tester.tap(actionFinders[2]);
    await tester.pumpAndSettle();
    expect(commentTapCount, 1);
    final tipSemantics = tester.getSemantics(actionFinders[3]);
    expect(tipSemantics.label, '为温柔测试员加油，累计 123,000 升');
    expect(tipSemantics.getSemanticsData().flagsCollection.isButton, isTrue);
    expect(
      tipSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );

    await expectLater(
      strip,
      matchesGoldenFile('goldens/moment_detail_actions_360.png'),
    );
    semantics.dispose();
  });

  testWidgets('本人动态保留只读加油累计且四项布局不变', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpBar(tester, card: _card(tipTotal: '8'));

    expect(
      find.descendant(
        of: find.byKey(const Key('moment-detail-tip')),
        matching: findFoundationIcon(WenyouIconIds.metricTips),
      ),
      findsOneWidget,
    );
    final tipSemantics = tester.getSemantics(
      find.byKey(const Key('moment-detail-tip')),
    );
    expect(tipSemantics.label, '累计获得 8 升加油');
    expect(tipSemantics.getSemanticsData().flagsCollection.isButton, isFalse);
    expect(
      tipSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
      isFalse,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('moment-detail-bookmark')),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('moment-detail-actions')),
        matching: find.byType(WenyouIcon),
      ),
      findsNWidgets(4),
    );
    semantics.dispose();
  });

  testWidgets('互动提交中只锁定对应图标并保留原投影', (tester) async {
    await _pumpBar(
      tester,
      card: _card(viewerLiked: true),
      pendingAction: MomentInteractionAction.like,
      onTip: _noop,
    );

    final like = find.byKey(const Key('moment-detail-like'));
    final bookmark = find.byKey(const Key('moment-detail-bookmark'));
    expect(
      find.descendant(
        of: like,
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: bookmark,
        matching: find.byType(CircularProgressIndicator),
      ),
      findsNothing,
    );
    expect(
      tester.getSemantics(like).getSemanticsData().flagsCollection.isEnabled,
      Tristate.isFalse,
    );
    expect(
      tester
          .widget<WenyouIcon>(
            find.descendant(of: like, matching: find.byType(WenyouIcon)),
          )
          .variant,
      WenyouIconVariant.filled,
    );
  });

  testWidgets('320dp 两倍字体下大计数互动栏不溢出', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await _pumpBar(
      tester,
      card: _card(
        likeCount: 999999999,
        commentCount: 888888888,
        bookmarkCount: 777777777,
        tipTotal: '9223372036854775807',
      ),
      onTip: _noop,
      textScaler: const TextScaler.linear(2),
      width: 296,
    );

    expect(tester.takeException(), isNull);
    for (final key in const [
      Key('moment-detail-like'),
      Key('moment-detail-bookmark'),
      Key('moment-detail-comments'),
      Key('moment-detail-tip'),
    ]) {
      expect(tester.getSize(find.byKey(key)).height, greaterThanOrEqualTo(48));
    }
  });
}

Future<void> _pumpBar(
  WidgetTester tester, {
  required MomentCard card,
  MomentInteractionAction? pendingAction,
  VoidCallback onComment = _noop,
  VoidCallback? onTip,
  TextScaler textScaler = TextScaler.noScaling,
  double width = 336,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: MediaQuery(
            data: const MediaQueryData().copyWith(textScaler: textScaler),
            child: SizedBox(
              width: width,
              child: MomentDetailInteractionBar(
                card: card,
                pendingAction: pendingAction,
                onLike: _noop,
                onBookmark: _noop,
                onComment: onComment,
                onTip: onTip,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

MomentCard _card({
  int likeCount = 2,
  int commentCount = 1,
  int bookmarkCount = 0,
  String tipTotal = '0',
  bool viewerLiked = false,
  bool viewerBookmarked = false,
}) {
  final now = DateTime.utc(2026, 8, 10, 12);
  return MomentCard(
    id: 'moment-1',
    author: const MomentAuthor(id: 'user-1', username: '温柔测试员', level: 4),
    title: '今日微光',
    contentExcerpt: '动态正文是纯文本',
    coverType: MomentCoverType.text,
    textCoverTheme: MomentTextCoverTheme.mint,
    imageCount: 0,
    likeCount: likeCount,
    commentCount: commentCount,
    bookmarkCount: bookmarkCount,
    tipTotal: tipTotal,
    viewerLiked: viewerLiked,
    viewerBookmarked: viewerBookmarked,
    canInteract: true,
    createdAt: now,
    updatedAt: now,
  );
}

void _noop() {}
