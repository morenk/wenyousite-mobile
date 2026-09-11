import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cached_cover_animation_source.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cover_animation_disk_store.dart';

class _ImmediateHttp implements HttpClientAdapter {
  _ImmediateHttp(this.bytes);
  final Uint8List bytes;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromBytes(
    bytes,
    200,
    headers: {
      'cache-control': ['public, max-age=60'],
      'content-type': ['image/webp'],
    },
  );
  @override
  void close({bool force = false}) {}
}

class _SlowDisk extends CoverAnimationDiskStore {
  _SlowDisk(Directory folder) : super(directory: () async => folder);
  Completer<void>? holdWrites;
  Completer<void>? holdTouches;
  int writes = 0;
  int touches = 0;
  bool failWrites = false;
  final pending = <Future<void>>[];

  @override
  Future<void> put(
    String owner,
    String key,
    Uint8List bytes,
    DateTime expires,
    bool Function() stillCurrent,
  ) {
    writes++;
    final result = () async {
      await holdWrites?.future;
      if (failWrites) throw const FileSystemException('disk unavailable');
      await super.put(owner, key, bytes, expires, stillCurrent);
    }();
    pending.add(result);
    return result;
  }

  @override
  Future<void> touch(String key) async {
    touches++;
    await holdTouches?.future;
    await super.touch(key);
  }
}

void main() {
  late Directory directory;
  late _SlowDisk disk;
  late CachedCoverAnimationSource source;
  var payload = Uint8List.fromList([1, 2, 3]);
  const url = 'https://cdn.example/a.webp';
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('wenyou-cache-latency-');
    disk = _SlowDisk(directory);
    source = CachedCoverAnimationSource(
      disk: disk,
      createDio: () => Dio()..httpClientAdapter = _ImmediateHttp(payload),
    );
  });
  tearDown(() async {
    source.dispose();
    if (disk.holdWrites?.isCompleted == false) disk.holdWrites!.complete();
    if (disk.holdTouches?.isCompleted == false) disk.holdTouches!.complete();
    await Future.wait(
      disk.pending.map((value) => value.catchError((Object _) {})),
    );
    await disk.flush();
    await directory.delete(recursive: true);
    payload = Uint8List.fromList([1, 2, 3]);
  });

  test('完整网络字节立即返回，慢写盘不占用起播关键路径', () async {
    disk.holdWrites = Completer();
    final result = await source
        .load(url, CancelToken())
        .timeout(const Duration(seconds: 2));
    expect(result.bytes, payload);
    expect(disk.writes, 1);
    expect(disk.holdWrites!.isCompleted, isFalse);
  });

  test('内存命中不等touch，持续热命中只排一个索引更新', () async {
    await source.load(url, CancelToken());
    await disk.flush();
    disk.holdTouches = Completer();
    for (var i = 0; i < 10; i++) {
      final data = await source
          .load(url, CancelToken())
          .timeout(const Duration(seconds: 2));
      expect(data.fromCache, isTrue);
    }
    expect(disk.touches, 1);
  });

  test('异步持久化失败不影响已就绪字节且关闭磁盘复用', () async {
    disk.holdWrites = Completer();
    disk.failWrites = true;
    final data = await source.load(url, CancelToken());
    expect(data.bytes, payload);
    disk.holdWrites!.complete();
    await Future<void>.delayed(Duration.zero);
    expect(source.diskAvailable, isFalse);
    expect((await source.load(url, CancelToken())).fromCache, isTrue);
  });

  for (final invalidate in [true, false]) {
    test('写盘等待中${invalidate ? '解码失败失效' : '切换账号'}阻止迟到写回', () async {
      disk.holdWrites = Completer();
      await source.load(url, CancelToken());
      if (invalidate) {
        await source.invalidate(url);
      } else {
        source.changeViewer('next', purge: true);
      }
      disk.holdWrites!.complete();
      await Future.wait(disk.pending);
      await disk.flush();
      expect(
        await directory
            .list()
            .where((file) => file.path.endsWith('.bin'))
            .length,
        0,
      );
    });
  }

  test('慢磁盘最多挂起两个写入，其余资源仍及时返回', () async {
    disk.holdWrites = Completer();
    for (var i = 0; i < 8; i++) {
      expect(
        (await source.load('https://cdn.example/$i.webp', CancelToken())).bytes,
        payload,
      );
    }
    expect(disk.writes, 2);
  });

  test('待写字节总量独立限制为32MiB，不随失效后新URL无限累积', () async {
    payload = Uint8List(20 * 1024 * 1024);
    disk.holdWrites = Completer();
    await source.load(url, CancelToken());
    await source.invalidate(url);
    await source.load('https://cdn.example/b.webp', CancelToken());
    expect(disk.writes, 1);
  });
}
