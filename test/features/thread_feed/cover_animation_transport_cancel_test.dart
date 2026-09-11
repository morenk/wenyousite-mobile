import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cached_cover_animation_source.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cover_animation_disk_store.dart';

void main() {
  test('真实慢流HTTP取消最后订阅关闭适配器并停止接收，不写入缓存', () async {
    final directory = await Directory.systemTemp.createTemp(
      'cover-cancel-transport-',
    );
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final disk = CoverAnimationDiskStore(directory: () async => directory);
    final adapter = _ObservedAdapter();
    var received = 0;
    final source = CachedCoverAnimationSource(
      disk: disk,
      createDio: () {
        final dio = Dio()..httpClientAdapter = adapter;
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              final original = options.onReceiveProgress;
              options.onReceiveProgress = (count, total) {
                received = count;
                original?.call(count, total);
              };
              handler.next(options);
            },
          ),
        );
        return dio;
      },
    );
    final firstChunk = Completer<void>();
    final stopped = Completer<void>();
    const totalChunks = 40;
    final chunk = Uint8List(64 * 1024);
    server.listen((request) async {
      request.response.contentLength = totalChunks * chunk.length;
      request.response.headers.set(
        HttpHeaders.cacheControlHeader,
        'public, max-age=86400',
      );
      unawaited(request.response.done.then((_) {}, onError: (Object _) {}));
      try {
        for (var i = 0; i < totalChunks; i++) {
          request.response.add(chunk);
          await request.response.flush();
          if (!firstChunk.isCompleted) firstChunk.complete();
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      } on Object {
        // HttpServer可能仍接受缓冲写入，不用服务端flush判定客户端收流。
      } finally {
        try {
          await request.response.close();
        } on Object {
          // HttpServer可能仍接受缓冲写入，不用服务端flush判定客户端收流。
        }
        stopped.complete();
      }
    });
    try {
      final cancel = CancelToken();
      final loading = source.load(
        'http://127.0.0.1:${server.port}/large.gif',
        cancel,
      );
      final failed = expectLater(
        loading,
        throwsA(isA<CoverAnimationLoadException>()),
      );
      await firstChunk.future;
      await Future<void>.delayed(const Duration(milliseconds: 100));
      cancel.cancel('fully offscreen');
      await failed;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final afterCancel = received;
      expect(afterCancel, greaterThan(0));
      expect(afterCancel, lessThan(totalChunks * chunk.length));
      expect(adapter.forceClosed, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(received, afterCancel, reason: '服务端继续写入期间，客户端取消后不得继续收到数据');
      await stopped.future.timeout(const Duration(seconds: 4));
      await disk.flush();
      expect(
        directory.listSync().whereType<File>().where(
          (file) => file.path.endsWith('.bin'),
        ),
        isEmpty,
      );
    } finally {
      source.dispose();
      await disk.flush();
      await server.close(force: true);
      await directory.delete(recursive: true);
    }
  });
}

class _ObservedAdapter extends IOHttpClientAdapter {
  bool forceClosed = false;
  @override
  void close({bool force = false}) {
    forceClosed = force;
    super.close(force: force);
  }
}
