String postControllerDiceMarkdown(int count, {int namespace = 0}) =>
    List.generate(count, (index) {
      final suffix = (namespace * 100 + index).toString().padLeft(12, '0');
      return '[[dice:v1:00000000-0000-4000-8000-$suffix:1d6]]';
    }).join(' ');

String postControllerIgnoredDiceMarkdown() {
  final nodes = postControllerDiceMarkdown(21);
  return [
    '可见文字',
    '```text',
    nodes,
    '```',
    '`${postControllerDiceMarkdown(1)}`',
    r'\[[dice:v1:00000000-0000-4000-8000-000000000099:1d6]]',
    '[[dice:v1:not-a-uuid:1d6]]',
    '[[dice:v1:00000000-0000-4000-8000-000000000098:1d1]]',
  ].join('\n');
}
