import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_site_clipboard.dart';

void main() {
  const parser = WenyouSiteClipboardParser();

  group('clipboard v2 顶层对齐白名单', () {
    for (final source in const ['reader', 'editor']) {
      for (final tag in const ['p', 'h2', 'h3']) {
        for (final alignment in const ['center', 'right']) {
          test('$source $tag $alignment 精确恢复为 Markdown v4', () {
            final delta = parser.parse(
              _envelope(
                version: 2,
                source: source,
                body: '<$tag data-wenyou-align="$alignment">内容</$tag>',
              ),
            );
            final prefix = switch (tag) {
              'h2' => '## ',
              'h3' => '### ',
              _ => '',
            };

            expect(delta, isNotNull);
            expect(
              MarkdownDeltaCodec.encode(delta!),
              '[wenyousite-align-v1-$alignment]: #\n$prefix内容',
            );
          });
        }
      }
    }

    for (final tag in const ['p', 'h2', 'h3']) {
      test('clipboard v1 $tag 即使带属性也固定降级为 left', () {
        final delta = parser.parse(
          _envelope(
            version: 1,
            source: 'editor',
            body: '<$tag data-wenyou-align="right">内容</$tag>',
          ),
        );
        final prefix = switch (tag) {
          'h2' => '## ',
          'h3' => '### ',
          _ => '',
        };

        expect(MarkdownDeltaCodec.encode(delta!), '$prefix内容');
      });
    }

    for (final attribute in const [
      '',
      'left',
      'justify',
      'Center',
      'RIGHT',
      ' center ',
      'right ',
    ]) {
      test('v2 不从非精确属性 "$attribute" 推断对齐', () {
        final rawAttribute = attribute.isEmpty
            ? ''
            : ' data-wenyou-align="$attribute"';
        final delta = parser.parse(
          _envelope(
            version: 2,
            source: 'reader',
            body: '<p$rawAttribute>内容</p>',
          ),
        );

        expect(MarkdownDeltaCodec.encode(delta!), '内容');
      });
    }

    test('CSS text-align 与 HTML align 属性都不能扩大能力', () {
      final delta = parser.parse(
        _envelope(
          version: 2,
          source: 'reader',
          body: '<p style="text-align:center" align="right">样式正文</p>',
        ),
      );

      expect(MarkdownDeltaCodec.encode(delta!), '样式正文');
    });
  });

  group('clipboard v2 排除块与原子节点', () {
    test('嵌套、列表、引用、分隔线、空块和普通图片都不继承属性', () {
      final delta = parser.parse(
        _envelope(
          version: 2,
          source: 'reader',
          body:
              '<div><p data-wenyou-align="center">嵌套</p></div>'
              '<blockquote data-wenyou-align="right">'
              '<p data-wenyou-align="right">引用</p></blockquote>'
              '<ul data-wenyou-align="center"><li>列表</li></ul>'
              '<hr data-wenyou-align="right">'
              '<p data-wenyou-align="center"><br></p>'
              '<p data-wenyou-align="right">正文'
              '<img src="https://cdn.example.com/a.png"></p>',
        ),
      );

      final markdown = MarkdownDeltaCodec.encode(delta!);
      expect(markdown, isNot(contains('wenyousite-align')));
      expect(markdown, contains('嵌套'));
      expect(markdown, contains('> 引用'));
      expect(markdown, contains('- 列表'));
      expect(markdown, contains(r'正文\[图片\]'));
    });

    test('reader 的提及、全体玩家、骰子与表情标签可继承居中', () {
      const diceId = '550e8400-e29b-41d4-a716-446655440000';
      final delta = parser.parse(
        _envelope(
          version: 2,
          source: 'reader',
          body:
              '<p data-wenyou-align="center">'
              '<a href="/users/user-zhang">@张三</a> @全体玩家 '
              '<span data-type="dice_inline" data-node-id="$diceId" '
              'data-notation="1d20">1d20 = ?</span> '
              '<span data-wenyou-clipboard-media="sticker">表情</span>'
              '</p>',
        ),
      );

      final markdown = MarkdownDeltaCodec.encode(delta!);
      expect(markdown, startsWith('[wenyousite-align-v1-center]: #\n'));
      expect(markdown, contains('[@张三](/users/user-zhang)'));
      expect(markdown, contains('@全体玩家'));
      expect(markdown, contains('[[dice:v1:'));
      expect(markdown, contains(r'\[表情\]'));
    });

    test('editor 的合法 sticker 原子可继承居右，普通图片仍清除', () {
      final sticker = parser.parse(
        _envelope(
          version: 2,
          source: 'editor',
          body:
              '<p data-wenyou-align="right">前 '
              '<img data-type="sticker-inline" '
              'data-asset-id="cm1234567890123456789012" '
              'src="https://cdn.example.com/stickers/a.webp" alt="表情"> 后'
              '</p>',
        ),
      );
      final image = parser.parse(
        _envelope(
          version: 2,
          source: 'editor',
          body:
              '<p data-wenyou-align="right">正文 '
              '<img data-type="image-block" '
              'src="https://cdn.example.com/a.png" alt="图片"></p>',
        ),
      );

      expect(
        MarkdownDeltaCodec.encode(sticker!),
        startsWith('[wenyousite-align-v1-right]: #\n'),
      );
      expect(
        MarkdownDeltaCodec.encode(image!),
        isNot(contains('wenyousite-align')),
      );
    });

    test('缺 envelope 与未知版本都不能把外部 HTML 对齐恢复为结构', () {
      expect(parser.parse('<p data-wenyou-align="center">外部内容</p>'), isNull);
      expect(
        parser.parse(
          _envelope(
            version: 999,
            source: 'reader',
            body: '<p data-wenyou-align="center">外部内容</p>',
          ),
        ),
        isNull,
      );
    });
  });
}

String _envelope({
  required int version,
  required String source,
  required String body,
}) =>
    '<div data-wenyou-clipboard="$version" '
    'data-wenyou-clipboard-source="$source">$body</div>';
