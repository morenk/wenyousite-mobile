import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/media/media_display.dart';

import 'api_failure.dart';

/// 头像等纯展示模型只投影展示地址；资料修改仍使用媒体 ID。
String? mapAvatarDisplayUrl(String? sourceUrl, MediaDisplayResponseDto? dto) =>
    sourceUrl == null ? null : mapMediaDisplay(dto)?.url ?? sourceUrl;

MediaDisplay? mapMediaDisplay(MediaDisplayResponseDto? dto) {
  if (dto == null) return null;
  try {
    return MediaDisplay.fromJson({
      'url': dto.url,
      'contentType':
          dto.contentType ==
              MediaDisplayResponseDtoContentTypeEnum.imageSlashWebp
          ? 'image/webp'
          : null,
      'width': dto.width,
      'height': dto.height,
      'bytes': dto.bytes,
      'animated': dto.animated,
      'frameCount': dto.frameCount,
      'durationMs': dto.durationMs,
      'loopCount': dto.loopCount,
    });
  } on FormatException {
    // 已声明却损坏的 display 不能被当成历史 null 后改下原 GIF。
    throw const ApiFailure.invalidResponse(
      diagnosticCode: 'media_display_invalid',
    );
  }
}

Map<String, MediaDisplay> mapMarkdownMediaDisplays(
  Iterable<MarkdownMediaDisplayResponseDto>? values,
) {
  final result = <String, MediaDisplay>{};
  final seen = <String>{};
  for (final value in values ?? const <MarkdownMediaDisplayResponseDto>[]) {
    if (!seen.add(value.sourceUrl)) {
      throw const ApiFailure.invalidResponse(
        diagnosticCode: 'media_display_duplicate_source',
      );
    }
    final display = mapMediaDisplay(value.display);
    if (display != null) result[value.sourceUrl] = display;
  }
  return Map.unmodifiable(result);
}
