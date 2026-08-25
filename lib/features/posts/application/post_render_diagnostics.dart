import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/diagnostics/debug_diagnostic_console.dart';

enum PostRenderFailureStage {
  fetch('fetch'),
  parse('parse'),
  layout('layout'),
  mediaDecode('media_decode'),
  webviewProcess('webview_process'),
  draw('draw');

  const PostRenderFailureStage(this.wireValue);

  final String wireValue;
}

class PostRenderRuntimeInfo {
  const PostRenderRuntimeInfo({
    required this.appVersion,
    required this.buildNumber,
    required this.operatingSystem,
    required this.deviceModel,
    required this.renderer,
  });

  const PostRenderRuntimeInfo.unknown()
    : appVersion = 'unknown',
      buildNumber = 'unknown',
      operatingSystem = 'unknown',
      deviceModel = 'unknown',
      renderer = 'flutter-native';

  final String appVersion;
  final String buildNumber;
  final String operatingSystem;
  final String deviceModel;
  final String renderer;
}

class PostRenderDiagnosticEvent {
  const PostRenderDiagnosticEvent({
    required this.succeeded,
    required this.fetchSucceeded,
    required this.contentType,
    required this.contentBlockCount,
    required this.containerWidth,
    required this.containerHeight,
    required this.keyboardInset,
    required this.duration,
    this.failureStage,
    this.errorCode,
  });

  final bool succeeded;
  final bool fetchSucceeded;
  final String contentType;
  final int contentBlockCount;
  final double containerWidth;
  final double containerHeight;
  final double keyboardInset;
  final Duration duration;
  final PostRenderFailureStage? failureStage;
  final String? errorCode;

  Map<String, Object?> toPayload(PostRenderRuntimeInfo runtime) => {
    'event': 'post_detail_render_result',
    'appVersion': runtime.appVersion,
    'buildNumber': runtime.buildNumber,
    'operatingSystem': runtime.operatingSystem,
    'deviceModel': runtime.deviceModel,
    'renderer': runtime.renderer,
    'rendererVariant': wenyouRendererVariant,
    'succeeded': succeeded,
    'fetchSucceeded': fetchSucceeded,
    'contentType': contentType,
    'contentBlockCount': contentBlockCount,
    'containerWidth': containerWidth.round(),
    'containerHeight': containerHeight.round(),
    'keyboardInset': keyboardInset.round(),
    'failureStage': failureStage?.wireValue,
    'errorCode': errorCode,
    'durationMs': duration.inMilliseconds,
  };
}

abstract interface class PostRenderDiagnostics {
  Future<void> record(PostRenderDiagnosticEvent event);
}

typedef PostRenderLogSink = void Function(String payload);

class LogcatPostRenderDiagnostics implements PostRenderDiagnostics {
  LogcatPostRenderDiagnostics({MethodChannel? channel, PostRenderLogSink? sink})
    : _channel = channel ?? const MethodChannel(channelName),
      _sink = sink ?? _writeLog;

  static const channelName = 'site.wenyou.app/runtime_diagnostics';

  final MethodChannel _channel;
  final PostRenderLogSink _sink;
  Future<PostRenderRuntimeInfo>? _runtimeInfo;

  @override
  Future<void> record(PostRenderDiagnosticEvent event) async {
    final runtime = await (_runtimeInfo ??= _loadRuntimeInfo());
    final payload = event.toPayload(runtime);
    _sink(jsonEncode(payload));
    if (kDebugMode) {
      DebugDiagnosticBuffer.instance.record(
        'post_render',
        payload,
        stackTrace: StackTrace.current,
      );
    }
  }

  Future<PostRenderRuntimeInfo> _loadRuntimeInfo() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return PostRenderRuntimeInfo(
        appVersion: 'unknown',
        buildNumber: 'unknown',
        operatingSystem: kIsWeb ? 'web' : defaultTargetPlatform.name,
        deviceModel: 'unknown',
        renderer: 'flutter-native',
      );
    }
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'getRuntimeInfo',
      );
      if (result == null) return const PostRenderRuntimeInfo.unknown();
      return PostRenderRuntimeInfo(
        appVersion: _safeValue(result['appVersion']),
        buildNumber: _safeValue(result['buildNumber']),
        operatingSystem: _safeValue(result['operatingSystem']),
        deviceModel: _safeValue(result['deviceModel']),
        renderer: _safeValue(result['renderer'], fallback: 'flutter-native'),
      );
    } on PlatformException {
      return const PostRenderRuntimeInfo.unknown();
    } on MissingPluginException {
      return const PostRenderRuntimeInfo.unknown();
    }
  }

  static String _safeValue(Object? value, {String fallback = 'unknown'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static void _writeLog(String payload) {
    developer.log(payload, name: 'wenyou.render');
  }
}

final postRenderDiagnosticsProvider = Provider<PostRenderDiagnostics>((ref) {
  return LogcatPostRenderDiagnostics();
});
