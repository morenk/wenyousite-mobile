import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/toolbox/domain/text_tool.dart';
import 'package:wenyousite_mobile/features/toolbox/domain/toolbox_location_policy.dart';

class TextToolPage extends StatefulWidget {
  const TextToolPage({required this.tool, super.key});

  final TextTool tool;

  @override
  State<TextToolPage> createState() => _TextToolPageState();
}

class _TextToolPageState extends State<TextToolPage> {
  ThemeData? _openingTheme;
  WebViewController? _controller;
  ToolboxLocationPolicy? _policy;
  late TextTool _currentTool = widget.tool;
  Timer? _timeout;
  var _generation = 0;
  var _loading = true;
  var _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_openingTheme != null) return;
    // 本次编辑固定打开时主题，避免系统主题变化重新加载并丢失输入。
    _openingTheme = Theme.of(context);
    unawaited(_load());
  }

  bool _isCurrent(int generation) => mounted && generation == _generation;

  Future<void> _load() async {
    final generation = ++_generation;
    _timeout?.cancel();
    setState(() {
      _loading = true;
      _failed = false;
      _controller = null;
    });
    try {
      final policy = ToolboxLocationPolicy();
      _policy = policy;
      final controller = WebViewController(
        onPermissionRequest: (request) => unawaited(request.deny()),
      );
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(_openingTheme!.colorScheme.surface);
      final platform = controller.platform;
      if (platform is AndroidWebViewController) {
        await platform.setAllowFileAccess(false);
        await platform.setAllowContentAccess(false);
        await platform.setGeolocationEnabled(false);
        await platform.setMixedContentMode(MixedContentMode.neverAllow);
        await platform.setOnShowFileSelector((_) async => <String>[]);
      }
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (!_isCurrent(generation)) return NavigationDecision.prevent;
            if (!request.isMainFrame || !policy.allows(request.url)) {
              return NavigationDecision.prevent;
            }
            if (Uri.parse(request.url).path == '/tools/embed') {
              _returnToDirectory();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            if (!_isCurrent(generation)) return;
            if (!policy.allows(url)) {
              unawaited(_stopLoading(generation, controller));
              _fail(generation);
              return;
            }
            setState(() {
              _loading = true;
              _failed = false;
              _currentTool =
                  TextTool.fromId(Uri.parse(url).pathSegments.last) ??
                  _currentTool;
            });
            _startTimeout(generation, controller);
          },
          onPageFinished: (_) {
            if (!_isCurrent(generation) || _failed) return;
            _timeout?.cancel();
            setState(() => _loading = false);
          },
          onHttpError: (error) {
            // WKWebView 的文档响应不提供 request；Android 同时报告子资源，
            // 有地址时仅处理当前文档，不能用词库错误替换整个工具页面。
            if (error.request == null ||
                error.request!.uri.path == '/tools/embed/${_currentTool.id}') {
              _fail(generation);
            }
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true) _fail(generation);
          },
          onHttpAuthRequest: (request) => request.onCancel(),
          onSslAuthError: (error) => unawaited(error.cancel()),
        ),
      );
      if (!_isCurrent(generation)) return;
      setState(() => _controller = controller);
      _startTimeout(generation, controller);
      await controller.loadRequest(
        policy.location(
          _currentTool,
          dark: _openingTheme!.brightness == Brightness.dark,
        ),
      );
    } catch (_) {
      // 平台错误及 URL 可能包含页面内容，不写日志或显示原始异常。
      _fail(generation);
    }
  }

  void _startTimeout(int generation, WebViewController controller) {
    _timeout?.cancel();
    _timeout = Timer(const Duration(seconds: 25), () {
      if (!_isCurrent(generation)) return;
      _fail(generation);
      unawaited(_stopLoading(generation, controller));
    });
  }

  Future<void> _stopLoading(
    int generation,
    WebViewController controller,
  ) async {
    try {
      // 插件没有跨平台 stopLoading；只执行固定停止命令，不读取页面内容。
      await controller.runJavaScript('window.stop();');
    } catch (_) {
      _fail(generation);
    }
  }

  void _fail(int generation) {
    if (!_isCurrent(generation)) return;
    _timeout?.cancel();
    setState(() {
      _failed = true;
      _loading = false;
    });
  }

  void _returnToDirectory() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouteLocations.toolbox);
    }
  }

  @override
  void dispose() {
    _generation++;
    _timeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: _openingTheme ?? Theme.of(context),
    child: Scaffold(
      appBar: AppBar(
        title: Text(_currentTool.title),
        leading: IconButton(
          tooltip: '返回工具箱',
          icon: const WenyouIcon(WenyouIconIds.navigationBack),
          onPressed: _returnToDirectory,
        ),
      ),
      body: SafeArea(
        child: _failed
            ? WenyouPageBody(
                child: WenyouEmptyState(
                  icon: WenyouIconIds.statusOffline,
                  title: '工具加载失败',
                  message: '请检查网络后重试。',
                  action: FilledButton(
                    onPressed: _load,
                    child: const Text('重试'),
                  ),
                ),
              )
            : Stack(
                children: [
                  if (_controller != null && _policy != null)
                    WebViewWidget(controller: _controller!),
                  if (_loading)
                    const Positioned.fill(
                      child: WenyouPageBody(
                        child: WenyouDetailSkeleton(label: '正在打开工具'),
                      ),
                    ),
                ],
              ),
      ),
    ),
  );
}
