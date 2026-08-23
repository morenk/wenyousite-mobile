import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_architecture.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('wenyou-architecture-');
    _write(root, 'README.md', '当前版本：`1.0.0+1`。');
    _write(
      root,
      'pubspec.yaml',
      'name: fixture\nversion: 1.0.0+1\ndependencies:\n',
    );
    _writeAllowlist(root);
  });

  tearDown(() async {
    if (root.existsSync()) await root.delete(recursive: true);
  });

  test('accepts a clean feature graph', () {
    _write(root, 'lib/features/alpha/domain/item.dart', 'class Item {}\n');

    expect(collectArchitectureFailures(root), isEmpty);
  });

  test('freezes domain debt to the exact imported dependency', () {
    const path = 'lib/features/alpha/domain/item.dart';
    _write(
      root,
      path,
      "import 'package:wenyousite_mobile/core/network/api_failure.dart';\n"
      "import 'package:flutter/material.dart';\n",
    );
    _writeAllowlist(
      root,
      domainBoundaryDebt: [
        {'source': path, 'target': 'lib/core/network/api_failure.dart'},
      ],
    );

    expect(
      collectArchitectureFailures(root),
      contains(
        '$path imports forbidden domain dependency package:flutter/material.dart',
      ),
    );
  });

  test('domain cannot own loading or submission state', () {
    const path = 'lib/features/alpha/domain/item.dart';
    _write(
      root,
      path,
      'enum ItemPhase { loading, ready }\n'
      'class ItemState {}\n',
    );

    expect(
      collectArchitectureFailures(root),
      containsAll(<String>[
        '$path declares application state in domain; move it to application',
        '$path declares an application phase in domain; move it to application',
      ]),
    );
  });

  test('non-generated Dart files cannot exceed 900 lines', () {
    const path = 'lib/features/alpha/presentation/page.dart';
    _write(root, path, '${List.filled(901, '// line').join('\n')}\n');

    expect(
      collectArchitectureFailures(root),
      contains(
        '$path has 901 lines; split non-generated Dart files above 900 lines',
      ),
    );
  });

  test('large-file debt is frozen to its exact line count', () {
    const path = 'lib/features/alpha/presentation/page.dart';
    _write(root, path, '${List.filled(901, '// line').join('\n')}\n');
    _writeAllowlist(root, largeFileDebt: const {path: 902});

    expect(
      collectArchitectureFailures(root),
      contains('$path large-file debt can be tightened from 902 to 901 lines'),
    );

    _writeAllowlist(root, largeFileDebt: const {path: 901});
    expect(collectArchitectureFailures(root), isEmpty);
  });

  test('generated Dart files are exempt from the line limit', () {
    _write(
      root,
      'lib/core/generated_client.g.dart',
      '${List.filled(901, '// generated').join('\n')}\n',
    );

    expect(collectArchitectureFailures(root), isEmpty);
  });

  test(
    'handwritten part libraries are rejected while generated parts remain allowed',
    () {
      const source = 'lib/features/alpha/presentation/page.dart';
      const fragment = 'lib/features/alpha/presentation/page_fragment.dart';
      _write(root, source, "part 'page_fragment.dart';\npart 'page.g.dart';\n");
      _write(root, fragment, "part of 'page.dart';\n");

      expect(
        collectArchitectureFailures(root),
        containsAll(<String>[
          '$source uses handwritten part; use an explicit library',
          '$fragment uses handwritten part-of; use an explicit library',
        ]),
      );
    },
  );

  test('detects a new layered dependency beside existing debt', () {
    const page = 'lib/features/alpha/presentation/page.dart';
    const first = 'lib/features/alpha/data/first_repository.dart';
    const second = 'lib/features/alpha/data/second_repository.dart';
    _write(root, first, 'class FirstRepository {}\n');
    _write(root, second, 'class SecondRepository {}\n');
    _write(
      root,
      page,
      "import 'package:wenyousite_mobile/features/alpha/data/first_repository.dart';\n"
      "import 'package:wenyousite_mobile/features/alpha/data/second_repository.dart';\n",
    );
    _writeAllowlist(root, layerDependencyDebt: ['$page->$first']);

    expect(
      collectArchitectureFailures(root),
      contains('new forbidden layer dependency: $page->$second'),
    );
  });

  test('allows data implementations to depend on application ports', () {
    _write(
      root,
      'lib/features/alpha/application/item_ports.dart',
      'abstract interface class ItemPort {}\n',
    );
    _write(
      root,
      'lib/features/alpha/data/item_repository.dart',
      "import '../application/item_ports.dart';\n"
          'class ItemRepository implements ItemPort {}\n',
    );

    expect(collectArchitectureFailures(root), isEmpty);
  });

  test('rejects data dependencies on application state', () {
    const data = 'lib/features/alpha/data/item_repository.dart';
    const controller = 'lib/features/alpha/application/item_controller.dart';
    _write(root, controller, 'class ItemController {}\n');
    _write(root, data, "import '../application/item_controller.dart';\n");

    expect(
      collectArchitectureFailures(root),
      contains('new forbidden layer dependency: $data->$controller'),
    );
  });

  test('requires a separate debt entry for every cyclic edge', () {
    _write(
      root,
      'lib/features/alpha/domain/item.dart',
      "import 'package:wenyousite_mobile/features/beta/domain/item.dart';\n",
    );
    _write(
      root,
      'lib/features/beta/domain/item.dart',
      "import 'package:wenyousite_mobile/features/alpha/domain/item.dart';\n",
    );
    _writeAllowlist(
      root,
      featureDependencies: const ['alpha->beta', 'beta->alpha'],
      featureCycleDebt: const ['alpha->beta'],
    );

    expect(
      collectArchitectureFailures(root),
      contains(
        'new cyclic cross-feature dependency is not allowed: beta->alpha',
      ),
    );
  });

  test('reports stale dependency debt when the import is removed', () {
    _write(root, 'lib/features/alpha/domain/item.dart', 'class Item {}\n');
    _writeAllowlist(root, featureDependencies: const ['alpha->beta']);

    expect(
      collectArchitectureFailures(root),
      contains('stale cross-feature dependency debt: alpha->beta'),
    );
  });

  test('normalizes relative imports before checking domain boundaries', () {
    const path = 'lib/features/alpha/domain/item.dart';
    _write(root, 'lib/core/network/api_failure.dart', 'class ApiFailure {}\n');
    _write(root, path, "import '../../../core/network/api_failure.dart';\n");

    expect(
      collectArchitectureFailures(root),
      contains(
        '$path imports forbidden domain dependency '
        'lib/core/network/api_failure.dart',
      ),
    );
  });

  test('ignores imports written only inside comments', () {
    _write(
      root,
      'lib/features/alpha/domain/item.dart',
      "// import 'package:flutter/material.dart';\n"
          "/* export 'package:dio/dio.dart'; */\n"
          'class Item {}\n',
    );

    expect(collectArchitectureFailures(root), isEmpty);
  });

  test('cross-feature editor consumers must use the public facade', () {
    const page = 'lib/features/posts/presentation/composer.dart';
    const internal =
        'lib/features/editor/presentation/rich_editor_session.dart';
    _write(root, internal, 'class RichEditorSession {}\n');
    _write(
      root,
      page,
      "import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';\n",
    );
    _writeAllowlist(root, featureDependencies: const ['posts->editor']);

    expect(
      collectArchitectureFailures(root),
      contains(
        '$page imports editor internals $internal; '
        'use an editor root facade',
      ),
    );
  });

  test('production UI must use Foundation semantic icons', () {
    const path = 'lib/features/alpha/presentation/page.dart';
    _write(
      root,
      path,
      'final iconData = IconData(0xe000);\n'
      'final widget = Icon(Icons.reply);\n',
    );

    expect(
      collectArchitectureFailures(root),
      containsAll(<String>[
        '$path uses Material Icons.*; use Foundation semantic icons',
        '$path uses Material IconData; use Foundation semantic icons',
        '$path uses Material Icon(...); use Foundation semantic icons',
      ]),
    );
  });

  test('feature pages must use the shared content tabs', () {
    const path = 'lib/features/alpha/presentation/page.dart';
    _write(
      root,
      path,
      'final controller = DefaultTabController(length: 2, child: body);\n'
      'final tabs = TabBar(tabs: const []);\n'
      'final pages = TabBarView(children: const []);\n',
    );

    expect(
      collectArchitectureFailures(root),
      containsAll(<String>[
        '$path uses Material DefaultTabController; use WenyouContentTabs',
        '$path uses Material TabBar; use WenyouContentTabs',
        '$path uses Material TabBarView; use WenyouContentTabs',
      ]),
    );
  });

  test('production UI must use the shared transient-feedback policy', () {
    const path = 'lib/features/alpha/presentation/page.dart';
    _write(
      root,
      path,
      "final action = SnackBarAction(label: '重试', onPressed: retry);\n"
      "final bar = SnackBar(content: Text('完成'), action: action);\n"
      'messenger.showSnackBar(bar);\n',
    );

    expect(
      collectArchitectureFailures(root),
      containsAll(<String>[
        '$path constructs SnackBar outside the shared transient-feedback policy',
        '$path constructs SnackBarAction outside the shared transient-feedback policy',
        '$path calls showSnackBar outside the shared transient-feedback policy',
      ]),
    );
  });

  test('shared transient-feedback policy may wrap Material SnackBar', () {
    _write(
      root,
      'lib/core/widgets/wenyou_snack_bar.dart',
      "final action = SnackBarAction(label: '重试', onPressed: retry);\n"
          "final bar = SnackBar(content: Text('完成'), action: action);\n"
          'messenger.showSnackBar(bar);\n',
    );

    expect(collectArchitectureFailures(root), isEmpty);
  });

  test('page transitions must use the shared navigation policy', () {
    const path = 'lib/features/alpha/presentation/page.dart';
    _write(
      root,
      path,
      'final first = MaterialPageRoute<void>(builder: build);\n'
      'final second = NoTransitionPage<void>(child: child);\n'
      'final third = CustomTransitionPage<void>(child: child);\n'
      'final fourth = PageRouteBuilder<void>(pageBuilder: build);\n'
      'final fifth = CupertinoPageRoute<void>(builder: build);\n'
      'final theme = PageTransitionsTheme(builders: builders);\n'
      'class LocalBuilder extends PageTransitionsBuilder {}\n',
    );

    expect(
      collectArchitectureFailures(root),
      containsAll(<String>[
        '$path uses MaterialPageRoute outside the shared navigation policy',
        '$path uses NoTransitionPage outside the shared navigation policy',
        '$path uses CustomTransitionPage outside the shared navigation policy',
        '$path uses PageRouteBuilder outside the shared navigation policy',
        '$path uses CupertinoPageRoute outside the shared navigation policy',
        '$path configures PageTransitionsTheme outside the app theme',
        '$path defines PageTransitionsBuilder outside the shared navigation policy',
      ]),
    );
  });

  test('shared policy and the composer nested route remain allowed', () {
    _write(
      root,
      'lib/core/navigation/wenyou_page_transitions.dart',
      'final first = MaterialPageRoute<void>(builder: build);\n'
          'final second = NoTransitionPage<void>(child: child);\n'
          'final third = PageRouteBuilder<void>(pageBuilder: build);\n',
    );
    _write(
      root,
      'lib/features/posts/presentation/post_composer_sheet.dart',
      'final route = PageRouteBuilder<void>(pageBuilder: build);\n',
    );
    _write(
      root,
      'lib/app/app_theme.dart',
      'final theme = PageTransitionsTheme(builders: builders);\n',
    );

    expect(collectArchitectureFailures(root), isEmpty);
  });

  test('golden tests must load Foundation fonts', () {
    const path = 'test/features/alpha/page_test.dart';
    const goldenMatcher = 'matchesGoldenFile';
    _write(root, path, "final matcher = $goldenMatcher('goldens/page.png');\n");

    expect(
      collectArchitectureFailures(root),
      contains('$path uses golden files without loading Foundation test fonts'),
    );
  });

  test('router definitions use centralized path and name constants', () {
    const path = 'lib/app/app_router.dart';
    _write(root, path, "final route = (path: '/home', name: 'home');\n");

    expect(
      collectArchitectureFailures(root),
      containsAll(<String>[
        '$path defines a raw route path; use AppRoutePaths constants',
        '$path defines a raw route name; use AppRouteNames constants',
      ]),
    );
  });

  test('README Foundation version must match pubspec ref', () {
    _write(root, 'README.md', '当前版本：`1.0.0+1`。wenyousite-foundation v2.4.1。');
    _write(
      root,
      'pubspec.yaml',
      'name: fixture\n'
          'version: 1.0.0+1\n'
          'dependencies:\n'
          '  wenyousite_foundation:\n'
          '    git:\n'
          '      ref: v2.4.2\n',
    );

    expect(
      collectArchitectureFailures(root),
      contains('README Foundation v2.4.1 does not match pubspec v2.4.2'),
    );
  });
}

void _writeAllowlist(
  Directory root, {
  List<Map<String, String>> domainBoundaryDebt = const [],
  List<String> featureDependencies = const [],
  List<String> featureCycleDebt = const [],
  List<String> layerDependencyDebt = const [],
  Map<String, int> largeFileDebt = const {},
}) {
  _write(
    root,
    'tool/architecture_allowlist.json',
    const JsonEncoder.withIndent('  ').convert({
      'domainBoundaryDebt': domainBoundaryDebt,
      'featureDependencies': featureDependencies,
      'featureCycleDebt': featureCycleDebt,
      'layerDependencyDebt': layerDependencyDebt,
      'largeFileDebt': largeFileDebt,
    }),
  );
}

void _write(Directory root, String relativePath, String contents) {
  final file = File('${root.path}/$relativePath');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(contents);
}
