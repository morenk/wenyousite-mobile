import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_reader_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_site_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'editor_clipboard_contract_test_support.dart';

void registerEditorClipboardContractSafetyAlignmentCases() {
  testWidgets('移动阅读菜单不把松散列表分隔当成空段', (tester) async {
    const threadId = 'cmsewdo0h000x7qv6aa77ll1v';
    const firstPostId = 'cmsewdqcr001a7qv6cy0y38bd';
    const secondPostId = 'cmsewdt0w001n7qv6f6ttylff';
    const source =
        '设定目录占位\n\n'
        '* **第一项**[传送门](/threads/$threadId?post=$firstPostId)\n\n'
        '* **第二项**[传送门](/threads/$threadId?post=$secondPostId)\n\n'
        '<br />';
    const scope = SessionScope(accountId: 'reader-account', generation: 16);
    final store = WenyouEditorClipboardStore();
    final gateway = EditorClipboardContractTestRoundTripClipboardGateway();

    await copyReaderMarkdownToClipboard(
      markdown: source,
      scope: scope,
      clipboardGateway: gateway,
      clipboardStore: store,
    );
    expect(
      gateway.snapshot.text,
      '设定目录占位\n\n'
      '• 第一项传送门\n'
      '• 第二项传送门',
    );

    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
      clipboardScope: scope,
      clipboardGateway: gateway,
      clipboardStore: store,
    );
    addTearDown(session.dispose);
    expect(await pasteEditorClipboard(session.controller), isTrue);

    expect(
      MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
      '设定目录占位\n\n'
      '- **第一项**[传送门](/threads/$threadId?post=$firstPostId)\n'
      '- **第二项**[传送门](/threads/$threadId?post=$secondPostId)\n'
      '\n<br />',
    );
  });

  testWidgets('移动阅读菜单归一无歧义的 CommonMark 块写法', (tester) async {
    const scope = SessionScope(accountId: 'reader-account', generation: 14);
    const source =
        '## 标题 ##\n\n'
        '>\t制表符引用\n\n'
        '-   多空格项目\n'
        '3)\t有序项目\n\n'
        '***\n\n'
        '___\n\n'
        '- - -\n\n'
        '----';
    final store = WenyouEditorClipboardStore();
    final gateway = EditorClipboardContractTestRoundTripClipboardGateway();
    await copyReaderMarkdownToClipboard(
      markdown: source,
      scope: scope,
      clipboardGateway: gateway,
      clipboardStore: store,
    );
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
      clipboardScope: scope,
      clipboardGateway: gateway,
      clipboardStore: store,
    );
    addTearDown(session.dispose);
    expect(await pasteEditorClipboard(session.controller), isTrue);

    final delta = session.controller.document.toDelta();
    final attributes = delta.operations
        .map((operation) => operation.attributes ?? const <String, dynamic>{})
        .toList(growable: false);
    expect(attributes, contains(containsPair('header', 2)));
    expect(attributes, contains(containsPair('blockquote', true)));
    expect(attributes, contains(containsPair('list', 'bullet')));
    expect(attributes, contains(containsPair('list', 'ordered')));
    expect(
      delta.operations
          .where(
            (operation) =>
                operation.data is Map &&
                (operation.data as Map).containsKey(
                  MarkdownDeltaCodec.horizontalRuleEmbed,
                ),
          )
          .length,
      4,
    );
    expect(
      MarkdownDeltaCodec.encode(delta),
      '## 标题\n\n> 制表符引用\n\n-   多空格项目\n1. 有序项目\n\n'
      '---\n\n---\n\n---\n\n---',
    );
  });

  testWidgets('移动阅读菜单保留样式内协议节点并继续标签化媒体', (tester) async {
    const diceId = '550e8400-e29b-41d4-a716-446655440000';
    const scope = SessionScope(accountId: 'reader-account', generation: 13);
    const source =
        '> **前 [传送门](/threads/cmsewdo0h000x7qv6aa77ll1v) '
        '[@张三](/users/user-zhang) @全体玩家 '
        '[[dice:v1:$diceId:1d20]] '
        '![表情](https://cdn.example.com/stickers/a.webp '
        '"wenyousite-sticker:v1:cm1234567890123456789012") '
        '![图片](https://cdn.example.com/images/a.png) 后**';
    final store = WenyouEditorClipboardStore();
    final gateway = EditorClipboardContractTestRoundTripClipboardGateway();

    await copyReaderMarkdownToClipboard(
      markdown: source,
      scope: scope,
      clipboardGateway: gateway,
      clipboardStore: store,
    );

    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
      clipboardScope: scope,
      clipboardGateway: gateway,
      clipboardStore: store,
    );
    addTearDown(session.dispose);
    expect(await pasteEditorClipboard(session.controller), isTrue);

    final delta = session.controller.document.toDelta();
    final attributes = delta.operations
        .map((operation) => operation.attributes ?? const <String, dynamic>{})
        .toList(growable: false);
    final nodes = MarkdownDeltaCodec.extractExtensionNodes(delta);
    final encoded = MarkdownDeltaCodec.encode(delta);
    expect(attributes, contains(containsPair('blockquote', true)));
    expect(attributes, contains(containsPair('bold', true)));
    expect(
      nodes.map((node) => node['type']),
      containsAll(['mention', 'mention_all_players', 'dice']),
    );
    expect(
      delta.operations.any(
        (operation) =>
            operation.data is Map &&
            (operation.data as Map).containsKey(
              MarkdownDeltaCodec.internalReferenceEmbed,
            ),
      ),
      isTrue,
    );
    expect(nodes.map((node) => node['type']), isNot(contains('image')));
    expect(nodes.map((node) => node['type']), isNot(contains('sticker')));
    expect(encoded, contains(r'\[表情\]'));
    expect(encoded, contains(r'\[图片\]'));
    expect(encoded, isNot(contains('cdn.example.com')));
    expect(
      nodes.singleWhere((node) => node['type'] == 'dice')['nodeId'],
      isNot(diceId),
    );
  });

  testWidgets('阅读复制不把代码、转义或不支持块中的语法升级为节点', (tester) async {
    const source =
        '`[@代码](/users/user-code)`\n\n'
        r'\[@转义](/users/user-escaped)'
        '\n\n```md\n'
        '[@围栏](/users/user-fence)\n'
        '```\n\n'
        '- [ ] [任务](/threads/cmsewdo0h000x7qv6aa77ll1v)';
    const scope = SessionScope(accountId: 'reader-account', generation: 15);
    final store = WenyouEditorClipboardStore();
    final gateway = EditorClipboardContractTestRoundTripClipboardGateway();
    await copyReaderMarkdownToClipboard(
      markdown: source,
      scope: scope,
      clipboardGateway: gateway,
      clipboardStore: store,
    );
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
      clipboardScope: scope,
      clipboardGateway: gateway,
      clipboardStore: store,
    );
    addTearDown(session.dispose);
    expect(await pasteEditorClipboard(session.controller), isTrue);

    final delta = session.controller.document.toDelta();
    expect(delta.operations.any((operation) => operation.data is Map), isFalse);
    expect(
      delta.operations.any(
        (operation) => operation.attributes?['link'] != null,
      ),
      isFalse,
    );
    expect(
      delta.operations.any(
        (operation) => operation.attributes?['code'] == true,
      ),
      isTrue,
    );
  });

  test('移动阅读菜单写入失败会清除旧载荷和本次捕获', () async {
    const scope = SessionScope(accountId: 'reader-account', generation: 10);
    final store = WenyouEditorClipboardStore();
    store.capture(
      delta: MarkdownDeltaCodec.decode('旧结构').delta,
      plainTextFallback: '旧结构',
      operation: WenyouEditorClipboardOperation.copy,
      marker: 'old-marker',
      scope: scope,
    );
    final gateway = EditorClipboardContractTestRoundTripClipboardGateway()
      ..failWrites = true;

    await expectLater(
      copyReaderMarkdownToClipboard(
        markdown: '**新结构**',
        scope: scope,
        clipboardGateway: gateway,
        clipboardStore: store,
      ),
      throwsA(isA<PlatformException>()),
    );

    expect(gateway.writeAttempts, 1);
    expect(gateway.snapshot.marker, isNotNull);
    expect(
      store
          .resolve(
            gateway.snapshot.text!,
            marker: gateway.snapshot.marker,
            scope: scope,
          )
          .delta,
      isNull,
    );
    expect(
      store.resolve('旧结构', marker: 'old-marker', scope: scope).delta,
      isNull,
    );
  });

  test('Web envelope 接受 v1/v2 并拒绝未知版本或重复载荷', () {
    const parser = WenyouSiteClipboardParser();

    expect(
      parser.parse(
        '<div data-wenyou-clipboard="2" '
        'data-wenyou-clipboard-source="reader">内容</div>',
      ),
      isNotNull,
    );
    expect(
      parser.parse(
        '<div data-wenyou-clipboard="999" '
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

  test('clipboard v2 仅恢复顶层合法块对齐，v1 强制移除对齐', () {
    const parser = WenyouSiteClipboardParser();
    const body =
        '<p data-wenyou-align="center">居中正文</p>'
        '<h2 data-wenyou-align="right">居右标题</h2>';

    final v2 = parser.parse(
      '<div data-wenyou-clipboard="2" '
      'data-wenyou-clipboard-source="editor">$body</div>',
    );
    final v1 = parser.parse(
      '<div data-wenyou-clipboard="1" '
      'data-wenyou-clipboard-source="editor">$body</div>',
    );

    expect(
      MarkdownDeltaCodec.encode(v2!),
      '[wenyousite-align-v1-center]: #\n居中正文\n\n'
      '[wenyousite-align-v1-right]: #\n## 居右标题',
    );
    expect(MarkdownDeltaCodec.encode(v1!), '居中正文\n\n## 居右标题');
  });

  test('clipboard v2 不从嵌套、空块、普通图片或样式推断对齐', () {
    const parser = WenyouSiteClipboardParser();
    final delta = parser.parse(
      '<div data-wenyou-clipboard="2" '
      'data-wenyou-clipboard-source="reader">'
      '<div><p data-wenyou-align="center">嵌套正文</p></div>'
      '<p data-wenyou-align="right"><br></p>'
      '<p data-wenyou-align="center">正文'
      '<span data-wenyou-clipboard-media="image">[图片]</span></p>'
      '<p style="text-align:right" align="right">样式正文</p>'
      '</div>',
    );

    final markdown = MarkdownDeltaCodec.encode(delta!);
    expect(markdown, isNot(contains('wenyousite-align')));
    expect(markdown, contains('嵌套正文'));
    expect(markdown, contains(r'\[图片\]'));
    expect(markdown, contains('样式正文'));
  });

  testWidgets('移动阅读菜单通过进程内 Delta 保留 v4 块对齐', (tester) async {
    final fixture = readerFixture('reader-aligned-blocks');
    const scope = SessionScope(accountId: 'reader-account', generation: 11);
    final store = WenyouEditorClipboardStore();
    final gateway = EditorClipboardContractTestRoundTripClipboardGateway();

    await copyReaderMarkdownToClipboard(
      markdown: fixture['markdown'] as String,
      scope: scope,
      clipboardGateway: gateway,
      clipboardStore: store,
    );
    expect(gateway.snapshot.text, fixture['expectedPlainText']);
    expect(gateway.snapshot.text, isNot(contains('wenyousite-align')));

    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
      clipboardScope: scope,
      clipboardGateway: gateway,
      clipboardStore: store,
    );
    addTearDown(session.dispose);

    expect(await pasteEditorClipboard(session.controller), isTrue);
    expect(
      MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
      fixture['markdown'],
    );
  });
}
