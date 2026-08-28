import 'dart:convert';
import 'dart:io';

const _idempotentOperations = <String>{
  'directConversationsCreate',
  'directConversationsSend',
  'economyTipMoment',
  'economyTipThread',
  'economyTipUser',
  'momentsCreate',
  'momentsCreateComment',
  'postsCreate',
  'stickersImportDirectMessage',
  'stickersImportMedia',
  'stickersImportPostImage',
  'subthreadsCreate',
  'threadsCreate',
};

const _maximumDartFileLines = 900;
const _reviewDartFileLines = 700;
const _legacyStateNotifierBaseline = 59;
const _crossFeatureInternalImportBaseline = 41;
const _featurePresentationSpinnerBaseline = 77;

void main() {
  final failures = collectArchitectureFailures(Directory.current);

  if (failures.isNotEmpty) {
    stderr.writeln('Architecture checks failed (${failures.length}):');
    for (final failure in failures) {
      stderr.writeln('- $failure');
    }
    exitCode = 1;
    return;
  }
  final reviewNotices = collectArchitectureReviewNotices(Directory.current);
  if (reviewNotices.isNotEmpty) {
    stdout.writeln('Architecture review budget (${reviewNotices.length}):');
    for (final notice in reviewNotices) {
      stdout.writeln('- $notice');
    }
  }
  stdout.writeln(
    'Architecture checks passed: request policies, domain boundaries, '
    'layering, feature dependencies, cycles, file size, version and '
    'dependency, transient-feedback and route-transition hygiene.',
  );
}

List<String> collectArchitectureFailures(Directory root) {
  final failures = <String>[];
  final allowlist = _readAllowlist(root);
  final dartFiles = _dartFiles(Directory('${root.path}/lib'));
  final testDartFiles = _dartFiles(Directory('${root.path}/test'));

  _checkIdempotentPolicies(dartFiles, failures, root);
  _checkDomainBoundaries(
    dartFiles,
    allowlist.domainBoundaryDebt,
    failures,
    root,
  );
  _checkDomainStateOwnership(dartFiles, failures, root);
  _checkDartFileSizes(dartFiles, allowlist.largeFileDebt, failures, root);
  _checkHandwrittenParts(dartFiles, failures, root);
  _checkLayerDependencies(
    dartFiles,
    allowlist.layerDependencyDebt,
    failures,
    root,
  );
  _checkFeatureDependencies(
    dartFiles,
    allowlist.featureDependencies,
    allowlist.featureCycleDebt,
    failures,
    root,
  );
  _checkCrossFeatureInternalImports(dartFiles, failures, root);
  _checkLegacyStateNotifierBudget(dartFiles, failures, root);
  _checkFeatureSpinnerBudget(dartFiles, failures, root);
  _checkEditorPublicSurface(dartFiles, failures, root);
  _checkFoundationIconBoundary(dartFiles, failures, root);
  _checkSharedTabBoundary(dartFiles, failures, root);
  _checkSnackBarBoundary(dartFiles, failures, root);
  _checkRouteTransitionBoundary(dartFiles, failures, root);
  _checkVersionConsistency(failures, root);
  _checkDirectDependencies(dartFiles, failures, root);
  _checkRawRequestFlags(dartFiles, failures, root);
  _checkRawRouteNavigation(dartFiles, failures, root);
  _checkRawRouteDefinitions(dartFiles, failures, root);
  _checkGoldenTestSetup(testDartFiles, failures, root);

  failures.sort();
  return failures;
}

void _checkFeatureSpinnerBudget(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  final pattern = RegExp(r'\bCircularProgressIndicator\s*\(');
  var count = 0;
  for (final file in files) {
    final path = _relative(file.path, root);
    if (!path.startsWith('lib/features/') || !path.contains('/presentation/')) {
      continue;
    }
    count += pattern.allMatches(file.readAsStringSync()).length;
  }
  if (count > _featurePresentationSpinnerBaseline) {
    failures.add(
      'feature presentation spinners grew from '
      '$_featurePresentationSpinnerBaseline to $count; use a shared loading '
      'primitive',
    );
  }
}

List<String> collectArchitectureReviewNotices(Directory root) {
  final notices = <String>[];
  for (final file in _dartFiles(
    Directory('${root.path}/lib'),
  ).where((file) => !file.path.replaceAll('\\', '/').endsWith('.g.dart'))) {
    final lineCount = _lineCount(file.readAsStringSync());
    if (lineCount <= _reviewDartFileLines ||
        lineCount > _maximumDartFileLines) {
      continue;
    }
    notices.add(
      '${_relative(file.path, root)} has $lineCount lines; review a focused '
      'split when this file is next changed',
    );
  }
  notices.sort();
  return notices;
}

