import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_clipboard_text.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_reader_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_site_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'editor_clipboard_contract_test_support.dart';

void main() {
  test('站内 HTML 成对保留原标签和精确角色，非法或缺项不回退猜目标', () {
    const href = '/users/user-1?rpIdentityId=c00000000000000000000000a';
    String html(String attributes) =>
        '<div data-wenyou-clipboard="2" data-wenyou-clipboard-source="reader"><p><a href="/users/user-1?identityMode=ACCOUNT" $attributes>@站内用户</a></p></div>';
    final parser = WenyouSiteClipboardParser();
    final source = parser.parse(
      html(
        'data-wenyou-mention-source-href="$href" data-wenyou-mention-source-label="@原角色"',
      ),
    )!;
    expect(MarkdownDeltaCodec.encode(source), '[@原角色]($href)');
    for (final target in [href, '/users/user-1?identityMode=ACCOUNT']) {
      final untrusted = parser.parse(
        html('').replaceFirst('/users/user-1?identityMode=ACCOUNT', target),
      )!;
      expect(untrusted.operations.any((op) => op.data is Map), isFalse);
      expect(MarkdownClipboardText.projectDelta(untrusted), '@站内用户');
    }
    for (final attributes in [
      'data-wenyou-mention-source-href="$href"',
      'data-wenyou-mention-source-label="@原角色"',
      'data-wenyou-mention-source-href="javascript:alert(1)" data-wenyou-mention-source-label="@原角色"',
    ]) {
      final decoded = parser.parse(html(attributes))!;
      expect(decoded.operations.any((op) => op.data is Map), isFalse);
    }
  });

  const source = '[@旧角色](/users/user-1)';
  const labels = {'user-1\u0000旧角色': '站内用户'};
  const scope = SessionScope(accountId: 'viewer', generation: 1);

  testWidgets('阅读复制使用显示昵称作为纯文本，并保留结构化原称呼', (tester) async {
    final gateway = EditorClipboardContractTestRoundTripClipboardGateway();
    final store = WenyouEditorClipboardStore();
    await copyReaderMarkdownToClipboard(
      markdown: source,
      mentionLabels: labels,
      scope: scope,
      clipboardGateway: gateway,
      clipboardStore: store,
    );
    expect(gateway.snapshot.text, '@站内用户');
    final editor = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
      clipboardScope: scope,
      clipboardGateway: gateway,
      clipboardStore: store,
    );
    addTearDown(editor.dispose);
    expect(await pasteEditorClipboard(editor.controller), isTrue);
    expect(
      MarkdownDeltaCodec.encode(editor.controller.document.toDelta()),
      source,
    );
  });

  testWidgets('编辑复制不让显示投影改写原 mention', (tester) async {
    final gateway = EditorClipboardContractTestRoundTripClipboardGateway();
    final store = WenyouEditorClipboardStore();
    final editor = RichEditorSession(
      initialMarkdown: source,
      mentionLabels: labels,
      onMarkdownChanged: (_) {},
      clipboardScope: scope,
      clipboardGateway: gateway,
      clipboardStore: store,
    );
    addTearDown(editor.dispose);
    editor.controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 1),
      ChangeSource.local,
    );
    expect(await editor.copySelection(), isTrue);
    expect(gateway.snapshot.text, '@站内用户');
    final retained = store.resolve(
      gateway.snapshot.text!,
      marker: gateway.snapshot.marker,
      scope: scope,
    );
    expect(MarkdownDeltaCodec.encode(retained.delta!), source);
  });
}
