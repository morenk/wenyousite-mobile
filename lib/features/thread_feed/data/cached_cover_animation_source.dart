import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_animation_source_ports.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cover_animation_byte_cache.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cover_animation_disk_store.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cover_animation_http_policy.dart';

class CoverAnimationLoadException implements Exception {
  const CoverAnimationLoadException();
  @override
  String toString() => 'Cover animation could not be loaded';
}

class CachedCoverAnimationSource implements CoverAnimationSource {
  CachedCoverAnimationSource({
    required this.disk,
    DateTime Function()? now,
    Dio Function()? createDio,
  }) : now = now ?? DateTime.now,
       _createDio = createDio ?? (() => Dio()),
       _memory = CoverAnimationByteCache(now: now);

  final CoverAnimationDiskStore disk;
  final DateTime Function() now;
  final Dio Function() _createDio;
  final CoverAnimationByteCache _memory;
  final _inflight = <String, _CoverDownload>{};
  String _owner = _digest('guest');
  int _generation = 0;
  bool _disposed = false;
  bool diskAvailable = true;

  static String _digest(String value) =>
      sha256.convert(utf8.encode(value)).toString();

  @override
  Future<CoverAnimationData> load(String url, CancelToken cancel) async {
    if (_disposed || cancel.isCancelled) {
      throw const CoverAnimationLoadException();
    }
    final key = _digest(url);
    final flight = _inflight.putIfAbsent(key, _CoverDownload.new);
    flight.readers++;
    flight.result ??= _load(url, key, flight.cancel, _generation, _owner)
        .whenComplete(() {
          flight.finished = true;
          if (identical(_inflight[key], flight)) _inflight.remove(key);
        });
    try {
      return await Future.any([
        flight.result!,
        cancel.whenCancel.then<CoverAnimationData>(
          (_) => throw const CoverAnimationLoadException(),
        ),
      ]);
    } finally {
      flight.readers--;
      if (flight.readers == 0 && !flight.finished) {
        if (identical(_inflight[key], flight)) _inflight.remove(key);
        flight.cancel.cancel('cover selection ended');
      }
    }
  }

  bool _current(int generation, CancelToken cancel) =>
      !_disposed && generation == _generation && !cancel.isCancelled;

  Future<CoverAnimationData> _load(
    String url,
    String key,
    CancelToken cancel,
    int generation,
    String owner,
  ) async {
    try {
      final memory = _memory.get(key);
      if (memory != null) {
        if (diskAvailable) {
          try {
            await disk.touch(key);
          } on Exception {
            diskAvailable = false;
          }
        }
        if (!_current(generation, cancel)) {
          throw const CoverAnimationLoadException();
        }
        return CoverAnimationData(memory, fromCache: true);
      }
      CoverDiskEntry? saved;
      if (diskAvailable) {
        try {
          saved = await disk.read(owner, key);
        } on Exception {
          // 缓存目录不可写/被系统清理只关闭本次磁盘缓存，网络加载继续。
          diskAvailable = false;
        }
      }
      if (!_current(generation, cancel)) {
        throw const CoverAnimationLoadException();
      }
      if (saved != null) {
        _memory.put(key, saved.bytes, expires: saved.expires);
        return CoverAnimationData(saved.bytes, fromCache: true);
      }
      final dio = _createDio();
      dio.options.connectTimeout = const Duration(seconds: 15);
      try {
        final started = now();
        final response = await dio.get<List<int>>(
          url,
          cancelToken: cancel,
          options: Options(
            responseType: ResponseType.bytes,
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 15),
            headers: {'X-Request-ID': const Uuid().v4()},
            validateStatus: (status) => status == 200,
          ),
          onReceiveProgress: (count, total) {
            if (count > 32 * 1024 * 1024 || total > 32 * 1024 * 1024) {
              cancel.cancel('cover size limit');
            }
          },
        );
        if (!_current(generation, cancel)) {
          throw const CoverAnimationLoadException();
        }
        final bytes = Uint8List.fromList(response.data!);
        if (bytes.isEmpty || bytes.length > 32 * 1024 * 1024) {
          throw const CoverAnimationLoadException();
        }
        final expires = coverAnimationFreshUntil(
          Uri.parse(url),
          response.realUri,
          response.headers,
          started,
          now(),
        );
        if (expires != null) {
          if (diskAvailable) {
            try {
              await disk.put(
                owner,
                key,
                bytes,
                expires,
                () => _current(generation, cancel),
              );
            } on Exception {
              diskAvailable = false;
            }
          }
          if (_current(generation, cancel)) {
            _memory.put(key, bytes, expires: expires);
          }
        }
        if (!_current(generation, cancel)) {
          throw const CoverAnimationLoadException();
        }
        return CoverAnimationData(bytes);
      } finally {
        dio.close(force: true);
      }
    } on Exception {
      // Dio 异常包含完整请求地址；此端口只暴露不带签名/账号内容的失败。
      throw const CoverAnimationLoadException();
    }
  }

  @override
  Future<void> invalidate(String url) async {
    final key = _digest(url);
    _memory.remove(key);
    if (diskAvailable) {
      try {
        await disk.remove(key);
      } on Exception {
        diskAvailable = false;
      }
    }
  }

  @override
  void changeViewer(String? accountId, {required bool purge}) {
    _cancelAll();
    _owner = _digest(accountId == null ? 'guest' : 'account:$accountId');
    if (purge) {
      unawaited(
        disk.clear().catchError((Object _) {
          diskAvailable = false;
        }),
      );
    }
  }

  void _cancelAll() {
    _generation++;
    for (final flight in _inflight.values) {
      flight.cancel.cancel('cover viewer changed');
    }
    _inflight.clear();
    _memory.clear();
  }

  @override
  void releaseMemory() => _memory.clear();

  @override
  void dispose() {
    _disposed = true;
    _cancelAll();
  }
}

class _CoverDownload {
  final cancel = CancelToken();
  Future<CoverAnimationData>? result;
  int readers = 0;
  bool finished = false;
}
