import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_audio_embed.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_audio_projection.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_link_identity.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';

import '../../support/inline_combination_assertions.dart';

const _url = 'https://media.example.invalid/song.mp3';
const _other = 'https://media.example.invalid/other.mp3';

void main() {
  final audio = MediaAudio.parse({
    'sourceUrl': _url,
    'mediaId': 'song',
    'contentType': 'audio/mpeg',
    'size': 16000,
    'durationMs': 59000,
  })!;
  final trusted = {_url: audio};

  test('相邻链接来源边界不切断整段规范化上下文', () {
    verifyInlineCombination([
      ('a', {}),
      ('甲', {'link': _url}),
      ('乙', {'link': _url, 'bold': true}),
      ('b', {}),
    ]);
  });

  for (final right in [_url, _other]) {
    for (final pair in [
      ('甲', '乙'),
      ('**甲**', '*乙*'),
      ('~~甲~~', '` 乙 `'),
      ('甲 ', ' 乙'),
    ]) {
      test('独立链接保留来源和阅读样式 ${right == _url} $pair', () {
        final source = '[${pair.$1}]($_url)[${pair.$2}]($right)';
        final decoded = MarkdownDeltaCodec.decode(source).delta;
        expect(_embeds(MarkdownAudioEmbed.project(decoded, trusted)), 0);
        final encoded = MarkdownDeltaCodec.encode(decoded);
        final blocks = _read(encoded);
        expect(_links(blocks), 2);
        expect(inlineReadingUnits(blocks), inlineReadingUnits(_read(source)));
        expect(
          MarkdownAudioProjection.fromBlock(blocks.single, trusted),
          isNull,
        );
        expect(
          MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(encoded).delta),
          encoded,
        );
        expect(encoded, isNot(contains(markdownLinkIdentityKey)));
        expect(encoded, isNot(contains('title=')));
      });
    }
  }

  test('一个原链接内部混合样式可投影，缺可信映射仍是普通链接', () {
    const source = '[**甲** *乙* ~~丙~~ `丁`]($_url)';
    final decoded = MarkdownDeltaCodec.decode(source).delta;
    expect(_embeds(MarkdownAudioEmbed.project(decoded, {})), 0);
    final projected = MarkdownAudioEmbed.project(decoded, trusted);
    expect(_embeds(projected), 1);
    final encoded = MarkdownDeltaCodec.encode(projected);
    final blocks = _read(encoded);
    expect(_links(blocks), 1);
    expect(inlineReadingUnits(blocks), inlineReadingUnits(_read(source)));
    expect(
      MarkdownAudioProjection.fromBlock(blocks.single, trusted),
      isNotNull,
    );
    expect(
      MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(encoded).delta),
      encoded,
    );
  });

  for (final identities in [(null, 'known'), ('known', null), ('a', 'b')]) {
    test('相同样式与地址但来源不同仍是两个链接 $identities', () {
      final delta = Delta()
        ..insert('甲', {'link': _url, markdownLinkIdentityKey: ?identities.$1})
        ..insert('乙', {'link': _url, markdownLinkIdentityKey: ?identities.$2})
        ..insert('\n');
      expect(_embeds(MarkdownAudioEmbed.project(delta, trusted)), 0);
      final encoded = MarkdownDeltaCodec.encode(delta);
      final blocks = _read(encoded);
      expect(_links(blocks), 2);
      expect(MarkdownAudioProjection.fromBlock(blocks.single, trusted), isNull);
      expect(
        inlineReadingUnits(blocks),
        inlineReadingUnits(_read('[甲]($_url)[乙]($_url)')),
      );
      expect(
        MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(encoded).delta),
        encoded,
      );
    });
  }
}

List<md.Node> _read(String source) => md.Document(
  extensionSet: md.ExtensionSet.gitHubFlavored,
  encodeHtml: false,
).parseLines(source.split('\n'));

int _links(List<md.Node> nodes) => nodes.fold(0, (count, node) {
  if (node is! md.Element) return count;
  return count + (node.tag == 'a' ? 1 : 0) + _links(node.children ?? []);
});

int _embeds(Delta value) => value.operations
    .where(
      (op) =>
          op.data is Map &&
          (op.data as Map).containsKey(MarkdownAudioEmbed.type),
    )
    .length;
