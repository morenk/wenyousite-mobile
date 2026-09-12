import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/background_execution.dart';

final androidBackgroundExecutionGatewayProvider =
    Provider<BackgroundExecutionGateway>((ref) {
      final gateway = AndroidBackgroundExecutionGateway();
      ref.onDispose(gateway.dispose);
      return gateway;
    });

class AndroidBackgroundExecutionGateway implements BackgroundExecutionGateway {
  AndroidBackgroundExecutionGateway({MethodChannel? channel})
    : _channel =
          channel ??
          const MethodChannel('site.wenyou.app/background_execution');

  final MethodChannel _channel;
  final _statuses = StreamController<BackgroundExecutionStatus>.broadcast();
  bool _initialized = false;

  @override
  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  @override
  Stream<BackgroundExecutionStatus> get statusChanges => _statuses.stream;

  @override
  Future<void> initialize() async {
    if (!isSupported || _initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'statusChanged' && !_statuses.isClosed) {
        _statuses.add(_decode(call.arguments));
      }
    });
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    if (!isSupported) return;
    await initialize();
    await _channel.invokeMethod<void>('setEnabled', {'enabled': enabled});
  }

  @override
  Future<BackgroundExecutionStatus> start() async {
    if (!isSupported) return BackgroundExecutionStatus.stopped;
    await initialize();
    return _decode(await _channel.invokeMethod<String>('start'));
  }

  @override
  Future<void> stop() async {
    if (isSupported) await _channel.invokeMethod<void>('stop');
  }

  @override
  Future<BackgroundExecutionStatus> getStatus() async {
    if (!isSupported) return BackgroundExecutionStatus.stopped;
    return _decode(await _channel.invokeMethod<String>('getStatus'));
  }

  @override
  Future<void> openNotificationSettings() async {
    if (isSupported) {
      await _channel.invokeMethod<void>('openNotificationSettings');
    }
  }

  void dispose() {
    _channel.setMethodCallHandler(null);
    unawaited(_statuses.close());
  }

  BackgroundExecutionStatus _decode(Object? value) => switch (value) {
    'stopped' => BackgroundExecutionStatus.stopped,
    'foreground' => BackgroundExecutionStatus.foreground,
    'starting' => BackgroundExecutionStatus.starting,
    'running' => BackgroundExecutionStatus.running,
    'blocked' => BackgroundExecutionStatus.blocked,
    _ => BackgroundExecutionStatus.failed,
  };
}
