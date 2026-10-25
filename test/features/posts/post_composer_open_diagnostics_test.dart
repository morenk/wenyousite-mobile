import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';

import '../../support/deterministic_test_fonts.dart';
import 'post_replies_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('实际楼层编辑入口对只读拦截显示可复制问题详情并保留原文', (tester) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previous = FailureDiagnostics.instance;
    final diagnostics = FailureDiagnostics();
    FailureDiagnostics.instance = diagnostics;
    addTearDown(() {
      FailureDiagnostics.instance = previous;
      diagnostics.dispose();
    });
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    const source =
        '[wenyousite-align-v1-center]: #\n'
        '<span>Y/N</span>';
    final repository = PostRepliesPageTestFakePostRepository(
      onFetchPost: (_) async => postRepliesPageTestRootWithContent(source),
    );
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'root-author',
      markdownAlignment: true,
      markdownImageAlignment: true,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);
    await postRepliesPageTestLongPressPostMetadata(tester, 'root');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('post-card-action-root-edit')));
    await postRepliesPageTestPumpUi(tester);

    final editor = tester.widget<QuillEditor>(
      find.byKey(const Key('post-composer-body')),
    );
    expect(editor.controller.readOnly, isTrue);
    expect(find.text('这段内容暂不支持编辑，原文已保留。'), findsOneWidget);
    expect(find.text('复制问题详情'), findsOneWidget);
    final record = diagnostics.records.single;
    expect(record.operation.name, 'editorOpen');
    await tester.tap(find.text('复制问题详情'));
    await tester.pumpAndSettle();
    final payload = jsonDecode(copied!) as Map;
    expect((payload['records'] as List).single['id'], record.id);
    expect(copied, isNot(contains('Y/N')));
    expect(copied, isNot(contains('wenyousite-align')));
    await postRepliesPageTestDismissPostComposerFromOutside(tester);
    expect(repository.updateRequests, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
