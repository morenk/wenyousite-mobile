import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_record.dart';

/// 复用已有只读原生通道，读取系统版本、API 级别、厂商机型和渲染器选择。
/// 不从 Platform.operatingSystemVersion 的任意数字猜测 Android 版本。
Future<Map<String, Object?>> loadDiagnosticAndroidRuntime({
  MethodChannel channel = const MethodChannel(
    'site.wenyou.app/runtime_diagnostics',
  ),
}) async {
  try {
    final data = await channel
        .invokeMapMethod<String, Object?>('getRuntimeInfo')
        .timeout(const Duration(seconds: 2));
    final os = data?['operatingSystem'];
    final match = os is String
        ? RegExp(
            r'^Android ([0-9]+(?:\.[0-9]+)*) \(API ([0-9]+)\)$',
          ).firstMatch(os)
        : null;
    return sanitizeDiagnosticFields({
      if (match != null) 'osVersion': match[1],
      if (match != null) 'androidApi': int.tryParse(match[2]!),
      // 此原生字段来自 Build.MANUFACTURER / MODEL，不是用户设备昵称。
      'deviceModel': data?['deviceModel'],
      if (const [
        'impeller-requested',
        'skia-opengles-requested',
      ].contains(data?['renderer']))
        'renderer': data!['renderer'],
    });
  } on PlatformException {
    return const {};
  } on MissingPluginException {
    return const {};
  } on TimeoutException {
    return const {};
  }
}
