import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';

import '../../support/deterministic_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final content in ['', ' \n\t']) {
    testWidgets('真实回复入口空内容仅提示，不展示故障或发起写入：$content', (tester) async {
      final repository = PostRepliesPageTestFakePostRepository();
      final container = await postRepliesPageTestPostContainer(
        repository,
        userId: 'author-1',
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
      await postRepliesPageTestPumpUi(tester);
      await tester.tap(find.byKey(const Key('post-reply-compose')));
      await postRepliesPageTestPumpUi(tester);
      if (content.isNotEmpty) {
        await postRepliesPageTestReplaceComposerText(tester, content);
      }
      final failures = FailureDiagnostics.instance.records.length;
      await tester.tap(find.byKey(const Key('editor-submit')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('消息框不能为空。'), findsOneWidget);
      expect(find.byKey(const Key('post-composer-failure')), findsNothing);
      expect(repository.createInputs, isEmpty);
      expect(FailureDiagnostics.instance.records.length, failures);
      expect(find.byKey(const Key('post-composer-sheet')), findsOneWidget);
      await postRepliesPageTestDismissPostComposerFromOutside(tester);
    });
  }
}
