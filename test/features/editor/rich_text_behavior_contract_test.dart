import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/rich_text_behavior_projection.dart';
import '../../support/rich_text_behavior_report.dart';
import '../../support/rich_text_behavior_save.dart';
import 'rich_editor_session_test_support.dart';

void main() {
  final report = RichTextBehaviorReport('editor');
  final fixture =
      jsonDecode(
            File(
              'contracts/rich-text-behavior-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as BehaviorJson;
  for (final item in (fixture['cases']! as List).cast<BehaviorJson>()) {
    if (item['family'] == 'failure') {
      // 故障必须接入实际业务保存流程；不能用模拟状态机冒充已执行。
      continue;
    }
    testWidgets('共享行为 ${item['id']} 的真实编辑结构与序列化', (tester) async {
      final initial = item['initial']! as BehaviorJson;
      final clipboard = RichEditorSessionTestMemoryEditorClipboardGateway();
      final generatedIds = <String>[];
      final session = RichEditorSession(
        initialMarkdown: initial['canonical']! as String,
        onMarkdownChanged: (_) {},
        imageAlignment: true,
        clipboardGateway: clipboard,
        clipboardStore: WenyouEditorClipboardStore(
          createDiceId: () => generatedIds.removeAt(0),
        ),
      );
      addTearDown(session.dispose);
      if (initial['selection'] case final BehaviorJson selection) {
        session.controller.updateSelection(
          RichTextBehaviorProjection(
            session.controller.document.toDelta(),
          ).decodeSelection(selection),
          ChangeSource.local,
        );
      }
      report.state(
        item['id']! as String,
        'initial',
        _assertState(session, initial, '${item['id']}/initial'),
      );
      if ((item['steps']! as List).cast<BehaviorJson>().any(
        (step) => (step['operation']! as BehaviorJson)['type'] == 'backspace',
      )) {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates:
                FlutterQuillLocalizations.localizationsDelegates,
            home: Scaffold(
              body: QuillEditor(
                controller: session.controller,
                focusNode: session.focusNode,
                scrollController: session.scrollController,
              ),
            ),
          ),
        );
        session.focusNode.requestFocus();
        await tester.pump();
      }
      for (final step in (item['steps']! as List).cast<BehaviorJson>()) {
        BehaviorJson? save;
        final operation = step['operation']! as BehaviorJson;
        final selection = session.controller.selection;
        if (operation['historyBoundary'] == true) {
          session.controller.document.history.lastRecorded = 0;
        }
        switch (operation['type']) {
          case 'enter':
          case 'insertText':
            final text = operation['type'] == 'enter'
                ? '\n'
                : operation['text']! as String;
            session.controller.replaceText(
              selection.start,
              selection.end - selection.start,
              text,
              TextSelection.collapsed(offset: selection.start + text.length),
            );
          case 'backspace':
            await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
          case 'undo':
            session.controller.undo();
          case 'redo':
            session.controller.redo();
          case 'copy':
            expect(await session.copySelection(), isTrue);
          case 'paste':
            if (operation['regeneratedIds'] case final List ids) {
              generatedIds.addAll(ids.cast<String>());
            }
            if (operation['plainText'] case final String text) {
              clipboard.snapshot = EditorClipboardSnapshot(text: text);
            }
            await pasteEditorClipboard(session.controller);
          case 'reopen':
            final canonical = MarkdownDeltaCodec.encode(
              session.controller.document.toDelta(),
              imageAlignment: true,
            );
            session.applyExternalMarkdown(canonical);
          case 'save':
            expect(await session.flush(), isTrue);
            save = await saveBehaviorMarkdown(
              MarkdownDeltaCodec.encode(
                session.controller.document.toDelta(),
                imageAlignment: true,
              ),
            );
            expect(save, (step['expected'] as BehaviorJson)['save']);
          default:
            fail('未实现的共享操作：${operation['type']}');
        }
        await tester.pump();
        if (operation['historyBoundary'] == true) {
          session.controller.document.history.lastRecorded = 0;
        }
        final actual = _assertState(
          session,
          step['expected']! as BehaviorJson,
          '${item['id']}/${step['id']}',
        );
        if (save != null) actual['save'] = save;
        report.state(item['id']! as String, step['id']! as String, actual);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await session.flush();
    });
  }
}

BehaviorJson _assertState(
  RichEditorSession session,
  BehaviorJson expected,
  String id,
) {
  final delta = session.controller.document.toDelta();
  final projection = RichTextBehaviorProjection(delta);
  expect(projection.summary, expected['summary'], reason: '$id/edited');
  if (expected['selection'] case final BehaviorJson selection) {
    expect(
      projection.encodeSelection(session.controller.selection),
      selection,
      reason: '$id/selection',
    );
  }
  expect(
    MarkdownDeltaCodec.encode(delta, imageAlignment: true),
    expected['canonical'],
    reason: '$id/serialized',
  );
  return {
    'canonical': MarkdownDeltaCodec.encode(delta, imageAlignment: true),
    'summary': projection.summary,
    if (expected.containsKey('selection'))
      'selection': projection.encodeSelection(session.controller.selection),
  };
}
