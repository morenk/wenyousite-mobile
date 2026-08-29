import 'dart:convert';
import 'dart:io';

import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editor_document.dart';

void main() {
  final editorRoundTripContract =
      jsonDecode(
            File(
              'contracts/markdown-editor-roundtrip-v6-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final editorRoundTripCases =
      (editorRoundTripContract['cases'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

  test('消费后端编辑器往返黄金语料 v6', () {
    expect(editorRoundTripContract['version'], 6);
    expect(editorRoundTripContract['markdownContractVersion'], 4);
    expect(editorRoundTripCases, isNotEmpty);
  });

  for (final fixture in editorRoundTripCases) {
    final id = fixture['id'] as String;
    final markdown = fixture['markdown'] as String;
    final serialized = fixture['serialized'] as String;

    test('$id 编辑器黄金语料往返不改写', () {
      final document = MarkdownDeltaCodec.decode(markdown);
      expect(MarkdownDeltaCodec.encode(document.delta), serialized);
      final expectedInlineSemantics =
          (fixture['inlineSemantics'] as List<dynamic>?)?.cast<String>();
      if (expectedInlineSemantics != null) {
        expect(
          _inlineSemantics(document.delta),
          expectedInlineSemantics,
          reason: fixture['id'] as String,
        );
      }
      final expectedSemantics = (fixture['blockSemantics'] as List<dynamic>?)
          ?.cast<String>();
      if (expectedSemantics != null) {
        expect(
          document.editorDocument.blockKinds.map(_blockSemantic),
          expectedSemantics,
          reason: fixture['id'] as String,
        );
      }
      final expectedAlignments = (fixture['blockAlignments'] as List<dynamic>?)
          ?.cast<String>();
      if (expectedAlignments != null) {
        expect(
          document.editorDocument.blocks.map((block) => block.alignment.name),
          expectedAlignments,
          reason: fixture['id'] as String,
        );
      }
      expect(
        MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(serialized).delta),
        serialized,
      );
    });
  }

  final nodeContract =
      jsonDecode(
            File(
              'contracts/markdown-v4-nodes-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final nodeCases = (nodeContract['cases'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  test('加载的是 Markdown v4 扩展节点黄金语料', () {
    expect(nodeContract['version'], 1);
    expect(nodeContract['markdownContractVersion'], 4);
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
      jsonDecode(File('contracts/markdown-v4-fixtures.json').readAsStringSync())
          as Map<String, dynamic>;
  final markdownCases = (markdownContract['cases'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  for (final fixture in markdownCases) {
    final id = fixture['id'] as String;
    final canonical = fixture['canonical'] as String;
    final supported = fixture['supported'] as bool;
    final expected = supported ? canonical : fixture['literal'] as String;

    test('$id canonical Markdown 经 Delta 按 v4 能力白名单往返', () {
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

  test('独占 br 映射为空段元数据且内联 br 按 v4 字面降级', () {
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

  test('历史连续空行逐段恢复并在下次编码写入规范标记', () {
    final document = MarkdownDeltaCodec.decode('第一段\n\n\n\n第二段');
    final emptyParagraphCount = document.delta.operations
        .where(
          (operation) =>
              operation.attributes?[MarkdownDeltaCodec
                  .emptyParagraphAttribute] ==
              true,
        )
        .fold<int>(
          0,
          (count, operation) =>
              count + '\n'.allMatches(operation.data as String).length,
        );

    expect(emptyParagraphCount, 2);
    expect(
      MarkdownDeltaCodec.encode(document.delta),
      '第一段\n<br />\n<br />\n第二段',
    );
  });

  test('键盘新建空段即使继承末行属性也编码为规范标记', () {
    final delta = Delta()
      ..insert('第一段')
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false})
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false})
      ..insert('第二段')
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false});

    expect(MarkdownDeltaCodec.encode(delta), '第一段\n<br />\n第二段');
  });

  test('键盘新建的首尾与连续空段逐段保留', () {
    final leading = Delta()
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false})
      ..insert('正文')
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false});
    final trailing = Delta()
      ..insert('正文')
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false})
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false});
    final repeated = Delta()
      ..insert('第一段')
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false})
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false})
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false})
      ..insert('第二段')
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false});

    expect(MarkdownDeltaCodec.encode(leading), '<br />\n正文');
    expect(MarkdownDeltaCodec.encode(trailing), '正文\n<br />');
    expect(MarkdownDeltaCodec.encode(repeated), '第一段\n<br />\n<br />\n第二段');
  });

  test('普通段落分隔解码后仍按原始 Markdown 往返', () {
    const source = '第一段\n\n第二段';

    expect(
      MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(source).delta),
      source,
    );
  });

  test('编辑器忽略协议标记的 Markdown 分块空行且重开保持幂等', () {
    const source = '第一段\n\n<br />\n\n<br>\n\n第二段';
    final encoded = MarkdownDeltaCodec.encode(
      MarkdownDeltaCodec.decode(source).delta,
    );

    expect(encoded, '第一段\n<br />\n<br />\n第二段');
    expect(
      MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(encoded).delta),
      encoded,
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

  test('历史 URL 自标签解码后仍保留原始 Markdown', () {
    const source =
        '[https://wenyou.site/join/AbCdEfGh_123-XYZ]'
        '(/join/AbCdEfGh_123-XYZ)';
    final document = MarkdownDeltaCodec.decode(source);

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

  test('未知协议所在行按 v4 整行字面降级且不激活扩展节点', () {
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

  test('历史安全转义正文显示原字符且保存时仍保持安全编码', () {
    const saved =
        r'\| 名称 \| 数值 \|'
        '\n'
        r'\| \-\-\- \| \-\-\-\: \|';

    final document = MarkdownDeltaCodec.decode(saved);
    final visible = document.delta.operations
        .where((operation) => operation.data is String)
        .map((operation) => operation.data! as String)
        .join();

    expect(visible, contains('| 名称 | 数值 |'));
    expect(visible, isNot(contains(r'\')));
    expect(MarkdownDeltaCodec.encode(document.delta), saved);
  });

  test('历史字面转义不会阻止同行受支持富文本恢复', () {
    const saved = r'**加粗** 与 \*字面星号\*';

    final document = MarkdownDeltaCodec.decode(saved);
    final textOperations = document.delta.operations.where(
      (operation) => operation.data is String && operation.data != '\n',
    );

    expect(
      textOperations.any((operation) => operation.attributes?['bold'] == true),
      isTrue,
    );
    expect(
      textOperations.map((operation) => operation.data! as String).join(),
      '加粗 与 *字面星号*',
    );
    expect(MarkdownDeltaCodec.encode(document.delta), saved);
  });

  test('分隔线使用独占块并写入 canonical 结构空行', () {
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
    expect(MarkdownDeltaCodec.encode(document.delta), '---\n\n* * *\n___');
    expect(
      MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(' ---\n--- ').delta),
      ' ---\n--- ',
    );
  });

  test('历史 Setext H2 与分隔线在块模型中保持不同语义', () {
    final heading = MarkdownDeltaCodec.decode('正文\n---');
    final rule = MarkdownDeltaCodec.decode('正文\n\n---\n\n正文');

    expect(heading.editorDocument.blockKinds, [
      MarkdownEditorBlockKind.heading2,
    ]);
    expect(MarkdownDeltaCodec.encode(heading.delta), '## 正文');
    expect(rule.editorDocument.blockKinds, [
      MarkdownEditorBlockKind.paragraph,
      MarkdownEditorBlockKind.horizontalRule,
      MarkdownEditorBlockKind.paragraph,
    ]);
    expect(MarkdownDeltaCodec.encode(rule.delta), '正文\n\n---\n\n正文');
  });

  test('分隔线与文字或其他块属性混在同一 Delta 行时拒绝保存', () {
    Delta horizontalRule() => Delta()
      ..insert({
        MarkdownDeltaCodec.horizontalRuleEmbed: const {'version': 1},
      });
    final inline = Delta()
      ..insert('正文')
      ..insert({
        MarkdownDeltaCodec.horizontalRuleEmbed: const {'version': 1},
      })
      ..insert('\n', {MarkdownDeltaCodec.sourceBreakAttribute: false});
    final styled = horizontalRule()
      ..insert('\n', {
        'header': 2,
        MarkdownDeltaCodec.sourceBreakAttribute: false,
      });
    final unterminated = horizontalRule();

    for (final delta in [inline, styled, unterminated]) {
      expect(
        () => MarkdownDeltaCodec.encode(delta),
        throwsA(isA<MarkdownCodecException>()),
      );
    }
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

  test('同一软换行段落混入普通图片时不能绕过对齐白名单', () {
    final imageBeforeAlignedText = Delta()
      ..insert({
        MarkdownDeltaCodec.imageEmbed: const {
          'version': 1,
          'url': 'https://cdn.example.com/images/a.png',
          'alt': '图片',
          'title': null,
        },
      })
      ..insert('\n')
      ..insert('正文')
      ..insert('\n', {
        MarkdownDeltaCodec.alignmentAttribute: 'center',
        MarkdownDeltaCodec.sourceBreakAttribute: false,
      });

    expect(
      () => MarkdownDeltaCodec.encode(imageBeforeAlignedText),
      throwsA(isA<MarkdownCodecException>()),
    );
  });
}

List<String> _inlineSemantics(Delta delta) {
  final semantics = <String>{};
  for (final operation in delta.operations) {
    final attributes = operation.attributes;
    if (attributes == null) continue;
    if (attributes['italic'] == true) semantics.add('emphasis');
    if (attributes['bold'] == true) semantics.add('strong');
    if (attributes['strike'] == true) semantics.add('strikethrough');
    if (attributes['code'] == true) semantics.add('inline-code');
  }
  return semantics.toList(growable: false);
}

String _blockSemantic(MarkdownEditorBlockKind kind) => switch (kind) {
  MarkdownEditorBlockKind.paragraph => 'paragraph',
  MarkdownEditorBlockKind.heading2 => 'heading-2',
  MarkdownEditorBlockKind.heading3 => 'heading-3',
  MarkdownEditorBlockKind.quote => 'blockquote',
  MarkdownEditorBlockKind.bulletListItem => 'bullet-list-item',
  MarkdownEditorBlockKind.orderedListItem => 'ordered-list-item',
  MarkdownEditorBlockKind.horizontalRule => 'horizontal-rule',
  MarkdownEditorBlockKind.protocolEmptyParagraph => 'empty-paragraph',
  MarkdownEditorBlockKind.compatibilityText => 'compatibility-text',
};
