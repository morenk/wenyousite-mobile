import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_interaction_bar.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/foundation_icon_finder.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('动态全部真实零值显示0且与图标垂直对齐', (tester) async {
    await _pumpBar(
      tester,
      card: _card(likeCount: 0, bookmarkCount: 0, tipTotal: '0'),
      width: 320,
      dark: true,
      textScaler: const TextScaler.linear(2),
      onTip: _noop,
    );
    expect(find.text('0'), findsNWidgets(3));
    double? countTop;
    for (final key in [
      'moment-detail-like',
      'moment-detail-bookmark',
      'moment-detail-tip',
    ]) {
      final action = find.byKey(Key(key));
      final count = find.descendant(of: action, matching: find.text('0'));
      final icon = find.descendant(
        of: action,
        matching: find.byType(WenyouIcon),
      );
      final bounds = tester.getRect(count);
      countTop ??= bounds.top;
      expect(bounds.top, closeTo(countTop, .1));
      expect(bounds.top, greaterThanOrEqualTo(tester.getRect(icon).bottom));
      expect(bounds.center.dx, closeTo(tester.getCenter(icon).dx, .1));
    }
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const Key('moment-detail-actions')),
      matchesGoldenFile('goldens/moment_detail_bottom_bar_320_zero_counts.png'),
    );
  });

  for (final width in [320.0, 360.0, 400.0]) {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 1.5]) {
        testWidgets('$width $dark 字号$scale 底栏预览', (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 760);
          addTearDown(tester.view.reset);
          await _pumpBar(
            tester,
            card: _card(
              likeCount: 12345,
              bookmarkCount: 67,
              tipTotal: '123000',
            ),
            width: width,
            dark: dark,
            textScaler: TextScaler.linear(scale),
            onTip: _noop,
          );
          expect(tester.takeException(), isNull);
          for (final key in [
            'moment-detail-like',
            'moment-detail-bookmark',
            'moment-detail-tip',
            'moment-comment-dock',
          ]) {
            final size = tester.getSize(find.byKey(Key(key)));
            expect(size.width, greaterThanOrEqualTo(48));
            expect(size.height, greaterThanOrEqualTo(48));
          }
          expect(
            find.ancestor(
              of: find.text('12k'),
              matching: find.byType(FittedBox),
            ),
            findsNothing,
          );
          if (scale == 1) {
            expect(
              tester
                  .getSize(find.byKey(const Key('moment-comment-dock')))
                  .width,
              greaterThanOrEqualTo(width - 172),
            );
          }
          await expectLater(
            find.byKey(const Key('moment-detail-actions')),
            matchesGoldenFile(
              'goldens/moment_detail_bottom_bar_${width.toInt()}_${dark ? 'dark' : 'light'}_${scale == 1 ? 'normal' : 'large'}.png',
            ),
          );
        });
      }
    }
  }
  testWidgets('禁止新互动仍可撤销已点赞收藏，回复隐藏且加油只读', (tester) async {
    var likes = 0;
    var bookmarks = 0;
    await _pumpBar(
      tester,
      card: _card(
        canInteract: false,
        viewerLiked: true,
        viewerBookmarked: true,
      ),
      onLike: () => likes++,
      onBookmark: () => bookmarks++,
    );
    expect(find.byKey(const Key('moment-comment-dock')), findsNothing);
    await tester.tap(find.byKey(const Key('moment-detail-like')));
    await tester.tap(find.byKey(const Key('moment-detail-bookmark')));
    expect(likes, 1);
    expect(bookmarks, 1);
    expect(
      tester
          .getSemantics(find.byKey(const Key('moment-detail-tip')))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isFalse,
    );
  });
  testWidgets('游客回复保留登录语义并只调用原入口', (tester) async {
    var calls = 0;
    await _pumpBar(
      tester,
      card: _card(),
      authenticated: false,
      onComment: () => calls++,
    );
    final reply = find.byKey(const Key('moment-comment-dock'));
    expect(tester.getSemantics(reply).label, '回复一下，1 条评论，登录后发表');
    await tester.tap(reply);
    expect(calls, 1);
  });

  testWidgets('360dp 动态详情将互动与回复合并为固定底栏', (tester) async {
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
      find.byKey(const Key('moment-detail-tip')),
    ];
    for (final action in actionFinders) {
      final size = tester.getSize(action);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(
        tester.getCenter(action).dy,
        closeTo(tester.getCenter(actionFinders.first).dy, 0.1),
      );
      final icon = find.descendant(
        of: action,
        matching: find.byType(WenyouIcon),
      );
      final firstIcon = find.descendant(
        of: actionFinders.first,
        matching: find.byType(WenyouIcon),
      );
      expect(
        tester.getCenter(icon).dy,
        closeTo(tester.getCenter(firstIcon).dy, .1),
      );
      final value = find.descendant(of: action, matching: find.byType(Text));
      expect(
        tester.getRect(value).top,
        greaterThanOrEqualTo(tester.getRect(icon).bottom),
      );
    }
    expect(
      find.descendant(of: strip, matching: find.text('12k')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: strip, matching: find.text('67')),
      findsOneWidget,
    );

    expect(
      find.descendant(of: strip, matching: find.text('123k')),
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
      expect(
        text.style?.fontFamily,
        ThemeData.light().textTheme.bodySmall!.fontFamily,
      );
      expect(
        text.style?.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
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
        matching: findFoundationIcon(WenyouIconIds.actionTip),
      ),
      findsOneWidget,
    );

    final likeSemantics = tester.getSemantics(actionFinders[0]);
    expect(likeSemantics.label, '取消点赞，12345 次点赞');
    expect(likeSemantics.getSemanticsData().flagsCollection.isButton, isTrue);
    final comment = find.byKey(const Key('moment-comment-dock'));
    final commentSemantics = tester.getSemantics(comment);
    expect(commentSemantics.label, '回复一下，89 条评论');
    expect(
      commentSemantics.getSemanticsData().flagsCollection.isButton,
      isTrue,
    );
    expect(
      commentSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );
    await tester.tap(comment);
    await tester.pumpAndSettle();
    expect(commentTapCount, 1);
    final tipSemantics = tester.getSemantics(actionFinders[2]);
    expect(tipSemantics.label, '为温柔测试员加油，累计 123,000 升');
    expect(tipSemantics.getSemanticsData().flagsCollection.isButton, isTrue);
    expect(
      tipSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );

    await expectLater(
      strip,
      matchesGoldenFile('goldens/moment_detail_bottom_bar_360_light.png'),
    );
    semantics.dispose();
  });

  testWidgets('本人动态保留只读加油累计和回复入口', (tester) async {
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
      findsNWidgets(3),
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
      Key('moment-comment-dock'),
      Key('moment-detail-tip'),
    ]) {
      expect(tester.getSize(find.byKey(key)).height, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('320dp两倍字同时显示三个四字符计数，回复保留48dp', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 760);
    addTearDown(tester.view.reset);
    await _pumpBar(
      tester,
      card: _card(likeCount: 9999, bookmarkCount: 999000, tipTotal: '9900000'),
      width: 320,
      textScaler: const TextScaler.linear(2),
      onTip: _noop,
    );
    expect(find.text('9.9k'), findsOneWidget);
    expect(find.text('999k'), findsOneWidget);
    expect(find.text('9.9m'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('moment-comment-dock'))).width,
      greaterThanOrEqualTo(48),
    );
    Rect? previousCount;
    for (final value in ['9.9k', '999k', '9.9m']) {
      final count = tester.getRect(find.text(value));
      if (previousCount != null) {
        expect(count.left - previousCount.right, greaterThanOrEqualTo(8));
      }
      previousCount = count;
      expect(
        find.ancestor(of: find.text(value), matching: find.byType(FittedBox)),
        findsNothing,
      );
    }
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const Key('moment-detail-actions')),
      matchesGoldenFile(
        'goldens/moment_detail_bottom_bar_320_large_counts.png',
      ),
    );
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
  bool dark = false,
  bool authenticated = true,
  VoidCallback onLike = _noop,
  VoidCallback onBookmark = _noop,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(
        body: Center(
          child: MediaQuery(
            data: const MediaQueryData().copyWith(textScaler: textScaler),
            child: SizedBox(
              width: width,
              child: MomentDetailInteractionBar(
                card: card,
                authenticated: authenticated,
                pendingAction: pendingAction,
                onLike: onLike,
                onBookmark: onBookmark,
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
  bool canInteract = true,
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
    canInteract: canInteract,
    createdAt: now,
    updatedAt: now,
  );
}

void _noop() {}
