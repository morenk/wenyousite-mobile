import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/media/media_display.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/media_display_mapper.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/thread_feed_mapper.dart';
import 'package:wenyousite_mobile/features/thread_feed/domain/thread_feed_models.dart';

void main() {
  final fixture =
      jsonDecode(
            File('contracts/media-display-v1-fixtures.json').readAsStringSync(),
          )
          as Map<String, Object?>;
  final cases = (fixture['cases']! as List).cast<Map<String, Object?>>();
  test('黄金资源通过实际选择器，完整展示不退回来源或轻预览', () {
    final sample = cases.firstWhere((item) => item['id'] == 'full-animation');
    final dto = standardSerializers.deserializeWith(
      MediaDisplayResponseDto.serializer,
      sample['display'],
    )!;
    final display = mapMediaDisplay(dto)!;
    expect(
      selectFullMediaUrls(
        sourceUrl: sample['sourceUrl']! as String,
        display: display,
        legacyUrls: ['https://cdn.example/preview.webp'],
      ),
      [sample['expectedDisplayUrl']],
    );
    expect(MediaDisplay.fromJson(display.toJson()).toJson(), display.toJson());
    final source = sample['sourceUrl']! as String;
    final map = {source: display};
    expect(
      mediaDisplaysFromJson(
        jsonDecode(jsonEncode(mediaDisplaysToJson(map))),
      )[source]!.toJson(),
      display.toJson(),
    );
  });
  test('有效完整描述不依赖 poster，保留小预览选择', () {
    final sample = cases.firstWhere((item) => item['id'] == 'full-animation');
    final source = sample['sourceUrl']! as String;
    final dto = standardSerializers.deserializeWith(
      ThreadCoverMediaResponseDto.serializer,
      {
        'url': source,
        'animated': true,
        'posterUrl': null,
        'display': sample['display'],
        'previewVariants': [
          {
            'url': 'https://cdn.example/preview.webp',
            'width': 80,
            'height': 45,
            'bytes': 184,
          },
        ],
      },
    )!;
    final media = mapThreadFeedCoverMedia(dto, [source])!;
    expect(media.animationUrl, sample['expectedDisplayUrl']);
    expect(
      media.previewVariants.single.url,
      'https://cdn.example/preview.webp',
    );
    expect(media.posterUrl, isNull);
  });
  test('历史 null 延用原 URL，坏 display 拒绝映射而非伪装 null', () {
    expect(
      selectFullMediaUrls(
        sourceUrl: 'https://cdn.example/original.gif',
        display: null,
      ),
      ['https://cdn.example/original.gif'],
    );
    final sample = cases.firstWhere((item) => item['id'] == 'full-animation');
    final raw = {...sample['display']! as Map<String, Object?>, 'width': 0};
    final dto = standardSerializers.deserializeWith(
      MediaDisplayResponseDto.serializer,
      raw,
    )!;
    expect(() => mapMediaDisplay(dto), throwsA(isA<ApiFailure>()));
  });
  test('完整动画可在无 poster 时播放，动态列表仍只取静态资源', () {
    final sample = cases.firstWhere((item) => item['id'] == 'full-animation');
    final display = MediaDisplay.fromJson(
      sample['display']! as Map<String, Object?>,
    );
    final source = sample['sourceUrl']! as String;
    final cover = ThreadFeedCoverMedia(
      url: source,
      animated: true,
      display: display,
    );
    expect(cover.animationUrl, display.url);
    final moment = MomentMedia(
      id: 'one',
      url: source,
      animated: true,
      display: display,
      thumbnailUrl: 'https://cdn.example/poster.png',
    );
    expect(moment.staticFeedUrls, ['https://cdn.example/poster.png']);
    expect(moment.contentUrls, [display.url]);
    expect(moment.playbackUrl, display.url);
    expect(moment.url, source);
    final uploaded = UploadedEditorImage(
      mediaId: 'one',
      url: source,
      display: display,
      animated: true,
      thumbnailUrl: source,
    );
    expect(uploaded.previewUrls, [display.url]);
  });
}