void _checkLegacyStateNotifierBudget(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  final declarations = <String>[];
  final pattern = RegExp(r'\bextends\s+StateNotifier\s*<');
  for (final file in files) {
    final count = pattern.allMatches(file.readAsStringSync()).length;
    declarations.addAll(
      List.filled(count, _relative(file.path, root), growable: false),
    );
  }
  if (declarations.length > _legacyStateNotifierBaseline) {
    failures.add(
      'legacy StateNotifier declarations grew from '
      '$_legacyStateNotifierBaseline to ${declarations.length}; use '
      'Notifier or AsyncNotifier for new state',
    );
  }
}

void _checkCrossFeatureInternalImports(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  final dependencies = <String>[];
  for (final file in files) {
    final path = _relative(file.path, root);
    if (!path.startsWith('lib/features/')) continue;
    final from = path.split('/')[2];
    for (final target in _dependencyTargets(file, root)) {
      final parts = target.split('/');
      if (parts.length < 5 || !target.startsWith('lib/features/')) continue;
      final to = parts[2];
      final layer = parts[3];
      if (from != to && (layer == 'data' || layer == 'presentation')) {
        dependencies.add('$path->$target');
      }
    }
  }
  if (dependencies.length > _crossFeatureInternalImportBaseline) {
    failures.add(
      'cross-feature data/presentation imports grew from '
      '$_crossFeatureInternalImportBaseline to ${dependencies.length}; '
      'publish and use a feature facade instead',
    );
  }
}

void _checkSnackBarBoundary(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  const sharedPolicy = 'lib/core/widgets/wenyou_snack_bar.dart';
  const forbiddenPatterns = <String, String>{
    r'\bSnackBar\s*\(': 'constructs SnackBar',
    r'\bSnackBarAction\s*\(': 'constructs SnackBarAction',
    r'\.showSnackBar\s*\(': 'calls showSnackBar',
  };

  for (final file in files) {
    final path = _relative(file.path, root);
    if (path == sharedPolicy) continue;
    final source = file.readAsStringSync();
    for (final entry in forbiddenPatterns.entries) {
      if (RegExp(entry.key).hasMatch(source)) {
        failures.add(
          '$path ${entry.value} outside the shared transient-feedback policy',
        );
      }
    }
  }
}

void _checkRouteTransitionBoundary(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  const sharedPolicy = 'lib/core/navigation/wenyou_page_transitions.dart';
  const appTheme = 'lib/app/app_theme.dart';
  const nestedNavigatorException =
      'lib/features/posts/presentation/post_composer_sheet.dart';
  const centralizedConstructors = <String>[
    'NoTransitionPage',
    'CustomTransitionPage',
    'MaterialPageRoute',
    'CupertinoPageRoute',
  ];

  for (final file in files) {
    final path = _relative(file.path, root);
    if (path == sharedPolicy) continue;
    final source = file.readAsStringSync();
    for (final constructor in centralizedConstructors) {
      if (RegExp('\\b$constructor(?:<[^>]+>)?\\s*\\(').hasMatch(source)) {
        failures.add(
          '$path uses $constructor outside the shared navigation policy',
        );
      }
    }
    if (RegExp(r'\bextends\s+PageTransitionsBuilder\b').hasMatch(source)) {
      failures.add(
        '$path defines PageTransitionsBuilder outside the shared navigation policy',
      );
    }
    if (path != appTheme &&
        RegExp(r'\bPageTransitionsTheme\s*\(').hasMatch(source)) {
      failures.add(
        '$path configures PageTransitionsTheme outside the app theme',
      );
    }
    if (path != nestedNavigatorException &&
        RegExp(r'\bPageRouteBuilder(?:<[^>]+>)?\s*\(').hasMatch(source)) {
      failures.add(
        '$path uses PageRouteBuilder outside the shared navigation policy',
      );
    }
  }
}

void _checkSharedTabBoundary(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  const forbiddenPatterns = <String, String>{
    r'\bTabBar\s*\(': 'Material TabBar',
    r'\bTabBarView\s*\(': 'Material TabBarView',
    r'\bDefaultTabController\s*\(': 'Material DefaultTabController',
  };
  for (final file in files) {
    final path = _relative(file.path, root);
    if (!path.startsWith('lib/features/') || !path.contains('/presentation/')) {
      continue;
    }
    final source = file.readAsStringSync();
    for (final entry in forbiddenPatterns.entries) {
      if (RegExp(entry.key).hasMatch(source)) {
        failures.add('$path uses ${entry.value}; use WenyouContentTabs');
      }
    }
  }
}

