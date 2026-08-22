import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';

void main() {
  const nodeId = '550e8400-e29b-41d4-a716-446655440000';
  const secondNodeId = '550e8400-e29b-41d4-a716-446655440001';

  group('骰子表达式', () {
    const validCases = <String, String>{
      'd2': '1d2',
      'D1000': '1d1000',
      '001d002': '1d2',
      ' 100 D 1000 - 10000 ': '100d1000-10000',
      '2d6 + 0003': '2d6+3',
      '2d6-0': '2d6',
      '2d6+0': '2d6',
    };

    for (final MapEntry(key: input, value: canonical) in validCases.entries) {
      test('$input 规范化为 $canonical', () {
        expect(MarkdownDiceContract.normalizeNotation(input), canonical);
      });
    }

    test('拒绝越界、非整数与混淆符号', () {
      const invalidCases = <String>[
        '',
        'd1',
        'd1001',
        '0d6',
        '101d6',
        '1.5d6',
        '1e2d6',
        'd6+10001',
        'd6-10001',
        'd6--1',
        'd6+-1',
        '-1d6',
        'd+6',
        '１d６',
        '🎲d6',
      ];

      for (final input in invalidCases) {
        expect(
          MarkdownDiceContract.normalizeNotation(input),
          isNull,
          reason: '非法表达式不应被接受：$input',
        );
      }
    });

    test('超长数字安全拒绝且不抛出解析异常', () {
      final hugeNumber = '9' * 10000;

      expect(
        () => MarkdownDiceContract.normalizeNotation('${hugeNumber}d6'),
        returnsNormally,
      );
      expect(MarkdownDiceContract.normalizeNotation('${hugeNumber}d6'), isNull);
      expect(MarkdownDiceContract.normalizeNotation('1d6+$hugeNumber'), isNull);
    });
  });

  group('骰子 UUID 与节点结构', () {
    test('仅接受 UUID v4 及 RFC 4122 variant', () {
      const valid = <String>[
        nodeId,
        '550E8400-E29B-41D4-A716-446655440000',
        '550e8400-e29b-41d4-8716-446655440000',
        '550e8400-e29b-41d4-9716-446655440000',
        '550e8400-e29b-41d4-b716-446655440000',
      ];
      const invalid = <String>[
        '550e8400-e29b-11d4-a716-446655440000',
        '550e8400-e29b-41d4-7716-446655440000',
        '550e8400-e29b-41d4-c716-446655440000',
        '550e8400e29b41d4a716446655440000',
        '{550e8400-e29b-41d4-a716-446655440000}',
        '550e8400-e29b-41d4-a716-446655440000x',
        '550e8400-e29b-41d4-a716-44665544000',
        ' $nodeId',
        '$nodeId\n',
      ];

      for (final value in valid) {
        expect(
          MarkdownDiceContract.uuidV4.hasMatch(value),
          isTrue,
          reason: '应接受 $value',
        );
      }
      for (final value in invalid) {
        expect(
          MarkdownDiceContract.uuidV4.hasMatch(value),
          isFalse,
          reason: '应拒绝 $value',
        );
      }
    });

    test('节点匹配不跨行、不吞右括号，表达式最长 32 字符', () {
      final valid = MarkdownDiceContract.nodeAtStart.firstMatch(
        '[[DICE:V1:${nodeId.toUpperCase()}:2D6 + 03]]尾部',
      );
      expect(valid, isNotNull);
      expect(valid!.group(1)!.toLowerCase(), nodeId);
      expect(MarkdownDiceContract.normalizeNotation(valid.group(2)!), '2d6+3');
      expect(valid.group(0), endsWith(']]'));

      expect(
        MarkdownDiceContract.nodeAtStart.firstMatch(
          '[[dice:v1:$nodeId:${'1' * 33}]]',
        ),
        isNull,
      );
      expect(
        MarkdownDiceContract.nodeAtStart.firstMatch(
          '[[dice:v1:$nodeId:1d6\n+1]]',
        ),
        isNull,
      );
      expect(
        MarkdownDiceContract.nodeAtStart.firstMatch(
          '[[dice:v1:$nodeId:1d6]evil]]',
        ),
        isNull,
      );
    });
  });

  group('Markdown 节点统计与移除', () {
    String dice(String id, [String notation = '1d20']) =>
        '[[dice:v1:$id:$notation]]';

    test('相邻节点和重复身份均按正文中的节点出现次数统计', () {
      final markdown = '${dice(nodeId)}${dice(secondNodeId)} ${dice(nodeId)}';

      expect(MarkdownDiceContract.countMarkdownNodes(markdown), 3);
      expect(MarkdownDiceContract.removeMarkdownNodes(markdown), ' ');
      expect(MarkdownContent.hasVisibleNonDiceContent(markdown), isFalse);
    });

    test('20 个节点达到上限，第 21 个可被稳定识别', () {
      final twenty = List.generate(
        MarkdownDiceContract.maximumNodesPerPost,
        (index) => dice(
          '550e8400-e29b-41d4-a716-${index.toString().padLeft(12, '0')}',
        ),
      ).join(' ');
      final twentyOne = '$twenty ${dice(secondNodeId)}';

      expect(
        MarkdownDiceContract.countMarkdownNodes(twenty),
        MarkdownDiceContract.maximumNodesPerPost,
      );
      expect(
        MarkdownDiceContract.countMarkdownNodes(twentyOne),
        MarkdownDiceContract.maximumNodesPerPost + 1,
      );
      expect(MarkdownContent.hasVisibleNonDiceContent(twentyOne), isFalse);
    });

    test('围栏代码和成对行内代码不计数也不移除', () {
      final marker = dice(nodeId);
      final markdown = <String>[
        '真实 $marker',
        '`行内 $marker`',
        '``包含 ` 的代码 $marker``',
        '```dart',
        marker,
        '````',
        '围栏后 $marker',
        '````',
        marker,
        '```', // 比 opening 短，不能闭合围栏。
        marker,
        '````',
        '~~~md',
        marker,
        '~~~',
        '结尾 $marker',
      ].join('\n');

      expect(MarkdownDiceContract.countMarkdownNodes(markdown), 3);
      final removed = MarkdownDiceContract.removeMarkdownNodes(markdown);
      expect(removed, contains('`行内 $marker`'));
      expect(removed, contains('``包含 ` 的代码 $marker``'));
      expect(removed, contains('```dart\n$marker\n````'));
      expect(removed, contains('````\n$marker\n```\n$marker\n````'));
      expect(removed, contains('~~~md\n$marker\n~~~'));
      expect(removed, isNot(contains('真实 $marker')));
      expect(removed, isNot(contains('围栏后 $marker')));
      expect(removed, isNot(contains('结尾 $marker')));
    });

    test('未闭合行内反引号之后仍按后端语义识别骰子', () {
      final marker = dice(nodeId);
      final markdown = '未闭合 `$marker';

      expect(MarkdownDiceContract.countMarkdownNodes(markdown), 1);
      expect(MarkdownDiceContract.removeMarkdownNodes(markdown), '未闭合 `');
    });

    test('奇数反斜杠转义标记，偶数反斜杠仍允许形成节点', () {
      final marker = dice(nodeId);
      final markdown = '奇数 \\$marker\n偶数 \\\\$marker';

      expect(MarkdownDiceContract.countMarkdownNodes(markdown), 1);
      expect(
        MarkdownDiceContract.removeMarkdownNodes(markdown),
        '奇数 \\$marker\n偶数 \\\\',
      );
    });

    test('非法版本、UUID、notation 与超长节点保持可见且不占配额', () {
      final malformed = <String>[
        '[[dice:v2:$nodeId:1d20]]',
        '[[dice:v1:not-a-uuid:1d20]]',
        '[[dice:v1:$nodeId:0d6]]',
        '[[dice:v1:$nodeId:1d1001]]',
        '[[dice:v1:$nodeId:${'1' * 33}]]',
        '[[dice:v1:$nodeId:1d6]suffix]]',
      ].join(' ');

      expect(MarkdownDiceContract.countMarkdownNodes(malformed), 0);
      expect(MarkdownDiceContract.removeMarkdownNodes(malformed), malformed);
      expect(MarkdownContent.hasVisibleNonDiceContent(malformed), isTrue);
    });

    test('大量畸形协议文本在线性时间内完成且不误计数', () {
      final malformed = List.filled(
        1000,
        '[[dice:v1:$nodeId:${'9' * 33}]]',
      ).join(' ');

      final stopwatch = Stopwatch()..start();
      final count = MarkdownDiceContract.countMarkdownNodes(malformed);
      final removed = MarkdownDiceContract.removeMarkdownNodes(malformed);
      stopwatch.stop();

      expect(count, 0);
      expect(removed, malformed);
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(seconds: 2)),
        reason: '约 8 万字符的畸形输入不应退化为逐字符 substring 的二次扫描',
      );
    });

    test('大小写前缀和 CRLF 不影响有效节点统计及规范换行输出', () {
      final markdown =
          '首行 [[DICE:V1:${nodeId.toUpperCase()}:D20]]\r\n'
          '次行 ${dice(secondNodeId, '2D6 + 03')}';

      expect(MarkdownDiceContract.countMarkdownNodes(markdown), 2);
      expect(MarkdownDiceContract.removeMarkdownNodes(markdown), '首行 \n次行 ');
    });
  });

  group('Delta 节点统计', () {
    test('统计所有骰子 embed，忽略普通文本及其他/非 Map 载荷', () {
      final delta = Delta()
        ..insert('正文')
        ..insert({
          MarkdownDiceContract.embedType: {
            'version': 1,
            'nodeId': nodeId,
            'notation': '1d20',
          },
        })
        ..insert({MarkdownDiceContract.embedType: <String, Object?>{}})
        ..insert({MarkdownDiceContract.embedType: 'invalid'})
        ..insert({
          'wenyou_sticker': {'version': 1},
        })
        ..insert('\n');

      expect(MarkdownDiceContract.countDeltaNodes(delta), 2);
    });

    test('Delta 第 20 与 21 个 embed 不受相邻操作合并影响', () {
      final delta = Delta();
      for (
        var index = 0;
        index < MarkdownDiceContract.maximumNodesPerPost + 1;
        index++
      ) {
        delta.insert({
          MarkdownDiceContract.embedType: {
            'version': 1,
            'nodeId': nodeId,
            'notation': '1d20',
          },
        });
      }

      expect(
        MarkdownDiceContract.countDeltaNodes(delta),
        MarkdownDiceContract.maximumNodesPerPost + 1,
      );
    });
  });
}
