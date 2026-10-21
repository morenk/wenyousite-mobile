import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_audio_embed.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_color_selection.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

const _a = 'https://example.invalid/a.mp3';
const _b = 'https://example.invalid/b.mp3';
const _source = '前\n\n[长音频一]($_a)\n\n中\n\n[长音频二]($_b)\n\n尾';
final _audios = {
  for (final url in [_a, _b])
    url: MediaAudio.parse({
      'sourceUrl': url,
      'mediaId': url,
      'contentType': 'audio/mpeg',
      'size': 16000,
      'durationMs': 1000,
    })!,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('双音频收缩和恢复表示保持既有 undo/redo 两条链及每步精确光标', () async {
    final session = _session();
    final editor = session.controller;
    editor.updateSelection(
      const TextSelection.collapsed(offset: 1),
      ChangeSource.local,
    );
    EditorTextColorPolicy.apply(editor, editor.selection, '#D14343');
    editor.replaceText(1, 0, '首', const TextSelection.collapsed(offset: 2));
    final tail = editor.document.toPlainText().indexOf('尾') + 1;
    editor.updateSelection(
      TextSelection.collapsed(offset: tail),
      ChangeSource.local,
    );
    EditorTextColorPolicy.apply(editor, editor.selection, '#25855A');
    editor.replaceText(tail, 0, '末', TextSelection.collapsed(offset: tail + 1));
    editor.undo();
    expect(editor.document.history.stack.undo, hasLength(1));
    expect(editor.document.history.stack.redo, hasLength(1));
    session.replaceMediaAudios(_audios);
    expect(_atoms(session), 2);
    expect(
      editor.selection.baseOffset,
      editor.document.toPlainText().indexOf('尾') + 1,
    );
    final undoEntry = editor.document.history.stack.undo.single;
    final redoEntry = editor.document.history.stack.redo.single;
    session.replaceMediaAudios(_audios);
    expect(
      identical(editor.document.history.stack.undo.single, undoEntry),
      isTrue,
    );
    expect(
      identical(editor.document.history.stack.redo.single, redoEntry),
      isTrue,
    );
    editor.undo();
    expect(editor.selection, const TextSelection.collapsed(offset: 1));
    expect(editor.document.toPlainText(), '前\n\uFFFC\n中\n\uFFFC\n尾\n');
    editor.redo();
    expect(editor.selection, const TextSelection.collapsed(offset: 2));
    expect(
      editor.document.collectStyle(1, 1).attributes['color']?.value,
      '#D14343',
    );
    editor.redo();
    expect(
      editor.selection.baseOffset,
      editor.document.toPlainText().indexOf('尾') + 2,
    );
    expect(
      editor.document
          .collectStyle(editor.selection.start - 1, 1)
          .attributes['color']
          ?.value,
      '#25855A',
    );
    expect(await session.flush(), isTrue, reason: session.codecFailure);
    session.replaceMediaAudios({});
    expect(_atoms(session), 0);
    editor.undo();
    expect(editor.document.toPlainText(), contains('长音频一'));
    expect(editor.document.toPlainText(), endsWith('尾\n'));
    editor.redo();
    expect(editor.document.toPlainText(), endsWith('尾末\n'));
  });

  test('媒体手势期间前方链接收缩仍校正内部光标，外部选区继续受抑制', () async {
    final session = _session(audios: {_b: _audios[_b]!});
    final editor = session.controller;
    editor.updateSelection(
      TextSelection.collapsed(offset: editor.document.length - 1),
      ChangeSource.local,
    );
    EditorTextColorPolicy.apply(editor, editor.selection, '#D14343');
    editor.beginAudioPointer(17);
    session.replaceMediaAudios(_audios);
    expect(_atoms(session), 2);
    expect(editor.selection.start, editor.document.length - 1);
    final intended = editor.selection;
    editor.updateSelection(
      const TextSelection.collapsed(offset: 0),
      ChangeSource.remote,
    );
    expect(editor.selection, intended);
    editor.endAudioPointer(17);
    await Future<void>.microtask(() {});
    editor.replaceText(
      intended.start,
      0,
      '后',
      TextSelection.collapsed(offset: intended.start + 1),
    );
    expect(editor.document.toPlainText(), endsWith('尾后\n'));
    expect(
      editor.document
          .collectStyle(intended.start, 1)
          .attributes['color']
          ?.value,
      '#D14343',
    );
    expect(await session.flush(), isTrue);
  });

  test('旧视图独占历史条目变空后删除，但继续保留先前真实输入', () {
    final session = _session(audios: _audios);
    final editor = session.controller;
    editor.updateSelection(
      const TextSelection.collapsed(offset: 1),
      ChangeSource.local,
    );
    editor.replaceText(1, 0, '首', const TextSelection.collapsed(offset: 2));
    editor.document.history.lastRecorded = 0;
    final current = editor.document.toDelta();
    editor.document.compose(
      current.diff(MarkdownAudioEmbed.expand(current)),
      ChangeSource.remote,
    );
    expect(editor.document.history.stack.undo, hasLength(2));
    editor.projectAudio();
    expect(editor.document.history.stack.undo, hasLength(1));
    editor.undo();
    expect(editor.document.toPlainText(), startsWith('前\n'));
    expect(editor.selection, const TextSelection.collapsed(offset: 1));
    editor.redo();
    expect(editor.document.toPlainText(), startsWith('前首\n'));
    expect(_atoms(session), 2);
  });

  test('端点投影异常不改文档、历史身份、选区或 ignoreChange', () {
    final session = _session();
    final editor = session.controller;
    editor.replaceText(1, 0, '新', const TextSelection.collapsed(offset: 2));
    final before = editor.document.toDelta();
    final selected = editor.selection;
    final history = editor.document.history;
    final originalEntry = history.stack.undo.single;
    var calls = 0;
    expect(
      () => editor.projectDocumentView((delta) {
        if (++calls == 2) throw StateError('测试端点失败');
        return MarkdownAudioEmbed.project(delta, _audios);
      }),
      throwsStateError,
    );
    expect(editor.document.toDelta(), before);
    expect(editor.selection, selected);
    expect(identical(history.stack.undo.single, originalEntry), isTrue);
    expect(history.stack.redo, isEmpty);
    expect(history.ignoreChange, isFalse);
  });
}

RichEditorSession _session({Map<String, MediaAudio> audios = const {}}) {
  final session = RichEditorSession(
    initialMarkdown: _source,
    initialMediaAudios: audios,
    onMarkdownChanged: (_) {},
  );
  addTearDown(session.dispose);
  return session;
}

int _atoms(RichEditorSession session) => session.controller.document
    .toDelta()
    .operations
    .where(
      (op) =>
          op.data is Map &&
          (op.data as Map).containsKey(MarkdownAudioEmbed.type),
    )
    .length;
