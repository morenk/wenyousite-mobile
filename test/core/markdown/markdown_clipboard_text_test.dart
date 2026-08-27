import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_clipboard_text.dart';

void main() {
  const threadId = 'cmsewdo0h000x7qv6aa77ll1v';
  const diceId = '550e8400-e29b-41d4-a716-446655440000';
  const diceNode = '[[dice:v1:$diceId:1d20]]';
  const stickerAssetId = 'cm1234567890123456789012';
  const sticker =
      '![表情](https://cdn.wenyou.site/sticker.webp '
      '"wenyousite-sticker:v1:$stickerAssetId")';

  test('只把受支持的行内原子投影为阅读态 label', () {
    const source =
        '**检定** [官网](https://example.com)；'
        '[设定 A](/threads/$threadId)，'
        'https://wenyou.site/threads/$threadId。'
        '[@张三](/users/user-zhang) 与 @全体玩家：$diceNode $sticker';

    expect(
      MarkdownClipboardText.project(
        source,
        diceLabels: const {diceId: '1d20 = 19'},
      ),
      '**检定** [官网](https://example.com)；'
      '设定 A，传送门。@张三 与 @全体玩家：1d20 = 19 [表情]',
    );
  });

  test('骰子没有结果时仍复制稳定可见占位 label', () {
    expect(MarkdownClipboardText.project(diceNode), '1d20 = ?');
  });

  test('代码、转义、普通链接图片和未知节点保持源文本', () {
    const unknownDice = '[[dice:v2:$diceId:1d20]]';
    const invalidDice = '[[dice:v1:$diceId:1d1]]';
    const ordinaryImage = '![入口](/threads/$threadId)';
    const emptyLink = '[](/threads/$threadId)';
    const source =
        '`[入口](/threads/$threadId) $diceNode $sticker`\n'
        '\\[入口](/threads/$threadId) \\$diceNode \\$sticker\n'
        '[外链](https://example.com) $ordinaryImage $emptyLink\n'
        '$unknownDice $invalidDice\n'
        '```md\n'
        '[入口](/threads/$threadId) $diceNode $sticker\n'
        '```';

    expect(
      MarkdownClipboardText.project(
        source,
        diceLabels: const {diceId: '1d20 = 19'},
      ),
      source,
    );
  });

  test('保留原有换行符、空白和未闭合代码前缀', () {
    const source =
        '  前文\r\n'
        '未闭合 ` 后文 $diceNode  \r\n'
        '\r\n'
        '[入口](/threads/$threadId)';

    expect(
      MarkdownClipboardText.project(
        source,
        diceLabels: const {diceId: '1d20 = 19'},
      ),
      '  前文\r\n'
      '未闭合 ` 后文 1d20 = 19  \r\n'
      '\r\n'
      '入口',
    );
  });
}
