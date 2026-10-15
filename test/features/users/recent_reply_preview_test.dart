import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/users/data/recent_reply_preview.dart';

void main() {
  test('先解码实体和压缩排版空白，再按可见文字截断', () {
    expect(
      recentReplyPreview('【构筑表】${'&#32;' * 60}\n────种族────\n**精灵**'),
      '【构筑表】 ────种族──── 精灵',
    );
    expect(recentReplyPreview('甲&#x20;&#032;&nbsp;\u3000乙'), '甲 乙');
  });

  test('实体只解码一次，代码和转义字面不作二次转换', () {
    expect(recentReplyPreview('&amp;#32;'), '&#32;');
    expect(recentReplyPreview(r'\&#32;'), '&#32;');
    expect(recentReplyPreview('`&#32;`'), '&#32;');
    expect(recentReplyPreview('```text\n&#32;\n```'), '&#32;');
    expect(recentReplyPreview('`甲\n<br />\n&#32;乙`'), '甲 <br /> &#32;乙');
  });

  test('保留链接标签、图片占位及段落分隔', () {
    expect(
      recentReplyPreview(
        '[标签](https://example.com)\n\n![图](https://example.com/a.png)\n<br />\n末段',
      ),
      '标签 [图片] 末段',
    );
    expect(recentReplyPreview('<https://example.com>'), '[链接]');
  });

  test('忽略正文对齐元数据', () {
    expect(recentReplyPreview('[align:center]: #\n\n正文'), '正文');
  });

  test('提及原子标签保留实体字面，骰子使用服务端结果', () {
    const id = '12345678-1234-4234-8234-123456789abc';
    expect(recentReplyPreview('[@甲&#32;乙](/users/user-1)'), '@甲&#32;乙');
    expect(
      recentReplyPreview('[[dice:v1:$id:2d6]]', diceLabels: {id: '2d6 = 8'}),
      '[2d6 = 8]',
    );
    expect(recentReplyPreview('[[dice:v1:$id:2d6]]'), '[2d6 = ?]');
  });

  test('截断不切开补充平面字符或留下半截实体', () {
    final text = recentReplyPreview('&#x1F600;' * 181);
    expect(text, '${'😀' * 179}…');
    expect(text.runes.length, 180);
  });
}