void _checkHandwrittenParts(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  final partOf = RegExp(r'^\s*part\s+of\b', multiLine: true);
  final partDirective = RegExp(
    r'''^\s*part\s+['"]([^'"]+)['"]\s*;''',
    multiLine: true,
  );
  for (final file in files.where((file) => !file.path.endsWith('.g.dart'))) {
    final source = file.readAsStringSync();
    final path = _relative(file.path, root);
    if (partOf.hasMatch(source)) {
      failures.add('$path uses handwritten part-of; use an explicit library');
    }
    for (final match in partDirective.allMatches(source)) {
      if (!match.group(1)!.endsWith('.g.dart')) {
        failures.add('$path uses handwritten part; use an explicit library');
      }
    }
  }
}

void _checkDartFileSizes(
  List<File> files,
  Map<String, int> allowlist,
  List<String> failures,
  Directory root,
) {
  final actualDebt = <String, int>{};
  for (final file in files.where(
    (file) => !file.path.replaceAll('\\', '/').endsWith('.g.dart'),
  )) {
    final path = _relative(file.path, root);
    final lineCount = _lineCount(file.readAsStringSync());
    if (lineCount <= _maximumDartFileLines) continue;

    actualDebt[path] = lineCount;
    final baseline = allowlist[path];
    if (baseline == null) {
      failures.add(
        '$path has $lineCount lines; split non-generated Dart files above '
        '$_maximumDartFileLines lines',
      );
    } else if (lineCount > baseline) {
      failures.add(
        '$path grew from the allowed $baseline lines to $lineCount lines',
      );
    } else if (lineCount < baseline) {
      failures.add(
        '$path large-file debt can be tightened from $baseline to '
        '$lineCount lines',
      );
    }
  }

  for (final path in allowlist.keys.where(
    (path) => !actualDebt.containsKey(path),
  )) {
    failures.add('stale large-file debt: $path');
  }
}

int _lineCount(String source) {
  if (source.isEmpty) return 0;
  final newlineCount = '\n'.allMatches(source).length;
  return source.endsWith('\n') ? newlineCount : newlineCount + 1;
}

void _checkFoundationIconBoundary(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  const forbiddenPatterns = <String, String>{
    r'\bIcons\.': 'Material Icons.*',
    r'\bIconData\b': 'Material IconData',
    r'\bIcon\s*\(': 'Material Icon(...)',
  };
  for (final file in files) {
    final source = file.readAsStringSync();
    final path = _relative(file.path, root);
    for (final entry in forbiddenPatterns.entries) {
      if (RegExp(entry.key).hasMatch(source)) {
        failures.add(
          '$path uses ${entry.value}; use Foundation semantic icons',
        );
      }
    }
  }
}

void _checkEditorPublicSurface(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  const publicEditorSurfaces = <String>{
    'lib/features/editor/editor.dart',
    'lib/features/editor/editor_persistence.dart',
  };
  for (final file in files) {
    final path = _relative(file.path, root);
    if (!path.startsWith('lib/features/') ||
        path.startsWith('lib/features/editor/')) {
      continue;
    }
    for (final target in _dependencyTargets(file, root)) {
      if (target.startsWith('lib/features/editor/') &&
          !publicEditorSurfaces.contains(target)) {
        failures.add(
          '$path imports editor internals $target; use an editor root facade',
        );
      }
    }
  }
}

void _checkIdempotentPolicies(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  for (final file in files) {
    final source = file.readAsStringSync();
    for (final operation in _idempotentOperations) {
      final matcher = RegExp('\\.$operation\\s*\\(');
      for (final match in matcher.allMatches(source)) {
        final openingParenthesis = source.indexOf('(', match.start);
        final call = _balancedCall(source, openingParenthesis);
        if (!call.contains('extra: ApiRequestPolicy.idempotentCreate.extra')) {
          failures.add(
            '${_relative(file.path, root)} calls $operation without the '
            'idempotent-create request policy',
          );
        }
      }
    }
  }
}

