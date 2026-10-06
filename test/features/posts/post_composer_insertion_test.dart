import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/posts/application/post_composer_draft.dart';

void main() {
  const mention = '[@白鸦](/users/player) ';
  test('身份卡提及在恢复正文后追加，不替换草稿', () {
    expect(
      mergePostComposerInsertion(
        content: '保留的草稿',
        insertion: mention,
        pending: false,
      ),
      '保留的草稿\n$mention',
    );
  });
  test('待重试请求保持原文，已存在的提及不重复', () {
    expect(
      mergePostComposerInsertion(
        content: '待重试',
        insertion: mention,
        pending: true,
      ),
      '待重试',
    );
    expect(
      mergePostComposerInsertion(
        content: mention,
        insertion: mention,
        pending: false,
      ),
      mention,
    );
  });
}
