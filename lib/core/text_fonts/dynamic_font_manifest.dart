import 'dart:convert';
import 'dart:typed_data';

import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';

TextFontAsset dynamicFontAsset(
  String version,
  String base,
  FontAssetDto dto, {
  required Set<String> formats,
  int maximumBytes = 64 * 1024 * 1024,
}) {
  if (!MarkdownTextFont.isVersionId(version) ||
      base != '/api/v1/meta/text-fonts/v2/versions/$version/assets/' ||
      !formats.contains(dto.format.name) ||
      dto.bytes > maximumBytes) {
    throw const FormatException('动态字体资源身份不符');
  }
  return TextFontAsset.dynamic(
    path: '$base${dto.sha256}.${dto.format.name}',
    hash: dto.sha256,
    bytes: dto.bytes,
  );
}

/// 清单只描述不可变资产，是否允许渲染由已再验证的版本描述符决定。
class DynamicFontManifest {
  DynamicFontManifest(Uint8List bytes, this.descriptor) {
    if (bytes.length > 4 * 1024 * 1024 ||
        descriptor.manifest == null ||
        descriptor.assetBasePath == null ||
        !descriptor.renderAllowed) {
      throw const FormatException('字体清单不可用');
    }
    final manifestAsset = dynamicFontAsset(
      descriptor.versionId,
      descriptor.assetBasePath!,
      descriptor.manifest!,
      formats: {'json'},
      maximumBytes: 4 * 1024 * 1024,
    );
    if (!manifestAsset.verifies(bytes)) throw const FormatException('字体清单校验失败');
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    _keys(json, {
      'manifestVersion',
      'buildKey',
      'sourceSha256',
      'baseWeight',
      'baseStyle',
      'coverage',
      'shards',
      'notices',
      'specimen',
    });
    if (json['manifestVersion'] != 2 ||
        json['baseWeight'] != 400 ||
        json['baseStyle'] != 'normal' ||
        !_hash(json['buildKey']) ||
        !_hash(json['sourceSha256'])) {
      throw const FormatException('无效字体清单');
    }
    final coverage = json['coverage'] as Map<String, dynamic>;
    _keys(coverage, {'codepointCount', 'unicodeRanges'});
    final whole = _ranges(
      coverage['unicodeRanges'],
      coverage['codepointCount'],
    );
    final rawShards = json['shards'] as List;
    final rawNotices = json['notices'] as List;
    if (rawShards.isEmpty ||
        rawShards.length > 4096 ||
        rawNotices.isEmpty ||
        rawNotices.length > 8) {
      throw const FormatException('字体清单数量超限');
    }
    final ids = <String>{}, families = <String>{};
    final allRanges = <(int, int)>[];
    final assets = <String, int>{};
    TextFontAsset readAsset(Object? value, Set<String> formats) {
      final map = value as Map<String, dynamic>;
      _keys(map, {'sha256', 'bytes', 'format'});
      final dto = standardSerializers.deserializeWith(
        FontAssetDto.serializer,
        map,
      )!;
      final asset = dynamicFontAsset(
        descriptor.versionId,
        descriptor.assetBasePath!,
        dto,
        formats: formats,
      );
      if (assets[asset.hash] != null && assets[asset.hash] != asset.bytes) {
        throw const FormatException('相同资源长度冲突');
      }
      assets[asset.hash] = asset.bytes;
      return asset;
    }

    for (final raw in rawShards) {
      final shard = raw as Map<String, dynamic>;
      _keys(shard, {
        'id',
        'family',
        'unicodeRanges',
        'codepointCount',
        'web',
        'mobile',
      });
      final id = shard['id'] as String, family = shard['family'] as String;
      if (!RegExp(r'^[a-z0-9-]{1,32}$').hasMatch(id) ||
          !RegExp(
            r'^(WYF2-[a-f0-9]{32}|WYF1-[a-f0-9]{16})-[a-z0-9-]{1,32}$',
          ).hasMatch(family) ||
          !ids.add(id) ||
          !families.add(family)) {
        throw const FormatException('分片身份重复或无效');
      }
      final ranges = _ranges(shard['unicodeRanges'], shard['codepointCount']);
      allRanges.addAll(ranges);
      readAsset(shard['web'], {'woff2'});
      shards.add(
        TextFontShard.validated(
          id: id,
          family: family,
          asset: readAsset(shard['mobile'], {'ttf', 'otf'}),
          ranges: ranges,
        ),
      );
    }
    allRanges.sort((a, b) => a.$1.compareTo(b.$1));
    final merged = _merge(allRanges);
    final expected = _merge(whole);
    if (merged.length != expected.length ||
        Iterable.generate(merged.length).any((i) => merged[i] != expected[i])) {
      throw const FormatException('分片覆盖与清单不一致');
    }
    notices.addAll(rawNotices.map((value) => readAsset(value, {'json'})));
    specimen = readAsset(json['specimen'], {'png'});
    if (descriptor.specimen?.sha256 != specimen.hash ||
        descriptor.specimen?.bytes != specimen.bytes ||
        assets.values.fold(0, (a, b) => a + b) > 2 * 1024 * 1024 * 1024) {
      throw const FormatException('字体输出身份或大小不符');
    }
  }
  final FontVersionDescriptorDto descriptor;
  final shards = <TextFontShard>[];
  final notices = <TextFontAsset>[];
  late final TextFontAsset specimen;
  TextFontFamily get family => TextFontFamily.dynamic(
    id: descriptor.versionId,
    name: descriptor.name,
    language: TextFontLanguage.parse(descriptor.designLanguage.name),
    ready: true,
    notices: List.unmodifiable(notices),
    shards: List.unmodifiable(shards),
  );

  static bool _hash(Object? value) =>
      value is String && RegExp(r'^[a-f0-9]{64}$').hasMatch(value);
  static void _keys(Map<String, dynamic> value, Set<String> keys) {
    if (value.length != keys.length || !keys.every(value.containsKey)) {
      throw const FormatException('字体清单字段不符');
    }
  }

  static List<(int, int)> _ranges(Object? value, Object? count) {
    if (value is! List ||
        value.isEmpty ||
        value.length > 1112064 ||
        count is! int ||
        count < 1 ||
        count > 1112064) {
      throw const FormatException('无效字形覆盖');
    }
    final result = <(int, int)>[];
    var total = 0, previous = -1;
    for (final raw in value) {
      if (raw is! String ||
          !RegExp(r'^U\+[0-9A-F]{4,6}(-[0-9A-F]{4,6})?$').hasMatch(raw)) {
        throw const FormatException('无效字形区间');
      }
      final parts = raw.substring(2).split('-');
      final first = int.parse(parts.first, radix: 16),
          last = int.parse(parts.last, radix: 16);
      if (first <= previous ||
          first > last ||
          last > 0x10ffff ||
          first <= 0xdfff && last >= 0xd800) {
        throw const FormatException('字形区间重叠或非标量');
      }
      result.add((first, last));
      total += last - first + 1;
      previous = last;
    }
    if (total != count) throw const FormatException('字形计数不符');
    return result;
  }

  static List<(int, int)> _merge(List<(int, int)> ranges) {
    final result = <(int, int)>[];
    for (final range in ranges) {
      if (result.isNotEmpty && range.$1 <= result.last.$2) {
        throw const FormatException('分片覆盖重叠');
      }
      if (result.isNotEmpty && range.$1 == result.last.$2 + 1) {
        result[result.length - 1] = (result.last.$1, range.$2);
      } else {
        result.add(range);
      }
    }
    return result;
  }
}
