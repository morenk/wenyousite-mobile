import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'source_files.dart';

/// Follows local export chains, not implementation imports, so a facade cannot
/// hide a forbidden layer while consumers stay independent of its internals.
class DependencyGraph {
  DependencyGraph(this.root);

  final Directory root;
  final _direct = <String, ({Set<String> all, Set<String> exports})>{};

  Set<String> directTargets(File file) =>
      _read(relativePath(file.path, root)).all;

  Set<String> targets(File file) {
    final result = <String>{};
    final pending = [...directTargets(file)];
    while (pending.isNotEmpty) {
      final target = pending.removeLast();
      if (!result.add(target) || !target.startsWith('lib/')) continue;
      pending.addAll(_read(target).exports);
    }
    return result;
  }

  ({Set<String> all, Set<String> exports}) _read(String path) =>
      _direct.putIfAbsent(path, () {
        final file = File('${root.path}/$path');
        if (!file.existsSync()) return (all: <String>{}, exports: <String>{});
        final unit = parseString(
          content: file.readAsStringSync(),
          throwIfDiagnostics: false,
        ).unit;
        final all = <String>{};
        final exports = <String>{};
        for (final directive
            in unit.directives.whereType<NamespaceDirective>()) {
          final uris = [
            directive.uri.stringValue,
            ...directive.configurations.map(
              (configuration) => configuration.uri.stringValue,
            ),
          ];
          for (final uri in uris.nonNulls) {
            final target = normalizeDependency(uri, path);
            all.add(target);
            if (directive is ExportDirective) exports.add(target);
          }
        }
        return (all: all, exports: exports);
      });
}

String normalizeDependency(String uri, String sourcePath) {
  const packagePrefix = 'package:wenyousite_mobile/';
  if (uri.startsWith(packagePrefix)) {
    return 'lib/${uri.substring(packagePrefix.length)}';
  }
  if (uri.contains(':')) return uri;
  final segments = <String>[
    ...sourcePath.split('/')..removeLast(),
    ...uri.replaceAll('\\', '/').split('/'),
  ];
  final normalized = <String>[];
  for (final segment in segments) {
    if (segment.isEmpty || segment == '.') continue;
    if (segment == '..') {
      if (normalized.isNotEmpty) normalized.removeLast();
      continue;
    }
    normalized.add(segment);
  }
  return normalized.join('/');
}
