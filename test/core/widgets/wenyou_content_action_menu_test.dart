import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_content_action_menu.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_reader_clipboard.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('复制失败保留当前任务并可显式重试', (tester) async {
    var shouldFail = true;
    var attempts = 0;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method != 'Clipboard.setData') return null;
      attempts += 1;
      if (shouldFail) {
        throw PlatformException(code: 'clipboard-unavailable');
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () =>
                  unawaited(copyPostCardValue(context, '正文', '已复制')),
              child: const Text('复制'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('复制'));
    await tester.pumpAndSettle();
    expect(attempts, 1);
    expect(find.text('复制失败'), findsOneWidget);
    expect(find.byKey(const Key('copy-failure-retry')), findsOneWidget);

    shouldFail = false;
    await tester.tap(find.byKey(const Key('copy-failure-retry')));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('复制失败'), findsNothing);
    expect(find.text('已复制'), findsOneWidget);
  });

  testWidgets('结构化复制失败后重试会重新捕获并写入新 marker', (tester) async {
    const scope = SessionScope(accountId: 'reader-account', generation: 3);
    final store = WenyouEditorClipboardStore();
    final gateway = _RetryClipboardGateway();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => unawaited(
                copyPostCardContent(
                  context,
                  '结构已复制',
                  write: () => copyReaderMarkdownToClipboard(
                    markdown: '**粗体**',
                    scope: scope,
                    clipboardGateway: gateway,
                    clipboardStore: store,
                  ),
                ),
              ),
              child: const Text('结构化复制'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('结构化复制'));
    await tester.pumpAndSettle();
    expect(gateway.markers, hasLength(1));
    expect(find.text('复制失败'), findsOneWidget);

    await tester.tap(find.byKey(const Key('copy-failure-retry')));
    await tester.pumpAndSettle();
    expect(gateway.markers, hasLength(2));
    expect(gateway.markers[1], isNot(gateway.markers[0]));
    expect(find.text('结构已复制'), findsOneWidget);

    final resolution = store.resolve(
      gateway.text!,
      marker: gateway.markers.last,
      scope: scope,
    );
    expect(resolution.delta, isNotNull);
    expect(MarkdownDeltaCodec.encode(resolution.delta!), '**粗体**');
  });

  testWidgets('从中央操作窗复制只写入一次并显示成功提示', (tester) async {
    var attempts = 0;
    String? copiedText;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method != 'Clipboard.setData') return null;
      attempts += 1;
      copiedText = (call.arguments as Map<Object?, Object?>)['text'] as String?;
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (pageContext) => PostCardActionMenu(
              canCopyText: true,
              canEdit: false,
              canDelete: false,
              canReport: false,
              pending: false,
              semanticLabel: '楼层操作',
              actionKeyPrefix: 'copy-flow',
              onSelected: (action) {
                if (action == PostCardAction.copyText) {
                  unawaited(copyPostCardValue(pageContext, '楼层正文', '内容已复制'));
                }
              },
              anchorBuilder: (context, handle) => FilledButton(
                key: const Key('copy-flow-trigger'),
                onPressed: handle.open,
                child: const Text('打开操作'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('copy-flow-trigger')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('copy-flow-copy')));
    await tester.pumpAndSettle();

    expect(attempts, 1);
    expect(copiedText, '楼层正文');
    expect(find.byKey(const Key('wenyou-modal-action-menu')), findsNothing);
    expect(find.text('复制失败'), findsNothing);
    expect(find.text('内容已复制'), findsOneWidget);
  });

  testWidgets('成功提示异常不会误报复制失败或重复写入', (tester) async {
    var attempts = 0;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method != 'Clipboard.setData') return null;
      attempts += 1;
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ScaffoldMessenger(
            child: Builder(
              builder: (context) => FilledButton(
                key: const Key('copy-without-feedback-target'),
                onPressed: () =>
                    unawaited(copyPostCardValue(context, '正文', '已复制')),
                child: const Text('复制'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('copy-without-feedback-target')));
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isA<AssertionError>());
    expect(attempts, 1);
    expect(find.text('复制失败'), findsNothing);
    expect(find.byKey(const Key('copy-failure-retry')), findsNothing);
  });

  testWidgets('帖子操作只保留长按所需动作且不再重复提供回复', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PostCardActionMenu(
            canCopyText: true,
            canEdit: true,
            canDelete: true,
            canReport: true,
            canPin: true,
            pending: false,
            semanticLabel: '楼层操作',
            actionKeyPrefix: 'content-action-test',
            onSelected: (_) {},
            anchorBuilder: (context, handle) => FilledButton(
              key: const Key('content-action-trigger'),
              onPressed: handle.open,
              child: const Text('打开操作'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('content-action-trigger')));
    await tester.pump();

    expect(find.text('复制内容'), findsOneWidget);
    expect(find.text('复制链接'), findsOneWidget);
    expect(find.text('编辑'), findsOneWidget);
    expect(find.text('置顶到当前子贴'), findsOneWidget);
    expect(find.byKey(const Key('content-action-test-pin')), findsOneWidget);
    expect(find.text('删除'), findsOneWidget);
    expect(find.text('举报'), findsOneWidget);
    expect(find.text('回复'), findsNothing);
    expect(find.byKey(const Key('content-action-test-reply')), findsNothing);
  });
}

class _RetryClipboardGateway implements EditorClipboardGateway {
  final markers = <String>[];
  String? text;

  @override
  Future<EditorClipboardSnapshot> read() async => EditorClipboardSnapshot(
    text: text,
    marker: markers.isEmpty ? null : markers.last,
  );

  @override
  Future<void> write({required String text, required String marker}) async {
    this.text = text;
    markers.add(marker);
    if (markers.length == 1) {
      throw PlatformException(code: 'clipboard-unavailable');
    }
  }
}
