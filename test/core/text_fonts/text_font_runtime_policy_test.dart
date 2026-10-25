import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_retry_ledger.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime_policy.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transport.dart';

void main() {
  final policy = File(
    'contracts/thread-font-runtime-policy-v2.json',
  ).readAsStringSync();
  final fixtures =
      jsonDecode(
            File(
              'contracts/thread-font-runtime-policy-v2-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final hash = (jsonDecode(policy) as Map)['manifestSha256'] as String;
  test('正式策略与实际868资产/注册键的两本汇总一致', () {
    final value = TextFontRuntimePolicy(
      jsonDecode(policy) as Map<String, dynamic>,
      hash,
    );
    final snapshot = value.freeze(
      TextFontManifest(
        File('contracts/thread-font-manifest-v1.json').readAsBytesSync(),
      ),
    );
    expect(snapshot.assetCount, 868);
    expect(value.totalRegistrationBytes, 184645488);
    expect(
      () => TextFontRuntimePolicy(
        jsonDecode(policy) as Map<String, dynamic>,
        '0' * 64,
      ),
      throwsFormatException,
    );
  });
  for (final invalid in fixtures['invalidPolicies'] as List) {
    test('正式拒绝夹具 ${invalid['path']}', () {
      final json = jsonDecode(policy) as Map<String, dynamic>;
      var parent = json;
      final path = (invalid['path'] as String).split('.');
      for (final key in path.take(path.length - 1)) {
        parent = parent[key] as Map<String, dynamic>;
      }
      parent[path.last] = invalid['value'];
      expect(() => TextFontRuntimePolicy(json, hash), throwsFormatException);
    });
  }
  for (final entry in fixtures['backoffCases'] as List) {
    test('正式full jitter ${entry['failureCount']}/${entry['random']}', () {
      final ledger = TextFontRetryLedger(
        random: () => (entry['random'] as num).toDouble(),
      );
      for (var i = 0; i < (entry['failureCount'] as int); i++) {
        ledger.transientFailure('asset', Duration.zero);
      }
      expect(
        ledger.availableAt('asset').inMilliseconds,
        entry['expectedDelayMs'],
      );
    });
  }
  test('Retry-After秒/HTTP日期/过期/非法值', () {
    final now = DateTime.fromMillisecondsSinceEpoch(100000, isUtc: true);
    expect(
      TextFontTransport.parseRetryAfter('120', now),
      const Duration(seconds: 120),
    );
    expect(
      TextFontTransport.parseRetryAfter('Thu, 01 Jan 1970 00:03:00 GMT', now),
      const Duration(seconds: 80),
    );
    expect(
      TextFontTransport.parseRetryAfter('Thu, 01 Jan 1970 00:00:00 GMT', now),
      Duration.zero,
    );
    expect(TextFontTransport.parseRetryAfter('-1', now), isNull);
    expect(TextFontTransport.parseRetryAfter('invalid', now), isNull);
  });
}
