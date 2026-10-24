import 'dart:convert';

/// 固定协议形状，仅允许服务器收紧已声明的预算值。
class DynamicFontPolicy {
  DynamicFontPolicy(Map<String, dynamic> value) {
    final expected = jsonDecode(_defaults) as Map<String, dynamic>;
    int bound(Map actual, Map target, String key, int ceiling) {
      final result = actual[key];
      if (result is! int || result < 1 || result > ceiling) {
        throw const FormatException('字体策略预算无效');
      }
      target[key] = result;
      return result;
    }

    for (final platform in ['web', 'mobile']) {
      final actual = (value[platform] as Map)['network'] as Map;
      final target = (expected[platform] as Map)['network'] as Map;
      bound(actual, target, 'maxRequests', 64);
      bound(actual, target, 'maxConcurrent', platform == 'web' ? 2 : 1);
      bound(
        actual,
        target,
        'maxBytes',
        (platform == 'web' ? 16 : 24) * 1024 * 1024,
      );
    }
    final actualWeb = (value['web'] as Map)['residency'] as Map;
    final expectedWeb = (expected['web'] as Map)['residency'] as Map;
    bound(actualWeb, expectedWeb, 'maxFaces', 64);
    bound(actualWeb, expectedWeb, 'maxSfntBytes', 16 * 1024 * 1024);
    final actual = (value['mobile'] as Map)['registration'] as Map;
    final target = (expected['mobile'] as Map)['registration'] as Map;
    maximumKeys = bound(actual, target, 'maxKeys', 1024);
    maximumInputBytes = bound(
      actual,
      target,
      'maxInputBytes',
      64 * 1024 * 1024,
    );
    maximumDiskBytes = bound(
      value,
      expected,
      'diskCacheBytes',
      64 * 1024 * 1024,
    );
    if (!_same(value, expected)) {
      throw const FormatException('字体策略形状不符');
    }
    final network = (value['mobile'] as Map)['network'] as Map;
    maximumRequests = network['maxRequests'] as int;
    maximumNetworkBytes = network['maxBytes'] as int;
  }
  late final int maximumKeys,
      maximumInputBytes,
      maximumRequests,
      maximumNetworkBytes,
      maximumDiskBytes;

  static bool _same(Object? a, Object? b) {
    if (a is Map && b is Map) {
      return a.length == b.length &&
          a.keys.every((k) => b.containsKey(k) && _same(a[k], b[k]));
    }
    if (a is List && b is List) {
      return a.length == b.length &&
          Iterable.generate(a.length).every((i) => _same(a[i], b[i]));
    }
    return a == b;
  }

  static const _defaults = r'''
{
  "policyVersion": 3,
  "web": {
    "network": {
      "windowMs": 60000,
      "maxRequests": 64,
      "maxBytes": 16777216,
      "maxConcurrent": 2,
      "timeoutMode": "idle-with-total-cap",
      "timeoutMs": 15000,
      "maxTransferMs": 600000
    },
    "residency": {
      "mode": "lease-lru",
      "scope": "document",
      "maxFaces": 64,
      "maxSfntBytes": 16777216
    }
  },
  "mobile": {
    "network": {
      "windowMs": 60000,
      "maxRequests": 64,
      "maxBytes": 25165824,
      "maxConcurrent": 1,
      "timeoutMode": "idle-with-total-cap",
      "timeoutMs": 15000,
      "maxTransferMs": 600000
    },
    "registration": {
      "mode": "append-only",
      "scope": "engine",
      "key": "asset-sha256-and-family",
      "maxAttemptsPerKey": 1,
      "failedAttempt": "quarantine-and-retain-charge",
      "maxKeys": 1024,
      "maxInputBytes": 67108864
    }
  },
  "retry": {
    "delayCeilingsMs": [
      1000,
      2000,
      4000,
      8000,
      16000,
      32000,
      60000
    ],
    "jitter": "full",
    "retryableHttpStatuses": [
      408,
      429,
      500,
      502,
      503,
      504
    ],
    "retryNetworkErrors": true,
    "retryTimeouts": true,
    "respectRetryAfter": true
  },
  "fontVersion": 2,
  "metadata": {
    "revalidateAfterMs": 300000,
    "negativeCacheMs": 30000,
    "reservationBytes": 65536,
    "revalidateOnForeground": true,
    "revalidateOnPickerOpen": true,
    "coalesceUnknownVersions": true
  },
  "diskCacheBytes": 67108864
}
''';
}
