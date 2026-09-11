import 'dart:io';
import 'architecture/allowlist.dart';
import 'architecture/dependency_checks.dart';
import 'architecture/dependency_graph.dart';
import 'architecture/editor_semantics_checks.dart';
import 'architecture/presentation_checks.dart';
import 'architecture/source_files.dart';

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
  final allowlist = readAllowlist(root);
  final graph = DependencyGraph(root);
  final allDartFiles = repositoryDartFiles(root);
  final applicationFiles = dartFiles(Directory('${root.path}/lib'));
  final testDartFiles = dartFiles(Directory('${root.path}/test'));

  _checkIdempotentPolicies(applicationFiles, failures, root);
  checkDomainBoundaries(
    applicationFiles,
    allowlist.domainBoundaryDebt,
    failures,
    root,
    graph,
  );
  checkDomainStateOwnership(applicationFiles, failures, root);
  _checkDartFileSizes(allDartFiles, allowlist.largeFileDebt, failures, root);
  _checkHandwrittenParts(allDartFiles, failures, root);
  checkLayerDependencies(
    applicationFiles,
    allowlist.layerDependencyDebt,
    failures,
    root,
    graph,
  );
  checkFeatureDependencies(
    applicationFiles,
    allowlist.featureDependencies,
    allowlist.featureCycleDebt,
    failures,
    root,
    graph,
  );
  checkCrossFeatureInternalImports(
    applicationFiles,
    allowlist.crossFeatureInternalImportDebt,
    failures,
    root,
    graph,
  );
  checkCoreBoundary(applicationFiles, failures, root, graph);
  _checkLegacyStateNotifierBudget(applicationFiles, failures, root);
  checkFeatureSpinnerBudget(applicationFiles, failures, root);
  checkEditorPublicSurface(applicationFiles, failures, root, graph);
  checkEditorSemanticsBoundary(applicationFiles, failures, root, graph);
  checkFoundationIconBoundary(applicationFiles, failures, root);
  checkTypographyBoundary(applicationFiles, failures, root);
  checkSharedTabBoundary(applicationFiles, failures, root);
  checkSnackBarBoundary(applicationFiles, failures, root);
  checkFailurePresentationBoundary(applicationFiles, failures, root);
  checkRouteTransitionBoundary(applicationFiles, failures, root);
  _checkVersionConsistency(failures, root);
  _checkDirectDependencies(applicationFiles, failures, root);
  _checkRawRequestFlags(applicationFiles, failures, root);
  _checkRawRouteNavigation(applicationFiles, failures, root);
  _checkRawRouteDefinitions(applicationFiles, failures, root);
  _checkGoldenTestSetup(testDartFiles, failures, root);

  failures.sort();
  return failures;
}

List<String> collectArchitectureReviewNotices(Directory root) {
  final notices = <String>[];
  for (final file in repositoryDartFiles(
    root,
  ).where((file) => !file.path.replaceAll('\\', '/').endsWith('.g.dart'))) {
    final count = lineCount(file.readAsStringSync());
    if (count <= _reviewDartFileLines || count > _maximumDartFileLines) {
      continue;
    }
    notices.add(
      '${relativePath(file.path, root)} has $count lines; review a focused '
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
      List.filled(count, relativePath(file.path, root), growable: false),
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
    final path = relativePath(file.path, root);
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
  for (final path in allowlist.keys) {
    failures.add('large-file debt cannot be reintroduced: $path');
  }
  final actualDebt = <String, int>{};
  for (final file in files.where(
    (file) => !file.path.replaceAll('\\', '/').endsWith('.g.dart'),
  )) {
    final path = relativePath(file.path, root);
    final count = lineCount(file.readAsStringSync());
    if (count <= _maximumDartFileLines) continue;

    actualDebt[path] = count;
    final baseline = allowlist[path];
    if (baseline == null) {
      failures.add(
        '$path has $count lines; split non-generated Dart files above '
        '$_maximumDartFileLines lines',
      );
    } else if (count > baseline) {
      failures.add(
        '$path grew from the allowed $baseline lines to $count lines',
      );
    } else if (count < baseline) {
      failures.add(
        '$path large-file debt can be tightened from $baseline to '
        '$count lines',
      );
    }
  }

  for (final path in allowlist.keys.where(
    (path) => !actualDebt.containsKey(path),
  )) {
    failures.add('stale large-file debt: $path');
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
            '${relativePath(file.path, root)} calls $operation without the '
            'idempotent-create request policy',
          );
        }
      }
    }
  }
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
        '${relativePath(file.path, root)} uses golden files without loading '
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
    final path = relativePath(file.path, root);
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
    final path = relativePath(file.path, root);
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
    final path = relativePath(file.path, root);
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
