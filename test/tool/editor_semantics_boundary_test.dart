import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/architecture/dependency_graph.dart';
import '../../tool/architecture/editor_semantics_checks.dart';
import 'architecture_test_workspace.dart';

void main() {
  late Directory root;
  setUp(() async => root = await createArchitectureTestWorkspace());
  tearDown(() => disposeArchitectureTestWorkspace(root));

  List<String> check(String source) {
    const path = 'lib/core/markdown/markdown_delta_codec.dart';
    writeArchitectureFixture(root, path, source);
    final failures = <String>[];
    checkEditorSemanticsBoundary(
      [File('${root.path}/$path')],
      failures,
      root,
      DependencyGraph(root),
    );
    return failures;
  }

  test('阻止通过转导出重新引入底层块语法', () {
    writeArchitectureFixture(
      root,
      'lib/shared.dart',
      "export 'core/markdown/markdown_list_structure.dart';",
    );
    expect(check("import '../../shared.dart';"), isNotEmpty);
  });
  test('阻止带别名的旧块解释调用', () {
    expect(
      check('void f() { old.MarkdownContent.quoteLineContent(s); }'),
      contains(contains('reinterprets block structure')),
    );
  });
  for (final argument in ['', ', inlineOnly: false']) {
    test('行内读取必须明确禁用块解释 $argument', () {
      expect(
        check('void f() { MarkdownDeltaRichLines.decode(s$argument); }'),
        contains(contains('inlineOnly: true')),
      );
    });
  }
  test('允许结构投影与纯行内解析，注释和字符串不误判', () {
    expect(
      check('''
      // MarkdownContent.quoteLineContent(s)
      void f() {
        final message = 'MarkdownRichLineDecoder.decode(s)';
        document.editableLines();
        MarkdownDeltaRichLines.decode(s, inlineOnly: true);
        MarkdownCanonicalLiteralDecoder.decode(s, inlineOnly: true);
      }
    '''),
      isEmpty,
    );
  });
}
