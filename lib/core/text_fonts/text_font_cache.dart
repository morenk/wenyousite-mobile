import 'dart:io';
import 'dart:typed_data';

import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';

/// 只存哈希对象；每次读取重新验证，不将损坏字体交给原生引擎。
class TextFontCache {
  TextFontCache(this.directory, {this.maximumBytes = 64 * 1024 * 1024});
  final Directory directory;
  int maximumBytes;
  void tighten(int bytes) {
    if (bytes < 1) throw ArgumentError('缓存上限必须为正数');
    if (bytes < maximumBytes) maximumBytes = bytes;
  }

  final pinned = <String>{};

  File _file(TextFontAsset asset) => File('${directory.path}/${asset.hash}');

  Future<Uint8List?> read(TextFontAsset asset) async {
    try {
      return await _read(asset);
    } on FileSystemException {
      // 缓存不决定资源可用性；读失败按miss，由下载层验证正式字节。
      return null;
    }
  }

  Future<Uint8List?> _read(TextFontAsset asset) async {
    final file = _file(asset);
    if (!await file.exists()) return null;
    if (await file.length() != asset.bytes) {
      await file.delete();
      return null;
    }
    final bytes = await file.readAsBytes();
    if (!asset.verifies(bytes)) {
      await file.delete();
      return null;
    }
    try {
      await file.setLastModified(DateTime.now());
    } on FileSystemException {
      // LRU时间维护失败不能丢弃已经完成完整性校验的缓存输入。
    }
    return bytes;
  }

  Future<void> write(TextFontAsset asset, Uint8List data) async {
    if (!asset.verifies(data)) throw const FormatException('字体资源校验失败');
    try {
      await _write(asset, data);
    } on FileSystemException {
      // 磁盘满/权限故障不使已验证输入失效，也不触发网络重试。
    }
  }

  Future<void> _write(TextFontAsset asset, Uint8List data) async {
    await directory.create(recursive: true);
    final files = <({File file, FileStat stat})>[];
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is File &&
          RegExp(
            r'^[a-f0-9]{64}\.partial$',
          ).hasMatch(entity.uri.pathSegments.last)) {
        await entity.delete();
        continue;
      }
      if (entity is File &&
          RegExp(r'^[a-f0-9]{64}$').hasMatch(entity.uri.pathSegments.last)) {
        files.add((file: entity, stat: await entity.stat()));
      }
    }
    var size = files.fold(0, (n, value) => n + value.stat.size);
    files.sort((a, b) => a.stat.modified.compareTo(b.stat.modified));
    for (final item in files) {
      if (size + data.length <= maximumBytes) break;
      if (pinned.contains(item.file.uri.pathSegments.last)) continue;
      await item.file.delete();
      size -= item.stat.size;
    }
    if (size + data.length > maximumBytes) return;
    final temporary = File('${_file(asset).path}.partial');
    try {
      await temporary.writeAsBytes(data, flush: true);
      await temporary.rename(_file(asset).path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }
}
