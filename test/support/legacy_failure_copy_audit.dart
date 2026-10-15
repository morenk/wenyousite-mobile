import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// 只统计实际传入旧展示文案的调用，不把类型化错误、声明或模式算作文案。
int countLegacyApiFailureCopy(String source) {
  final visitor = _LegacyFailureCopyVisitor();
  parseString(content: source).unit.accept(visitor);
  return visitor.count;
}

final class _LegacyFailureCopyVisitor extends RecursiveAstVisitor<void> {
  var count = 0;

  void _countArguments(ArgumentList arguments) {
    if (arguments.arguments.whereType<NamedArgument>().any(
      (argument) => argument.name.lexeme == 'userMessage',
    )) {
      count++;
    }
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.constructorName.type.name.lexeme == 'ApiFailure') {
      _countArguments(node.argumentList);
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // 无 new/const 的调用在未解析 AST 中是 MethodInvocation，命名工厂同理。
    final target = node.target;
    final isApiFailureTarget = switch (target) {
      SimpleIdentifier(:final name) => name == 'ApiFailure',
      PrefixedIdentifier(:final identifier) => identifier.name == 'ApiFailure',
      _ => false,
    };
    if (node.methodName.name == 'ApiFailure' || isApiFailureTarget) {
      _countArguments(node.argumentList);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitRedirectingConstructorInvocation(
    RedirectingConstructorInvocation node,
  ) {
    final constructor = node.parent;
    if (constructor is ConstructorDeclaration &&
        constructor.typeName?.name == 'ApiFailure') {
      _countArguments(node.argumentList);
    }
    super.visitRedirectingConstructorInvocation(node);
  }
}
