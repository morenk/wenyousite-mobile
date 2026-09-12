import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BackgroundExecutionStatus {
  stopped,
  foreground,
  starting,
  running,
  blocked,
  failed,
}

abstract interface class BackgroundExecutionGateway {
  bool get isSupported;
  Stream<BackgroundExecutionStatus> get statusChanges;
  Future<void> initialize();

  /// 在前台预先授权原生 onPause 启动；关闭时同时撤销待启动请求。
  Future<void> setEnabled(bool enabled);
  Future<BackgroundExecutionStatus> start();
  Future<void> stop();
  Future<BackgroundExecutionStatus> getStatus();
  Future<void> openNotificationSettings();
}

final backgroundExecutionGatewayProvider = Provider<BackgroundExecutionGateway>(
  (ref) => const UnsupportedBackgroundExecutionGateway(),
);

class UnsupportedBackgroundExecutionGateway
    implements BackgroundExecutionGateway {
  const UnsupportedBackgroundExecutionGateway();

  @override
  bool get isSupported => false;
  @override
  Stream<BackgroundExecutionStatus> get statusChanges => const Stream.empty();
  @override
  Future<void> initialize() async {}
  @override
  Future<void> setEnabled(bool enabled) async {}
  @override
  Future<BackgroundExecutionStatus> start() async =>
      BackgroundExecutionStatus.stopped;
  @override
  Future<void> stop() async {}
  @override
  Future<BackgroundExecutionStatus> getStatus() async =>
      BackgroundExecutionStatus.stopped;
  @override
  Future<void> openNotificationSettings() async {}
}
