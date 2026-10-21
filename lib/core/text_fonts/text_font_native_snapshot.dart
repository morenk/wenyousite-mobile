import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';

/// 一个进程只能持有一个已协商快照。这里只计算原生注册输入的上界，
/// 不把输入长度称为RSS，也不提供假卸载或失败注册退款。
class TextFontNativeSnapshot {
  TextFontNativeSnapshot({
    required TextFontManifest manifest,
    required int assetCount,
    required int totalBytes,
    int? registrationCount,
    int? totalRegistrationBytes,
  }) {
    final familyHashes = <String, String>{};
    for (final font in manifest.fonts.values) {
      if (!font.ready || !MarkdownTextFont.ids.contains(font.id)) continue;
      for (final shard in font.shards) {
        if (familyHashes.containsKey(shard.family) &&
            familyHashes[shard.family] != shard.asset.hash) {
          throw const FormatException('字体快照存在别名或哈希冲突');
        }
        _assets[_key(shard)] = shard;
        familyHashes[shard.family] = shard.asset.hash;
      }
    }
    final unique = {for (final s in _assets.values) s.asset.hash: s.asset};
    _uniqueAssetCount = unique.length;
    final registeredBytes = _assets.values.fold(
      0,
      (sum, s) => sum + s.asset.bytes,
    );
    if (unique.length != assetCount ||
        unique.values.fold(0, (sum, a) => sum + a.bytes) != totalBytes ||
        _assets.length != (registrationCount ?? assetCount) ||
        registeredBytes != (totalRegistrationBytes ?? totalBytes) ||
        _assets.length > 1024 ||
        unique.length > 1024 ||
        totalBytes > 256 * 1024 * 1024 ||
        registeredBytes > 256 * 1024 * 1024) {
      throw const FormatException('字体注册快照与协商上界不一致');
    }
  }
  final _assets = <String, TextFontShard>{};
  final _attempted = <String>{};
  final _loaded = <String>{};
  int _possiblyRetainedInputBytes = 0;
  late final int _uniqueAssetCount;

  int get assetCount => _uniqueAssetCount;
  int get registrationCount => _assets.length;
  int get attemptedCount => _attempted.length;
  int get loadedCount => _loaded.length;
  int get possiblyRetainedInputBytes => _possiblyRetainedInputBytes;
  static String _key(TextFontShard shard) =>
      '${shard.asset.hash}:${shard.family}';
  bool attempted(TextFontShard shard) => _attempted.contains(_key(shard));
  bool contains(TextFontShard shard) {
    final known = _assets[_key(shard)];
    return known != null &&
        known.family == shard.family &&
        known.asset.bytes == shard.asset.bytes;
  }

  /// 只有SHA和长度验证成功、即将调用FontLoader时才预留。
  bool beginNativeAttempt(TextFontShard shard) {
    if (!contains(shard) || !_attempted.add(_key(shard))) return false;
    _possiblyRetainedInputBytes += shard.asset.bytes;
    return true;
  }

  void completeNativeAttempt(TextFontShard shard) {
    if (!contains(shard) || !attempted(shard)) {
      throw StateError('原生注册未预留');
    }
    _loaded.add(_key(shard));
  }

  String? loadedFamily(TextFontShard shard) =>
      contains(shard) && _loaded.contains(_key(shard)) ? shard.family : null;
}
