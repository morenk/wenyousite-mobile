import 'dart:io';
import 'dart:typed_data';

import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';

/// 只存哈希对象；每次读取重新验证，不将损坏字体交给原生引擎。
class TextFontCache {
  TextFontCache(this.directory, {this.maximumBytes = 64 * 1024 * 1024});
  final Directory directory;
  final int maximumBytes;
  final pinned = <String>{};

  File _file(TextFontAsset asset) => File('${directory.path}/${asset.hash}');

  Future<Uint8List?> read(TextFontAsset asset) async {
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
    await file.setLastModified(DateTime.now());
    return bytes;
  }

  Future<void> write(TextFontAsset asset, Uint8List data) async {
    if (!asset.verifies(data)) throw const FormatException('字体资源校验失败');
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
