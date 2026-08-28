// ignore_for_file: experimental_member_use

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_site_clipboard.dart';
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

  testWidgets('Web 阅读态片段粘贴保留文本白名单样式', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
      clipboardGateway: const _ContractClipboardGateway(
        text: '标题\n\n粗体、斜体、删除、代码\n\n引用\n\n• 甲\n• 乙',
        html:
            '<div data-wenyou-clipboard="1" '
            'data-wenyou-clipboard-source="reader">'
            '<h2>标题</h2>'
            '<p><strong>粗体</strong>、<em>斜体</em>、'
            '<del>删除</del>、<code>代码</code></p>'
            '<blockquote><p>引用</p></blockquote>'
            '<ul><li><p>甲</p></li><li><p>乙</p></li></ul>'
            '</div>',
      ),
      clipboardStore: WenyouEditorClipboardStore(),
    );
    addTearDown(session.dispose);

    expect(await session.controller.clipboardPaste(), isTrue);

    expect(
      MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
      '## 标题\n\n**粗体**、*斜体*、~~删除~~、`代码`\n\n'
      '> 引用\n\n- 甲\n- 乙',
    );
  });

  testWidgets('Web 行内片段不改变当前段落边界', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '前后',
      onMarkdownChanged: (_) {},
      clipboardGateway: const _ContractClipboardGateway(
        text: '中',
        html:
            '<div data-wenyou-clipboard="1" '
            'data-wenyou-clipboard-source="reader"><strong>中</strong></div>',
      ),
      clipboardStore: WenyouEditorClipboardStore(),
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection.collapsed(offset: 1),
      ChangeSource.local,
    );

    expect(await session.controller.clipboardPaste(), isTrue);
    expect(
      MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
      '前**中**后',
    );
  });

  testWidgets('Web 块片段在已有正文末尾保持独立块', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '前文',
      onMarkdownChanged: (_) {},
      clipboardGateway: const _ContractClipboardGateway(
        text: '标题',
        html:
            '<div data-wenyou-clipboard="1" '
            'data-wenyou-clipboard-source="reader"><h2>标题</h2></div>',
      ),
      clipboardStore: WenyouEditorClipboardStore(),
      initialSelection: RichEditorSelectionPlacement.end,
    );
    addTearDown(session.dispose);

    expect(await session.controller.clipboardPaste(), isTrue);
    expect(
      MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
      '前文\n\n## 标题',
    );
  });

  testWidgets('Web 阅读态媒体标签化且协议原子按各自规则恢复', (tester) async {
    const oldDiceId = '550e8400-e29b-41d4-a716-446655440000';
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
      clipboardGateway: const _ContractClipboardGateway(
        text: '传送门 @张三 @全体玩家 1d20+2 = 99 [表情] [图片]',
        html:
            '<div data-wenyou-clipboard="1" '
            'data-wenyou-clipboard-source="reader"><p>'
            '<a href="/threads/cmsewdo0h000x7qv6aa77ll1v">传送门</a> '
            '<a href="/users/user-zhang">@张三</a> @全体玩家 '
            '<span data-type="dice_inline" data-node-id="$oldDiceId" '
            'data-notation="1d20+2">1d20+2 = 99</span> '
            '<span data-wenyou-clipboard-media="sticker">忽略资源</span> '
            '<img src="https://cdn.example.com/images/a.webp">'
            '</p></div>',
      ),
      clipboardStore: WenyouEditorClipboardStore(),
    );
    addTearDown(session.dispose);

    expect(await session.controller.clipboardPaste(), isTrue);

    final delta = session.controller.document.toDelta();
    final nodes = MarkdownDeltaCodec.extractExtensionNodes(delta);
    final markdown = MarkdownDeltaCodec.encode(delta);
    final dice = nodes.singleWhere(
      (node) => node['type'] == 'dice',
      orElse: () => fail('未恢复骰子节点：$markdown / $nodes'),
    );
    expect(dice['notation'], '1d20+2');
    expect(dice['nodeId'], isNot(oldDiceId));
    expect(
      nodes.map((node) => node['type']),
      containsAll(['mention', 'mention_all_players', 'dice']),
    );
    expect(nodes.map((node) => node['type']), isNot(contains('image')));
    expect(nodes.map((node) => node['type']), isNot(contains('sticker')));
    expect(markdown, contains('[传送门](/threads/cmsewdo0h000x7qv6aa77ll1v)'));
    expect(markdown, contains('[@张三](/users/user-zhang)'));
    expect(markdown, contains('@全体玩家'));
    expect(markdown, contains(r'\[表情\] \[图片\]'));
    expect(markdown, isNot(contains('1d20+2 = 99')));
  });

  testWidgets('Web 编辑器片段保留媒体节点并重建骰子身份', (tester) async {
    const oldDiceId = '7c9e6679-7425-40de-944b-e07fc1f90ae7';
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
      clipboardGateway: const _ContractClipboardGateway(
        text: '前 [表情] 2d6+1 = 11 后\n\n[图片]',
        html:
            '<div data-wenyou-clipboard="1" '
            'data-wenyou-clipboard-source="editor">'
            '<p>前 <img data-type="sticker-inline" '
            'data-asset-id="cm1234567890123456789012" '
            'src="https://cdn.example.com/stickers/a.webp" alt="表情"> '
            '<span data-type="dice_inline" data-node-id="$oldDiceId" '
            'data-notation="2d6+1">2d6+1 = 11</span> 后</p>'
            '<img data-type="image-block" '
            'src="https://cdn.example.com/images/a.webp" '
            'caption="地图" ratio="1.5">'
            '</div>',
      ),
      clipboardStore: WenyouEditorClipboardStore(),
    );
    addTearDown(session.dispose);

    expect(await session.controller.clipboardPaste(), isTrue);

    final nodes = MarkdownDeltaCodec.extractExtensionNodes(
      session.controller.document.toDelta(),
    );
    expect(
      nodes.map((node) => node['type']),
      containsAll(['sticker', 'dice', 'image']),
    );
    expect(
      nodes.singleWhere((node) => node['type'] == 'dice')['nodeId'],
      isNot(oldDiceId),
    );
    expect(
      MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
      contains('![1.50](https://cdn.example.com/images/a.webp "地图")'),
    );
  });

  test('Web envelope 重新执行白名单并拒绝未知版本或重复载荷', () {
    const parser = WenyouSiteClipboardParser();

    expect(
      parser.parse(
        '<div data-wenyou-clipboard="2" '
        'data-wenyou-clipboard-source="reader">内容</div>',
      ),
      isNull,
    );
    expect(
      parser.parse(
        '<div data-wenyou-clipboard="1" '
        'data-wenyou-clipboard-source="reader">一</div>'
        '<div data-wenyou-clipboard="1" '
        'data-wenyou-clipboard-source="reader">二</div>',
      ),
      isNull,
    );

    final sanitized = parser.parse(
      '<div data-wenyou-clipboard="1" '
      'data-wenyou-clipboard-source="reader">'
      '<p style="color:red" onclick="evil()"><strong>安全</strong>'
      '<a href="javascript:alert(1)">危险链接文字</a>'
      '<script>不可见脚本</script></p></div>',
    );
    expect(sanitized, isNotNull);
    final markdown = MarkdownDeltaCodec.encode(sanitized!);
    expect(markdown, contains('**安全**危险链接文字'));
    expect(markdown, isNot(contains('javascript')));
    expect(markdown, isNot(contains('不可见脚本')));
  });
}

class _ContractClipboardGateway implements EditorClipboardGateway {
  const _ContractClipboardGateway({required this.text, this.html});

  final String text;
  final String? html;

  @override
  Future<EditorClipboardSnapshot> read() async =>
      EditorClipboardSnapshot(text: text, html: html);

  @override
  Future<void> write({required String text, required String marker}) async {}
}
