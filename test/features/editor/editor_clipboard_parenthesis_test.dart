import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_reader_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/editor_test_paste.dart';

void main() {
  const scope = SessionScope(accountId: 'parenthesis-probe', generation: 1);
  final cases = <({String name, String source, String visible})>[
    (
      name: '复杂列表仍只复制媒体标签和安全链接文字',
      source:
          '1. 项目\n'
          r'\(一\) [站外](https://example.com) '
          '![图片](https://example.com/a.png) '
          '[@甲](/users/user-1)',
      visible: '1. 项目\n(一) 站外 [图片] @甲',
    ),
    (
      name: '多段列表与嵌套列表保留可见段落边界',
      source:
          '1. 项目\n\n   '
          r'\(一\) 内容'
          '\n\n   - 子项',
      visible: '1. 项目\n\n(一) 内容\n  • 子项',
    ),
    (
      name: '既有不支持围栏源码的反斜杠不解码',
      source:
          '1. 项目\n\n   ```\n   '
          r'\(代码\)'
          '\n   ```',
      visible:
          '1. 项目\n\n   ```\n   '
          r'\(代码\)'
          '\n   ```',
    ),
    (
      name: '列表懒续行中的转义括号与强调',
      source:
          '1. 项目\n'
          r'\(一\) **内容**',
      visible: '1. 项目\n(一) 内容',
    ),
    (
      name: '无序列表多行中的链接文字与代码',
      source:
          '- 项目\n'
          r'[\(一\)](https://example.com) `\(代码\)`',
      visible:
          '• 项目\n(一) '
          r'\(代码\)',
    ),
    (
      name: '复杂列表双重转义与路径不被二次解码',
      source:
          '1. 项目\n'
          r'\\(一\\) C:\work\notes &amp; 内容',
      visible:
          '1. 项目\n'
          r'\(一\) C:\work\notes & 内容',
    ),
    (
      name: '23 个括号与相邻数字列表的真实结构等价样本',
      source:
          r'\(一\) 正文'
          '\n1. 项目\n2. 内容\n'
          '${List.generate(22, (i) => '\\(项目$i\\) 内容').join('\n')}',
      visible:
          '(一) 正文\n1. 项目\n2. 内容\n'
          '${List.generate(22, (i) => '(项目$i) 内容').join('\n')}',
    ),
    (
      name: '普通文字两行的语法转义',
      source:
          r'\(一\) 项目'
          '\n'
          r'\(二\) 内容',
      visible: '(一) 项目\n(二) 内容',
    ),
    (name: '双重反斜杠保留一个可见反斜杠', source: r'\\(一\\) 项目', visible: r'\(一\) 项目'),
    (name: '反斜杠和括号均转义', source: r'\\\(一\\\) 项目', visible: r'\(一\) 项目'),
    (
      name: '链接文字中的括号',
      source: r'[\(一\) 项目](https://example.com)',
      visible: '(一) 项目',
    ),
    (name: '行内代码保留原始反斜杠', source: r'`\(一\)`', visible: r'\(一\)'),
    (name: '路径保留反斜杠', source: r'C:\work\notes', visible: r'C:\work\notes'),
    (
      name: '23 个普通文字行中的括号',
      source: List.generate(23, (i) => '\\(项目$i\\) 内容').join('\n'),
      visible: List.generate(23, (i) => '(项目$i) 内容').join('\n'),
    ),
  ];
  test('阅读复制降级不改变直接编辑复杂列表的源码保护', () {
    const source =
        '1. 项目\n'
        r'\(一\) **内容**';
    final decoded = MarkdownDeltaCodec.decode(source);
    expect(decoded.issues.single.kind, MarkdownCodecIssueKind.unsupportedList);
    final embed = decoded.delta.operations.first.data as Map;
    expect(
      (embed[MarkdownDeltaCodec.compatibilityEmbed] as Map)['raw'],
      source,
    );
  });
  for (final sample in cases) {
    for (final structured in [true, false]) {
      testWidgets('${sample.name}：${structured ? '结构' : '纯文本'}粘贴及重开', (
        tester,
      ) async {
        final store = WenyouEditorClipboardStore();
        // 使用真实平台 gateway，截获实际传给 Clipboard.setData 的值。
        final platform = tester.binding.defaultBinaryMessenger;
        String? clipboardText;
        platform.setMockMethodCallHandler(SystemChannels.platform, (
          call,
        ) async {
          if (call.method == 'Clipboard.setData') {
            clipboardText = (call.arguments as Map)['text'] as String;
          }
          if (call.method == 'Clipboard.getData') {
            return {'text': clipboardText};
          }
          return null;
        });
        addTearDown(() {
          platform.setMockMethodCallHandler(SystemChannels.platform, null);
        });
        await copyReaderMarkdownToClipboard(
          markdown: sample.source,
          scope: scope,
          clipboardStore: store,
        );
        expect(clipboardText, sample.visible);

        // 再捕获同一入口的 marker，区分内部结构和进程丢失后的纯文本。
        final gateway = _MemoryClipboard();
        await copyReaderMarkdownToClipboard(
          markdown: sample.source,
          scope: scope,
          clipboardStore: store,
          clipboardGateway: gateway,
        );
        expect(gateway.snapshot.text, sample.visible);
        if (!structured) store.clear();
        String? saved;
        final session = RichEditorSession(
          initialMarkdown: '',
          onMarkdownChanged: (value) => saved = value,
          clipboardScope: scope,
          clipboardGateway: gateway,
          clipboardStore: store,
        );
        addTearDown(session.dispose);
        expect(await pasteEditorClipboard(session.controller), isTrue);
        // Quill 的纯文字接口对原子提及返回占位符；另核对真实标签。
        final hasMention = structured && sample.source.contains('[@甲]');
        final editableText = hasMention
            ? sample.visible.replaceFirst('@甲', '\uFFFC')
            : sample.visible;
        expect(session.controller.document.toPlainText(), '$editableText\n');
        expect(await session.flush(), isTrue);
        expect(saved, isNotNull);
        final reopened = RichEditorSession(
          initialMarkdown: saved!,
          onMarkdownChanged: (_) {},
        );
        addTearDown(reopened.dispose);
        expect(reopened.controller.document.toPlainText(), '$editableText\n');
        if (hasMention) {
          for (final editor in [session, reopened]) {
            final embed =
                editor.controller.document
                        .toDelta()
                        .operations
                        .where((operation) => operation.data is Map)
                        .single
                        .data
                    as Map;
            expect(
              (embed[MarkdownDeltaCodec.mentionEmbed] as Map)['label'],
              '@甲',
            );
          }
        }
      });
    }
  }

  testWidgets('外部纯文本有意输入的转义和路径不被解码', (tester) async {
    const text = r'\(一\) \\(二) C:\work\notes `\(代码\)`';
    final gateway = _MemoryClipboard()
      ..snapshot = const EditorClipboardSnapshot(text: text);
    String? saved;
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (value) => saved = value,
      clipboardGateway: gateway,
      clipboardStore: WenyouEditorClipboardStore(),
    );
    addTearDown(session.dispose);
    expect(await pasteEditorClipboard(session.controller), isTrue);
    expect(session.controller.document.toPlainText(), '$text\n');
    expect(await session.flush(), isTrue);
    final reopened = RichEditorSession(
      initialMarkdown: saved!,
      onMarkdownChanged: (_) {},
    );
    addTearDown(reopened.dispose);
    expect(reopened.controller.document.toPlainText(), '$text\n');
  });
}

class _MemoryClipboard implements EditorClipboardGateway {
  EditorClipboardSnapshot snapshot = const EditorClipboardSnapshot(text: null);

  @override
  Future<EditorClipboardSnapshot> read() async => snapshot;

  @override
  Future<void> write({required String text, required String marker}) async {
    snapshot = EditorClipboardSnapshot(text: text, marker: marker);
  }
}
