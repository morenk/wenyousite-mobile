import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

enum TextFontLanguage {
  zh('中文'),
  ja('日文'),
  en('英文');

  const TextFontLanguage(this.label);
  final String label;

  static TextFontLanguage? parse(Object? value) => switch (value) {
    'zh' => zh,
    'ja' => ja,
    'en' => en,
    _ => null,
  };
}

/// 唯一获准的原件，额度不得转借其他字体或许可声明。
abstract final class TextFontOriginal {
  static const id = 'xiaocheng-lafeng';
  static const hash =
      'cf4a4215e562d6de6e3ee88f25fc5d47d77668d28eb3a0f2533c7290de307423';
  static const bytes = 18410600;
  static const family = 'WYF1-cf4a4215e562d6de-original';

  static bool accepts(Map<String, dynamic> font) {
    final budget = font['budgetException'];
    return font['id'] == id &&
        budget is Map &&
        budget.length == 4 &&
        budget['kind'] == 'original-source' &&
        budget['assetSha256'] == hash &&
        budget['assetBytes'] == bytes &&
        budget['additionalSessionBytes'] == bytes;
  }
}

class TextFontAsset {
  TextFontAsset.dynamic({
    required this.path,
    required this.hash,
    required this.bytes,
  }) : isOriginal = false {
    if (!RegExp(
          r'^/api/v1/meta/text-fonts/v2/versions/tfv_[a-f0-9]{32}/assets/[a-f0-9]{64}\.(json|png|ttf|otf|woff2)$',
        ).hasMatch(path) ||
        !path.split('/').last.startsWith('$hash.') ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(hash) ||
        bytes <= 0 ||
        bytes > 64 * 1024 * 1024) {
      throw const FormatException('无效动态字体资源');
    }
  }
  TextFontAsset({required this.path, required this.hash, required this.bytes})
    : isOriginal = false {
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(hash) ||
        !RegExp('^fonts/v1/$hash\\.(?:json|txt|ttf|otf)\$').hasMatch(path) ||
        bytes <= 0 ||
        bytes > 6 * 1024 * 1024) {
      throw const FormatException('无效字体资源');
    }
  }
  factory TextFontAsset.fromJson(Map<String, dynamic> json) => TextFontAsset(
    path: json['path'] as String,
    hash: json['sha256'] as String,
    bytes: json['bytes'] as int,
  );
  TextFontAsset._original(Map<String, dynamic> json)
    : path = json['path'] as String,
      hash = json['sha256'] as String,
      bytes = json['bytes'] as int,
      isOriginal = true {
    if (hash != TextFontOriginal.hash ||
        bytes != TextFontOriginal.bytes ||
        path != 'fonts/v1/${TextFontOriginal.hash}.ttf' ||
        json['format'] != 'ttf' ||
        json['contentType'] != 'font/ttf') {
      throw const FormatException('原件身份不符');
    }
  }
  final String path;
  final String hash;
  final int bytes;
  final bool isOriginal;
  bool verifies(Uint8List value) =>
      value.length == bytes && sha256.convert(value).toString() == hash;
  Map<String, Object> toJson() => {
    'path': path,
    'sha256': hash,
    'bytes': bytes,
  };
}

class TextFontShard {
  TextFontShard.validated({
    required this.id,
    required this.family,
    required this.asset,
    required this.ranges,
  });
  TextFontShard._(Map<String, dynamic> json, {required bool original})
    : id = json['id'] as String,
      family = json['family'] as String,
      asset = original
          ? TextFontAsset._original(json['mobile'] as Map<String, dynamic>)
          : TextFontAsset.fromJson(json['mobile'] as Map<String, dynamic>),
      ranges = [
        for (final range in json['unicodeRanges'] as List)
          _range(range as String),
      ] {
    if (!RegExp(r'^WYF1-[a-f0-9]+-[a-z0-9-]+$').hasMatch(family)) {
      throw const FormatException('无效字体家族');
    }
    if (original) {
      final web = TextFontAsset._original(json['web'] as Map<String, dynamic>);
      if (id != 'original' ||
          family != TextFontOriginal.family ||
          web.hash != asset.hash) {
        throw const FormatException('无效原件分片');
      }
    } else if (id == 'original') {
      throw const FormatException('原件不可使用普通额度');
    }
  }
  final String id;
  final String family;
  final TextFontAsset asset;
  final List<(int, int)> ranges;
  static (int, int) _range(String value) {
    if (!RegExp(r'^U\+[0-9A-F]{4,6}(?:-[0-9A-F]{4,6})?$').hasMatch(value)) {
      throw const FormatException('无效字形范围');
    }
    final parts = value.substring(2).split('-');
    final first = int.parse(parts.first, radix: 16);
    final last = int.parse(parts.last, radix: 16);
    if (first > last || last > 0x10ffff) throw const FormatException('无效字形范围');
    return (first, last);
  }

  bool contains(int rune) => ranges.any((r) => rune >= r.$1 && rune <= r.$2);
}

class TextFontFamily {
  TextFontFamily.dynamic({
    required this.id,
    required this.name,
    required this.language,
    required this.ready,
    required this.notices,
    required this.shards,
  });
  factory TextFontFamily(Map<String, dynamic> json) {
    final language = TextFontLanguage.parse(json['designLanguage']);
    final original = json['deliveryMode'] == 'original';
    final supported =
        language != null &&
        (original
            ? TextFontOriginal.accepts(json)
            : json['deliveryMode'] == 'subset' &&
                  !json.containsKey('budgetException'));
    final ready = json['availability'] == 'ready' && supported;
    // 旧目录和未来未知元数据保留名称供说明，但不能猜测分类或加载方式。
    final notices = [
      if (ready)
        for (final asset in json['notices'] as List? ?? [])
          TextFontAsset.fromJson(asset as Map<String, dynamic>),
    ];
    final shards = [
      if (ready)
        for (final shard in json['shards'] as List? ?? [])
          TextFontShard._(shard as Map<String, dynamic>, original: original),
    ];
    if (ready &&
        (notices.isEmpty || shards.isEmpty || original && shards.length != 1)) {
      throw const FormatException('字体缺少声明或分片');
    }
    return TextFontFamily._(
      id: json['id'] as String,
      name: json['name'] as String,
      language: language,
      ready: ready,
      notices: notices,
      shards: shards,
    );
  }
  TextFontFamily._({
    required this.id,
    required this.name,
    required this.language,
    required this.ready,
    required this.notices,
    required this.shards,
  });
  final String id;
  final String name;
  final TextFontLanguage? language;
  final bool ready;
  final List<TextFontAsset> notices;
  final List<TextFontShard> shards;
}

class TextFontManifest {
  TextFontManifest.combined(Map<String, TextFontFamily> values) {
    fonts.addAll(values);
  }
  TextFontManifest(Uint8List data) {
    final json = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
    if (json['schemaVersion'] != 1 || json['fontVersion'] != 1) {
      throw const FormatException('未知字体版本');
    }
    for (final value in json['fonts'] as List) {
      final family = TextFontFamily(value as Map<String, dynamic>);
      if (fonts.containsKey(family.id)) throw const FormatException('重复字体');
      fonts[family.id] = family;
    }
  }
  final fonts = <String, TextFontFamily>{};
}
