import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class TextFontAsset {
  TextFontAsset({required this.path, required this.hash, required this.bytes}) {
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
  final String path;
  final String hash;
  final int bytes;
  bool verifies(Uint8List value) =>
      value.length == bytes && sha256.convert(value).toString() == hash;
  Map<String, Object> toJson() => {
    'path': path,
    'sha256': hash,
    'bytes': bytes,
  };
}

class TextFontShard {
  TextFontShard(Map<String, dynamic> json)
    : family = json['family'] as String,
      asset = TextFontAsset.fromJson(json['mobile'] as Map<String, dynamic>),
      ranges = [
        for (final range in json['unicodeRanges'] as List)
          _range(range as String),
      ] {
    if (!RegExp(r'^WYF1-[a-f0-9]+-[a-z0-9-]+$').hasMatch(family)) {
      throw const FormatException('无效字体家族');
    }
  }
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
  TextFontFamily(Map<String, dynamic> json)
    : id = json['id'] as String,
      name = json['name'] as String,
      ready = json['availability'] == 'ready',
      notices = [
        for (final asset in json['notices'] as List? ?? [])
          TextFontAsset.fromJson(asset as Map<String, dynamic>),
      ],
      shards = [
        for (final shard in json['shards'] as List? ?? [])
          TextFontShard(shard as Map<String, dynamic>),
      ] {
    if (ready && (notices.isEmpty || shards.isEmpty)) {
      throw const FormatException('字体缺少声明或分片');
    }
  }
  final String id;
  final String name;
  final bool ready;
  final List<TextFontAsset> notices;
  final List<TextFontShard> shards;
}

class TextFontManifest {
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
