import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_compose_controller.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_compose_page.dart';

import '../../support/foundation_test_fonts.dart';
import '../../support/rich_text_behavior_projection.dart';
import '../../support/rich_text_behavior_report.dart';
import 'thread_compose_page_test_support.dart';

void main() {
  setUpAll(loadFoundationTestFonts);
  final report = RichTextBehaviorReport('close');

  testWidgets('共享关闭序列经过真实主题路由与本地快照', (tester) async {
    final fixture =
        jsonDecode(
              File(
                'contracts/rich-text-behavior-v1-fixtures.json',
              ).readAsStringSync(),
            )
            as BehaviorJson;
    final item = (fixture['cases'] as List).cast<BehaviorJson>().singleWhere(
      (item) => item['id'] == 'rtb-close-encode-error',
    );
    final initial = item['initial'] as BehaviorJson;
    final store = ThreadComposePageTestMemorySnapshotStore();
    final controller = await threadComposePageTestReadyController(store);
    controller.updateBody(initial['canonical'] as String);
    await controller.flushLocalSnapshot();
    await _openEditor(tester, controller);
    final quill = tester
        .widget<QuillEditor>(find.byKey(const Key('compose-body')))
        .controller;
    quill.updateSelection(
      RichTextBehaviorProjection(
        quill.document.toDelta(),
      ).decodeSelection(initial['selection'] as BehaviorJson),
      ChangeSource.local,
    );
    report.state(item['id'] as String, 'initial', {
      'canonical': MarkdownDeltaCodec.encode(quill.document.toDelta()),
      'summary': RichTextBehaviorProjection(quill.document.toDelta()).summary,
      'selection': RichTextBehaviorProjection(
        quill.document.toDelta(),
      ).encodeSelection(quill.selection),
    });
    const fault = Attribute<String>(
      'wenyou_test_encoding_failure',
      AttributeScope.inline,
      'synthetic',
    );
    for (final step in (item['steps'] as List).cast<BehaviorJson>()) {
      final operation = step['operation'] as BehaviorJson;
      final expected = step['expected'] as BehaviorJson;
      if (operation['type'] == 'insertText') {
        final text = operation['text'] as String;
        final position = quill.selection.start;
        quill.replaceText(
          position,
          0,
          text,
          TextSelection.collapsed(offset: position + text.length),
        );
      } else {
        quill.document.format(
          0,
          1,
          operation['outcome'] == 'encode-error'
              ? fault
              : Attribute.clone(fault, null),
        );
      }
      final projection = RichTextBehaviorProjection(quill.document.toDelta());
      final actual = <String, Object?>{
        'canonical': null,
        'summary': projection.summary,
        'selection': projection.encodeSelection(quill.selection),
      };
      expect(projection.summary, expected['summary']);
      expect(
        projection.encodeSelection(quill.selection),
        expected['selection'],
      );
      if (expected['canonical'] == null) {
        expect(
          () => MarkdownDeltaCodec.encode(quill.document.toDelta()),
          throwsA(isA<MarkdownCodecException>()),
        );
      } else {
        actual['canonical'] = MarkdownDeltaCodec.encode(
          quill.document.toDelta(),
        );
        expect(
          MarkdownDeltaCodec.encode(quill.document.toDelta()),
          expected['canonical'],
        );
      }
      if (operation['type'] == 'close') {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        final stayed = find.byType(ThreadComposePage).evaluate().isNotEmpty;
        expect(stayed ? 'stay' : 'close', expected['navigation']);
        final save = expected['save'] as BehaviorJson;
        expect(store.snapshot!.body, save['persistedMarkdown']);
        expect(
          jsonEncode(projection.summary) !=
              jsonEncode(
                RichTextBehaviorProjection(
                  MarkdownDeltaCodec.decode(store.snapshot!.body).delta,
                ).summary,
              ),
          save['dirty'],
        );
        actual['navigation'] = stayed ? 'stay' : 'close';
        actual['save'] = {
          'target': 'local-snapshot',
          'requestMarkdown': null,
          'persistedMarkdown': store.snapshot!.body,
          'dirty':
              jsonEncode(projection.summary) !=
              jsonEncode(
                RichTextBehaviorProjection(
                  MarkdownDeltaCodec.decode(store.snapshot!.body).delta,
                ).summary,
              ),
        };
      }
      report.state(item['id'] as String, step['id'] as String, actual);
    }
  });

  testWidgets('编码失败时返回保留当前正文和有效快照，恢复后保存退出', (tester) async {
    final store = ThreadComposePageTestMemorySnapshotStore();
    final controller = await threadComposePageTestReadyController(store);
    controller.updateBody('有效正文 A');
    await controller.flushLocalSnapshot();
    final validSnapshot = store.snapshot;
    await _openEditor(tester, controller);
    final editor = tester.widget<QuillEditor>(
      find.byKey(const Key('compose-body')),
    );
    // 故障注入：模拟绕过输入来源保护的异常 producer，不代表已知用户操作。
    final document = editor.controller.document;
    document.delete(0, document.length - 1);
    document.insert(0, '**待保存 B**');
    expect(
      () => MarkdownDeltaCodec.encode(document.toDelta()),
      throwsA(isA<MarkdownCodecException>()),
    );
    final failedDelta = document.toDelta().toJson();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ThreadComposePage), findsOneWidget);
    expect(document.toDelta().toJson(), failedDelta);
    expect(store.snapshot, same(validSnapshot));
    expect(controller.state.body, '有效正文 A');
    // 连续返回仍不能丢稿，也不能把一次失败永久锁成无法退出。
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ThreadComposePage), findsOneWidget);

    document.format(
      0,
      document.length - 1,
      Attribute<bool>(
        MarkdownDeltaCodec.literalTextAttribute,
        AttributeScope.inline,
        true,
      ),
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ThreadComposePage), findsNothing);
    expect(find.text('编辑前页面'), findsOneWidget);
    expect(store.snapshot!.body, r'\*\*待保存 B\*\*');
    expect(store.snapshot, isNot(same(validSnapshot)));
  });

  testWidgets('只读原文禁止发布，未修改时可保留原文并关闭', (tester) async {
    const source = '历史正文 [[widget:v9:future]]';
    final store = ThreadComposePageTestMemorySnapshotStore();
    final repository = ThreadComposePageTestFakeRepository();
    final controller = await threadComposePageTestReadyController(
      store,
      repository: repository,
    );
    controller
      ..updateTitle('历史主题')
      ..updateBody(source);
    await _openEditor(tester, controller);
    final editor = tester.widget<QuillEditor>(
      find.byKey(const Key('compose-body')),
    );
    expect(editor.controller.readOnly, isTrue);
    expect(find.text('这段内容暂不支持编辑，原文已保留。'), findsOneWidget);
    await tester.tap(find.byKey(const Key('compose-publish')));
    await tester.pumpAndSettle();
    expect(repository.createCalls, 0);
    expect(controller.state.body, source);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ThreadComposePage), findsNothing);
    expect(store.snapshot!.body, source);
  });
}

Future<void> _openEditor(
  WidgetTester tester,
  ThreadComposeController controller,
) async {
  final navigator = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appCapabilitiesProvider.overrideWithValue(const AppCapabilities()),
        stickersEnabledProvider.overrideWithValue(false),
        threadComposeControllerProvider.overrideWith((ref) => controller),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        navigatorKey: navigator,
        home: const Scaffold(body: Text('编辑前页面')),
      ),
    ),
  );
  unawaited(
    navigator.currentState!.push<void>(
      MaterialPageRoute(builder: (_) => const ThreadComposePage()),
    ),
  );
  await tester.pumpAndSettle();
}
