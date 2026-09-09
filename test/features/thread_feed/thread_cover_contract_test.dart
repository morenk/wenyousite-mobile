import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/features/thread_feed/thread_feed_mapping.dart';
import 'package:wenyousite_mobile/features/thread_feed/thread_feed_models.dart';

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

  test('按实际绘制尺寸与DPR选最小够用档，无够用档只用最大预览', () {
    const variants = [
      ThreadFeedCoverPreviewVariant(
        url: 'small',
        width: 480,
        height: 270,
        bytes: 9000,
      ),
      ThreadFeedCoverPreviewVariant(
        url: 'large',
        width: 800,
        height: 450,
        bytes: 14000,
      ),
    ];
    for (final entry in <(double, double, String)>[
      (300, 1, 'small'),
      (300, 2, 'large'),
      (480, 1, 'small'),
      (700, 2, 'large'),
    ]) {
      expect(
        selectThreadCoverAnimation(
          variants: variants,
          originalUrl: 'original',
          width: entry.$1,
          height: entry.$1 * 9 / 16,
          devicePixelRatio: entry.$2,
        ),
        entry.$3,
      );
    }
    expect(
      selectThreadCoverAnimation(
        variants: const [],
        originalUrl: 'original',
        width: 300,
        height: 169,
        devicePixelRatio: 2,
      ),
      'original',
    );
    expect(
      selectThreadCoverAnimation(
        variants: variants,
        originalUrl: null,
        width: 300,
        height: 169,
        devicePixelRatio: 2,
      ),
      isNull,
    );
    const portrait = [
      ThreadFeedCoverPreviewVariant(
        url: 'portrait-small',
        width: 270,
        height: 480,
        bytes: 9000,
      ),
      ThreadFeedCoverPreviewVariant(
        url: 'portrait-large',
        width: 450,
        height: 800,
        bytes: 14000,
      ),
    ];
    expect(
      selectThreadCoverAnimation(
        variants: portrait,
        originalUrl: 'original',
        width: 300,
        height: 169,
        devicePixelRatio: 1,
      ),
      'portrait-large',
    );
  });

  test('11条共享契约实际映射保留预览，异常元数据丢弃后保持受控原图降级', () {
    final raw = (fixture['cases']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .firstWhere((item) => item['name'] == 'preview-two-sizes');
    final dto = standardSerializers.deserializeWith(
      ThreadCoverMediaResponseDto.serializer,
      raw['coverMedia'],
    )!;
    final mapped = mapThreadFeedCoverMedia(dto, [dto.url])!;
    expect(mapped.previewVariants.map((item) => item.width), [480, 800]);
    expect(mapped.previewVariants.map((item) => item.bytes), [9820, 14408]);
    final invalid = dto.rebuild(
      (cover) => cover.previewVariants.replace([
        dto.previewVariants!.first.rebuild((item) => item..url = dto.posterUrl),
        dto.previewVariants!.last.rebuild((item) => item..width = 0),
      ]),
    );
    final fallback = mapThreadFeedCoverMedia(invalid, [dto.url])!;
    expect(fallback.previewVariants, isEmpty);
    expect(fallback.animationUrl, dto.url);
    final unknown = mapThreadFeedCoverMedia(
      dto.rebuild((cover) => cover..animated = null),
      [dto.url],
    )!;
    expect(unknown.previewVariants, isEmpty);
    expect(unknown.animationUrl, isNull);
  });
}