void _checkDomainBoundaries(
  List<File> files,
  Set<_DomainBoundaryDebt> allowlist,
  List<String> failures,
  Directory root,
) {
  const forbiddenImports = <String>[
    'package:flutter/',
    'package:flutter_riverpod/',
    'package:riverpod/',
    'package:dio/',
    'package:wenyou_api/',
    'lib/core/network/',
  ];
  final actualDebt = <_DomainBoundaryDebt>{};
  for (final file in files.where(
    (file) => _relative(file.path, root).contains('/domain/'),
  )) {
    final path = _relative(file.path, root);
    final dependencies = _dependencyTargets(file, root);
    for (final dependency in dependencies.where(
      (target) => forbiddenImports.any(target.startsWith),
    )) {
      final debt = _DomainBoundaryDebt(source: path, target: dependency);
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

void _checkDomainStateOwnership(
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
    (file) => _relative(file.path, root).contains('/domain/'),
  )) {
    final source = file.readAsStringSync();
    final path = _relative(file.path, root);
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

Set<String> _dependencyTargets(File file, Directory root) {
  final source = file
      .readAsStringSync()
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '');
  final directivePattern = RegExp(
    r'^\s*(?:import|export)\s+([\s\S]*?);',
    multiLine: true,
  );
  final uriPattern = RegExp(r'''['"]([^'"]+)['"]''');
  final sourcePath = _relative(file.path, root);
  return {
    for (final directive in directivePattern.allMatches(source))
      for (final uri in uriPattern.allMatches(directive.group(1)!))
        _normalizeDependency(uri.group(1)!, sourcePath),
  };
}

String _normalizeDependency(String uri, String sourcePath) {
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

void _checkLayerDependencies(
  List<File> files,
  Set<String> allowlist,
  List<String> failures,
  Directory root,
) {
  final actualDebt = <String>{};
  for (final file in files) {
    final path = _relative(file.path, root);
    final parts = path.split('/');
    if (parts.length < 5 || !path.startsWith('lib/features/')) continue;
    final fromLayer = parts[3];
    for (final target in _dependencyTargets(file, root)) {
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

void _checkFeatureDependencies(
  List<File> files,
  Set<String> allowlist,
  Set<String> cycleDebt,
  List<String> failures,
  Directory root,
) {
  final edges = <String>{};
  for (final file in files) {
    final path = _relative(file.path, root);
    if (!path.startsWith('lib/features/')) continue;
    final from = path.split('/')[2];
    for (final target in _dependencyTargets(file, root)) {
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

void _checkVersionConsistency(List<String> failures, Directory root) {
  final pubspec = File('${root.path}/pubspec.yaml').readAsStringSync();
  final readme = File('${root.path}/README.md').readAsStringSync();
  final pubspecVersion = RegExp(
    r'^version:\s*([^\s]+)',
    multiLine: true,
  ).firstMatch(pubspec)?.group(1);
  final readmeVersion = RegExp(r'当前版本：`([^`]+)`').firstMatch(readme)?.group(1);
  if (pubspecVersion == null || readmeVersion == null) {
    failures.add('cannot read version from pubspec.yaml or README.md');
  } else if (pubspecVersion != readmeVersion) {
    failures.add(
      'README version $readmeVersion does not match pubspec $pubspecVersion',
    );
  }

  final foundationRef = RegExp(
    r'wenyousite_foundation:\s*[\s\S]*?^\s+ref:\s*([^\s]+)',
    multiLine: true,
  ).firstMatch(pubspec)?.group(1);
  if (foundationRef == null) return;

  final documentedFoundationVersions = <String>{
    for (final match in RegExp(
      r'wenyousite-foundation(?:/tree/|\s+)v(\d+\.\d+\.\d+)',
    ).allMatches(readme))
      'v${match.group(1)}',
  };
  if (documentedFoundationVersions.isEmpty) {
    failures.add('README does not document the locked Foundation ref');
  } else {
    for (final documentedVersion in documentedFoundationVersions) {
      if (documentedVersion != foundationRef) {
        failures.add(
          'README Foundation $documentedVersion does not match pubspec '
          '$foundationRef',
        );
      }
    }
  }
}

void _checkGoldenTestSetup(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  for (final file in files) {
    final source = file.readAsStringSync();
    if (!source.contains('matchesGoldenFile(')) continue;
    if (!source.contains('setUpAll(loadFoundationTestFonts)')) {
      failures.add(
        '${_relative(file.path, root)} uses golden files without loading '
        'Foundation test fonts',
      );
    }
  }
}

void _checkDirectDependencies(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  final pubspec = File('${root.path}/pubspec.yaml').readAsLinesSync();
  final dependencies = <String>{};
  var inDependencies = false;
  for (final line in pubspec) {
    if (line == 'dependencies:') {
      inDependencies = true;
      continue;
    }
    if (line == 'dev_dependencies:') break;
    if (!inDependencies) continue;
    final match = RegExp(r'^  ([a-zA-Z0-9_]+):').firstMatch(line);
    if (match != null) dependencies.add(match.group(1)!);
  }
  final allSource = files.map((file) => file.readAsStringSync()).join('\n');
  for (final dependency in dependencies.toList()..sort()) {
    if (!allSource.contains('package:$dependency/')) {
      failures.add('direct dependency is unused by lib/: $dependency');
    }
  }
}

void _checkRawRequestFlags(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  for (final file in files) {
    final path = _relative(file.path, root);
    if (path.endsWith('/api_request_policy.dart')) continue;
    final source = file.readAsStringSync();
    if (RegExp(r'''["'](?:skipAuth|idempotentCreate)["']''').hasMatch(source)) {
      failures.add('$path uses a raw request-policy flag');
    }
  }
}

void _checkRawRouteNavigation(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  final rawNavigation = RegExp(
    r'''\b(?:context|router)\.(?:go|push|replace)\(\s*["']/''',
  );
  for (final file in files) {
    final path = _relative(file.path, root);
    if (rawNavigation.hasMatch(file.readAsStringSync())) {
      failures.add(
        '$path navigates with a raw path; use a named route or '
        'AppRouteLocations',
      );
    }
  }
}

void _checkRawRouteDefinitions(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  for (final file in files) {
    final path = _relative(file.path, root);
    if (path != 'lib/app/app_router.dart' &&
        !path.startsWith('lib/app/routes/')) {
      continue;
    }
    final source = file.readAsStringSync();
    if (RegExp(r'''\bpath:\s*["']''').hasMatch(source)) {
      failures.add(
        '$path defines a raw route path; use AppRoutePaths constants',
      );
    }
    if (RegExp(r'''\bname:\s*["']''').hasMatch(source)) {
      failures.add(
        '$path defines a raw route name; use AppRouteNames constants',
      );
    }
  }
}

String _balancedCall(String source, int openingParenthesis) {
  var depth = 0;
  String? quote;
  var escaped = false;
  for (var index = openingParenthesis; index < source.length; index += 1) {
    final character = source[index];
    if (quote != null) {
      if (escaped) {
        escaped = false;
      } else if (character == r'\') {
        escaped = true;
      } else if (character == quote) {
        quote = null;
      }
      continue;
    }
    if (character == "'" || character == '"') {
      quote = character;
      continue;
    }
    if (character == '(') depth += 1;
    if (character == ')') {
      depth -= 1;
      if (depth == 0) return source.substring(openingParenthesis, index + 1);
    }
  }
  return source.substring(openingParenthesis);
}

List<File> _dartFiles(Directory directory) {
  if (!directory.existsSync()) return const <File>[];
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList(growable: false);
}

String _relative(String path, Directory rootDirectory) {
  final root = rootDirectory.absolute.path.replaceAll('\\', '/');
  return path
      .replaceAll('\\', '/')
      .replaceFirst(RegExp('^${RegExp.escape(root)}/?'), '');
}

_ArchitectureAllowlist _readAllowlist(Directory root) {
  final json =
      jsonDecode(
            File(
              '${root.path}/tool/architecture_allowlist.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  return _ArchitectureAllowlist(
    domainBoundaryDebt: (json['domainBoundaryDebt'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_DomainBoundaryDebt.fromJson)
        .toSet(),
    featureDependencies: (json['featureDependencies'] as List<dynamic>)
        .cast<String>()
        .toSet(),
    featureCycleDebt: (json['featureCycleDebt'] as List<dynamic>)
        .cast<String>()
        .toSet(),
    layerDependencyDebt: (json['layerDependencyDebt'] as List<dynamic>)
        .cast<String>()
        .toSet(),
    largeFileDebt: (json['largeFileDebt'] as Map<String, dynamic>? ?? const {})
        .map((path, lines) => MapEntry(path, (lines as num).toInt())),
  );
}

class _ArchitectureAllowlist {
  const _ArchitectureAllowlist({
    required this.domainBoundaryDebt,
    required this.featureDependencies,
    required this.featureCycleDebt,
    required this.layerDependencyDebt,
    required this.largeFileDebt,
  });

  final Set<_DomainBoundaryDebt> domainBoundaryDebt;
  final Set<String> featureDependencies;
  final Set<String> featureCycleDebt;
  final Set<String> layerDependencyDebt;
  final Map<String, int> largeFileDebt;
}

class _DomainBoundaryDebt {
  const _DomainBoundaryDebt({required this.source, required this.target});

  factory _DomainBoundaryDebt.fromJson(Map<String, dynamic> json) {
    return _DomainBoundaryDebt(
      source: json['source'] as String,
      target: json['target'] as String,
    );
  }

  final String source;
  final String target;

  String get key => '$source->$target';

  @override
  bool operator ==(Object other) {
    return other is _DomainBoundaryDebt &&
        other.source == source &&
        other.target == target;
  }

  @override
  int get hashCode => Object.hash(source, target);
}
