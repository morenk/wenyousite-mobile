import 'dart:io';

import 'package:flutter/services.dart';

/// 只作为队列唤醒信号，不能将网络能力当作字体服务器可达证明。
/// 非Android平台仍由资源级定时退避和前台事件恢复。
Stream<bool> deviceNetworkAvailability() {
  if (!Platform.isAndroid) return const Stream.empty();
  return const EventChannel('site.wenyou.app/network_availability')
      .receiveBroadcastStream()
      .where((event) => event is bool)
      .cast<bool>()
      .distinct();
}
