import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cached_cover_animation_source.dart';
import 'package:wenyousite_mobile/features/thread_feed/data/cover_animation_disk_store.dart';

void main() {
  late Directory directory;
  late HttpServer server;
  late DateTime clock;
  late CachedCoverAnimationSource source;
  final sources = <CachedCoverAnimationSource>[];
  var requests = 0;
  var control = '';
  var status = 200;
  var oversized = false;
  Completer<void>? responseGate;
  Completer<void>? started;
  final payload = File(
    'test/fixtures/cover-animation/hello_loop_2.webp',
  ).readAsBytesSync();

  CachedCoverAnimationSource create({int entries = 128, int? bytes}) {
    final result = CachedCoverAnimationSource(
      now: () => clock,
      disk: CoverAnimationDiskStore(
        directory: () async => directory,
        maximumEntries: entries,
        maximumBytes: bytes ?? 128 * 1024 * 1024,
        now: () => clock,
      ),
    );
    sources.add(result);
    addTearDown(result.dispose);
    return result;
  }

  String address([String resource = 'v1.webp']) =>
      'http://127.0.0.1:${server.port}/$resource';
  Future<int> fileCount() async {
    for (final current in sources) {
      await current.disk.flush();
    }
    return (await directory
            .list()
            .where((item) => item.path.endsWith('.bin'))
            .toList())
        .length;
  }

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('wenyou-cover-cache-');
    sources.clear();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    clock = DateTime.utc(2026, 9, 9);
    requests = 0;
    status = 200;
    oversized = false;
    control = 'public, max-age=60';
    responseGate = null;
    started = null;
    server.listen((request) async {
      requests++;
      expect(request.headers.value('authorization'), isNull);
      expect(request.headers.value('cookie'), isNull);
      expect(
        request.headers.value('x-request-id'),
        matches(RegExp(r'^[a-f0-9-]{36}$')),
      );
      if (request.uri.path == '/redirect.webp') {
        request.response.statusCode = 302;
        request.response.headers.set('location', '/v1.webp?signature=secret');
        await request.response.close();
        return;
      }
      request.response.statusCode = status;
      request.response.headers.set('cache-control', control);
      request.response.headers.set('date', HttpDate.format(clock));
      request.response.headers.set('content-type', 'image/webp');
      if (oversized) request.response.contentLength = 33 * 1024 * 1024;
      final gate = responseGate;
      final arrival = started;
      if (arrival != null && !arrival.isCompleted) arrival.complete();
      if (gate != null) await gate.future;
      try {
        request.response.add(payload);
        await request.response.close();
      } on SocketException {
        // 取消请求后，真实本地服务端可能观察到连接关闭。
      } on HttpException {
        // 同上，客户端已撤销，不把迟到响应作为测试失败。
      }
    });
    addTearDown(() async {
      if (responseGate != null && !responseGate!.isCompleted) {
        responseGate!.complete();
      }
      await server.close(force: true);
      for (final current in sources) {
        await current.disk.flush();
      }
      await directory.delete(recursive: true);
    });
    source = create();
  });

  test('真实HTTP只下载选中项，内存/磁盘及重建来源复用完整WebP', () async {
    expect(requests, 0);
    expect((await source.load(address(), CancelToken())).bytes, payload);
    expect((await source.load(address(), CancelToken())).fromCache, isTrue);
    source.releaseMemory();
    expect((await source.load(address(), CancelToken())).fromCache, isTrue);
    final reopened = create();
    expect((await reopened.load(address(), CancelToken())).fromCache, isTrue);
    expect(requests, 1);
    expect(await fileCount(), 1);
    expect(
      await File('${directory.path}/index.json').readAsString(),
      isNot(contains(address())),
    );
  });

  test('已登录用户冷启动恢复同账号后命中持久缓存', () async {
    source.changeViewer('restored-user', purge: false);
    await source.load(address(), CancelToken());
    await source.disk.flush();
    source.dispose();
    final restarted = create();
    // 实际 StartupGate 会先完成会话恢复，再首次实例化并激活来源。
    restarted.changeViewer('restored-user', purge: false);
    expect((await restarted.load(address(), CancelToken())).fromCache, isTrue);
    expect(requests, 1);
  });

  test('损坏索引与路径穿越键不能读取或删除专用目录之外文件', () async {
    await source.load(address(), CancelToken());
    await source.disk.flush();
    final outside = File(
      '${directory.parent.path}/${directory.uri.pathSegments.where((part) => part.isNotEmpty).last}-outside.bin',
    );
    await outside.writeAsString('keep');
    addTearDown(outside.delete);
    final indexFile = File('${directory.path}/index.json');
    final index =
        jsonDecode(await indexFile.readAsString()) as Map<String, dynamic>;
    final entries = index['entries'] as Map<String, dynamic>;
    entries['../${outside.uri.pathSegments.last}'] = entries.values.first;
    entries[(List.filled(64, 'a')).join()] = {
      'size': 9999999999,
      'expires': 99999999999999999,
      'used': 0,
      'digest': 'invalid',
    };
    await indexFile.writeAsString(jsonEncode(index));
    final reopened = create();
    expect((await reopened.load(address(), CancelToken())).fromCache, isTrue);
    expect(await outside.readAsString(), 'keep');
    final cleaned =
        jsonDecode(await indexFile.readAsString()) as Map<String, dynamic>;
    expect((cleaned['entries'] as Map).length, 1);
    await indexFile.writeAsString('{broken');
    final broken = create();
    expect((await broken.load(address(), CancelToken())).fromCache, isFalse);
    expect(requests, 2);
    expect(await outside.readAsString(), 'keep');
  });

  for (final policy in [
    'public, no-store, max-age=60',
    'private, max-age=60',
    'public, no-cache, max-age=60',
    'public',
  ]) {
    test('真实HTTP $policy 不进入内存或磁盘缓存', () async {
      control = policy;
      await source.load(address(), CancelToken());
      await source.load(address(), CancelToken());
      expect(requests, 2);
      expect(await fileCount(), 0);
    });
  }

  test('签名query不缓存且异常文本不会暴露完整URL', () async {
    final signed = address('v1.webp?signature=private-value');
    await source.load(signed, CancelToken());
    await source.load(signed, CancelToken());
    expect(requests, 2);
    expect(await fileCount(), 0);
    status = 403;
    try {
      await source.load(signed, CancelToken());
      fail('Expected HTTP failure');
    } on CoverAnimationLoadException catch (error) {
      expect(error.toString(), isNot(contains('private-value')));
      expect(error.toString(), isNot(contains('http')));
    }
  });

  test('重定向到签名地址不进入缓存，超大或截断下载不能落盘', () async {
    await source.load(address('redirect.webp'), CancelToken());
    await source.load(address('redirect.webp'), CancelToken());
    expect(requests, 4);
    expect(await fileCount(), 0);
    oversized = true;
    await expectLater(
      source.load(address('oversized.webp'), CancelToken()),
      throwsA(isA<CoverAnimationLoadException>()),
    );
    expect(await fileCount(), 0);
  });

  test('过期与资源版本变化重新取新，网络失败不回退旧文件', () async {
    await source.load(address(), CancelToken());
    clock = clock.add(const Duration(seconds: 61));
    status = 503;
    await expectLater(
      source.load(address(), CancelToken()),
      throwsA(isA<CoverAnimationLoadException>()),
    );
    expect(await fileCount(), 0);
    status = 200;
    expect(
      (await source.load(address('v2.webp'), CancelToken())).fromCache,
      isFalse,
    );
    expect(requests, 3);
  });

  test('容量与条目双上限按最近访问淘汰，过期读清理磁盘', () async {
    source = create(entries: 2, bytes: payload.length * 2);
    await source.load(address('a.webp'), CancelToken());
    await source.disk.flush();
    clock = clock.add(const Duration(seconds: 1));
    await source.load(address('b.webp'), CancelToken());
    await source.disk.flush();
    clock = clock.add(const Duration(seconds: 1));
    source.releaseMemory();
    await source.load(address('a.webp'), CancelToken());
    await source.disk.flush();
    clock = clock.add(const Duration(seconds: 1));
    await source.load(address('c.webp'), CancelToken());
    expect(await fileCount(), 2);
    source.releaseMemory();
    expect(
      (await source.load(address('b.webp'), CancelToken())).fromCache,
      isFalse,
    );
    expect(requests, 4);
    await source.disk.flush();
    final index =
        jsonDecode(await File('${directory.path}/index.json').readAsString())
            as Map<String, dynamic>;
    final entries = (index['entries'] as Map<String, dynamic>).values;
    expect(
      entries.fold<int>(0, (sum, entry) => sum + (entry['size'] as int)),
      lessThanOrEqualTo(payload.length * 2),
    );
    clock = clock.add(const Duration(minutes: 2));
    source.releaseMemory();
    await source.load(address('new.webp'), CancelToken());
    expect(await fileCount(), 1);
  });

  test('被改坏的缓存hash不命中，单次网络重取并清除崩溃残留', () async {
    await source.load(address(), CancelToken());
    await source.disk.flush();
    final file =
        (await directory
                    .list()
                    .where((item) => item.path.endsWith('.bin'))
                    .toList())
                .single
            as File;
    final damaged = payload.toList()..[0] = 0;
    await file.writeAsBytes(damaged);
    await File('${directory.path}/orphan.part').writeAsString('unfinished');
    final reopened = create();
    expect((await reopened.load(address(), CancelToken())).bytes, payload);
    expect(requests, 2);
    expect(await File('${directory.path}/orphan.part').exists(), isFalse);
    expect(await fileCount(), 1);
  });

  test('同URL并发去重，一个订阅取消不取消仍被选中的请求', () async {
    responseGate = Completer();
    started = Completer();
    final firstCancel = CancelToken();
    final first = source.load(address(), firstCancel);
    final firstFailure = expectLater(
      first,
      throwsA(isA<CoverAnimationLoadException>()),
    );
    final second = source.load(address(), CancelToken());
    await started!.future;
    firstCancel.cancel();
    await firstFailure;
    responseGate!.complete();
    expect((await second).bytes, payload);
    expect(requests, 1);
    expect(await fileCount(), 1);
  });

  test('全部取消的迟到响应不落盘，下一次选择可重新下载', () async {
    responseGate = Completer();
    started = Completer();
    final cancel = CancelToken();
    final request = source.load(address(), cancel);
    final failure = expectLater(
      request,
      throwsA(isA<CoverAnimationLoadException>()),
    );
    await started!.future;
    cancel.cancel();
    await failure;
    responseGate!.complete();
    responseGate = null;
    await source.load(address(), CancelToken());
    expect(requests, 2);
    expect(await fileCount(), 1);
  });

  test('退出/账号切换清除旧缓存并取消在途，持久owner禁止跨账号复用', () async {
    source.changeViewer('account-a', purge: false);
    await source.load(address(), CancelToken());
    responseGate = Completer();
    started = Completer();
    final oldRequest = source.load(address('late.webp'), CancelToken());
    final failed = expectLater(
      oldRequest,
      throwsA(isA<CoverAnimationLoadException>()),
    );
    await started!.future;
    source.changeViewer('account-b', purge: true);
    responseGate!.complete();
    responseGate = null;
    await failed;
    expect((await source.load(address(), CancelToken())).fromCache, isFalse);
    expect(requests, 3);
    // 播放不等待落盘；模拟重新打开前先结束旧实例的持久化。
    await source.disk.flush();
    final reopened = create()..changeViewer('account-c', purge: false);
    expect((await reopened.load(address(), CancelToken())).fromCache, isFalse);
    await reopened.disk.flush();
    final index = await File('${directory.path}/index.json').readAsString();
    expect(index, isNot(contains('account-')));
    expect(await fileCount(), 1);
  });

  test('磁盘不可用仍可在线播放，但不伪装持久化成功', () async {
    final blocked = File('${directory.path}/not-a-directory');
    await blocked.writeAsString('blocked');
    final unavailable = CachedCoverAnimationSource(
      disk: CoverAnimationDiskStore(
        directory: () async => Directory(blocked.path),
      ),
    );
    addTearDown(unavailable.dispose);
    expect((await unavailable.load(address(), CancelToken())).bytes, payload);
    expect(unavailable.diskAvailable, isFalse);
  });
}
