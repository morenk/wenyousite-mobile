import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:wenyousite_mobile/app/app_route_access.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/routes/account_routes.dart';
import 'package:wenyousite_mobile/features/toolbox/domain/text_tool.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/text_tool_page.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';

import '../../support/deterministic_test_fonts.dart';
import 'fake_toolbox_webview.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  late FakeToolboxWebView platform;
  setUp(() {
    platform = FakeToolboxWebView();
    WebViewPlatform.instance = platform;
  });

  Future<void> pumpRoutes(
    WidgetTester tester, {
    String path = '/tools',
    ThemeData? theme,
  }) async {
    final provider = Provider((ref) {
      final router = GoRouter(
        initialLocation: path,
        routes: [
          GoRoute(path: '/me', builder: (_, _) => const MePage()),
          ...buildAccountRoutes(ref),
        ],
      );
      ref.onDispose(router.dispose);
      return router;
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: theme ?? AppTheme.light,
          routerConfig: container.read(provider),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> pumpTool(WidgetTester tester, {ThemeData? theme}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.light,
        home: const TextToolPage(tool: TextTool.vertical),
      ),
    );
    await tester.pump();
  }

  testWidgets('游客我的页进入目录，四种工具可打开且不要求认证', (tester) async {
    await pumpRoutes(tester, path: '/me');
    await tester.tap(find.byKey(const Key('me-open-toolbox')));
    await tester.pumpAndSettle();
    for (final tool in TextTool.values) {
      expect(find.text(tool.title), findsOneWidget);
      expect(
        AppRouteAccessPolicy.forLocation('/tools/${tool.id}'),
        AppRouteAccess.public,
      );
    }
    await tester.tap(find.byKey(const Key('toolbox-morse')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      platform.controllers.single.loads.single.uri.toString(),
      'https://wenyou.site/tools/embed/morse?theme=light',
    );
    expect(platform.controllers.single.loads.single.headers, isEmpty);
    platform.navigation.finished(
      'https://wenyou.site/tools/embed/morse?theme=light',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('返回工具箱'));
    await tester.pumpAndSettle();
    expect(find.text('温油工具箱'), findsOneWidget);
  });

  testWidgets('未知工具安全回目录', (tester) async {
    await pumpRoutes(tester, path: '/tools/unknown');
    await tester.pumpAndSettle();
    expect(find.text('温油工具箱'), findsOneWidget);
    expect(platform.controllers, isEmpty);
  });

  testWidgets('亮暗主题在打开时传入，系统变化不重载或清空输入', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpTool(tester, theme: AppTheme.dark);
    final controller = platform.controllers.single;
    expect(controller.loads.single.uri.queryParameters, {'theme': 'dark'});
    expect(find.bySemanticsLabel('正在打开工具'), findsOneWidget);
    platform.navigation.finished(controller.loads.single.uri.toString());
    await tester.pumpAndSettle();
    await pumpTool(tester, theme: AppTheme.light);
    expect(controller.loads, hasLength(1));
    expect(find.bySemanticsLabel('正在打开工具'), findsNothing);
    expect(find.byKey(const Key('fake-toolbox-webview')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('主文档错误显示重试；迟到完成事件不掩盖错误', (tester) async {
    await pumpTool(tester);
    final oldNavigation = platform.navigation;
    oldNavigation.resourceError(
      const WebResourceError(
        errorCode: -2,
        description: 'sensitive URL deliberately not displayed',
        isForMainFrame: true,
      ),
    );
    oldNavigation.finished('https://wenyou.site/tools/embed/vertical');
    await tester.pumpAndSettle();
    expect(find.text('工具加载失败'), findsOneWidget);
    expect(find.textContaining('sensitive'), findsNothing);
    await tester.tap(find.text('重试'));
    await tester.pump();
    expect(platform.controllers, hasLength(2));
    oldNavigation.resourceError(
      const WebResourceError(
        errorCode: -2,
        description: 'old',
        isForMainFrame: true,
      ),
    );
    platform.navigation.finished('https://wenyou.site/tools/embed/vertical');
    await tester.pumpAndSettle();
    expect(find.text('工具加载失败'), findsNothing);
  });

  testWidgets('资源错误由网页处理，主文档404提供重试', (tester) async {
    await pumpTool(tester);
    platform.navigation.resourceError(
      const WebResourceError(
        errorCode: -2,
        description: 'dictionary',
        isForMainFrame: false,
      ),
    );
    platform.navigation.httpError(
      HttpResponseError(
        request: WebResourceRequest(
          uri: Uri.parse('https://wenyou.site/assets/names.js'),
        ),
      ),
    );
    platform.navigation.finished('https://wenyou.site/tools/embed/vertical');
    await tester.pumpAndSettle();
    expect(find.text('工具加载失败'), findsNothing);
    platform.navigation.httpError(
      HttpResponseError(
        request: WebResourceRequest(
          uri: Uri.parse(
            'https://wenyou.site/tools/embed/vertical?theme=light',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('工具加载失败'), findsOneWidget);
  });

  testWidgets('超时终止加载并可重试', (tester) async {
    await pumpTool(tester);
    await tester.pump(const Duration(seconds: 26));
    expect(find.text('工具加载失败'), findsOneWidget);
    expect(platform.controllers.single.stops, 1);
  });

  testWidgets('WKWebView未提供request的HTTP错误仍显示恢复入口', (tester) async {
    await pumpTool(tester);
    platform.navigation.httpError(
      const HttpResponseError(
        response: WebResourceResponse(uri: null, statusCode: 503),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('工具加载失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
  });

  testWidgets('外部scheme和登录重定向被阻止，目录链接返回原生目录', (tester) async {
    await pumpRoutes(tester, path: '/tools/fancy');
    for (final url in [
      'https://evil.test/',
      'https://wenyou.site/login',
      'intent://open',
    ]) {
      expect(
        await platform.navigation.navigate(
          NavigationRequest(url: url, isMainFrame: true),
        ),
        NavigationDecision.prevent,
      );
    }
    expect(
      await platform.navigation.navigate(
        const NavigationRequest(
          url: 'https://wenyou.site/tools/embed/names?theme=light',
          isMainFrame: true,
        ),
      ),
      NavigationDecision.navigate,
    );
    platform.navigation.started(
      'https://wenyou.site/tools/embed/names?theme=light',
    );
    platform.navigation.finished(
      'https://wenyou.site/tools/embed/names?theme=light',
    );
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, '起名工具'), findsOneWidget);
    expect(
      await platform.navigation.navigate(
        const NavigationRequest(
          url: 'https://wenyou.site/tools/embed?theme=light',
          isMainFrame: true,
        ),
      ),
      NavigationDecision.prevent,
    );
    await tester.pumpAndSettle();
    expect(find.text('温油工具箱'), findsOneWidget);
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('完整工具目录视觉 ${theme.brightness.name}', (tester) async {
      tester.view.physicalSize = const Size(400, 860);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpRoutes(tester, theme: theme);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('起名工具'), findsOneWidget);
      await expectLater(
        find.byType(Scaffold).last,
        matchesGoldenFile('goldens/toolbox_400_${theme.brightness.name}.png'),
      );
    });

    testWidgets('目录窄屏与大字无溢出 ${theme.brightness.name}', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpRoutes(tester, theme: theme);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold).last,
        matchesGoldenFile(
          'goldens/toolbox_320_2x_${theme.brightness.name}.png',
        ),
      );
    });
  }
}
