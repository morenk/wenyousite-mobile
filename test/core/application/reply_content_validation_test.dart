import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/reply_content_validation.dart';

void main() {
  test('空白和仅格式内容使用相同提示', () {
    for (final content in ['', ' \n\t', '\u200b', '<br />', '>\n>']) {
      expect(replyContentValidationMessage(content), '消息框不能为空。');
    }
  });
  test('文字、纯图片、表情、骰子和独立附件仍可发送', () {
    for (final content in [
      '回复',
      '![图片](https://example.com/a.png)',
      '![表情](https://example.com/a.webp "wenyousite-sticker:v1:asset")',
      '[[dice:v1:550e8400-e29b-41d4-a716-446655440000:1d20]]',
      '[音频](https://example.com/a "wenyousite-audio:v1:x")',
    ]) {
      expect(replyContentValidationMessage(content), isNull);
    }
    expect(replyContentValidationMessage('', hasAttachment: true), isNull);
  });
}
