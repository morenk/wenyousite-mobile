import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoverAnimationData {
  const CoverAnimationData(this.bytes, {this.fromCache = false});
  final Uint8List bytes;
  final bool fromCache;
}

abstract interface class CoverAnimationSource {
  Future<CoverAnimationData> load(String url, CancelToken cancel);
  Future<void> invalidate(String url);
  void changeViewer(String? accountId, {required bool purge});
  void releaseMemory();
  void dispose();
}

/// 生产在装配层提供带 HTTP 策略的文件缓存；Widget 测试可注入独立来源。
final coverAnimationSourceProvider = Provider<CoverAnimationSource?>(
  (ref) => null,
);
