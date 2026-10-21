import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_native_ledger.dart';

/// 一个进程只能持有一个已协商快照。这里只计算原生注册输入的上界，
/// 不把输入长度称为RSS，也不提供假卸载或失败注册退款。
class TextFontNativeSnapshot {
  TextFontNativeSnapshot.dynamic(TextFontNativeLedger ledger)
    : _ledger = ledger,
      _dynamic = true,
      _uniqueAssetCount = 0;

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
  TextFontNativeLedger? _ledger;
  bool _dynamic = false;

  void attachLedger(
    TextFontNativeLedger ledger, {
    bool dynamicVersions = false,
  }) {
    if (_ledger != null && !identical(_ledger, ledger)) {
      throw StateError('不能替换同一引擎注册账本');
    }
    for (final entry in _assets.entries) {
      if (!_attempted.contains(entry.key)) continue;
      final shard = entry.value;
      ledger.importEngineAttempt(
        hash: shard.asset.hash,
        family: shard.family,
        inputBytes: shard.asset.bytes,
        succeeded: _loaded.contains(entry.key),
      );
    }
    _ledger = ledger;
    _dynamic = _dynamic || dynamicVersions;
  }

  int get assetCount => _uniqueAssetCount;
  int get registrationCount => _assets.length;
  int get attemptedCount => _ledger?.attemptedCount ?? _attempted.length;
  int get loadedCount => _ledger?.loadedCount ?? _loaded.length;
  int get possiblyRetainedInputBytes =>
      _ledger?.chargedInputBytes ?? _possiblyRetainedInputBytes;
  static String _key(TextFontShard shard) =>
      '${shard.asset.hash}:${shard.family}';
  bool attempted(TextFontShard shard) =>
      _ledger?.attempted(hash: shard.asset.hash, family: shard.family) ??
      _attempted.contains(_key(shard));
  bool canAttempt(TextFontShard shard) =>
      contains(shard) &&
      !attempted(shard) &&
      (_ledger?.canAttempt(
            hash: shard.asset.hash,
            family: shard.family,
            inputBytes: shard.asset.bytes,
          ) ??
          true);
  bool contains(TextFontShard shard) {
    if (_dynamic) return true;
    final known = _assets[_key(shard)];
    return known != null &&
        known.family == shard.family &&
        known.asset.bytes == shard.asset.bytes;
  }

  /// 只有SHA和长度验证成功、即将调用FontLoader时才预留。
  bool beginNativeAttempt(TextFontShard shard) {
    if (!canAttempt(shard)) return false;
    if (_ledger case final ledger?) {
      return ledger.beginNativeAttempt(
        hash: shard.asset.hash,
        family: shard.family,
        inputBytes: shard.asset.bytes,
      );
    }
    _attempted.add(_key(shard));
    _possiblyRetainedInputBytes += shard.asset.bytes;
    return true;
  }

  void completeNativeAttempt(TextFontShard shard) {
    if (!contains(shard) || !attempted(shard)) {
      throw StateError('原生注册未预留');
    }
    _loaded.add(_key(shard));
    _ledger?.completeNativeAttempt(
      hash: shard.asset.hash,
      family: shard.family,
    );
  }

  String? loadedFamily(TextFontShard shard) =>
      contains(shard) &&
          (_ledger?.loaded(hash: shard.asset.hash, family: shard.family) ??
              _loaded.contains(_key(shard)))
      ? shard.family
      : null;
}
