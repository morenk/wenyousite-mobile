import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_widgets.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_post_author_line.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('作者信息 320dp ${dark ? 'dark' : 'light'} 字号 $scale', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 320);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(12),
                child: ThreadIdentityReadingScope(
                  threadId: 'thread',
                  available: true,
                  ownerId: 'author',
                  child: ThreadPostAuthorLine(
                    author: const ThreadAuthorModel(
                      id: 'author',
                      username: '来自群山的白夜与尚未抵达的漫长旅程',
                      level: 4,
                    ),
                    time: DateTime(2020, 8, 9),
                    compact: true,
                    metadata: const [Text('置顶')],
                    trailing: const Text('#9999'),
                  ),
                ),
              ),
            ),
          ),
        );
        final name = tester.getRect(find.text('来自群山的白夜与尚未抵达的漫长旅程'));
        final badge = tester.getRect(find.byType(WenyouLevelBadge));
        final number = tester.getRect(find.text('#9999'));
        expect(badge.right, 308);
        expect(name.right, badge.left - 4);
        expect(name.center.dy, badge.center.dy);
        expect(number.right, 308);
        expect(number.top, greaterThanOrEqualTo(name.bottom));
        expect(
          tester.getTopLeft(find.text('楼主')).dy,
          greaterThanOrEqualTo(name.bottom),
        );
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            'goldens/post_author_320_${dark ? 'dark' : 'light'}_${scale.toInt()}x.png',
          ),
        );
      });
    }
  }

  testWidgets('昵称与小号等级共用首行，时间不挤占名字', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 336,
            child: ThreadPostAuthorLine(
              author: const ThreadAuthorModel(
                id: 'author',
                username: '断首的斩姬·玛利亚',
                level: 4,
              ),
              time: DateTime(2026, 8, 9),
              compact: true,
            ),
          ),
        ),
      ),
    );
    final name = tester.getRect(find.text('断首的斩姬·玛利亚'));
    final badge = tester.getRect(find.byType(WenyouLevelBadge));
    expect(badge.left, name.right + 4);
    expect(badge.right, lessThanOrEqualTo(336));
    expect(badge.center.dy, name.center.dy);
    final style = tester.widget<Text>(find.text('断首的斩姬·玛利亚')).style!;
    expect(style.fontSize, 12);
    expect(style.fontWeight, FontWeight.w400);
    expect(tester.getSize(find.byType(ThreadPostAuthorLine)).height, 48);
    expect(tester.takeException(), isNull);
  });
}
