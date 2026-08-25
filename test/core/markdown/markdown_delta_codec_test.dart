import 'dart:convert';
import 'dart:io';

import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

void main() {
  final editorRoundTripContract =
      jsonDecode(
            File(
              'contracts/markdown-editor-roundtrip-v2-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final editorRoundTripCases =
      (editorRoundTripContract['cases'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

  test('消费后端编辑器往返黄金语料 v2', () {
    expect(editorRoundTripContract['version'], 2);
    expect(editorRoundTripContract['markdownContractVersion'], 3);
    expect(editorRoundTripCases, isNotEmpty);
  });

  for (final fixture in editorRoundTripCases) {
    final id = fixture['id'] as String;
    final markdown = fixture['markdown'] as String;
    final serialized = fixture['serialized'] as String;

    test('$id 编辑器黄金语料往返不改写', () {
      final document = MarkdownDeltaCodec.decode(markdown);
      expect(MarkdownDeltaCodec.encode(document.delta), serialized);
      expect(
        MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(serialized).delta),
        serialized,
      );
    });
  }

  final nodeContract =
      jsonDecode(
            File(
              'contracts/markdown-v3-nodes-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final nodeCases = (nodeContract['cases'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  test('加载的是 Markdown v3 扩展节点黄金语料', () {
    expect(nodeContract['version'], 1);
    expect(nodeContract['markdownContractVersion'], 3);
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
      jsonDecode(File('contracts/markdown-v3-fixtures.json').readAsStringSync())
          as Map<String, dynamic>;
  final markdownCases = (markdownContract['cases'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  for (final fixture in markdownCases) {
    final id = fixture['id'] as String;
    final canonical = fixture['canonical'] as String;
    final supported = fixture['supported'] as bool;
    final expected = supported ? canonical : fixture['literal'] as String;

    test('$id canonical Markdown 经 Delta 按 v3 能力白名单往返', () {
      final document = MarkdownDeltaCodec.decode(canonical);

      expect(MarkdownDeltaCodec.encode(document.delta), expected);
    });

    if (!supported) {
      test('$id 未经 decode 的普通 Delta 也在编码出口安全降级', () {
        final delta = Delta()
          ..insert(canonical)
          ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false});

        final encoded = MarkdownDeltaCodec.encode(delta);

        expect(encoded, expected);
        expect(MarkdownContent.unsupportedLineIndexes(encoded), isEmpty);
      });
    }
  }

  test('独占 br 映射为空段元数据且内联 br 按 v3 字面降级', () {
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
      '第一段\n<br />\n\n正文 \\<br\\> 示例',
    );
  });

  test('站内链接按原子传送门往返且保留同行富文本', () {
    const source =
        '**入口**：[楼层动态](/threads/cmsewdo0h000x7qv6aa77ll1v?post=cmsewdqcr001a7qv6cy0y38bd)';
    final document = MarkdownDeltaCodec.decode(source);

    final portals = document.delta.operations.where(
      (operation) =>
          operation.data is Map &&
          (operation.data as Map).containsKey(
            MarkdownDeltaCodec.internalReferenceEmbed,
          ),
    );
    expect(portals, hasLength(1));
    expect(MarkdownDeltaCodec.encode(document.delta), source);
  });

  test('行内代码里的站内链接保持代码文本', () {
    const source = '`[不是传送门](/threads/cmsewdo0h000x7qv6aa77ll1v)`';
    final document = MarkdownDeltaCodec.decode(source);

    expect(
      document.delta.operations.any(
        (operation) =>
            operation.data is Map &&
            (operation.data as Map).containsKey(
              MarkdownDeltaCodec.internalReferenceEmbed,
            ),
      ),
      isFalse,
    );
    expect(MarkdownDeltaCodec.encode(document.delta), source);
  });

  test('未知协议所在行按 v3 整行字面降级且不激活扩展节点', () {
    const source =
        '[[dice:v2:raw-node:1d20]] '
        '[[dice:v1:550e8400-e29b-41d4-a716-446655440000:1d1]] '
        '![风险](javascript:alert "说明")';

    final document = MarkdownDeltaCodec.decode(source);
    final literal = MarkdownContent.literalizeUnsupported(source);

    expect(document.isSourceCompatible, isFalse);
    expect(document.issues, isEmpty);
    expect(MarkdownDeltaCodec.extractExtensionNodes(document.delta), isEmpty);
    expect(MarkdownDeltaCodec.encode(document.delta), literal);
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

  test('骰子在混排文本与换行第二行中保持行内原子节点并无损往返', () {
    const firstId = '550e8400-e29b-41d4-a716-446655440000';
    const secondId = '550e8400-e29b-41d4-a716-446655440001';
    const source =
        '他掷出 [[dice:v1:$firstId:1d20]] 后继续前进\n'
        '第二行 [[dice:v1:$secondId:2D6 + 03]] 仍接着叙述';

    final document = MarkdownDeltaCodec.decode(source);
    final operations = document.delta.operations.toList(growable: false);

    expect(document.issues, isEmpty);
    expect(
      operations.where((operation) => operation.data is Map),
      hasLength(2),
    );
    expect(operations[1].data, {
      MarkdownDeltaCodec.diceEmbed: {
        'version': 1,
        'nodeId': firstId,
        'notation': '1d20',
      },
    });
    expect(
      operations[2].data,
      ' 后继续前进\n第二行 ',
      reason: '骰子后文字与下一行前缀保持连续文本，不能被 embed 拆成块级卡片',
    );
    expect(
      (operations[2].data as String).split('\n'),
      [' 后继续前进', '第二行 '],
      reason: 'Markdown 源换行必须原位保留在两个骰子节点之间',
    );
    expect(
      MarkdownDeltaCodec.encode(document.delta),
      '他掷出 [[dice:v1:$firstId:1d20]] 后继续前进\n'
      '第二行 [[dice:v1:$secondId:2d6+3]] 仍接着叙述',
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

  test('畸形骰子 Quill embed 拒绝序列化而不是绕过协议约束', () {
    const validNodeId = '550e8400-e29b-41d4-a716-446655440000';

    Delta diceDelta(Object? payload) => Delta()
      ..insert({MarkdownDeltaCodec.diceEmbed: payload})
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false});

    final malformedPayloads = <Object?>[
      'not-a-map',
      <String, Object?>{},
      {'version': 2, 'nodeId': validNodeId, 'notation': '1d20'},
      {'version': 1, 'nodeId': 'not-a-uuid', 'notation': '1d20'},
      {'version': 1, 'nodeId': validNodeId, 'notation': '0d6'},
      {'version': 1, 'nodeId': validNodeId, 'notation': '1d1001'},
      {'version': 1, 'nodeId': validNodeId, 'notation': 20},
    ];

    for (final payload in malformedPayloads) {
      expect(
        () => MarkdownDeltaCodec.encode(diceDelta(payload)),
        throwsA(isA<MarkdownCodecException>()),
        reason: '畸形骰子载荷不得静默序列化：$payload',
      );
    }
  });

  test('重复骰子 UUID 按大小写无关判重', () {
    const lower = '550e8400-e29b-41d4-a716-446655440000';
    const upper = '550E8400-E29B-41D4-A716-446655440000';
    final document = MarkdownDeltaCodec.decode(
      '[[dice:v1:$lower:1d20]] [[dice:v1:$upper:2d6]]',
    );

    expect(document.issues, hasLength(1));
    expect(document.issues.single.kind, MarkdownCodecIssueKind.duplicateDice);
    expect(MarkdownDeltaCodec.extractExtensionNodes(document.delta), [
      {'type': 'dice', 'nodeId': lower, 'notation': '1d20'},
    ]);
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

  test('Quill 行内与块级富文本属性序列化为安全 Markdown', () {
    final delta = Delta()
      ..insert('标题')
      ..insert('\n', {'header': 2})
      ..insert('粗斜', {'bold': true, 'italic': true})
      ..insert('链接', {'link': 'https://wenyou.site/help'})
      ..insert('\n')
      ..insert('条目')
      ..insert('\n', {'list': 'bullet', 'indent': 1})
      ..insert('引用')
      ..insert('\n', {'blockquote': true})
      ..insert('a`b', {'code': true})
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false});

    expect(
      MarkdownDeltaCodec.encode(delta),
      '## 标题\n***粗斜***[链接](https://wenyou.site/help)\n'
      '  - 条目\n> 引用\n``a`b``',
    );
  });

  test('受支持的既有 Markdown 解码为 Quill 富文本属性而不是源码标记', () {
    const source =
        '## 标题\n'
        '***粗斜***[链接](https://wenyou.site/help)\n'
        '  - 条目\n'
        '> 引用\n'
        '``a`b``';

    final document = MarkdownDeltaCodec.decode(source);
    final operations = document.delta.operations.toList(growable: false);

    expect(
      operations,
      contains(
        isA<Operation>()
            .having((operation) => operation.data, 'text', '粗斜')
            .having(
              (operation) => operation.attributes,
              'attributes',
              containsPair('bold', true),
            )
            .having(
              (operation) => operation.attributes,
              'attributes',
              containsPair('italic', true),
            ),
      ),
    );
    expect(
      operations.where((operation) => operation.data == '\n'),
      contains(
        isA<Operation>().having(
          (operation) => operation.attributes,
          'heading',
          containsPair('header', 2),
        ),
      ),
    );
    expect(
      operations.where((operation) => operation.data == '\n'),
      contains(
        isA<Operation>().having(
          (operation) => operation.attributes,
          'nested list',
          allOf(containsPair('list', 'bullet'), containsPair('indent', 1)),
        ),
      ),
    );
    expect(MarkdownDeltaCodec.encode(document.delta), source);
  });

  test('未支持的任务列表按 v3 转为安全字面文本', () {
    final document = MarkdownDeltaCodec.decode('- [ ] 待处理');

    expect(document.delta.operations.first.data, '- [ ] 待处理');
    expect(document.delta.operations.first.attributes, isNull);
    expect(MarkdownDeltaCodec.encode(document.delta), r'\- \[ \] 待处理');
  });

  test('分隔线使用本地原子节点往返且不改变其他主题分隔线写法', () {
    final document = MarkdownDeltaCodec.decode('---\n* * *\n___');

    expect(
      document.delta.operations.any(
        (operation) =>
            operation.data is Map &&
            (operation.data as Map).containsKey(
              MarkdownDeltaCodec.horizontalRuleEmbed,
            ),
      ),
      isTrue,
    );
    expect(MarkdownDeltaCodec.encode(document.delta), '---\n* * *\n___');
    expect(
      MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(' ---\n--- ').delta),
      ' ---\n--- ',
    );
  });

  test('不安全链接、未知属性和冲突块样式拒绝序列化', () {
    final unsafeLink = Delta()
      ..insert('风险', {'link': 'javascript:alert(1)'})
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false});
    final unknownAttribute = Delta()
      ..insert('颜色', {'color': '#ff0000'})
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false});
    final conflictingBlocks = Delta()
      ..insert('冲突')
      ..insert('\n', {
        'header': 2,
        'list': 'bullet',
        MarkdownDeltaCodec.sourceBreakAttribute: false,
      });

    expect(
      () => MarkdownDeltaCodec.encode(unsafeLink),
      throwsA(isA<MarkdownCodecException>()),
    );
    expect(
      () => MarkdownDeltaCodec.encode(unknownAttribute),
      throwsA(isA<MarkdownCodecException>()),
    );
    expect(
      () => MarkdownDeltaCodec.encode(conflictingBlocks),
      throwsA(isA<MarkdownCodecException>()),
    );
  });
}
