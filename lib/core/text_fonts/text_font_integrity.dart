import 'package:flutter/foundation.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';

/// 大分片 SHA 校验放到工作 isolate，避免加载动画和触摸被同步散列占用。
/// 小声明文件保留同步路径；长度和哈希条件与原校验完全相同。
Future<bool> verifyTextFontAsset(TextFontAsset asset, Uint8List bytes) async {
  if (bytes.length != asset.bytes) return false;
  if (bytes.length <= 64 * 1024) return asset.verifies(bytes);
  return compute(_verify, (asset, bytes), debugLabel: 'text-font-integrity');
}

bool _verify((TextFontAsset, Uint8List) input) => input.$1.verifies(input.$2);
