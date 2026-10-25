import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' show Attribute, ChangeSource;
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_audio_embed.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_format_policy.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_publish_preparation.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/text_color_assertions.dart';

const _marker = '[wenyousite-align-v1-center]: #';
const _original = r'*<\<Y/N \>\>*';
const _url = 'https://example.invalid/song.mp3';
const _color = '#D14343';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  RichEditorSession open(String source, {bool audio = false}) {
    final session = RichEditorSession(
      initialMarkdown: source,
      initialMediaAudios: audio
          ? {
              _url: MediaAudio.parse({
                'sourceUrl': _url,
                'mediaId': 'song',
                'contentType': 'audio/mpeg',
                'size': 16000,
                'durationMs': 59000,
              })!,
            }
          : {},
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    return session;
  }

  for (final (inner, visible, code) in [
    ('&lt;tag&gt;', '<tag>', false),
    ('&#60;br /&#62;', '<br />', false),
    ('`[[dice:v2:example:1d20]]`', '[[dice:v2:example:1d20]]', true),
  ]) {
    test('颜色与居中不被当作 HTML：$inner', () async {
      final source =
          '$_marker\n<span data-wenyou-color-v1="$_color">**$inner**</span>';
      final session = open(source);
      void check(RichEditorSession value, String text) {
        expect(value.isSourceProtected, isFalse);
        expect(value.controller.document.toPlainText(), '$text\n');
        final marks = value.controller.document
            .collectStyle(0, text.length)
            .attributes;
        expect(marks['color']?.value, _color);
        expect(marks['bold']?.value, isTrue);
        expect(marks['align']?.value, 'center');
        if (code) expect(marks['code']?.value, isTrue);
        expect(value.diagnosticId, isNull);
      }

      check(session, visible);
      session.controller.replaceText(
        1,
        0,
        '新',
        const TextSelection.collapsed(offset: 2),
      );
      final expected = '${visible.substring(0, 1)}新${visible.substring(1)}';
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      check(open(session.localMarkdown), expected);
      expect(
        colorReaderUnits(colorReaderNodes(session.localMarkdown)),
        colorExpectedUnits([
          (expected, {'color': _color, 'bold': true, if (code) 'code': true}),
        ]),
      );
    });
  }

  test('原片段混排颜色、独立音频和同 URL 双链接，经公共发布流程保存重开', () async {
    const source =
        '$_marker\n$_original\n<br />\n'
        '<span data-wenyou-color-v1="$_color">**&lt;tag&gt;**</span>\n<br />\n'
        '[**&lt;曲&gt;**]($_url)\n<br />\n[甲]($_url)[乙]($_url)';
    final session = open(source, audio: true);
    void check(RichEditorSession value, String originalText) {
      expect(value.isSourceProtected, isFalse);
      final document = value.controller.document;
      final plain = document.toPlainText();
      expect(plain, startsWith('$originalText\n\n<tag>\n\n'));
      expect(plain, endsWith('\n\n甲乙\n'));
      expect(plain, isNot(contains('wenyousite-align')));
      final firstStyle = document
          .collectStyle(0, originalText.length)
          .attributes;
      expect(firstStyle['italic']?.value, isTrue);
      expect(firstStyle['align']?.value, 'center');
      final colorStyle = document
          .collectStyle(plain.indexOf('<tag>'), 5)
          .attributes;
      expect(colorStyle['color']?.value, _color);
      expect(colorStyle['bold']?.value, isTrue);
      expect(
        document.toDelta().operations.where(
          (op) =>
              op.data is Map &&
              (op.data as Map).containsKey(MarkdownAudioEmbed.type),
        ),
        hasLength(1),
      );
    }

    check(session, '<<Y/N >>');
    session.controller.replaceText(
      2,
      0,
      '确认',
      const TextSelection.collapsed(offset: 4),
    );
    String? saved;
    await withPreparedEditorPublish(
      waitForReady: () async => true,
      generation: () => 1,
      isIntentCurrent: (intent) => intent == 1,
      isActive: () => true,
      flush: session.flush,
      onNotReady: () async => fail('附件已就绪'),
      submit: () async => saved = session.localMarkdown,
      finishWaiting: () {},
    );
    expect(saved, isNotNull);
    check(open(saved!, audio: true), '<<确认Y/N >>');
    expect(
      _links(colorReaderNodes(saved!)),
      3,
      reason: '独立音频仍是一个链接，相邻两个同地址链接不得合并',
    );
    expect(
      MarkdownContent.toPlainTextPreview(saved!),
      '<<确认Y/N >> <tag> <曲> 甲乙',
    );
  });

  test('真实颜色旁的实体标签文字不会变成第二个颜色样式', () async {
    const literal = '<span data-wenyou-color-v1="#123456">原文</span>';
    const source =
        '<span data-wenyou-color-v1="$_color">红字</span> '
        '&lt;span data-wenyou-color-v1="#123456"&gt;原文&lt;/span&gt;';
    final session = open(source);
    expect(session.isSourceProtected, isFalse);
    expect(await session.flush(), isTrue, reason: session.codecFailure);
    final reopened = open(session.localMarkdown);
    expect(reopened.isSourceProtected, isFalse);
    expect(reopened.controller.document.toPlainText(), '红字 $literal\n');
    expect(
      colorReaderUnits(colorReaderNodes(session.localMarkdown)),
      colorExpectedUnits([
        ('红字', {'color': _color}),
        (' $literal', {}),
      ]),
    );
  });

  for (final italic in [false, true]) {
    test('完整颜色标记的实体文字仍是正文，italic=$italic', () async {
      const literal = '<span data-wenyou-color-v1="#123456">原文</span>';
      const entity =
          '&lt;span data-wenyou-color-v1="#123456"&gt;原文&lt;/span&gt;';
      final session = open(italic ? '*$entity*' : entity);
      expect(session.isSourceProtected, isFalse);
      expect(session.controller.document.toPlainText(), '$literal\n');
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      final reopened = open(session.localMarkdown);
      expect(reopened.isSourceProtected, isFalse);
      expect(reopened.controller.document.toPlainText(), '$literal\n');
      expect(
        colorReaderUnits(colorReaderNodes(session.localMarkdown)),
        colorExpectedUnits([
          (literal, {if (italic) 'italic': true}),
        ]),
      );
    });
  }

  for (final code in [false, true]) {
    test('标签形正文取消格式后不会变成颜色标记，code=$code', () async {
      const literal = '<span data-wenyou-color-v1="#123456">原文</span>';
      const entity =
          '**&lt;span** data-wenyou-color-v1="#123456"&gt;原文&lt;/span&gt;';
      final session = open(code ? '`$literal`' : entity);
      expect(session.controller.document.toPlainText(), '$literal\n');
      session.controller.updateSelection(
        TextSelection(baseOffset: 0, extentOffset: code ? literal.length : 5),
        ChangeSource.local,
      );
      WenyouEditorFormatPolicy.toggle(
        session.controller,
        code ? Attribute.inlineCode : Attribute.bold,
      );
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      final reopened = open(session.localMarkdown);
      expect(reopened.isSourceProtected, isFalse);
      expect(reopened.controller.document.toPlainText(), '$literal\n');
      expect(
        colorReaderUnits(colorReaderNodes(session.localMarkdown)),
        colorExpectedUnits([(literal, {})]),
      );
    });
  }

  test('结构化摘要保留颜色、身份显示映射及代码里的字面标记', () {
    const source =
        '$_marker\n$_original\n\n'
        '<span data-wenyou-color-v1="$_color">**彩色**</span> '
        '[@原称呼](/users/alice?identityMode=ACCOUNT)\n\n`$_marker`';
    expect(
      MarkdownContent.toPlainTextPreview(
        source,
        mentionLabels: {'/users/alice?identityMode=ACCOUNT\u0000原称呼': '新称呼'},
      ),
      '<<Y/N >> 彩色 @新称呼 $_marker',
    );
    expect(
      MarkdownContent.toPlainTextPreview('$_marker\n<span>旧 HTML</span>'),
      '$_marker <span>旧 HTML</span>',
    );
  });

  for (final source in [
    '<span data-wenyou-color-v1="#12345">损坏</span>',
    '<span data-wenyou-color-v1="$_color"><i>嵌套 HTML</i></span>',
  ]) {
    test('损坏颜色仍保护原文且阻止公共发布：$source', () async {
      final session = open('$_marker\n$source');
      expect(session.isSourceProtected, isTrue);
      expect(session.diagnosticId, isNotNull);
      var submitted = false;
      await withPreparedEditorPublish(
        waitForReady: () async => true,
        generation: () => 1,
        isIntentCurrent: (_) => true,
        isActive: () => true,
        flush: session.flush,
        onNotReady: () async {},
        submit: () async => submitted = true,
        finishWaiting: () {},
      );
      expect(submitted, isFalse);
      expect(session.localMarkdown, '$_marker\n$source');
    });
  }
}

int _links(List<md.Node> nodes) => nodes.fold(
  0,
  (count, node) => node is md.Element
      ? count + (node.tag == 'a' ? 1 : 0) + _links(node.children ?? [])
      : count,
);
