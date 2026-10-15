import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_audio_embed.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_pending_audio_document.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/editor_test_paste.dart';

final _audio = MediaAudio.parse({
  'sourceUrl': 'https://storage.example/audio.mp3',
  'mediaId': 'audio',
  'contentType': 'audio/mpeg',
  'size': 16000,
  'durationMs': 123000,
})!;
final _link = '[**雨夜**与*片段*](${_audio.sourceUrl})';

int _embeds(RichEditorSession session) => session.controller.document
    .toDelta()
    .operations
    .where(
      (op) =>
          op.data is Map &&
          (op.data as Map).containsKey(MarkdownAudioEmbed.type),
    )
    .length;

void main() {
  final fixtures =
      jsonDecode(
            File(
              'contracts/markdown-audio-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  for (final row in fixtures['cases'] as List) {
    testWidgets('可信音频编辑投影与既有fixture一致 ${row['id']}', (tester) async {
      final source = row['markdown'] as String;
      final session = RichEditorSession(
        initialMarkdown: source,
        initialMediaAudios: mediaAudiosFromJson(row['mediaAudios']),
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      expect(
        _embeds(session),
        row['player'] == true ? (row['labels'] as List).length : 0,
        reason: session.controller.document.toDelta().toJson().toString(),
      );
      expect(await session.flush(), isTrue);
      expect(
        session.localMarkdown,
        MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(source).delta),
      );
      expect(session.localMarkdown, isNot(contains(MarkdownAudioEmbed.type)));
      final reopened = RichEditorSession(
        initialMarkdown: session.localMarkdown,
        initialMediaAudios: session.mediaAudios,
        onMarkdownChanged: (_) {},
      );
      addTearDown(reopened.dispose);
      expect(_embeds(reopened), _embeds(session));
    });
  }

  for (final row in fixtures['invalidProjectionCases'] as List) {
    testWidgets('坏音频投影不创建播放器 ${row['id']}', (tester) async {
      final session = RichEditorSession(
        initialMarkdown: row['markdown'] as String,
        initialMediaAudios: mediaAudiosFromJson([row['projection']]),
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      expect(_embeds(session), 0);
      expect(await session.flush(), isTrue);
      expect(session.localMarkdown, isNot(contains(MarkdownAudioEmbed.type)));
    });
  }

  testWidgets('重复引用保留marks和URL；缺少投影恢复普通链接', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '$_link\n\n$_link',
      initialMediaAudios: {_audio.sourceUrl: _audio},
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    expect(_embeds(session), 2);
    expect(await session.flush(), isTrue);
    final canonical = session.localMarkdown;
    session.replaceMediaAudios({});
    expect(_embeds(session), 0);
    expect(await session.flush(), isTrue);
    expect(session.localMarkdown, canonical);
    session.replaceMediaAudios({_audio.sourceUrl: _audio});
    expect(_embeds(session), 2);
    expect(await session.flush(), isTrue);
    expect(session.localMarkdown, canonical);
  });

  for (final attribute in <Attribute<dynamic>>[
    Attribute.blockQuote,
    Attribute.ul,
    Attribute.h2,
  ]) {
    testWidgets('格式变成${attribute.key}降级并可撤销重做', (tester) async {
      final session = RichEditorSession(
        initialMarkdown: _link,
        initialMediaAudios: {_audio.sourceUrl: _audio},
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      final controller = session.controller;
      controller.updateSelection(
        const TextSelection(baseOffset: 0, extentOffset: 1),
        ChangeSource.local,
      );
      controller.formatSelection(attribute);
      expect(_embeds(session), 0);
      expect(await session.flush(), isTrue);
      final formatted = session.localMarkdown;
      expect(formatted, contains(_audio.sourceUrl));
      controller.undo();
      expect(_embeds(session), 1);
      expect(controller.hasRedo, isTrue);
      controller.redo();
      expect(_embeds(session), 0);
      expect(await session.flush(), isTrue);
      expect(session.localMarkdown, formatted);
    });
  }

  testWidgets('相邻输入降级普通链接，撤销恢复卡片且选区不跳', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: _link,
      initialMediaAudios: {_audio.sourceUrl: _audio},
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    final controller = session.controller;
    controller.replaceText(0, 0, '前', const TextSelection.collapsed(offset: 1));
    expect(_embeds(session), 0);
    expect(controller.selection.baseOffset, 1);
    expect(await session.flush(), isTrue);
    expect(
      MarkdownDeltaCodec.decode(
        session.localMarkdown,
      ).delta.operations.first.data,
      startsWith('前'),
    );
    controller.undo();
    expect(_embeds(session), 1);
    controller.redo();
    expect(_embeds(session), 0);
    expect(controller.selection.baseOffset, 1);
  });

  testWidgets('前后独立输入、删除卡片、undo redo和草稿恢复', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '前文\n\n$_link\n\n后文',
      initialMediaAudios: {_audio.sourceUrl: _audio},
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    final controller = session.controller;
    controller.replaceText(0, 0, '雨', const TextSelection.collapsed(offset: 1));
    final last = controller.document.length - 1;
    controller.replaceText(
      last,
      0,
      '雨',
      TextSelection.collapsed(offset: last + 1),
    );
    expect(_embeds(session), 1);
    await session.flush();
    final saved = session.localMarkdown;
    controller.document.history.clear();
    final at = controller.document.toPlainText().indexOf('\uFFFC');
    controller.updateSelection(
      TextSelection(baseOffset: at, extentOffset: at + 1),
      ChangeSource.local,
    );
    controller.replaceText(at, 1, '', TextSelection.collapsed(offset: at));
    expect(_embeds(session), 0);
    controller.undo();
    expect(_embeds(session), 1);
    expect(
      controller.selection,
      TextSelection(baseOffset: at, extentOffset: at + 1),
    );
    controller.redo();
    expect(_embeds(session), 0);
    session.applyExternalMarkdown(
      saved,
      mediaAudios: {_audio.sourceUrl: _audio},
    );
    expect(_embeds(session), 1);
    expect(await session.flush(), isTrue);
    expect(session.localMarkdown, saved);
  });

  testWidgets('整块剪切移动和跨会话粘贴不传播播放权限或内部JSON', (tester) async {
    String? text;
    final gateway = CallbackEditorClipboardGateway(
      readCallback: () async => text,
      writeCallback: (value) async {
        text = value;
      },
    );
    final store = WenyouEditorClipboardStore();
    final session = RichEditorSession(
      initialMarkdown: '$_link\n\n后文',
      initialMediaAudios: {_audio.sourceUrl: _audio},
      onMarkdownChanged: (_) {},
      clipboardGateway: gateway,
      clipboardStore: store,
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 1),
      ChangeSource.local,
    );
    expect(await session.copySelection(cut: true), isTrue);
    expect(text, '雨夜与片段');
    expect(_embeds(session), 0);
    final end = session.controller.document.length - 1;
    session.controller.updateSelection(
      TextSelection.collapsed(offset: end),
      ChangeSource.local,
    );
    expect(await pasteEditorClipboard(session.controller), isTrue);
    expect(_embeds(session), 1);
    expect(await session.flush(), isTrue);
    expect(
      session.localMarkdown.indexOf('后文'),
      lessThan(session.localMarkdown.indexOf(_audio.sourceUrl)),
    );
    expect(session.controller.selection.isCollapsed, isTrue);
    final other = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
      clipboardGateway: gateway,
      clipboardStore: store,
    );
    addTearDown(other.dispose);
    expect(await pasteEditorClipboard(other.controller), isTrue);
    expect(_embeds(other), 0);
    expect(await other.flush(), isTrue);
    expect(other.localMarkdown, contains(_audio.sourceUrl));
    expect(other.localMarkdown, isNot(contains(MarkdownAudioEmbed.type)));
  });

  testWidgets('上传完成仅替换仍存在占位，删除或切稿后不复活', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    session.insertLocalAudio('deleted');
    session.removeLocalAudio('deleted');
    session.resolveLocalAudio('deleted', _audio);
    expect(_embeds(session), 0);
    session.applyExternalMarkdown('', mediaAudios: {});
    session.insertLocalAudio('undone');
    session.controller.undo();
    session.resolveLocalAudio('undone', _audio);
    expect(_embeds(session), 0);
    session.insertLocalAudio('previous');
    session.applyExternalMarkdown('后文', mediaAudios: {});
    session.resolveLocalAudio('previous', _audio);
    expect(_embeds(session), 0);
    expect(session.controller.document.toPlainText(), '后文\n');
    session.insertLocalAudio('ready');
    session.resolveLocalAudio('ready', _audio);
    expect(_embeds(session), 1);
    expect(await session.flush(), isTrue);
    expect(session.localMarkdown, contains(_audio.sourceUrl));
  });
}
