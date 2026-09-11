/// 经服务端验证的完整展示资源；与正文、收藏和编辑使用的来源身份分开。
class MediaDisplay {
  const MediaDisplay({
    required this.url,
    required this.width,
    required this.height,
    required this.bytes,
    required this.animated,
    required this.frameCount,
    required this.durationMs,
    required this.loopCount,
  });

  final String url;
  final int width;
  final int height;
  final int bytes;
  final bool animated;
  final int frameCount;
  final int durationMs;
  final int loopCount;
  String get contentType => 'image/webp';

  Map<String, Object?> toJson() => {
    'url': url,
    'contentType': contentType,
    'width': width,
    'height': height,
    'bytes': bytes,
    'animated': animated,
    'frameCount': frameCount,
    'durationMs': durationMs,
    'loopCount': loopCount,
  };

  factory MediaDisplay.fromJson(Map<String, Object?> json) {
    final url = json['url'];
    final uri = url is String ? Uri.tryParse(url) : null;
    final animated = json['animated'];
    if (uri == null ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        json['contentType'] != 'image/webp' ||
        animated is! bool) {
      throw const FormatException('图片展示资源无效');
    }
    int integer(String key, {int minimum = 1}) {
      final value = json[key];
      if (value is! num ||
          !value.isFinite ||
          value < minimum ||
          value != value.toInt()) {
        throw const FormatException('图片展示元数据无效');
      }
      return value.toInt();
    }

    final result = MediaDisplay(
      url: url as String,
      width: integer('width'),
      height: integer('height'),
      bytes: integer('bytes'),
      animated: animated,
      frameCount: integer('frameCount'),
      durationMs: integer('durationMs', minimum: 0),
      loopCount: integer('loopCount', minimum: 0),
    );
    if (!animated &&
        (result.frameCount != 1 ||
            result.durationMs != 0 ||
            result.loopCount != 1)) {
      throw const FormatException('静态图片展示时序无效');
    }
    return result;
  }
}

/// 完整展示失败不能把昂贵的来源 GIF 加入自动回退链。
List<String> selectFullMediaUrls({
  required String sourceUrl,
  required MediaDisplay? display,
  List<String> legacyUrls = const [],
}) {
  if (display != null) return [display.url];
  return {
    for (final url in [...legacyUrls, sourceUrl])
      if (url.trim().isNotEmpty) url,
  }.toList(growable: false);
}

Map<String, Object?> mediaDisplaysToJson(Map<String, MediaDisplay> displays) =>
    {for (final entry in displays.entries) entry.key: entry.value.toJson()};

Map<String, MediaDisplay> mediaDisplaysFromJson(Object? value) {
  if (value is! Map<String, Object?>) return const {};
  return Map.unmodifiable({
    for (final entry in value.entries)
      if (cachedMediaDisplayFromJson(entry.value)
          case final MediaDisplay display)
        entry.key: display,
  });
}

/// 本地缓存是恢复辅助信息，损坏不能阻断原 Markdown 与身份恢复。
/// API 声明的 display 仍由严格 mapper 验证，不调用这个容错入口。
MediaDisplay? cachedMediaDisplayFromJson(Object? value) {
  if (value is! Map<String, Object?>) return null;
  try {
    return MediaDisplay.fromJson(value);
  } on FormatException {
    return null;
  }
}
