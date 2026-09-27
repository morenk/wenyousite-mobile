import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'source_files.dart';

// 专用表单、冲突决策及剪贴板持久化确认保留自己的生命周期。
const _dialogExceptions = {
  'lib/features/reports/presentation/report_widgets.dart#_ReportDialogState.build',
  'lib/features/wallet/presentation/wallet_widgets.dart#_TipDialogState.build',
  'lib/features/app_shell/presentation/clipboard_navigation_prompt.dart#_ClipboardNavigationDialogState.build',
  'lib/features/threads/presentation/thread_management_page.dart#_ThreadManagementPageState._resolveConflict',
  'lib/features/moments/presentation/moment_compose_page.dart#_MomentComposePageState._resolveConflict',
};

// 角色切换按钮具有选中态，不能当作一次性提交操作迁移。
const _asyncButtonExceptions = {
  'lib/features/threads/presentation/thread_member_management_page.dart#_MemberRow.build',
};

void checkComponentBoundaries(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  for (final file in files) {
    final path = relativePath(file.path, root);
    if (!path.startsWith('lib/features/') || !path.contains('/presentation/')) {
      continue;
    }
    final unit = parseString(
      content: file.readAsStringSync(),
      throwIfDiagnostics: false,
    ).unit;
    for (final node in _nodes(unit).whereType<ArgumentList>()) {
      final parent = node.parent;
      if (parent is! MethodInvocation &&
          parent is! InstanceCreationExpression) {
        continue;
      }
      final invocation = parent!.toSource();
      final constructor = RegExp(
        r'^(?:const |new )?(AlertDialog|FilledButton|OutlinedButton|TextButton|IconButton)(?:\.\w+)?\(',
      ).firstMatch(invocation)?.group(1);
      if (constructor == null) continue;
      final owner = node.thisOrAncestorOfType<ClassDeclaration>();
      final className = owner == null
          ? ''
          : RegExp(r'class\s+(\w+)').firstMatch(owner.toSource())?.group(1);
      final method = node
          .thisOrAncestorOfType<MethodDeclaration>()
          ?.name
          .lexeme;
      final location = '$path#$className.$method';
      if (constructor == 'AlertDialog') {
        if (!_dialogExceptions.contains(location)) {
          failures.add(
            '$location constructs AlertDialog outside shared confirmation policy',
          );
        }
        continue;
      }
      final source = node.toSource();
      if (RegExp(r'\bCircularProgressIndicator\s*\(').hasMatch(source) &&
          !_asyncButtonExceptions.contains(location)) {
        failures.add(
          '$location constructs a loading button outside shared async controls',
        );
      }
      if (RegExp(r'''['"](?:加载更多[^'"]*|查看更早消息)['"]''').hasMatch(source)) {
        failures.add(
          '$location constructs a pagination button outside shared pagination controls',
        );
      }
    }
  }
}

Iterable<AstNode> _nodes(AstNode node) sync* {
  yield node;
  for (final child in node.childEntities.whereType<AstNode>()) {
    yield* _nodes(child);
  }
}
