import 'package:flutter/material.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class FakeToolboxWebView extends WebViewPlatform {
  final controllers = <FakeToolboxController>[];
  late FakeToolboxNavigation navigation;

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    final controller = FakeToolboxController(params);
    controllers.add(controller);
    return controller;
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => navigation = FakeToolboxNavigation(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => _FakeWidget(params);
}

class FakeToolboxController extends PlatformWebViewController {
  FakeToolboxController(super.params) : super.implementation();

  final loads = <LoadRequestParams>[];
  JavaScriptMode? javaScriptMode;
  var stops = 0;

  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {
    javaScriptMode = mode;
  }

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> setOnPlatformPermissionRequest(
    void Function(PlatformWebViewPermissionRequest request) onPermissionRequest,
  ) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}

  @override
  Future<void> loadRequest(LoadRequestParams params) async => loads.add(params);

  @override
  Future<void> runJavaScript(String javaScript) async {
    if (javaScript != 'window.stop();') throw StateError('Unexpected script');
    stops++;
  }
}

class FakeToolboxNavigation extends PlatformNavigationDelegate {
  FakeToolboxNavigation(super.params) : super.implementation();

  late NavigationRequestCallback navigate;
  late PageEventCallback started;
  late PageEventCallback finished;
  late WebResourceErrorCallback resourceError;
  late HttpResponseErrorCallback httpError;
  late HttpAuthRequestCallback authRequest;
  late SslAuthErrorCallback sslError;

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback callback,
  ) async {
    navigate = callback;
  }

  @override
  Future<void> setOnPageStarted(PageEventCallback callback) async {
    started = callback;
  }

  @override
  Future<void> setOnPageFinished(PageEventCallback callback) async {
    finished = callback;
  }

  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback callback) async {
    resourceError = callback;
  }

  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback callback) async {
    httpError = callback;
  }

  @override
  Future<void> setOnHttpAuthRequest(HttpAuthRequestCallback callback) async {
    authRequest = callback;
  }

  @override
  Future<void> setOnSSlAuthError(SslAuthErrorCallback callback) async {
    sslError = callback;
  }
}

class _FakeWidget extends PlatformWebViewWidget {
  _FakeWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.expand(
    key: Key('fake-toolbox-webview'),
    child: Text('工具网页'),
  );
}
