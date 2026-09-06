import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_semantics.dart';

void main() {
  for (final source in const [
    '~~***甲乙***~~',
    '[***~~甲乙~~***](https://wenyou.site/help)',
    '***~~[甲乙](https://wenyou.site/help)~~***',
  ]) {
    test('历史嵌套按全部 marks 证明后规范写回：$source', () {
      final decoded = MarkdownDeltaCodec.decode(source).delta;
      expect(decoded.operations.first.data, '甲乙');
      expect(decoded.operations.first.attributes, {
        'bold': true,
        'italic': true,
        'strike': true,
        if (source.contains('https:')) 'link': 'https://wenyou.site/help',
      });
      final expected = source.contains('https:')
          ? '***[~~甲乙~~](https://wenyou.site/help)***'
          : '***~~甲乙~~***';
      expect(MarkdownDeltaCodec.encode(decoded), expected);
      expect(
        MarkdownDeltaSemantics.equivalent(
          decoded,
          MarkdownDeltaCodec.decode(expected).delta,
        ),
        isTrue,
      );
    });
  }

  final nodes = <Map<String, Object?>>[
    {
      MarkdownDeltaCodec.mentionEmbed: {
        'version': 1,
        'kind': 'user',
        'userId': 'user-one',
        'label': '@用户',
      },
    },
    {
      MarkdownDeltaCodec.mentionEmbed: {
        'version': 1,
        'kind': 'all_players',
        'label': '@全体玩家',
      },
    },
    {
      MarkdownDeltaCodec.diceEmbed: {
        'version': 1,
        'nodeId': '550e8400-e29b-41d4-a716-446655440000',
        'notation': '1d20',
      },
    },
    {
      MarkdownDeltaCodec.imageEmbed: {
        'version': 1,
        'url': 'https://cdn.example.com/a.webp',
        'alt': '图片',
        'title': '图注',
      },
    },
    {
      MarkdownDeltaCodec.stickerEmbed: {
        'version': 1,
        'assetId': 'cm1234567890123456789012',
        'url': 'https://cdn.example.com/a.webp',
        'alt': '表情',
      },
    },
    {
      MarkdownDeltaCodec.internalReferenceEmbed: {
        'version': 1,
        'label': '传送门',
        'location': '/threads/cmsewdo0h000x7qv6aa77ll1v',
      },
    },
  ];
  for (final node in nodes) {
    test('同样式不同来源不能跨越 ${node.keys.single}', () {
      final delta = Delta()
        ..insert('甲', {'bold': true})
        ..insert(node)
        ..insert('新*乙', {
          'bold': true,
          MarkdownDeltaCodec.literalTextAttribute: true,
        })
        ..insert('\n');
      final encoded = MarkdownDeltaCodec.encode(delta);
      final reopened = MarkdownDeltaCodec.decode(encoded).delta;
      expect(MarkdownDeltaSemantics.equivalent(delta, reopened), isTrue);
      expect(
        reopened.operations.where((op) => op.data is Map).single.data,
        node,
      );
      expect(MarkdownDeltaCodec.encode(reopened), encoded);
    });
  }

  test('不同链接目标与真实样式边界保持独立', () {
    final delta = Delta()
      ..insert('甲', {'bold': true})
      ..insert('乙', {'link': 'https://wenyou.site/help'})
      ..insert('新', {
        'link': 'https://wenyou.site/other',
        MarkdownDeltaCodec.literalTextAttribute: true,
      })
      ..insert('\n');
    expect(
      MarkdownDeltaCodec.encode(delta),
      '**甲**[乙](https://wenyou.site/help)[新](https://wenyou.site/other)',
    );
  });

  test('带安全转义的历史嵌套也按文字与全部 marks 规范化', () {
    const source = r'[***~~甲\*乙~~***](https://wenyou.site/help)';
    const expected = r'***[~~甲\*乙~~](https://wenyou.site/help)***';
    final decoded = MarkdownDeltaCodec.decode(source).delta;
    expect(
      decoded.operations
          .where((op) => op.data != '\n')
          .map((op) => op.data)
          .join(),
      '甲*乙',
    );
    expect(MarkdownDeltaCodec.encode(decoded), expected);
  });

  test('无损比较不能忽略文字、完整 marks、块、换行或节点身份', () {
    for (final (before, after) in const [
      ('甲', '乙'),
      ('**甲**', '*甲*'),
      ('[甲](https://wenyou.site/help)', '[甲](https://wenyou.site/other)'),
      ('## 甲', '### 甲'),
      ('甲\n乙', '甲乙'),
      ('甲\n\n乙', '甲\n乙'),
      ('甲\n<br />\n乙', '甲\n乙'),
      ('[wenyousite-align-v1-center]: #\n甲', '甲'),
      ('[@用户](/users/user-one)', '[@用户](/users/user-two)'),
      (
        '![图片](https://cdn.example.com/a.webp)',
        '![图片](https://cdn.example.com/b.webp)',
      ),
    ]) {
      expect(
        MarkdownDeltaSemantics.equivalent(
          MarkdownDeltaCodec.decode(before).delta,
          MarkdownDeltaCodec.decode(after).delta,
        ),
        isFalse,
      );
    }
  });

  test('公共编码拒绝可解析但语义变化的文字及未知来源属性', () {
    final unmarked = Delta()..insert('**源码字符**\n');
    final unknown = Delta()
      ..insert('甲', {'bold': true, 'unknown_origin': true})
      ..insert('\n');
    for (final delta in [unmarked, unknown, Delta()..retain(1)]) {
      expect(
        () => MarkdownDeltaCodec.encode(delta),
        throwsA(isA<MarkdownCodecException>()),
      );
    }
  });
}
