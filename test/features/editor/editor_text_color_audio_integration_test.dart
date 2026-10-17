import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_audio_embed.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_color.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_color_selection.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/text_color_assertions.dart';

const _url = 'https://example.invalid/audio.mp3';
const _red = '#D14343';
const _green = '#25855A';
final _audio = MediaAudio.parse({
  'sourceUrl': _url,
  'mediaId': 'audio',
  'contentType': 'audio/mpeg',
  'size': 16000,
  'durationMs': 1000,
})!;

void main() {
  for (final secondColor in <String?>[null, _green]) {
    test('同一来源链接混色保存时按颜色分开且不反包 span $secondColor', () async {
      final session = _session('[A**B**]($_url)');
      EditorTextColorPolicy.apply(
        session.controller,
        const TextSelection(baseOffset: 0, extentOffset: 1),
        _red,
      );
      if (secondColor != null) {
        EditorTextColorPolicy.apply(
          session.controller,
          const TextSelection(baseOffset: 1, extentOffset: 2),
          secondColor,
        );
      }
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      final expected = colorExpectedUnits([
        ('A', {'color': _red, 'link': _url}),
        ('B', {'color': ?secondColor, 'bold': true, 'link': _url}),
      ]);
      _expectOuterColors(session.localMarkdown);
      expect(
        colorReaderUnits(colorReaderNodes(session.localMarkdown)),
        expected,
      );
      final reopened = _session(session.localMarkdown, audio: true);
      expect(_audioCount(reopened), 0);
      expect(colorDeltaUnits(reopened.controller.document.toDelta()), expected);
      expect(await reopened.flush(), isTrue);
      _expectOuterColors(reopened.localMarkdown);
    });
  }

  test('同一链接的统一颜色包在完整链接外且保留粗体代码', () async {
    final session = _session(
      '<span data-wenyou-color-v1="$_red">[A**B**`C`]($_url)</span>',
      audio: true,
    );
    expect(_audioCount(session), 0);
    expect(await session.flush(), isTrue, reason: session.codecFailure);
    _expectOuterColors(session.localMarkdown);
    final nodes = colorReaderNodes(session.localMarkdown);
    expect(_elements(nodes, 'a'), hasLength(1));
    expect(_elements(nodes, MarkdownTextColor.tag), hasLength(1));
    expect(
      colorReaderUnits(nodes),
      colorExpectedUnits([
        ('A', {'color': _red, 'link': _url}),
        ('B', {'color': _red, 'link': _url, 'bold': true}),
        ('C', {'color': _red, 'link': _url, 'code': true}),
      ]),
    );
    final reopened = _session(session.localMarkdown, audio: true);
    expect(_audioCount(reopened), 0);
    expect(await reopened.flush(), isTrue);
    _expectOuterColors(reopened.localMarkdown);
  });

  test('同 URL 不同来源的彩色链接不合并为一链接或播放器', () async {
    final session = _session(
      '<span data-wenyou-color-v1="$_red">[A]($_url)[**B**]($_url)</span>',
      audio: true,
    );
    expect(await session.flush(), isTrue);
    _expectOuterColors(session.localMarkdown);
    expect(
      _elements(colorReaderNodes(session.localMarkdown), 'a'),
      hasLength(2),
    );
    expect(_audioCount(session), 0);
    final reopened = _session(session.localMarkdown, audio: true);
    expect(_audioCount(reopened), 0);
    expect(await reopened.flush(), isTrue);
    expect(
      _elements(colorReaderNodes(reopened.localMarkdown), 'a'),
      hasLength(2),
    );
  });

  test('未着色的多样式音频仍是同一原子，改色跳过且重开仍保留', () async {
    final session = _session('[**A**与*B*]($_url)', audio: true);
    expect(_audioCount(session), 1);
    final before = session.controller.document.toDelta();
    expect(
      EditorTextColorPolicy.apply(
        session.controller,
        const TextSelection(baseOffset: 0, extentOffset: 1),
        _red,
      ),
      isFalse,
    );
    expect(session.controller.document.toDelta(), before);
    expect(await session.flush(), isTrue);
    expect(
      _elements(colorReaderNodes(session.localMarkdown), 'a'),
      hasLength(1),
    );
    final reopened = _session(session.localMarkdown, audio: true);
    expect(_audioCount(reopened), 1);
    expect(await reopened.flush(), isTrue);
  });
}

RichEditorSession _session(String markdown, {bool audio = false}) {
  final session = RichEditorSession(
    initialMarkdown: markdown,
    initialMediaAudios: audio ? {_url: _audio} : const {},
    onMarkdownChanged: (_) {},
  );
  addTearDown(session.dispose);
  expect(session.isSourceProtected, isFalse);
  return session;
}

int _audioCount(RichEditorSession session) => session.controller.document
    .toDelta()
    .operations
    .where(
      (op) =>
          op.data is Map &&
          (op.data as Map).containsKey(MarkdownAudioEmbed.type),
    )
    .length;

List<md.Element> _elements(List<md.Node> nodes, String tag) => [
  for (final node in nodes)
    if (node is md.Element) ...[
      if (node.tag == tag) node,
      ..._elements(node.children ?? [], tag),
    ],
];

void _expectOuterColors(String markdown) {
  void visit(List<md.Node> nodes, {bool inline = false}) {
    for (final node in nodes.whereType<md.Element>()) {
      if (node.tag == MarkdownTextColor.tag) {
        // Backend 08bb 的独立语法约束：颜色必须包在链接与其余 marks 外侧。
        expect(inline, isFalse, reason: markdown);
      }
      visit(
        node.children ?? [],
        inline:
            inline ||
            const {'a', 'strong', 'em', 'del', 'code'}.contains(node.tag),
      );
    }
  }

  visit(colorReaderNodes(markdown));
}
