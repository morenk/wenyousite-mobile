import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_clipboard_text.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/core/storage/app_database.dart';
import 'package:wenyousite_mobile/features/editor/data/editor_snapshot_store.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import '../../support/block_boundary_fixtures.dart';
import '../../support/editor_test_paste.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fixture = loadBlockBoundaryFixture();
  for (final item
      in (fixture['clipboardCases'] as List).cast<Map<String, dynamic>>()) {
    testWidgets('整篇结构复制与外部纯文本 ${item['id']}', (tester) async {
      final gateway = _Gateway();
      final store = WenyouEditorClipboardStore();
      final session = RichEditorSession(
        initialMarkdown: item['markdown'] as String,
        onMarkdownChanged: (_) {},
        clipboardStore: store,
        clipboardGateway: gateway,
      );
      addTearDown(session.dispose);
      session.controller.updateSelection(
        TextSelection(
          baseOffset: 0,
          extentOffset: session.controller.document.length - 1,
        ),
        ChangeSource.local,
      );
      expect(await session.copySelection(), isTrue);
      expect(gateway.snapshot.text, item['plainText']);
      expect(gateway.snapshot.text, isNot(contains('wenyousite-align')));
      final pasted = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: (_) {},
        clipboardStore: store,
        clipboardGateway: gateway,
      );
      addTearDown(pasted.dispose);
      expect(await pasteEditorClipboard(pasted.controller), isTrue);
      await tester.pump();
      expect(await pasted.flush(), isTrue);
      expect(
        MarkdownDeltaCodec.encode(pasted.controller.document.toDelta()),
        item['serialized'],
      );
      final plain = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: (_) {},
        clipboardStore: WenyouEditorClipboardStore(),
        clipboardGateway: gateway,
      );
      addTearDown(plain.dispose);
      expect(await pasteEditorClipboard(plain.controller), isTrue);
      await tester.pump();
      expect(
        boundaryRows(
          plain.controller.document.toDelta(),
        ).map((row) => row['alignment']),
        everyElement('left'),
      );
      expect(await plain.flush(), isTrue);
    });
  }
  for (final direction in ['center', 'right']) {
    test('v5 图片纯文本投影无隐藏 marker 或媒体地址 $direction', () {
      final source =
          '前文\n[wenyousite-align-v1-$direction]: #\n![图片](https://cdn.example.com/a.png)';
      expect(MarkdownClipboardText.project(source), '前文\n[图片]');
    });
    test('本地数据库草稿恢复保留独立对齐块 $direction', () async {
      final source = '前文\n[wenyousite-align-v1-$direction]: #\n正文';
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final store = DatabaseEditorSnapshotStore(database);
      final session = RichEditorSession(
        initialMarkdown: source,
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      final saved = MarkdownDeltaCodec.encode(
        session.controller.document.toDelta(),
      );
      await store.saveThreadSnapshot(
        LocalEditorSnapshot(
          id: threadEditorSnapshotId('boundary-owner'),
          contextType: EditorContextType.thread,
          body: saved,
          metadataJson: '{}',
          clientRequestId: 'boundary-request',
          updatedAt: DateTime.utc(2026, 9, 11),
        ),
      );
      final snapshot = await store.findThreadSnapshot('boundary-owner');
      expect(snapshot!.body, saved);
      final restored = RichEditorSession(
        initialMarkdown: snapshot.body,
        onMarkdownChanged: (_) {},
      );
      addTearDown(restored.dispose);
      expect(
        boundaryRows(
          restored.controller.document.toDelta(),
        ).map((row) => row['alignment']).toList(),
        ['left', direction],
      );
      expect(
        MarkdownDeltaCodec.encode(restored.controller.document.toDelta()),
        saved,
      );
    });
  }
}

class _Gateway implements EditorClipboardGateway {
  EditorClipboardSnapshot snapshot = const EditorClipboardSnapshot(text: null);
  @override
  Future<EditorClipboardSnapshot> read() async => snapshot;
  @override
  Future<void> write({required String text, required String marker}) async {
    snapshot = EditorClipboardSnapshot(text: text, marker: marker);
  }
}
