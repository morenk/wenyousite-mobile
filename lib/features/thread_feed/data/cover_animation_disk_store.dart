import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

typedef CoverDiskEntry = ({Uint8List bytes, DateTime expires});

/// 专用缓存目录只保存散列文件名及容量/完整性信息，不保存 URL 或账号明文。
class CoverAnimationDiskStore {
  CoverAnimationDiskStore({
    required this.directory,
    this.maximumBytes = 128 * 1024 * 1024,
    this.maximumEntries = 128,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  final Future<Directory> Function() directory;
  final int maximumBytes;
  final int maximumEntries;
  final DateTime Function() now;
  final _entries = <String, Map<String, Object>>{};
  Future<void> _queue = Future.value();
  Directory? _directory;
  String? _owner;

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  File _file(String name) => File('${_directory!.path}/$name');

  Future<void> _open(String owner) async {
    if (_directory == null) {
      _directory = await directory();
      await _directory!.create(recursive: true);
      try {
        final indexFile = _file('index.json');
        if (await indexFile.length() > 128 * 1024) {
          throw const FormatException('Cover cache index exceeds limit');
        }
        final index = jsonDecode(await indexFile.readAsString());
        if (index is Map<String, dynamic> && index['owner'] == owner) {
          final values = index['entries'];
          if (values is Map<String, dynamic>) {
            for (final entry in values.entries) {
              final value = entry.value;
              if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(entry.key) ||
                  value is! Map<String, dynamic> ||
                  value['size'] is! int ||
                  value['size'] <= 0 ||
                  value['size'] > 32 * 1024 * 1024 ||
                  value['expires'] is! int ||
                  value['expires'] >
                      now()
                          .add(const Duration(days: 7))
                          .millisecondsSinceEpoch ||
                  value['used'] is! int ||
                  value['digest'] is! String) {
                continue;
              }
              _entries[entry.key] = {
                'size': value['size'] as int,
                'expires': value['expires'] as int,
                'used': value['used'] as int,
                'digest': value['digest'] as String,
              };
            }
          }
        }
      } on FileSystemException {
        // 首次启动或系统清除临时缓存，按空缓存继续。
      } on FormatException {
        // 索引损坏时不信任任何文件；下方清理孤立文件。
      }
      _owner = owner;
      await _prune();
      await for (final file in _directory!.list(followLinks: false)) {
        if (file is! File) continue;
        final name = file.uri.pathSegments.last;
        if (name != 'index.json' &&
            !(_entries.containsKey(name.replaceFirst('.bin', '')) &&
                name.endsWith('.bin'))) {
          await file.delete();
        }
      }
      await _saveIndex();
    } else if (_owner != owner) {
      await _clear();
      _owner = owner;
      await _saveIndex();
    }
  }

  Future<CoverDiskEntry?> read(String owner, String key) => _serial(() async {
    await _open(owner);
    await _prune();
    final entry = _entries[key];
    if (entry == null) {
      await _saveIndex();
      return null;
    }
    try {
      final file = _file('$key.bin');
      if (await file.length() != entry['size']) {
        await _remove(key);
        await _saveIndex();
        return null;
      }
      final bytes = await file.readAsBytes();
      if (sha256.convert(bytes).toString() != entry['digest']) {
        await _remove(key);
        await _saveIndex();
        return null;
      }
      entry['used'] = now().millisecondsSinceEpoch;
      await _saveIndex();
      return (
        bytes: bytes,
        expires: DateTime.fromMillisecondsSinceEpoch(entry['expires'] as int),
      );
    } on FileSystemException {
      await _remove(key);
      await _saveIndex();
      return null;
    }
  });

  Future<void> put(
    String owner,
    String key,
    Uint8List bytes,
    DateTime expires,
    bool Function() stillCurrent,
  ) => _serial(() async {
    if (!stillCurrent() || bytes.isEmpty || bytes.length > maximumBytes) return;
    await _open(owner);
    if (!stillCurrent()) return;
    await _remove(key);
    await _prune(reservedBytes: bytes.length, reservedEntries: 1);
    final temporary = _file('$key.part');
    await temporary.writeAsBytes(bytes, flush: true);
    if (!stillCurrent()) {
      await temporary.delete();
      return;
    }
    await temporary.rename(_file('$key.bin').path);
    if (!stillCurrent()) {
      await _file('$key.bin').delete();
      return;
    }
    _entries[key] = {
      'size': bytes.length,
      'expires': expires.millisecondsSinceEpoch,
      'used': now().millisecondsSinceEpoch,
      'digest': sha256.convert(bytes).toString(),
    };
    await _prune();
    await _saveIndex();
  });

  Future<void> remove(String key) => _serial(() async {
    if (_directory == null) return;
    await _remove(key);
    await _saveIndex();
  });

  Future<void> touch(String key) => _serial(() async {
    final entry = _entries[key];
    if (entry == null) return;
    entry['used'] = now().millisecondsSinceEpoch;
    await _saveIndex();
  });

  Future<void> clear() => _serial(_clear);

  /// 等待已排队的持久化完成；播放关键路径不等待此屏障。
  Future<void> flush() => _queue;

  Future<void> _clear() async {
    _directory ??= await directory();
    await _directory!.create(recursive: true);
    _entries.clear();
    await for (final file in _directory!.list(followLinks: false)) {
      if (file is File) await file.delete();
    }
  }

  Future<void> _remove(String key) async {
    _entries.remove(key);
    final file = _file('$key.bin');
    if (await file.exists()) await file.delete();
  }

  Future<void> _prune({int reservedBytes = 0, int reservedEntries = 0}) async {
    for (final key in _entries.keys.toList()) {
      if ((_entries[key]!['expires'] as int) <= now().millisecondsSinceEpoch) {
        await _remove(key);
      }
    }
    int size() =>
        _entries.values.fold(0, (sum, entry) => sum + (entry['size'] as int));
    while (_entries.isNotEmpty &&
        (_entries.length + reservedEntries > maximumEntries ||
            size() + reservedBytes > maximumBytes)) {
      final oldest = _entries.keys.reduce(
        (a, b) => (_entries[a]!['used'] as int) <= (_entries[b]!['used'] as int)
            ? a
            : b,
      );
      await _remove(oldest);
    }
  }

  Future<void> _saveIndex() async {
    final temporary = _file('index.part');
    await temporary.writeAsString(
      jsonEncode({'owner': _owner, 'entries': _entries}),
      flush: true,
    );
    await temporary.rename(_file('index.json').path);
  }
}
