import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const dice = '[[dice:v1:550e8400-e29b-41d4-a716-446655440000:1d20]]';
  for (final token in [dice, '[[dice:v2:example:1d20]]', '@全体玩家']) {
    for (final source in [
      '[链接](https://example.com "$token")',
      '[链接](https://example.com/$token)',
      '<https://example.com/$token>',
      'https://example.com/$token',
      '`$token`',
      '`` `$token` ``',
    ]) {
      test('代码或链接内部示例不会提升为协议节点：$source', () async {
        final decoded = MarkdownDeltaCodec.decode(source);
        expect(decoded.issues, isEmpty);
        expect(
          MarkdownDeltaCodec.extractExtensionNodes(decoded.delta),
          isEmpty,
        );
        final session = RichEditorSession(
          initialMarkdown: source,
          onMarkdownChanged: (_) {},
        );
        addTearDown(session.dispose);
        expect(session.isSourceProtected, isFalse);
        expect(await session.flush(), isTrue);
        final saved = MarkdownDeltaCodec.encode(decoded.delta);
        final reopened = MarkdownDeltaCodec.decode(saved);
        expect(reopened.issues, isEmpty);
        expect(
          MarkdownDeltaCodec.extractExtensionNodes(reopened.delta),
          isEmpty,
        );
        if (source.startsWith('[链接]')) {
          // Quill 尚无 title 字段，沿用完整源码保留策略，不能丢弃标题。
          expect(
            Document.fromDelta(decoded.delta).toPlainText(),
            source.contains('"') ? '$source\n' : '链接\n',
          );
          if (source.contains('"')) expect(saved, source);
          expect(
            md.Document(
              encodeHtml: false,
            ).parseInline(saved).single.textContent,
            '链接',
          );
        }
      });
    }
  }

  test('链接标题的骰子示例不占用正文骰子身份，真实节点仍可编辑', () {
    const source = '[链接](https://example.com "$dice") $dice';
    final decoded = MarkdownDeltaCodec.decode(source);
    expect(decoded.issues, isEmpty);
    expect(
      MarkdownDeltaCodec.extractExtensionNodes(decoded.delta),
      hasLength(1),
    );
    final saved = MarkdownDeltaCodec.encode(decoded.delta);
    expect(MarkdownDeltaCodec.decode(saved).issues, isEmpty);
  });
}
