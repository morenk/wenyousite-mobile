import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'dependency_graph.dart';
import 'source_files.dart';

/// 结构适配入口只能消费文档投影，不能恢复另一套块前缀和列表解析。
void checkEditorSemanticsBoundary(
  List<File> files,
  List<String> failures,
  Directory root,
  DependencyGraph graph,
) {
  const adapter = 'lib/core/markdown/markdown_delta_codec.dart';
  const forbiddenImports = {
    'package:markdown/markdown.dart',
    'lib/core/markdown/markdown_editable_block_syntax.dart',
    'lib/core/markdown/markdown_list_structure.dart',
    'lib/core/markdown/markdown_empty_paragraphs.dart',
  };
  for (final file in files) {
    if (relativePath(file.path, root) != adapter) continue;
    for (final target in graph.targets(file).intersection(forbiddenImports)) {
      failures.add('$adapter must consume document projection, not $target');
    }
    parseString(
      content: file.readAsStringSync(),
      throwIfDiagnostics: false,
    ).unit.accept(_EditorAdapterVisitor(failures));
  }
}

final class _EditorAdapterVisitor extends RecursiveAstVisitor<void> {
  _EditorAdapterVisitor(this.failures);
  final List<String> failures;

  static const _forbidden = {
    'MarkdownContent.unsupportedLineIndexes',
    'MarkdownContent.quoteLineContent',
    'MarkdownContent.isEmptyQuoteLine',
    'MarkdownContent.isQuotedEmptyParagraphLine',
    'MarkdownAlignmentContract.analyzeLines',
    'MarkdownRichLineDecoder.decode',
    'MarkdownRichLineDecoder.decodeEditable',
    'MarkdownRichLineDecoder.canonicalizeReaderBlockPrefix',
  };

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target?.toSource().split('.').last;
    final call = '$target.${node.methodName.name}';
    if (_forbidden.contains(call)) {
      failures.add('editor adapter reinterprets block structure through $call');
    }
    if (call == 'MarkdownDeltaRichLines.decode' ||
        call == 'MarkdownCanonicalLiteralDecoder.decode') {
      final inline = node.argumentList.arguments
          .whereType<NamedArgument>()
          .where((argument) => argument.name.lexeme == 'inlineOnly');
      if (inline.length != 1 ||
          inline.single.argumentExpression is! BooleanLiteral ||
          !(inline.single.argumentExpression as BooleanLiteral).value) {
        failures.add(
          'editor adapter must explicitly use inlineOnly: true for $call',
        );
      }
    }
    super.visitMethodInvocation(node);
  }
}
