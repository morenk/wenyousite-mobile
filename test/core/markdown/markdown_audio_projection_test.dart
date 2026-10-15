import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_audio_projection.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';

void main() {
  final fixture =
      jsonDecode(
            File(
              'contracts/markdown-audio-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as Map;
  for (final entry in fixture['cases'] as List) {
    test('音频投影与普通链接往返 ${entry['id']}', () {
      final source = entry['markdown'] as String;
      final projection = mediaAudiosFromJson(entry['mediaAudios']);
      final players = md.Document(extensionSet: md.ExtensionSet.gitHubFlavored)
          .parse(source)
          .map((block) => MarkdownAudioProjection.fromBlock(block, projection))
          .whereType<MarkdownAudioProjection>()
          .toList();
      expect(players.isNotEmpty, entry['player']);
      if (entry['player'] == true) {
        expect(players.map((p) => p.label), entry['labels']);
      }
      final decoded = MarkdownDeltaCodec.decode(source);
      final encoded = MarkdownDeltaCodec.encode(decoded.delta);
      expect(encoded, isNotEmpty);
      if (entry['id'] == 'adjacent') {
        final rendered = md.Document(
          extensionSet: md.ExtensionSet.gitHubFlavored,
        ).parse(encoded);
        expect(
          MarkdownAudioProjection.fromBlock(rendered.single, projection),
          isNull,
        );
        expect(
          (rendered.single as md.Element).children!
              .whereType<md.Element>()
              .where((e) => e.tag == 'a'),
          hasLength(2),
        );
      }
      if (entry['id'] == 'marked-label') {
        final operations = decoded.delta.toList();
        expect(operations.any((o) => o.attributes?['bold'] == true), isTrue);
        expect(operations.any((o) => o.attributes?['italic'] == true), isTrue);
        final roundtrip = MarkdownDeltaCodec.decode(encoded).delta.toList();
        expect(roundtrip.any((o) => o.attributes?['bold'] == true), isTrue);
        expect(roundtrip.any((o) => o.attributes?['italic'] == true), isTrue);
        final rendered = md.Document(
          extensionSet: md.ExtensionSet.gitHubFlavored,
        ).parse(encoded);
        expect(
          MarkdownAudioProjection.fromBlock(rendered.single, projection)?.label,
          '雨夜与片段',
        );
      }
      // 原始独立链接边界、文字、URL 和 marks 均保留。
      for (final label in entry['labels'] as List) {
        expect(
          decoded.delta
              .toList()
              .map((o) => o.data is String ? o.data : '')
              .join(),
          contains(label),
        );
      }
      if ((entry['labels'] as List).isNotEmpty) {
        expect(encoded, contains('https://storage.example/'));
      }
    });
  }
  for (final entry in fixture['invalidProjectionCases'] as List) {
    test('拒绝非法投影 ${entry['id']}', () {
      expect(mediaAudiosFromJson([entry['projection']]), isEmpty);
    });
  }
}
