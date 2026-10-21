import 'dart:convert';

import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_native_snapshot.dart';

/// v2严格形状与本地接受边界；未知字段/模式不能授权扩大原生集合。
class TextFontRuntimePolicy {
  TextFontRuntimePolicy(Map<String, dynamic> json, String manifestHash) {
    final expected = jsonDecode(_shape) as Map<String, dynamic>;
    expected['manifestSha256'] = manifestHash;
    final registration = (json['mobile'] as Map?)?['registration'] as Map?;
    final snapshot = registration?['snapshot'];
    if (snapshot is! Map ||
        snapshot.length != 4 ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(manifestHash)) {
      throw const FormatException('无效字体策略');
    }
    int read(String key, int maximum) {
      final value = snapshot[key];
      if (value is! int || value < 1 || value > maximum) {
        throw const FormatException('字体快照超过本地接受边界');
      }
      return value;
    }

    assetCount = read('assetCount', 1024);
    totalAssetBytes = read('totalAssetBytes', 256 * 1024 * 1024);
    registrationCount = read('registrationCount', 1024);
    totalRegistrationBytes = read(
      'totalRegistrationAssetBytes',
      256 * 1024 * 1024,
    );
    ((expected['mobile'] as Map)['registration'] as Map)['snapshot'] = snapshot;
    if (!_same(json, expected)) {
      throw const FormatException('未知字体策略或绑定不符');
    }
  }

  late final int assetCount;
  late final int totalAssetBytes;
  late final int registrationCount;
  late final int totalRegistrationBytes;

  static bool _same(Object? a, Object? b) {
    if (a is Map && b is Map) {
      return a.length == b.length &&
          a.keys.every((k) => b.containsKey(k) && _same(a[k], b[k]));
    }
    if (a is List && b is List) {
      return a.length == b.length &&
          List.generate(a.length, (i) => i).every((i) => _same(a[i], b[i]));
    }
    return a == b;
  }

  TextFontNativeSnapshot freeze(TextFontManifest manifest) =>
      TextFontNativeSnapshot(
        manifest: manifest,
        assetCount: assetCount,
        totalBytes: totalAssetBytes,
        registrationCount: registrationCount,
        totalRegistrationBytes: totalRegistrationBytes,
      );

  // 与contracts/thread-font-runtime-policy-v2.schema.json的const字段逐项对应。
  static const _shape = '''{
    "policyVersion":2,"manifestSha256":"",
    "web":{
      "network":{"windowMs":60000,"maxRequests":64,"maxBytes":16777216,"maxConcurrent":2,"timeoutMode":"idle-with-total-cap","timeoutMs":15000,"maxTransferMs":600000},
      "residency":{"mode":"lease-lru","scope":"document","maxFamilies":28,"maxFaces":64,"maxSfntBytes":16777216}
    },
    "mobile":{
      "network":{"windowMs":60000,"maxRequests":64,"maxBytes":25165824,"maxConcurrent":1,"timeoutMode":"idle-with-total-cap","timeoutMs":15000,"maxTransferMs":600000},
      "registration":{"mode":"fixed-manifest","scope":"engine","key":"asset-sha256-and-family","maxAttemptsPerKey":1,"failedAttempt":"quarantine-and-retain-charge","snapshot":{},"safetyCeiling":{"maxSnapshotAssets":1024,"maxSnapshotAssetBytes":268435456}}
    },
    "retry":{"delayCeilingsMs":[1000,2000,4000,8000,16000,32000,60000],"jitter":"full","retryableHttpStatuses":[408,429,500,502,503,504],"retryNetworkErrors":true,"retryTimeouts":true,"respectRetryAfter":true}
  }''';
}
