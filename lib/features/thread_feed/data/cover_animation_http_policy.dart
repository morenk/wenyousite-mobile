import 'dart:io';

import 'package:dio/dio.dart';

/// 只复用显式公开、明确新鲜的响应。查询参数保守视为签名凭据。
DateTime? coverAnimationFreshUntil(
  Uri requested,
  Uri resolved,
  Headers headers,
  DateTime requestedAt,
  DateTime receivedAt,
) {
  String? header(String name) => headers.map[name]?.join(',');
  bool safe(Uri uri) =>
      (uri.scheme == 'https' || uri.scheme == 'http') &&
      uri.host.isNotEmpty &&
      uri.userInfo.isEmpty &&
      !uri.hasQuery &&
      !uri.hasFragment;
  if (!safe(requested) || !safe(resolved)) return null;
  final directives = <String, List<String>>{};
  for (final part in (header('cache-control') ?? '').split(',')) {
    final pair = part.trim().toLowerCase().split('=');
    directives
        .putIfAbsent(pair.first, () => [])
        .add(pair.length == 2 ? pair.last.replaceAll('"', '').trim() : '');
  }
  if (!directives.containsKey('public') ||
      ['private', 'no-store', 'no-cache'].any(directives.containsKey) ||
      header('set-cookie') != null ||
      (header('vary') ?? '')
          .split(',')
          .map((value) => value.trim().toLowerCase())
          .any((value) => value.isNotEmpty && value != 'accept-encoding')) {
    return null;
  }
  DateTime? date(String key) {
    final value = header(key);
    if (value == null) return null;
    try {
      return HttpDate.parse(value);
    } on FormatException {
      return null;
    }
  }

  final responseDate = date('date') ?? receivedAt;
  final ages = directives['max-age'];
  Duration lifetime;
  if (ages != null) {
    final seconds = ages.length == 1 ? int.tryParse(ages.single) : null;
    if (seconds == null || seconds <= 0 || seconds > 1000000000000) return null;
    lifetime = Duration(seconds: seconds);
  } else {
    final expires = date('expires');
    if (expires == null) return null;
    lifetime = expires.difference(responseDate);
  }
  final ageHeader = header('age');
  final ageSeconds = ageHeader == null ? 0 : int.tryParse(ageHeader);
  if (ageSeconds == null || ageSeconds < 0 || ageSeconds > 1000000000000) {
    return null;
  }
  final rawAge = receivedAt.difference(responseDate);
  final apparentAge = rawAge < Duration.zero ? Duration.zero : rawAge;
  final rawDelay = receivedAt.difference(requestedAt);
  final correctedAge =
      Duration(seconds: ageSeconds) +
      (rawDelay < Duration.zero ? Duration.zero : rawDelay);
  final age = apparentAge > correctedAge ? apparentAge : correctedAge;
  final remaining = lifetime - age;
  if (remaining <= Duration.zero) return null;
  return receivedAt.add(
    remaining > const Duration(days: 7) ? const Duration(days: 7) : remaining,
  );
}
