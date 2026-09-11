import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cover_animation_http_policy.dart';

void main() {
  final now = DateTime.utc(2026, 9, 9);
  final url = Uri.parse('https://media.example/preview/v1.webp');
  DateTime? evaluate(
    Map<String, List<String>> values, {
    Uri? request,
    Uri? target,
    Duration latency = Duration.zero,
  }) => coverAnimationFreshUntil(
    request ?? url,
    target ?? url,
    Headers.fromMap(values),
    now.subtract(latency),
    now,
  );

  test('Age、Date 与传输时间限制 max-age，Expires 与七天硬上限有效', () {
    expect(
      evaluate({
        'cache-control': ['public, max-age=120'],
        'age': ['50'],
        'date': [HttpDate.format(now.subtract(const Duration(seconds: 30)))],
      }, latency: const Duration(seconds: 10)),
      now.add(const Duration(seconds: 60)),
    );
    expect(
      evaluate({
        'cache-control': ['public'],
        'expires': [HttpDate.format(now.add(const Duration(minutes: 3)))],
      }),
      now.add(const Duration(minutes: 3)),
    );
    expect(
      evaluate({
        'cache-control': ['public, max-age=99999999'],
      }),
      now.add(const Duration(days: 7)),
    );
  });

  for (final control in [
    'private, max-age=60',
    'public, no-store, max-age=60',
    'public, no-cache, max-age=60',
    'public, max-age=0',
    'public',
    'max-age=60',
    'public, max-age=60, max-age=120',
    'public, max-age=abc',
  ]) {
    test('不复用不明确或受限制响应：$control', () {
      expect(
        evaluate({
          'cache-control': [control],
        }),
        isNull,
      );
    });
  }

  test('查询签名、带凭据地址、私有Vary和Cookie不缓存', () {
    final headers = {
      'cache-control': ['public, max-age=60'],
    };
    expect(
      evaluate(headers, request: url.replace(query: 'token=secret')),
      isNull,
    );
    expect(
      evaluate(headers, target: url.replace(query: 'signature=secret')),
      isNull,
    );
    expect(
      evaluate(headers, target: Uri.parse('https://user:pass@media.example/a')),
      isNull,
    );
    expect(
      evaluate({
        ...headers,
        'vary': ['Authorization'],
      }),
      isNull,
    );
    expect(
      evaluate({
        ...headers,
        'vary': ['*'],
      }),
      isNull,
    );
    expect(
      evaluate({
        ...headers,
        'set-cookie': ['a=b', 'c=d'],
      }),
      isNull,
    );
    expect(
      evaluate({
        ...headers,
        'age': ['n/a'],
      }),
      isNull,
    );
  });

  test('多行公开缓存头与 accept-encoding 可安全解析', () {
    expect(
      evaluate({
        'cache-control': ['public', 'max-age="60"'],
        'vary': ['Accept-Encoding'],
      }),
      now.add(const Duration(seconds: 60)),
    );
  });

  test('一年公开缓存即使Age已超过七天仍新鲜，本地从剩余寿命封顶', () {
    expect(
      evaluate({
        'cache-control': ['public, max-age=31536000, immutable'],
        'age': ['864000'],
      }),
      now.add(const Duration(days: 7)),
    );
    expect(
      evaluate({
        'cache-control': ['public, max-age=9223372036854775807'],
      }),
      isNull,
    );
    expect(
      evaluate({
        'cache-control': ['public, max-age=60'],
        'age': ['9223372036854775807'],
      }),
      isNull,
    );
  });
}
