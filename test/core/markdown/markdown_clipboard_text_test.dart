import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_clipboard_text.dart';

void main() {
  final contract =
      jsonDecode(
            File(
              'contracts/editor-clipboard-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final goldenCases = (contract['goldenCases'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  test('消费 clipboard v1 的移动端入口、传输和节点规则', () {
    expect(contract['version'], 1);
    expect(contract['markdownContractVersion'], 3);
    final entryPoints = (contract['entryPoints'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    expect(
      entryPoints
          .where((entry) => entry['platform'] == 'mobile')
          .map((entry) => entry['id']),
      containsAll(<String>[
        'mobile-reader-selection',
        'mobile-reader-menu',
        'mobile-editor',
      ]),
    );
    expect(
      (contract['mobileTransport']
          as Map<String, dynamic>)['maximumAgeSeconds'],
      600,
    );
    expect(
      contract['webEnvelope'],
      containsPair('validation', 'strict-allowlist'),
    );
    expect(
      (contract['pasteRules'] as List<dynamic>).cast<Map<String, dynamic>>(),
      contains(
        allOf(
          containsPair('source', 'site-fragment-v1'),
          containsPair('result', 'structured'),
        ),
      ),
    );
    final nodeRules = (contract['nodeRules'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    expect(
      nodeRules.map((rule) => rule['nodeType']),
      containsAll(<String>[
        'internal_reference',
        'mention',
        'mention_all_players',
        'dice',
        'image',
        'sticker',
      ]),
    );
  });

  for (final fixture in goldenCases.where(
    (fixture) => fixture['kind'] == 'reader-copy',
  )) {
    test('${fixture['id']} 阅读态复制只写可见文本', () {
      final diceLabels = <String, String>{};
      for (final rawRoll
          in fixture['diceRolls'] as List<dynamic>? ?? const []) {
        final roll = Map<String, dynamic>.from(rawRoll as Map);
        diceLabels[(roll['nodeId'] as String).toLowerCase()] =
            '${roll['notation']} = ${roll['total']}';
      }
      expect(
        MarkdownClipboardText.project(
          fixture['markdown'] as String,
          diceLabels: diceLabels,
        ),
        fixture['expectedPlainText'],
      );
    });
  }

  test('纯文本换行统一为 LF，字面 Markdown 字符保持可见', () {
    expect(
      MarkdownClipboardText.project(
        r'\*字面星号\*'
        '\r\n'
        r'\# 字面井号',
      ),
      '*字面星号*\n# 字面井号',
    );
  });

  test('历史 URL 自标签复制为阅读态展示的传送门名称', () {
    expect(
      MarkdownClipboardText.project(
        '入口 [https://wenyou.site/join/AbCdEfGh_123-XYZ]'
        '(/join/AbCdEfGh_123-XYZ)',
      ),
      '入口 传送门',
    );
  });
}
