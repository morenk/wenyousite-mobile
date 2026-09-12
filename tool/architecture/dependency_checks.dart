import 'dart:io';

import 'allowlist.dart';
import 'dependency_graph.dart';
import 'source_files.dart';

void checkDomainBoundaries(
  List<File> files,
  Set<DomainBoundaryDebt> allowlist,
  List<String> failures,
  Directory root,
  DependencyGraph graph,
) {
  const forbiddenImports = <String>[
    'package:flutter/',
    'package:flutter_riverpod/',
    'package:riverpod/',
    'package:dio/',
    'package:wenyou_api/',
    'lib/core/network/',
  ];
  final actualDebt = <DomainBoundaryDebt>{};
  for (final file in files.where(
    (file) => relativePath(file.path, root).contains('/domain/'),
  )) {
    final path = relativePath(file.path, root);
    final dependencies = graph.targets(file);
    for (final dependency in dependencies.where(
      (target) => forbiddenImports.any(target.startsWith),
    )) {
      final debt = DomainBoundaryDebt(source: path, target: dependency);
      actualDebt.add(debt);
      if (!allowlist.contains(debt)) {
        failures.add('$path imports forbidden domain dependency $dependency');
      }
    }
  }
  for (final debt
      in allowlist.difference(actualDebt).toList()
        ..sort((left, right) => left.key.compareTo(right.key))) {
    failures.add('stale domain boundary debt: ${debt.key}');
  }
}

void checkDomainStateOwnership(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  final stateDeclaration = RegExp(
    r'^(?:sealed\s+|abstract\s+|final\s+)?class\s+\w*State\b',
    multiLine: true,
  );
  final phaseDeclaration = RegExp(r'^enum\s+\w*Phase\b', multiLine: true);
  for (final file in files.where(
    (file) => relativePath(file.path, root).contains('/domain/'),
  )) {
    final source = file.readAsStringSync();
    final path = relativePath(file.path, root);
    if (stateDeclaration.hasMatch(source)) {
      failures.add(
        '$path declares application state in domain; move it to application',
      );
    }
    if (phaseDeclaration.hasMatch(source)) {
      failures.add(
        '$path declares an application phase in domain; move it to application',
      );
    }
  }
}

void checkLayerDependencies(
  List<File> files,
  Set<String> allowlist,
  List<String> failures,
  Directory root,
  DependencyGraph graph,
) {
  final actualDebt = <String>{};
  for (final file in files) {
    final path = relativePath(file.path, root);
    final parts = path.split('/');
    if (parts.length < 5 || !path.startsWith('lib/features/')) continue;
    final fromLayer = parts[3];
    for (final target in graph.targets(file)) {
      final targetParts = target.split('/');
      if (targetParts.length < 5 || !target.startsWith('lib/features/')) {
        continue;
      }
      final toLayer = targetParts[3];
      if (fromLayer == 'data' &&
          toLayer == 'application' &&
          !target.endsWith('_ports.dart')) {
        final dependency = '$path->$target';
        actualDebt.add(dependency);
        if (!allowlist.contains(dependency)) {
          failures.add('new forbidden layer dependency: $dependency');
        }
        continue;
      }
      if (!_isForbiddenLayerDependency(fromLayer, toLayer)) continue;
      final dependency = '$path->$target';
      actualDebt.add(dependency);
      if (!allowlist.contains(dependency)) {
        failures.add('new forbidden layer dependency: $dependency');
      }
    }
  }
  for (final dependency in allowlist.difference(actualDebt).toList()..sort()) {
    failures.add('stale forbidden layer dependency debt: $dependency');
  }
}

bool _isForbiddenLayerDependency(String from, String to) {
  return switch (from) {
    'presentation' => to == 'data',
    'application' => to == 'data' || to == 'presentation',
    'domain' => to == 'data' || to == 'application' || to == 'presentation',
    'data' => to == 'presentation',
    _ => false,
  };
}

void checkFeatureDependencies(
  List<File> files,
  Set<String> allowlist,
  Set<String> cycleDebt,
  List<String> failures,
  Directory root,
  DependencyGraph graph,
) {
  final edges = <String>{};
  for (final file in files) {
    final path = relativePath(file.path, root);
    if (!path.startsWith('lib/features/')) continue;
    final from = path.split('/')[2];
    for (final target in graph.targets(file)) {
      final parts = target.split('/');
      if (parts.length < 4 || !target.startsWith('lib/features/')) continue;
      final to = parts[2];
      if (to != from) edges.add('$from->$to');
    }
  }
  for (final edge in edges.difference(allowlist).toList()..sort()) {
    failures.add('new cross-feature dependency is not allowed: $edge');
  }
  for (final edge in allowlist.difference(edges).toList()..sort()) {
    failures.add('stale cross-feature dependency debt: $edge');
  }
  final cyclicEdges = _cyclicFeatureEdges(edges);
  for (final edge in cyclicEdges.difference(cycleDebt).toList()..sort()) {
    failures.add('new cyclic cross-feature dependency is not allowed: $edge');
  }
  for (final edge in cycleDebt.difference(cyclicEdges).toList()..sort()) {
    failures.add('stale cyclic cross-feature dependency debt: $edge');
  }
}

Set<String> _cyclicFeatureEdges(Set<String> edges) {
  final graph = <String, Set<String>>{};
  for (final edge in edges) {
    final parts = edge.split('->');
    graph.putIfAbsent(parts[0], () => <String>{}).add(parts[1]);
    graph.putIfAbsent(parts[1], () => <String>{});
  }
  final result = <String>{};
  for (final edge in edges) {
    final parts = edge.split('->');
    if (_reachableFeatures(parts[1], graph).contains(parts[0])) {
      result.add(edge);
    }
  }
  return result;
}

Set<String> _reachableFeatures(String start, Map<String, Set<String>> graph) {
  final visited = <String>{};
  final pending = <String>[start];
  while (pending.isNotEmpty) {
    final current = pending.removeLast();
    for (final next in graph[current] ?? const <String>{}) {
      if (visited.add(next)) pending.add(next);
    }
  }
  return visited;
}

void checkCrossFeatureInternalImports(
  List<File> files,
  Set<String> allowlist,
  List<String> failures,
  Directory root,
  DependencyGraph graph,
) {
  final dependencies = <String>{};
  for (final file in files) {
    final path = relativePath(file.path, root);
    if (!path.startsWith('lib/features/')) continue;
    final from = path.split('/')[2];
    for (final target in graph.directTargets(file)) {
      final parts = target.split('/');
      if (parts.length < 5 || !target.startsWith('lib/features/')) continue;
      if (from != parts[2] &&
          (parts[3] == 'data' || parts[3] == 'presentation')) {
        dependencies.add('$path->$target');
      }
    }
  }
  for (final edge in dependencies.difference(allowlist).toList()..sort()) {
    failures.add(
      'new cross-feature internal import: $edge; use a feature facade',
    );
  }
  for (final edge in allowlist.difference(dependencies).toList()..sort()) {
    failures.add('stale cross-feature internal import debt: $edge');
  }
}

void checkCoreBoundary(
  List<File> files,
  List<String> failures,
  Directory root,
  DependencyGraph graph,
) {
  for (final file in files) {
    final path = relativePath(file.path, root);
    if (!path.startsWith('lib/core/')) continue;
    for (final target
        in graph
            .targets(file)
            .where((path) => path.startsWith('lib/features/'))) {
      failures.add(
        '$path depends on feature implementation $target; core must remain feature-independent',
      );
    }
  }
}
