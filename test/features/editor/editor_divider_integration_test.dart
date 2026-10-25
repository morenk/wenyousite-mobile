import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_audio_embed.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/features/editor/presentation/literal_text_quill_controller.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/text_color_assertions.dart';

const _audioUrl = 'https://example.invalid/audio.mp3';
const _linkUrl = 'https://example.invalid/page';
final _audio = MediaAudio.parse({
  'sourceUrl': _audioUrl,
  'mediaId': 'audio',
  'contentType': 'audio/mpeg',
  'size': 16000,
  'durationMs': 1000,
})!;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('分隔线补边界不清掉待输入色，补边界与输入只占一步历史', () {
    final controller = LiteralTextQuillController(
      document: Document.fromDelta(
        MarkdownDeltaCodec.decode('前\n\n---\n\n后').delta,
      ),
      selection: const TextSelection.collapsed(offset: 4),
      config: const QuillControllerConfig(),
    );
    addTearDown(controller.dispose);
    final before = controller.document.toDelta();
    controller.useColorForTyping('#D14343');
    controller.replaceText(4, 0, '新', const TextSelection.collapsed(offset: 5));
    expect(controller.captureTypingStyle().hasColor, isTrue);
    expect(controller.typingColor, '#D14343');
    expect(controller.document.toPlainText(), '前\n\n\uFFFC\n新\n\n后\n');
    final saved = MarkdownDeltaCodec.encode(controller.document.toDelta());
    expect(
      colorReaderUnits(colorReaderNodes(saved)),
      colorExpectedUnits([
        ('前', {}),
        ('新', {'color': '#D14343'}),
        ('后', {}),
      ]),
    );
    expect(controller.document.history.stack.undo, hasLength(1));
    final edited = controller.document.toDelta();
    final selected = controller.selection;
    controller.undo();
    expect(controller.document.toDelta(), before);
    expect(controller.document.history.stack.undo, isEmpty);
    controller.redo();
    expect(controller.document.toDelta(), edited);
    expect(controller.selection, selected);
    expect(controller.typingColor, '#D14343');
  });

  test('分隔线编辑保存重开保留音频标签、同URL链接、字体颜色及投影历史', () async {
    const source =
        '前\n\n---\n\n[**音频**]($_audioUrl)\n\n[甲]($_linkUrl)[乙]($_linkUrl)';
    final session = RichEditorSession(
      initialMarkdown: source,
      initialMediaAudios: {_audioUrl: _audio},
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    final controller = session.controller;
    final before = controller.document.toDelta();
    final audioPayload = _audioPayload(session);
    final divider = controller.document.toPlainText().indexOf('\uFFFC');
    controller.updateSelection(
      TextSelection.collapsed(offset: divider + 1),
      ChangeSource.local,
    );
    controller.useColorForTyping('#25855A');
    controller.useFontForTyping('wenkai');
    controller.replaceText(
      divider + 1,
      0,
      '新',
      TextSelection.collapsed(offset: divider + 2),
    );
    expect(await session.flush(), isTrue, reason: session.codecFailure);
    final saved = session.localMarkdown;
    final nodes = colorReaderNodes(saved);
    expect(
      colorReaderUnits(nodes),
      colorExpectedUnits([
        ('前', {}),
        ('新', {'font': 'wenkai', 'color': '#25855A'}),
        ('音频', {'bold': true, 'link': _audioUrl}),
        ('甲乙', {'link': _linkUrl}),
      ]),
    );
    expect(
      nodes.whereType<md.Element>().where((node) => node.tag == 'hr'),
      hasLength(1),
    );
    expect(_links(nodes).map((node) => node.textContent), ['音频', '甲', '乙']);
    expect(controller.document.history.stack.undo, hasLength(1));
    final edited = controller.document.toDelta();
    expect(_audioPayload(session), audioPayload);
    final selected = controller.selection;
    session.replaceMediaAudios({});
    session.replaceMediaAudios({_audioUrl: _audio});
    expect(controller.document.toDelta(), edited);
    expect(controller.document.history.stack.undo, hasLength(1));
    controller.undo();
    expect(controller.document.toDelta(), before);
    expect(controller.document.history.stack.undo, isEmpty);
    controller.redo();
    expect(controller.document.toDelta(), edited);
    expect(controller.selection, selected);
    expect(await session.flush(), isTrue);

    final reopened = RichEditorSession(
      initialMarkdown: saved,
      initialMediaAudios: {_audioUrl: _audio},
      onMarkdownChanged: (_) {},
    );
    addTearDown(reopened.dispose);
    expect(
      reopened.controller.document.toPlainText().replaceAll('\n', ''),
      '前\uFFFC新\uFFFC甲乙',
    );
    final projection = MarkdownAudioEmbed.projection(_audioPayload(reopened), {
      _audioUrl: _audio,
    })!;
    expect(projection.label, '音频');
    expect(projection.audio.sourceUrl, _audioUrl);
    expect(
      projection.labelRuns.every((run) => run.marks.contains('strong')),
      isTrue,
    );
    expect(await reopened.flush(), isTrue);
    expect(
      _links(
        colorReaderNodes(reopened.localMarkdown),
      ).map((node) => node.textContent),
      ['音频', '甲', '乙'],
    );
  });
}

Object? _audioPayload(RichEditorSession session) {
  final data = session.controller.document
      .toDelta()
      .operations
      .map((op) => op.data)
      .whereType<Map>()
      .singleWhere((data) => data.containsKey(MarkdownAudioEmbed.type));
  return data[MarkdownAudioEmbed.type];
}

Iterable<md.Element> _links(Iterable<md.Node> nodes) sync* {
  for (final node in nodes.whereType<md.Element>()) {
    if (node.tag == 'a') yield node;
    yield* _links(node.children ?? []);
  }
}
