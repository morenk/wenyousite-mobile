import 'dart:typed_data';

/// 仅缓存已播放封面的压缩字节，限制总量；不持有解码帧或发起预取。
class CoverAnimationByteCache {
  CoverAnimationByteCache({this.maximumBytes = 16 * 1024 * 1024});

  final int maximumBytes;
  final _entries = <String, Uint8List>{};
  int _size = 0;

  int get size => _size;

  Uint8List? get(String url) {
    final bytes = _entries.remove(url);
    if (bytes != null) _entries[url] = bytes;
    return bytes;
  }

  void put(String url, Uint8List bytes) {
    final previous = _entries.remove(url);
    if (previous != null) _size -= previous.length;
    if (bytes.length > maximumBytes) return;
    while (_size + bytes.length > maximumBytes && _entries.isNotEmpty) {
      _size -= _entries.remove(_entries.keys.first)!.length;
    }
    _entries[url] = bytes;
    _size += bytes.length;
  }

  void clear() {
    _entries.clear();
    _size = 0;
  }
}
