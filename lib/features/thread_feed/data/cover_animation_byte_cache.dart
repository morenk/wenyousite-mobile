import 'dart:typed_data';

/// 仅缓存已播放封面的压缩字节，限制总量；不持有解码帧或发起预取。
class CoverAnimationByteCache {
  CoverAnimationByteCache({
    this.maximumBytes = 16 * 1024 * 1024,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  final int maximumBytes;
  final DateTime Function() now;
  final _entries = <String, ({Uint8List bytes, DateTime? expires})>{};
  int _size = 0;

  int get size => _size;

  Uint8List? get(String url) {
    final entry = _entries.remove(url);
    if (entry == null) return null;
    if (entry.expires != null && !now().isBefore(entry.expires!)) {
      _size -= entry.bytes.length;
      return null;
    }
    _entries[url] = entry;
    return entry.bytes;
  }

  void put(String url, Uint8List bytes, {DateTime? expires}) {
    final previous = _entries.remove(url);
    if (previous != null) _size -= previous.bytes.length;
    if (bytes.length > maximumBytes) return;
    while (_size + bytes.length > maximumBytes && _entries.isNotEmpty) {
      _size -= _entries.remove(_entries.keys.first)!.bytes.length;
    }
    _entries[url] = (bytes: bytes, expires: expires);
    _size += bytes.length;
  }

  void remove(String key) {
    final entry = _entries.remove(key);
    if (entry != null) _size -= entry.bytes.length;
  }

  void clear() {
    _entries.clear();
    _size = 0;
  }
}
