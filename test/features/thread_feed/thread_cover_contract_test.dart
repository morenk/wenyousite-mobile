import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/features/thread_feed/thread_feed_mapping.dart';

void main() {
  final fixture =
      jsonDecode(
            File(
              'contracts/thread-cover-media-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;
  for (final raw in fixture['cases']! as List<Object?>) {
    final item = raw! as Map<String, Object?>;
    test('封面共享契约：${item['name']}', () {
      final input = item['coverMedia'];
      final dto = input == null
          ? null
          : standardSerializers.deserializeWith(
              ThreadCoverMediaResponseDto.serializer,
              input,
            );
      final value = mapThreadFeedCoverMedia(
        dto,
        (item['coverImages']! as List<Object?>).cast<String>(),
      );
      switch (item['name']) {
        case 'registered-gif':
        case 'registered-animation-webp':
        case 'preview-two-sizes':
        case 'preview-single-size':
        case 'preview-null-original-fallback':
          expect(value!.animationUrl, dto!.url);
          expect(value.staticUrl, dto.posterUrl);
        case 'registered-static':
        case 'legacy-static':
          expect(value!.animationUrl, isNull);
          expect(value.staticUrl, dto!.posterUrl);
        default:
          expect(value?.animationUrl, isNull);
          expect(value?.staticUrl, isNull);
      }
    });
  }

  test('源地址错配、无效poster与缺poster不回退请求原图', () {
    const url = 'https://cdn.example/a.gif';
    final dto = ThreadCoverMediaResponseDto(
      (cover) => cover
        ..url = url
        ..animated = false,
    );
    expect(mapThreadFeedCoverMedia(dto, [url])!.staticUrl, isNull);
    expect(mapThreadFeedCoverMedia(dto, ['https://cdn.example/b.gif']), isNull);
    expect(
      mapThreadFeedCoverMedia(
        dto.rebuild(
          (cover) => cover
            ..animated = true
            ..posterUrl = 'javascript:alert(1)',
        ),
        [url],
      )!.animationUrl,
      isNull,
    );
    final originalAsPoster = dto.rebuild(
      (cover) => cover
        ..animated = true
        ..posterUrl = url,
    );
    expect(mapThreadFeedCoverMedia(originalAsPoster, [url])!.staticUrl, isNull);
  });
}
