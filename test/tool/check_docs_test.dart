import 'package:flutter_test/flutter_test.dart';

import '../../tool/docs/module_status.dart';

void main() {
  test('模块索引与正文状态一致时通过', () {
    final index = parseModuleIndex('''
| 模块 | 状态 | 当前事实 | 文档 |
| --- | --- | --- | --- |
| search | in_progress | cursor 分页待接入 | [搜索](search.md) |
| social | implemented | 验收完成 | [社交](social.md) |
''');
    final errors = validateModuleStatusIndex(
      modules: {'search', 'social'},
      documents: {
        'search': parseModuleStatusDeclarations('状态：`in_progress`'),
        'social': parseModuleStatusDeclarations('状态：`implemented`'),
      },
      index: index,
    );

    expect(errors, isEmpty);
  });

  test('拒绝未知状态、重复索引、未知模块和正文不一致', () {
    final index = parseModuleIndex('''
| 模块 | 状态 | 当前事实 | 文档 |
| --- | --- | --- | --- |
| search | complete | 旧状态 | [搜索](search.md) |
| search | in_progress | 重复 | [搜索](search.md) |
| ghost | planned | 不存在 | [未知](ghost.md) |
''');
    final errors = validateModuleStatusIndex(
      modules: {'search'},
      documents: {'search': parseModuleStatusDeclarations('状态：`in_progress`')},
      index: index,
    );

    expect(errors, contains('模块索引 search 使用未知状态 complete。'));
    expect(errors, contains('模块索引重复声明 search（第 4 行）。'));
    expect(errors, contains('模块索引包含不存在的功能模块 ghost。'));
    expect(errors, contains('search.md 状态 in_progress 与模块索引状态 complete 不一致。'));
  });

  test('拒绝索引缺项以及正文状态缺失或重复', () {
    final index = parseModuleIndex('''
| 模块 | 状态 | 当前事实 | 文档 |
| --- | --- | --- | --- |
| search | in_progress | 进行中 | [搜索](search.md) |
''');
    final errors = validateModuleStatusIndex(
      modules: {'search', 'social'},
      documents: {
        'search': const [],
        'social': parseModuleStatusDeclarations(
          '状态：`planned`\n状态：`in_progress`',
        ),
      },
      index: index,
    );

    expect(errors, contains('模块 social 未出现在模块索引中。'));
    expect(errors, contains('search.md 未声明模块状态。'));
    expect(errors, contains('social.md 重复声明模块状态。'));
  });
}
