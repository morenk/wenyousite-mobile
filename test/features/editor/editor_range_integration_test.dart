import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/editor/quill_document_range.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_audio_embed.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/features/editor/presentation/audio_projected_quill_controller.dart';

const _url = 'https://example.invalid/audio.mp3';
const _red = '#D14343';
const _green = '#25855A';
const _font = 'tfv_00000000000000000000000000000001';
final _audios = {
  _url: MediaAudio.parse({
    'sourceUrl': _url,
    'mediaId': 'range-audio',
    'contentType': 'audio/mpeg',
    'size': 16000,
    'durationMs': 1000,
  })!,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final initiallyProjected in [false, true]) {
    for (final invalid in ['negative', 'sentinel', 'overflow', 'length']) {
      test('音频投影=$initiallyProjected 的非法范围 $invalid 保留正文、输入样式和两侧历史', () {
        var audios = initiallyProjected ? _audios : <String, MediaAudio>{};
        var projectionReads = 0;
        final decoded = MarkdownDeltaCodec.decode('[长音频标签]($_url)\n\n尾');
        final controller = AudioProjectedQuillController(
          document: Document.fromDelta(
            MarkdownAudioEmbed.project(decoded.delta, audios),
          ),
          selection: const TextSelection.collapsed(offset: 0),
          config: const QuillControllerConfig(),
          audios: () {
            projectionReads++;
            return audios;
          },
        );
        addTearDown(controller.dispose);
        final tail = controller.document.length - 1;
        controller.updateSelection(
          TextSelection.collapsed(offset: tail),
          ChangeSource.local,
        );
        controller.useColorForTyping(_red);
        controller.replaceText(
          tail,
          0,
          '红😀',
          TextSelection.collapsed(offset: tail + 3),
        );
        controller.useColorForTyping(_green);
        controller.replaceText(
          tail + 3,
          0,
          '绿',
          TextSelection.collapsed(offset: tail + 4),
        );
        controller.undo();
        controller.useColorForTyping(_red);
        controller.useFontForTyping(_font);

        // 元数据已变化，但视图尚未刷新。拒绝输入不能顺便投影、改坐标或历史。
        audios = initiallyProjected ? <String, MediaAudio>{} : _audios;
        final before = controller.document.toDelta();
        expect(MarkdownAudioEmbed.project(before, audios), isNot(before));
        final selection = controller.selection;
        final style = controller.toggledStyle;
        final history = controller.document.history;
        final undo = List.of(history.stack.undo);
        final redo = List.of(history.stack.redo);
        expect(undo, hasLength(1));
        expect(redo, hasLength(1));
        final lastRecorded = history.lastRecorded;
        projectionReads = 0;
        final (start, length) = switch (invalid) {
          'negative' => (-1, 0),
          'sentinel' => (controller.document.length, 0),
          'overflow' => (0, controller.document.length + 1),
          _ => (1, -1),
        };
        controller.replaceText(
          start,
          length,
          '拒绝',
          const TextSelection.collapsed(offset: 0),
        );
        expect(controller.document.toDelta(), before);
        expect(controller.selection, selection);
        expect(controller.typingColor, _red);
        expect(controller.captureTypingStyle().font, _font);
        expect(controller.toggledStyle, style);
        expect(projectionReads, 0);
        expect(history.lastRecorded, lastRecorded);
        expect(history.stack.undo, hasLength(undo.length));
        expect(history.stack.redo, hasLength(redo.length));
        expect(history.stack.undo.single, same(undo.single));
        expect(history.stack.redo.single, same(redo.single));

        // 正常元数据刷新仍更新视图，并保持输入色、有效替换和撤销重做。
        controller.projectAudio();
        expect(
          readQuillDocumentRange(
            controller.document,
            0,
            controller.document.length - 1,
          ),
          initiallyProjected ? '长音频标签\n尾红😀' : '\uFFFC\n尾红😀',
        );
        expect(controller.typingColor, _red);
        expect(controller.captureTypingStyle().font, _font);
        final projected = controller.document.toDelta();
        final at = controller.selection.start;
        controller.replaceText(
          at,
          0,
          '续',
          TextSelection.collapsed(offset: at + 1),
        );
        expect(
          controller.document.collectStyle(at, 1).attributes['color']?.value,
          _red,
        );
        expect(
          controller.document.collectStyle(at, 1).attributes['font']?.value,
          _font,
        );
        expect(controller.typingColor, _red);
        final after = controller.document.toDelta();
        controller.undo();
        expect(controller.document.toDelta(), projected);
        expect(controller.selection.start, at);
        controller.redo();
        expect(controller.document.toDelta(), after);
        expect(controller.selection.start, at + 1);
      });
    }
  }
}
