import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';

void main() {
  test('主题草稿允许骰子正文，发布时要求包含文字', () {
    final diceOnly = _diceMarkdown(1);

    expect(
      validateThreadDraft(title: '', body: diceOnly, tags: const []),
      isNull,
    );
    expect(
      validateThreadPublish(
        title: '测试主题',
        categorySlug: 'chat',
        body: diceOnly,
        tags: const [],
      ),
      contains('主题正文需要包含文字'),
    );
    expect(
      validateThreadPublish(
        title: '测试主题',
        categorySlug: 'chat',
        body: '正文 $diceOnly',
        tags: const [],
      ),
      isNull,
    );
  });

  test('主题正文阻止第 21 个骰子', () {
    expect(
      validateThreadDraft(title: '', body: _diceMarkdown(21), tags: const []),
      contains('最多可插入 20 个骰子'),
    );
  });
}

String _diceMarkdown(int count) => List.generate(count, (index) {
  final suffix = index.toString().padLeft(12, '0');
  return '[[dice:v1:00000000-0000-4000-8000-$suffix:1d6]]';
}).join(' ');
