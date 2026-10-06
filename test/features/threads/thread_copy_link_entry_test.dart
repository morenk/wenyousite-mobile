import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/deterministic_test_fonts.dart';
import 'thread_detail_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('主题/子贴正文和楼层真实菜单共用链接复制端口', (tester) async {
    final links = <String>[];
    await tester.pumpWidget(
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(),
        linkWriter: (text) async => links.add(text),
      ),
    );
    await tester.pumpAndSettle();
    final body = find.byKey(const Key('thread-body-container-subthread-1'));
    await tester.scrollUntilVisible(
      body,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    final rect = tester.getRect(body);
    await tester.longPressAt(Offset(rect.right - 12, rect.top + 12));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('thread-body-action-subthread-1-link')),
    );
    await tester.pumpAndSettle();
    final floor = find.byKey(const Key('thread-floor-card-floor-1'));
    await tester.scrollUntilVisible(
      floor,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.longPressAt(tester.getTopLeft(floor) + const Offset(8, 8));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-floor-action-floor-1-link')));
    await tester.pumpAndSettle();
    expect(links, [
      'https://wenyou.site/threads/thread-1?subthread=subthread-1',
      'https://wenyou.site/threads/thread-1?post=floor-1',
    ]);
  });
}
