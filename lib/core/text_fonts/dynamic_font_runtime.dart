import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/text_fonts/dynamic_font_catalog.dart';
import 'package:wenyousite_mobile/core/text_fonts/dynamic_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/dynamic_font_policy.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_download_window.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_legacy_mapping.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transport.dart';

typedef DynamicFontRead =
    Future<TextFontResponse?> Function(
      String path,
      int bytes,
      String mime, {
      String? etag,
    });

/// 与旧加载器共享 runtime/cache/window/ledger，单版本清单有独立驻留边界。
class DynamicFontRuntime {
  DynamicFontRuntime({
    required this.runtime,
    required this.window,
    required this.read,
    required this.elapsed,
    required this.cancel,
    this.retryLater,
  }) {
    catalog = DynamicFontCatalog(
      read: (path, {etag}) => read(path, 65536, 'application/json', etag: etag),
      elapsed: elapsed,
      directory: runtime.cache.directory,
      changed: rebuild,
    );
  }
  final TextFontRuntime runtime;
  final TextFontDownloadWindow window;
  final DynamicFontRead read;
  final Duration Function() elapsed;
  final void Function(TextFontAsset) cancel;
  final void Function()? retryLater;
  late final DynamicFontCatalog catalog;
  final _manifests =
      <String, ({String hash, int bytes, DynamicFontManifest value})>{};
  bool _policyReady = false, _restoredPolicy = false;
  Duration _policyDue = Duration.zero;
  static const maximumManifestBytes = 16 * 1024 * 1024;
  static const maximumManifests = 32;

  Future<void> refresh(Iterable<String> needed, {bool force = false}) async {
    await catalog.restore();
    try {
      await _policy(force: force);
    } on Object {
      retryLater?.call();
    }
    if (!_policyReady) return;
    runtime.enableDynamic(window, elapsed, cancel);
    await runtime.demandQueue?.pauseForMetadata();
    try {
      await catalog.refresh(force: force);
    } on Object {
      retryLater?.call();
    }
    final ids = needed
        .map(dynamicTextFontVersion)
        .nonNulls
        .toSet()
        .take(maximumManifests)
        .toSet();
    for (final id in ids) {
      try {
        await catalog.ensureVersion(id, force: force);
        final descriptor = catalog.descriptor(id);
        if (descriptor == null || !descriptor.renderAllowed) {
          if (!catalog.withdrawn(id)) retryLater?.call();
          continue;
        }
        final asset = dynamicFontAsset(
          id,
          descriptor.assetBasePath!,
          descriptor.manifest!,
          formats: {'json'},
          maximumBytes: 4 * 1024 * 1024,
        );
        if (_manifests[id]?.hash == asset.hash) continue;
        Uint8List? bytes = await runtime.cache.read(asset);
        if (bytes == null) {
          final response = await read(
            asset.path,
            asset.bytes,
            'application/json',
          );
          if (response?.status == 410) {
            catalog.markWithdrawn(id);
            await catalog.persist();
            continue;
          }
          if (response?.status != 200) {
            retryLater?.call();
            continue;
          }
          bytes = response!.bytes;
        }
        if (!catalog.canRender(id)) continue;
        final parsed = DynamicFontManifest(bytes, descriptor);
        await runtime.cache.write(asset, bytes);
        _manifests.remove(id);
        while (_manifests.isNotEmpty &&
            (_manifests.length >= maximumManifests ||
                _manifests.values.fold(0, (sum, entry) => sum + entry.bytes) +
                        bytes.length >
                    maximumManifestBytes)) {
          _manifests.remove(_manifests.keys.first);
        }
        _manifests[id] = (hash: asset.hash, bytes: bytes.length, value: parsed);
      } on Object {
        retryLater?.call();
      }
    }
    rebuild();
    runtime.demandQueue?.resumeAfterMetadata();
  }

  void rebuild() {
    _manifests.removeWhere((id, _) => catalog.withdrawn(id));
    runtime.updateManifest(
      TextFontManifest.combined({
        for (final entry in _manifests.entries)
          if (catalog.canRender(entry.key)) entry.key: entry.value.value.family,
        for (final entry in legacyTextFontVersions.entries)
          if (catalog.canRender(entry.value) &&
              _manifests.containsKey(entry.value))
            entry.key: _manifests[entry.value]!.value.family,
      }),
    );
  }

  Future<Uint8List?> specimen(FontCatalogEntryDto entry) async {
    if (catalog.withdrawn(entry.versionId) ||
        !catalog.entries.any((e) => e.versionId == entry.versionId)) {
      return null;
    }
    final asset = dynamicFontAsset(
      entry.versionId,
      entry.assetBasePath,
      entry.specimen,
      formats: {'png'},
      maximumBytes: 4 * 1024 * 1024,
    );
    final cached = await runtime.cache.read(asset);
    if (cached != null) return cached;
    final response = await read(asset.path, asset.bytes, 'image/png');
    if (response?.status == 410) {
      catalog.markWithdrawn(entry.versionId);
      await catalog.persist();
      return null;
    }
    if (response?.status != 200 || catalog.withdrawn(entry.versionId)) {
      return null;
    }
    if (!asset.verifies(response!.bytes)) {
      throw const FormatException('字体样张校验失败');
    }
    await runtime.cache.write(asset, response.bytes);
    return response.bytes;
  }

  bool allowsAsset(TextFontAsset asset) {
    final parts = asset.path.split('/');
    return parts.length == 10 && catalog.canRender(parts[7]);
  }

  void assetWithdrawn(TextFontAsset asset) {
    final parts = asset.path.split('/');
    if (parts.length == 10) catalog.markWithdrawn(parts[7]);
  }

  Future<void> _policy({required bool force}) async {
    final file = File('${runtime.cache.directory.path}/dynamic-policy.json');
    if (!_restoredPolicy) {
      _restoredPolicy = true;
      try {
        if (await file.exists() && await file.length() <= 65536) {
          _applyPolicy(
            jsonDecode(await file.readAsString()) as Map<String, dynamic>,
          );
        }
      } on Object {
        /* 损坏策略不能启用动态注册。 */
      }
    }
    if (!force && elapsed() < _policyDue) return;
    final response = await read(
      '/api/v1/meta/text-fonts/v2/runtime-policy',
      65536,
      'application/json',
    );
    if (response?.status != 200) return;
    final envelope =
        jsonDecode(utf8.decode(response!.bytes)) as Map<String, dynamic>;
    if (envelope['code'] != 0) throw const FormatException('字体策略加载失败');
    final data = envelope['data'] as Map<String, dynamic>;
    _applyPolicy(data);
    _policyDue = elapsed() + const Duration(minutes: 5);
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(data), flush: true);
    } on FileSystemException {
      /* 已验证策略继续生效。 */
    }
  }

  void _applyPolicy(Map<String, dynamic> value) {
    final policy = DynamicFontPolicy(value);
    runtime.ledger.tighten(
      maximumInputBytes: policy.maximumInputBytes,
      maximumKeys: policy.maximumKeys,
    );
    window.tighten(
      bytes: policy.maximumNetworkBytes,
      requests: policy.maximumRequests,
    );
    runtime.cache.tighten(policy.maximumDiskBytes);
    _policyReady = true;
  }
}
