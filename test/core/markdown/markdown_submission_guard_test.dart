import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_submission_guard.dart';

void main() {
  for (final source in [
    '[链接](ftp://example.com)',
    'ftp://example.com',
    '[链接](javascript:alert)',
    '![图](data:image/png;base64,AA)',
    r'\[链接\]\(ftp://example.com\)',
  ]) {
    test('保存前拒绝不允许的实际 URL $source', () {
      expect(
        () => MarkdownSubmissionGuard.validate(source),
        throwsA(isA<MarkdownCodecException>()),
      );
    });
  }
  for (final source in [
    '[链接](https://example.com)',
    'https://example.com',
    '[邮箱](mailto:user@example.com)',
    '[@用户](/users/cuser123)',
    r'\[链接\]\(ftp\:\/\/example\.com\)',
    '`[链接](ftp://example.com)`',
    '> `代码\n[链接](ftp://example.com)\n结束`',
    '- `代码\n[链接](ftp://example.com)\n结束`',
  ]) {
    test('合法目标及代码或字面文本不误报 $source', () {
      expect(() => MarkdownSubmissionGuard.validate(source), returnsNormally);
    });
  }
}
