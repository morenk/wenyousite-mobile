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
  testWidgets('原文件名安全往返，旧占位恢复补名，用户自定义label与marks保留', (tester) async {
    for (final name in ['雨夜 [原声] (现场).wav', 'a_*`<>.flac']) {
      final session = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: (_) {},
      );
      session.insertLocalAudio('new', filename: name);
      session.resolveLocalAudio('new', _audio, filename: name);
      expect(
        await session.flush(),
        isTrue,
        reason: '$name: ${session.codecFailure}',
      );
      final block = md.Document(
        encodeHtml: false,
      ).parse(session.localMarkdown).single;
      expect((block as md.Element).textContent, name);
      session.applyExternalMarkdown(session.localMarkdown);
      expect(await session.flush(), isTrue);
      expect(
        md.Document(
          encodeHtml: false,
        ).parse(session.localMarkdown).single.textContent,
        name,
      );
      session.dispose();
    }
    final old = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
    );
    addTearDown(old.dispose);
    old.insertLocalAudio('old');
    old.resolveLocalAudio('old', _audio, filename: '现场.wav');
    await old.flush();
    expect(
      md.Document(
        encodeHtml: false,
      ).parse(old.localMarkdown).single.textContent,
      '现场.wav',
    );
    old.applyExternalMarkdown(
      '[**自定义**](https://local.invalid/wenyou-pending-audio/custom)',
    );
    old.resolveLocalAudio('custom', _audio, filename: '不应覆盖.wav');
    await old.flush();
    final projection = MarkdownAudioProjection.fromBlock(
      md.Document(encodeHtml: false).parse(old.localMarkdown).single,
      old.mediaAudios,
    );
    expect(projection!.label, '自定义');
    expect(
      projection.labelRuns,
      everyElement(
        isA<MarkdownAudioLabelRun>().having(
          (run) => run.marks,
          'marks',
          contains('strong'),
        ),
      ),
    );
  });
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
      final blocks = md.Document(
        encodeHtml: false,
      ).parse(session.localMarkdown);
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
    final block = md.Document(
      encodeHtml: false,
    ).parse(session.localMarkdown).single;
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
