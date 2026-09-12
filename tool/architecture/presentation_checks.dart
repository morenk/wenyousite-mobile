import 'dart:io';
import 'dependency_graph.dart';
import 'source_files.dart';

const _featurePresentationSpinnerBaseline = 77;

void checkFailurePresentationBoundary(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  const allowedFiles = <String>{
    'lib/core/application/user_facing_failure.dart',
    'lib/core/network/api_failure.dart',
    'lib/core/network/api_interceptors.dart',
    'lib/core/widgets/wenyou_feedback.dart',
  };
  final rawProblemNumber = RegExp(r'''['"]问题编号：''');
  final interpolatedTechnicalCode = RegExp(
    r'''['"][^'"\n]*\$\{?[^'"\n]*(?:businessCode|httpStatus|diagnosticCode)''',
  );

  for (final file in files) {
    final path = relativePath(file.path, root);
    if (allowedFiles.contains(path) ||
        path.startsWith('lib/core/diagnostics/') ||
        path.endsWith('_diagnostics.dart')) {
      continue;
    }
    final source = file.readAsStringSync();
    if (rawProblemNumber.hasMatch(source)) {
      failures.add(
        '$path formats a problem number outside the shared failure policy',
      );
    }
    if (interpolatedTechnicalCode.hasMatch(source)) {
      failures.add(
        '$path interpolates a technical error code outside diagnostics',
      );
    }
  }
}

void checkFeatureSpinnerBudget(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  final pattern = RegExp(r'\bCircularProgressIndicator\s*\(');
  var count = 0;
  for (final file in files) {
    final path = relativePath(file.path, root);
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

void checkSnackBarBoundary(
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
    final path = relativePath(file.path, root);
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

void checkRouteTransitionBoundary(
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
    final path = relativePath(file.path, root);
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

void checkSharedTabBoundary(
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
    final path = relativePath(file.path, root);
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

void checkFoundationIconBoundary(
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
    final path = relativePath(file.path, root);
    for (final entry in forbiddenPatterns.entries) {
      if (RegExp(entry.key).hasMatch(source)) {
        failures.add(
          '$path uses ${entry.value}; use Foundation semantic icons',
        );
      }
    }
  }
}

void checkTypographyBoundary(
  List<File> files,
  List<String> failures,
  Directory root,
) {
  const centralizedFiles = <String>{
    'lib/app/app_theme.dart',
    'lib/app/wenyou_text_styles.dart',
  };
  final rawMaterialSlot = RegExp(
    r'\btextTheme\s*\.\s*'
    r'(?:displayLarge|displayMedium|displaySmall|'
    r'headlineLarge|headlineMedium|headlineSmall|'
    r'titleLarge|titleMedium|titleSmall|'
    r'bodyLarge|bodyMedium|bodySmall|'
    r'labelLarge|labelMedium|labelSmall)\b',
  );
  final literalFontSize = RegExp(
    r'\bfontSize\s*:\s*(?:const\s+)?\d+(?:\.\d+)?\b',
  );

  for (final file in files.where(
    (file) => !file.path.replaceAll('\\', '/').endsWith('.g.dart'),
  )) {
    final path = relativePath(file.path, root);
    if (centralizedFiles.contains(path)) continue;
    final source = file.readAsStringSync();
    if (rawMaterialSlot.hasMatch(source)) {
      failures.add(
        '$path reads a raw Material text slot; use a Wenyou semantic text role',
      );
    }
    if (literalFontSize.hasMatch(source)) {
      failures.add(
        '$path declares a literal font size; use Foundation typography or an '
        'exported component contract',
      );
    }
  }
}

void checkEditorPublicSurface(
  List<File> files,
  List<String> failures,
  Directory root,
  DependencyGraph graph,
) {
  const publicEditorSurfaces = <String>{
    'lib/features/editor/editor.dart',
    'lib/features/editor/editor_persistence.dart',
  };
  for (final file in files) {
    final path = relativePath(file.path, root);
    if (!path.startsWith('lib/features/') ||
        path.startsWith('lib/features/editor/')) {
      continue;
    }
    for (final target in graph.directTargets(file)) {
      if (target.startsWith('lib/features/editor/') &&
          !publicEditorSurfaces.contains(target)) {
        failures.add(
          '$path imports editor internals $target; use an editor root facade',
        );
      }
    }
  }
}
