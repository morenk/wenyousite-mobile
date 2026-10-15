import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_audio_projection.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_submission_guard.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_pending_audio_document.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

final _audio = MediaAudio.parse({
  'sourceUrl': 'https://storage.example/a.mp3',
  'mediaId': 'a',
  'contentType': 'audio/mpeg',
  'size': 16000,
  'durationMs': 1000,
})!;

void main() {
  for (final placement in [0, 2, 4]) {
    testWidgets('插入与完成音频保留独立段落/选区 $placement', (tester) async {
      final emitted = <String>[];
      final session = RichEditorSession(
        initialMarkdown: '前文后文',
        onMarkdownChanged: emitted.add,
      );
      addTearDown(session.dispose);
      session.controller.updateSelection(
        TextSelection.collapsed(offset: placement),
        ChangeSource.local,
      );
      session.insertLocalAudio('pending');
      await session.flush();
      expect(session.localAudioIds, {'pending'});
      expect(emitted, isEmpty);
      expect(
        () => MarkdownSubmissionGuard.validate(session.localMarkdown),
        throwsException,
      );
      final selection = session.controller.selection;
      session.resolveLocalAudio('pending', _audio);
      await session.flush();
      expect(session.controller.selection, selection);
      expect(session.localAudioIds, isEmpty);
      expect(session.codecFailure, isNull);
      final blocks = md.Document().parse(session.localMarkdown);
      expect(
        blocks
            .map(
              (b) => MarkdownAudioProjection.fromBlock(b, session.mediaAudios),
            )
            .whereType<MarkdownAudioProjection>(),
        hasLength(1),
      );
      expect(emitted.last, session.localMarkdown);
    });
  }
  testWidgets('同URL相邻独立链接经过真实Quill仍保持两个链接', (tester) async {
    final source = '[甲](${_audio.sourceUrl})[乙](${_audio.sourceUrl})';
    final session = RichEditorSession(
      initialMarkdown: source,
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    expect(await session.flush(), isTrue);
    final block = md.Document().parse(session.localMarkdown).single;
    expect(
      MarkdownAudioProjection.fromBlock(block, {_audio.sourceUrl: _audio}),
      isNull,
    );
    expect(
      (block as md.Element).children!.whereType<md.Element>().where(
        (e) => e.tag == 'a',
      ),
      hasLength(2),
    );
  });
}
