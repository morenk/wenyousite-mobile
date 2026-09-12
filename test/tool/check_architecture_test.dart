import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_architecture.dart';
import 'architecture_test_workspace.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await createArchitectureTestWorkspace();
  });

  tearDown(() => disposeArchitectureTestWorkspace(root));

  test('accepts a clean feature graph', () {
    writeArchitectureFixture(
      root,
      'lib/features/alpha/domain/item.dart',
      'class Item {}\n',
    );

    expect(collectArchitectureFailures(root), isEmpty);
  });

  test('freezes domain debt to the exact imported dependency', () {
    const path = 'lib/features/alpha/domain/item.dart';
    writeArchitectureFixture(
      root,
      path,
      "import 'package:wenyousite_mobile/core/network/api_failure.dart';\n"
      "import 'package:flutter/material.dart';\n",
    );
    writeArchitectureAllowlist(
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
    writeArchitectureFixture(
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
    writeArchitectureFixture(
      root,
      path,
      '${List.filled(901, '// line').join('\n')}\n',
    );

    expect(
      collectArchitectureFailures(root),
      contains(
        '$path has 901 lines; split non-generated Dart files above 900 lines',
      ),
    );
  });

  test('cleared large-file debt cannot be reintroduced', () {
    const path = 'lib/features/alpha/presentation/page.dart';
    writeArchitectureFixture(
      root,
      path,
      '${List.filled(901, '// line').join('\n')}\n',
    );
    writeArchitectureAllowlist(root, largeFileDebt: const {path: 902});

    expect(
      collectArchitectureFailures(root),
      contains('$path large-file debt can be tightened from 902 to 901 lines'),
    );

    writeArchitectureAllowlist(root, largeFileDebt: const {path: 901});
    expect(
      collectArchitectureFailures(root),
      contains('large-file debt cannot be reintroduced: $path'),
    );
  });

  test('generated Dart files are exempt from the line limit', () {
    writeArchitectureFixture(
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
      writeArchitectureFixture(
        root,
        source,
        "part 'page_fragment.dart';\npart 'page.g.dart';\n",
      );
      writeArchitectureFixture(root, fragment, "part of 'page.dart';\n");

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
    writeArchitectureFixture(root, first, 'class FirstRepository {}\n');
    writeArchitectureFixture(root, second, 'class SecondRepository {}\n');
    writeArchitectureFixture(
      root,
      page,
      "import 'package:wenyousite_mobile/features/alpha/data/first_repository.dart';\n"
      "import 'package:wenyousite_mobile/features/alpha/data/second_repository.dart';\n",
    );
    writeArchitectureAllowlist(root, layerDependencyDebt: ['$page->$first']);

    expect(
      collectArchitectureFailures(root),
      contains('new forbidden layer dependency: $page->$second'),
    );
  });

  test('allows data implementations to depend on application ports', () {
    writeArchitectureFixture(
      root,
      'lib/features/alpha/application/item_ports.dart',
      'abstract interface class ItemPort {}\n',
    );
    writeArchitectureFixture(
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
    writeArchitectureFixture(root, controller, 'class ItemController {}\n');
    writeArchitectureFixture(
      root,
      data,
      "import '../application/item_controller.dart';\n",
    );

    expect(
      collectArchitectureFailures(root),
      contains('new forbidden layer dependency: $data->$controller'),
    );
  });

  test('requires a separate debt entry for every cyclic edge', () {
    writeArchitectureFixture(
      root,
      'lib/features/alpha/domain/item.dart',
      "import 'package:wenyousite_mobile/features/beta/domain/item.dart';\n",
    );
    writeArchitectureFixture(
      root,
      'lib/features/beta/domain/item.dart',
      "import 'package:wenyousite_mobile/features/alpha/domain/item.dart';\n",
    );
    writeArchitectureAllowlist(
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
    writeArchitectureFixture(
      root,
      'lib/features/alpha/domain/item.dart',
      'class Item {}\n',
    );
    writeArchitectureAllowlist(
      root,
      featureDependencies: const ['alpha->beta'],
    );

    expect(
      collectArchitectureFailures(root),
      contains('stale cross-feature dependency debt: alpha->beta'),
    );
  });

  test('normalizes relative imports before checking domain boundaries', () {
    const path = 'lib/features/alpha/domain/item.dart';
    writeArchitectureFixture(
      root,
      'lib/core/network/api_failure.dart',
      'class ApiFailure {}\n',
    );
    writeArchitectureFixture(
      root,
      path,
      "import '../../../core/network/api_failure.dart';\n",
    );

    expect(
      collectArchitectureFailures(root),
      contains(
        '$path imports forbidden domain dependency '
        'lib/core/network/api_failure.dart',
      ),
    );
  });

  test('ignores imports written only inside comments', () {
    writeArchitectureFixture(
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
    writeArchitectureFixture(root, internal, 'class RichEditorSession {}\n');
    writeArchitectureFixture(
      root,
      page,
      "import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';\n",
    );
    writeArchitectureAllowlist(
      root,
      featureDependencies: const ['posts->editor'],
    );

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
    writeArchitectureFixture(
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

  test('production UI must use semantic typography and contract sizes', () {
    const path = 'lib/features/alpha/presentation/page.dart';
    writeArchitectureFixture(
      root,
      path,
      'final caption = Theme.of(context).textTheme.bodySmall;\n'
      'final style = const TextStyle(fontSize: 13);\n',
    );

    expect(
      collectArchitectureFailures(root),
      containsAll(<String>[
        '$path reads a raw Material text slot; '
            'use a Wenyou semantic text role',
        '$path declares a literal font size; use Foundation typography or an '
            'exported component contract',
      ]),
    );
  });

  test('semantic typography and exported component sizes are allowed', () {
    const path = 'lib/features/alpha/presentation/page.dart';
    writeArchitectureFixture(
      root,
      path,
      'final caption = Theme.of(context).textTheme.wenyouCaption;\n'
      'final style = caption.copyWith(\n'
      '  fontSize: WenyouElementContract.levelFontSize,\n'
      ');\n',
    );

    expect(collectArchitectureFailures(root), isEmpty);
  });

  test('feature pages must use the shared content tabs', () {
    const path = 'lib/features/alpha/presentation/page.dart';
    writeArchitectureFixture(
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
    writeArchitectureFixture(
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
    writeArchitectureFixture(
      root,
      'lib/core/widgets/wenyou_snack_bar.dart',
      "final action = SnackBarAction(label: '重试', onPressed: retry);\n"
          "final bar = SnackBar(content: Text('完成'), action: action);\n"
          'messenger.showSnackBar(bar);\n',
    );

    expect(collectArchitectureFailures(root), isEmpty);
  });

  test('feature UI cannot format problem numbers or technical error codes', () {
    const path = 'lib/features/alpha/presentation/page.dart';
    writeArchitectureFixture(
      root,
      path,
      "final detail = '问题编号：\$requestId';\n"
      "final debug = '错误：\${failure.businessCode}';\n",
    );

    expect(
      collectArchitectureFailures(root),
      containsAll(<String>[
        '$path formats a problem number outside the shared failure policy',
        '$path interpolates a technical error code outside diagnostics',
      ]),
    );
  });

  test('shared failure policy may format user and diagnostic details', () {
    writeArchitectureFixture(
      root,
      'lib/core/widgets/wenyou_feedback.dart',
      "final detail = '问题编号：\$requestId';\n",
    );
    writeArchitectureFixture(
      root,
      'lib/core/diagnostics/network_diagnostics.dart',
      "final debug = 'code=\${failure.businessCode}';\n",
    );

    expect(collectArchitectureFailures(root), isEmpty);
  });

  test('page transitions must use the shared navigation policy', () {
    const path = 'lib/features/alpha/presentation/page.dart';
    writeArchitectureFixture(
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
    writeArchitectureFixture(
      root,
      'lib/core/navigation/wenyou_page_transitions.dart',
      'final first = MaterialPageRoute<void>(builder: build);\n'
          'final second = NoTransitionPage<void>(child: child);\n'
          'final third = PageRouteBuilder<void>(pageBuilder: build);\n',
    );
    writeArchitectureFixture(
      root,
      'lib/features/posts/presentation/post_composer_sheet.dart',
      'final route = PageRouteBuilder<void>(pageBuilder: build);\n',
    );
    writeArchitectureFixture(
      root,
      'lib/app/app_theme.dart',
      'final theme = PageTransitionsTheme(builders: builders);\n',
    );

    expect(collectArchitectureFailures(root), isEmpty);
  });

  test('golden tests must load deterministic test fonts', () {
    const path = 'test/features/alpha/page_test.dart';
    const goldenMatcher = 'matchesGoldenFile';
    writeArchitectureFixture(
      root,
      path,
      "final matcher = $goldenMatcher('goldens/page.png');\n",
    );

    expect(
      collectArchitectureFailures(root),
      contains(
        '$path uses golden files without loading deterministic test fonts',
      ),
    );
  });

  test('production typography must inherit the system font', () {
    const path = 'lib/features/alpha/presentation/page.dart';
    writeArchitectureFixture(
      root,
      path,
      "const style = TextStyle(fontFamily: 'Custom UI');\n",
    );

    expect(
      collectArchitectureFailures(root),
      contains(
        '$path sets a production fontFamily; inherit the platform system '
        'font unless this is the approved monospace presentation',
      ),
    );
  });

  test('router definitions use centralized path and name constants', () {
    const path = 'lib/app/app_router.dart';
    writeArchitectureFixture(
      root,
      path,
      "final route = (path: '/home', name: 'home');\n",
    );

    expect(
      collectArchitectureFailures(root),
      containsAll(<String>[
        '$path defines a raw route path; use AppRoutePaths constants',
        '$path defines a raw route name; use AppRouteNames constants',
      ]),
    );
  });

  test('README Foundation version must match pubspec ref', () {
    writeArchitectureFixture(
      root,
      'README.md',
      '当前版本：`1.0.0+1`。wenyousite-foundation v2.4.1。',
    );
    writeArchitectureFixture(
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
