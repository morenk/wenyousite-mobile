import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_boundary.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_code_source.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_compatibility_syntax.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_rich_line_decoder.dart';

import '../../support/inline_combination_assertions.dart';

void main() {
  test('删除线代码只消费一个代码片段并保留跨行来源', () {
    const source = '~~`a\nb`~~';
    final line = MarkdownRichLineDecoder.decodeInline(source)!;
    expect(line.spans.single.text, 'a b');
    expect(line.spans.single.attributes?['code'], true);
    expect(line.spans.single.attributes?['strike'], true);
    expect(
      line.spans.single.attributes?[MarkdownInlineCodeSource.key],
      '`a\nb`',
    );
    expect(
      MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(source).delta),
      source,
    );
  });
  test('跨端局部阅读适配不激活转义、代码内部或未闭合格式', () {
    for (final source in [
      r'\~~`code`~~',
      r'~~~`code`~~~',
      r'~~`code`',
      r'``~~`code`~~ &amp;``',
      r'~~code~~',
      r'~~`a``b`~~',
      r'`&amp;&#32;`',
      r'\&amp;',
      r'~~`a` b`c`~~',
      r'~~x!~~`a`~~',
      r'\**甲**',
      r'**甲',
      r'***甲***',
      r'****甲****',
      r'**甲 *乙* 丙**',
      r'**甲** **乙**',
      r'[**甲**](https://example.com/a)',
      r'`**甲**`',
      r'**&#42;甲&#42;**',
      r'a**甲**b',
      r'前**甲**后',
      r'***x**y**z*',
      r'***x**y**z',
      r'~~~x~~y~~z~',
      r'~~x~~y~~z',
      r'~~x **y** z~~',
    ]) {
      final original = md.Document(
        extensionSet: md.ExtensionSet.gitHubFlavored,
        encodeHtml: false,
      ).parseInline(source);
      final adapted = md.Document(
        inlineSyntaxes: MarkdownInlineCompatibilitySyntax.create(),
        extensionSet: md.ExtensionSet.gitHubFlavored,
        encodeHtml: false,
      ).parseInline(source);
      expect(
        inlineReadingUnits(adapted),
        inlineReadingUnits(original),
        reason: source,
      );
    }
  });
  test('外部代码后实体与相邻删除线保留标准阅读语义', () {
    for (final (source, expected) in [
      (
        '*~~`甲`~~*~~乙~~',
        [
          {
            'text': '甲',
            'marks': {'italic': true, 'strike': true, 'code': true},
          },
          {
            'text': '乙',
            'marks': {'strike': true},
          },
        ],
      ),
      (
        '&#x61;_`甲`&#x4E59;_&#x62;',
        [
          {'text': 'a', 'marks': {}},
          {
            'text': '甲',
            'marks': {'italic': true, 'code': true},
          },
          {
            'text': '乙',
            'marks': {'italic': true},
          },
          {'text': 'b', 'marks': {}},
        ],
      ),
      (
        '_**[甲](https://example.com/inline-a)**_**乙**',
        [
          {
            'text': '甲',
            'marks': {
              'italic': true,
              'bold': true,
              'link': 'https://example.com/inline-a',
            },
          },
          {
            'text': '乙',
            'marks': {'bold': true},
          },
        ],
      ),
      (
        '&#97;`甲`&#32;**[&#20057;](https://example.com/inline-a)**&#98;',
        [
          {'text': 'a', 'marks': {}},
          {
            'text': '甲',
            'marks': {'code': true},
          },
          {'text': ' ', 'marks': {}},
          {
            'text': '乙',
            'marks': {'bold': true, 'link': 'https://example.com/inline-a'},
          },
          {'text': 'b', 'marks': {}},
        ],
      ),
      (
        '&#97;**~~&#30002;~~** ~~`乙`~~&#98;',
        [
          {'text': 'a', 'marks': {}},
          {
            'text': '甲',
            'marks': {'bold': true, 'strike': true},
          },
          {'text': ' ', 'marks': {}},
          {
            'text': '乙',
            'marks': {'code': true, 'strike': true},
          },
          {'text': 'b', 'marks': {}},
        ],
      ),
    ]) {
      expect(
        inlineReadingUnits(
          md.Document(
            inlineSyntaxes: MarkdownInlineCompatibilitySyntax.create(),
            extensionSet: md.ExtensionSet.gitHubFlavored,
            encodeHtml: false,
          ).parseInline(source),
        ),
        expected,
      );
      final saved = MarkdownDeltaCodec.encode(
        MarkdownDeltaCodec.decode(source).delta,
      );
      expect(
        inlineReadingUnits(
          md.Document(
            extensionSet: md.ExtensionSet.gitHubFlavored,
            encodeHtml: false,
          ).parseInline(saved),
        ),
        expected,
      );
    }
  });
  const path = String.fromEnvironment('INLINE_COMBINATION_WEB_IMPORT');
  if (path.isEmpty) return;
  const textOnly = bool.fromEnvironment('INLINE_COMBINATION_WEB_TEXT_ONLY');
  test(
    'Web 实际候选${textOnly ? '文本子集' : '全部语料'}可阅读、编辑并再次保存',
    () {
      final payload = jsonDecode(File(path).readAsStringSync()) as Map;
      expect(payload['contract'], 'wenyousite-inline-cross-client-result');
      expect(payload['version'], 1);
      expect(payload['producer'], 'web');
      expect(payload['producerCommit'], matches(r'^[0-9a-f]{40}$'));
      expect(
        payload['fixtureCommit'],
        'f3cad6799d7fdd6b484d7341b3b918970767a190',
      );
      expect(
        payload['fixtureSha256'],
        sha256
            .convert(
              File(
                'contracts/markdown-inline-combinations-v1-fixtures.json',
              ).readAsBytesSync(),
            )
            .toString(),
      );
      final samples = payload['samples'] as List;
      expect(samples.length, 11904);
      final cases = samples
          .cast<Map>()
          .where(
            (item) => !textOnly || (item['id'] as String).startsWith('text:'),
          )
          .toList();
      expect(cases.length, textOnly ? 384 : 11904);
      final failures = <String>[];
      for (final item in cases.cast<Map>()) {
        final source = item['markdown'] as String;
        final segments = (item['expectedSegments'] as List).cast<Map>();
        final expected = <Object>[
          for (final segment in segments)
            for (final rune in (segment['text'] as String).runes)
              {'text': String.fromCharCode(rune), 'marks': segment['marks']},
        ];
        try {
          final nodes = md.Document(
            inlineSyntaxes: MarkdownInlineCompatibilitySyntax.create(),
            extensionSet: md.ExtensionSet.gitHubFlavored,
            encodeHtml: false,
          ).parseLines(MarkdownInlineBoundary.canonicalize(source).split('\n'));
          expect(inlineReadingUnits(nodes), expected, reason: '阅读: $source');
          final delta = MarkdownDeltaCodec.decode(source).delta;
          final actual = <Object>[];
          for (final operation in delta.operations) {
            expect(operation.data, isA<String>());
            final marks = <String, Object>{
              for (final key in ['bold', 'italic', 'strike', 'code', 'link'])
                if (operation.attributes?[key] != null)
                  key: operation.attributes![key] as Object,
            };
            for (final rune
                in (operation.data as String).replaceAll('\n', '').runes) {
              actual.add({'text': String.fromCharCode(rune), 'marks': marks});
            }
          }
          expect(actual, expected, reason: '编辑: $source');
          final saved = MarkdownDeltaCodec.encode(delta);
          expect(
            inlineReadingUnits(
              md.Document(
                inlineSyntaxes: MarkdownInlineCompatibilitySyntax.create(),
                extensionSet: md.ExtensionSet.gitHubFlavored,
                encodeHtml: false,
              ).parseLines(
                MarkdownInlineBoundary.canonicalize(saved).split('\n'),
              ),
            ),
            expected,
            reason: '再次保存阅读: $saved',
          );
          final reopened = MarkdownDeltaCodec.decode(saved).delta;
          final reopenedUnits = <Object>[
            for (final operation in reopened.operations)
              for (final rune
                  in (operation.data as String).replaceAll('\n', '').runes)
                {
                  'text': String.fromCharCode(rune),
                  'marks': {
                    for (final key in [
                      'bold',
                      'italic',
                      'strike',
                      'code',
                      'link',
                    ])
                      if (operation.attributes?[key] != null)
                        key: operation.attributes![key],
                  },
                },
          ];
          expect(reopenedUnits, expected, reason: '再次保存重开: $saved');
          expect(MarkdownDeltaCodec.encode(reopened), saved);
        } on Object catch (error) {
          failures.add('${item['id']}: $error');
        }
      }
      File(
        'build/inline-combinations-web-import-failures.log',
      ).writeAsStringSync(failures.join('\n'));
      expect(
        failures.take(10),
        isEmpty,
        reason: '${failures.length}/${cases.length} 跨端失败',
      );
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}
