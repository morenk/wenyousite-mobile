import 'dart:convert';
import 'dart:io';

import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

void main() {
  final nodeContract =
      jsonDecode(
            File(
              'contracts/markdown-v2-nodes-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final nodeCases = (nodeContract['cases'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  test('加载的是 Markdown v2 扩展节点黄金语料', () {
    expect(nodeContract['version'], 1);
    expect(nodeContract['markdownContractVersion'], 2);
    expect(nodeCases, isNotEmpty);
  });

  for (final fixture in nodeCases) {
    final id = fixture['id'] as String;
    final markdown = fixture['markdown'] as String;
    final serialized = fixture['serialized'] as String;
    final expectedNodes = (fixture['nodes'] as List<dynamic>)
        .map((node) => Map<String, Object?>.from(node as Map))
        .toList(growable: false);

    test('$id 扩展节点解析、序列化与幂等一致', () {
      final document = MarkdownDeltaCodec.decode(markdown);

      expect(document.issues, isEmpty);
      expect(
        MarkdownDeltaCodec.extractExtensionNodes(document.delta),
        expectedNodes,
      );
      expect(MarkdownDeltaCodec.encode(document.delta), serialized);
      expect(
        MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(serialized).delta),
        serialized,
      );
    });
  }

  final markdownContract =
      jsonDecode(File('contracts/markdown-v2-fixtures.json').readAsStringSync())
          as Map<String, dynamic>;
  final markdownCases = (markdownContract['cases'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  for (final fixture in markdownCases) {
    final id = fixture['id'] as String;
    final canonical = fixture['canonical'] as String;

    test('$id canonical Markdown 经 Delta 往返不变', () {
      final document = MarkdownDeltaCodec.decode(canonical);

      expect(MarkdownDeltaCodec.encode(document.delta), canonical);
    });
  }

  test('独占 br 映射为空段元数据且不把内联 br 当协议', () {
    final document = MarkdownDeltaCodec.decode('第一段\n<br />\n正文 <br> 示例');

    expect(
      document.delta.operations.any(
        (operation) =>
            operation.attributes?[MarkdownDeltaCodec.emptyParagraphAttribute] ==
            true,
      ),
      isTrue,
    );
    expect(
      MarkdownDeltaCodec.encode(document.delta),
      '第一段\n<br />\n正文 <br> 示例',
    );
  });

  test('未知协议、非法骰子与不安全图片进入只读兼容节点并保留原文', () {
    const source =
        '[[dice:v2:raw-node:1d20]] '
        '[[dice:v1:550e8400-e29b-41d4-a716-446655440000:1d1]] '
        '![风险](javascript:alert "说明")';

    final document = MarkdownDeltaCodec.decode(source);

    expect(document.isSourceCompatible, isTrue);
    expect(document.issues.map((issue) => issue.kind), [
      MarkdownCodecIssueKind.unknownProtocol,
      MarkdownCodecIssueKind.invalidDice,
      MarkdownCodecIssueKind.unsafeImage,
    ]);
    expect(MarkdownDeltaCodec.extractExtensionNodes(document.delta), isEmpty);
    expect(MarkdownDeltaCodec.encode(document.delta), source);
  });

  test('重复骰子节点不丢原文且只暴露第一个可编辑节点', () {
    const marker = '[[dice:v1:550e8400-e29b-41d4-a716-446655440000:2D6 + 03]]';
    final document = MarkdownDeltaCodec.decode('$marker $marker');

    expect(document.issues.single.kind, MarkdownCodecIssueKind.duplicateDice);
    expect(MarkdownDeltaCodec.extractExtensionNodes(document.delta), [
      {
        'type': 'dice',
        'nodeId': '550e8400-e29b-41d4-a716-446655440000',
        'notation': '2d6+3',
      },
    ]);
    expect(
      MarkdownDeltaCodec.encode(document.delta),
      '[[dice:v1:550e8400-e29b-41d4-a716-446655440000:2d6+3]] $marker',
    );
  });

  test('损坏或未知 Quill embed 拒绝序列化而不是静默丢失', () {
    final unknown = Delta()
      ..insert({
        'unknown_embed': {'raw': 'value'},
      })
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false});
    final damaged = Delta()
      ..insert({
        MarkdownDeltaCodec.imageEmbed: {
          'version': 1,
          'url': 'data:image/png;base64,YQ==',
          'alt': '风险',
          'title': null,
        },
      })
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false});
    final wrongVersion = Delta()
      ..insert({
        MarkdownDeltaCodec.mentionEmbed: {
          'version': 2,
          'kind': 'user',
          'userId': 'user-one',
          'label': '@用户',
        },
      })
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false});

    expect(
      () => MarkdownDeltaCodec.encode(unknown),
      throwsA(isA<MarkdownCodecException>()),
    );
    expect(
      () => MarkdownDeltaCodec.encode(damaged),
      throwsA(isA<MarkdownCodecException>()),
    );
    expect(
      () => MarkdownDeltaCodec.encode(wrongVersion),
      throwsA(isA<MarkdownCodecException>()),
    );
  });

  test('空 Markdown 仍生成合法终止换行且编码回空字符串', () {
    final document = MarkdownDeltaCodec.decode('');

    expect(document.delta.operations.last.data, '\n');
    expect(
      document.delta.operations.last.attributes?[MarkdownDeltaCodec
          .sourceBreakAttribute],
      isFalse,
    );
    expect(MarkdownDeltaCodec.encode(document.delta), isEmpty);
  });
}
