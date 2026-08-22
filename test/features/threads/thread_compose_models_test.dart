import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';

void main() {
  test('主题草稿允许空正文和纯骰子，发布时要求可见非骰子内容', () {
    for (final body in ['', _diceMarkdown(1), _diceMarkdown(20)]) {
      expect(
        validateThreadDraft(title: '', body: body, tags: const []),
        isNull,
      );
      expect(
        validateThreadPublish(
          title: '测试主题',
          categorySlug: 'chat',
          body: body,
          tags: const [],
        ),
        '主题正文需要包含文字，骰子可作为补充。',
      );
    }

    expect(
      validateThreadPublish(
        title: '测试主题',
        categorySlug: 'chat',
        body: '正文 ${_diceMarkdown(20)}',
        tags: const [],
      ),
      isNull,
    );
  });

  test('主题草稿和发布均在第 21 个骰子返回稳定上限错误', () {
    const error = '当前正文最多可插入 20 个骰子，请删除一个后重试。';
    expect(
      validateThreadDraft(title: '', body: _diceMarkdown(21), tags: const []),
      error,
    );
    expect(
      validateThreadPublish(
        title: '测试主题',
        categorySlug: 'chat',
        body: '正文 ${_diceMarkdown(21)}',
        tags: const [],
      ),
      error,
    );
  });

  test('两份主题草稿各自拥有 20 个骰子限额，验证不跨 Post 聚合', () {
    expect(
      validateThreadDraft(
        title: '草稿一',
        body: _diceMarkdown(20, namespace: 0),
        tags: const [],
      ),
      isNull,
    );
    expect(
      validateThreadDraft(
        title: '草稿二',
        body: _diceMarkdown(20, namespace: 1),
        tags: const [],
      ),
      isNull,
    );
  });

  test('代码、行内代码、转义和非法协议中的伪骰子不占用主题限额', () {
    final body =
        '${_ignoredDiceMarkdown()}\n${_diceMarkdown(20, namespace: 5)}';

    expect(validateThreadDraft(title: '', body: body, tags: const []), isNull);
    expect(
      validateThreadPublish(
        title: '测试主题',
        categorySlug: 'chat',
        body: body,
        tags: const [],
      ),
      isNull,
    );
  });
}

String _diceMarkdown(int count, {int namespace = 0}) =>
    List.generate(count, (index) {
      final suffix = (namespace * 100 + index).toString().padLeft(12, '0');
      return '[[dice:v1:00000000-0000-4000-8000-$suffix:1d6]]';
    }).join(' ');

String _ignoredDiceMarkdown() {
  return [
    '可发布的文字',
    '```text',
    _diceMarkdown(21),
    '```',
    '`${_diceMarkdown(1)}`',
    r'\[[dice:v1:00000000-0000-4000-8000-000000000099:1d6]]',
    '[[dice:v1:not-a-uuid:1d6]]',
    '[[dice:v1:00000000-0000-4000-8000-000000000098:0d6]]',
  ].join('\n');
}
