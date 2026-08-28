// ignore_for_file: experimental_member_use

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  final contract =
      jsonDecode(
            File(
              'contracts/editor-clipboard-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final goldenCases = (contract['goldenCases'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  for (final fixture in goldenCases.where(
    (fixture) => fixture['kind'] != 'reader-copy',
  )) {
    testWidgets('${fixture['id']} 编辑器粘贴遵循 clipboard v1', (tester) async {
      final gateway = _ContractClipboardGateway(
        text: fixture['plainText'] as String,
      );
      final session = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: (_) {},
        clipboardGateway: gateway,
        clipboardStore: WenyouEditorClipboardStore(),
      );
      addTearDown(session.dispose);

      expect(await session.controller.clipboardPaste(), isTrue);

      final expectedMode = fixture['expectedMode'];
      if (expectedMode == 'internal-reference') {
        expect(
          MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
          '[${fixture['expectedLabel']}](${fixture['expectedHref']})',
        );
      } else {
        expect(
          session.controller.document.toPlainText(),
          '${fixture['expectedText']}\n',
        );
        expect(
          MarkdownDeltaCodec.extractExtensionNodes(
            session.controller.document.toDelta(),
          ),
          isEmpty,
        );
      }
    });
  }

  test('进程内结构化媒体保留，系统 fallback 只写标签', () {
    final store = WenyouEditorClipboardStore();
    final delta = MarkdownDeltaCodec.decode(
      '![表情](https://cdn.example.com/stickers/a.webp '
      '"wenyousite-sticker:v1:cm1234567890123456789012") '
      '![图片](https://cdn.example.com/images/a.png)',
    ).delta;

    final fallback = store.capture(
      delta: delta,
      plainTextFallback: '[表情] [图片]',
      operation: WenyouEditorClipboardOperation.copy,
      marker: 'marker',
      scope: 'session',
    );

    expect(fallback, '[表情] [图片]');
    expect(
      MarkdownDeltaCodec.extractExtensionNodes(
        store.resolve(fallback, marker: 'marker', scope: 'session').delta!,
      ).map((node) => node['type']),
      ['sticker', 'image'],
    );
  });
}

class _ContractClipboardGateway implements EditorClipboardGateway {
  _ContractClipboardGateway({required this.text});

  final String text;

  @override
  Future<EditorClipboardSnapshot> read() async =>
      EditorClipboardSnapshot(text: text);

  @override
  Future<void> write({required String text, required String marker}) async {}
}
