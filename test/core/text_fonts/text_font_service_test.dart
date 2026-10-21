import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_retry_ledger.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transfer_failure.dart';

import 'font_test_fixture.dart';

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('font-v2-service-');
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test('目录在途离屏后立即出现新正文，取消完成后自动恢复新需求', () async {
    final fixture = FontTestFixture();
    final started = Completer<void>(), loaded = Completer<void>();
    var catalogs = 0;
    final service = TextFontService(
      WenyouApi(basePathOverride: 'https://api.example'),
      cache: MemoryFontCache(directory),
      observePlatform: false,
      register: (_, _) async {
        if (!loaded.isCompleted) loaded.complete();
      },
      fetch: (uri, limit, mime, cancel) async {
        if (uri.path.endsWith('/text-fonts')) {
          catalogs++;
          if (catalogs == 1) {
            started.complete();
            await cancel.whenCancel;
            throw const TextFontTransferFailure(
              TextFontTransferFailureKind.cancelled,
            );
          }
          return fixture.envelope(fixture.catalog());
        }
        if (uri.path.endsWith('runtime-policy')) {
          return fixture.envelope(fixture.policy());
        }
        return fixture.data[uri.pathSegments.last.split('.').first]!;
      },
    );
    addTearDown(service.dispose);
    final first = service.retain('old', {'wenkai': 'A'});
    await started.future;
    service.release('old');
    final second = service.retain('new', {'wenkai': 'B'});
    await first;
    final runtime = await second;
    await loaded.future.timeout(const Duration(seconds: 5));
    await runtime.demandQueue!.settle();
    expect(catalogs, 2);
    expect(runtime.loadedFamilies('wenkai'), ['WYF1-abc-b']);
  });

  test('A仍可见且慢下载时B/C进入正文不取消A或重复占额', () async {
    final fixture = FontTestFixture();
    final started = Completer<void>(), finish = Completer<void>();
    var fontRequests = 0, cancelled = false;
    final service = TextFontService(
      WenyouApi(basePathOverride: 'https://api.example'),
      cache: MemoryFontCache(directory),
      observePlatform: false,
      register: (_, _) async {},
      fetch: (uri, limit, mime, cancel) async {
        if (uri.path.endsWith('/text-fonts')) {
          return fixture.envelope(fixture.catalog());
        }
        if (uri.path.endsWith('runtime-policy')) {
          return fixture.envelope(fixture.policy());
        }
        final hash = uri.pathSegments.last.split('.').first;
        if (uri.path.endsWith('.ttf')) fontRequests++;
        if (hash == fixture.a.hash) {
          started.complete();
          await finish.future;
          cancelled = cancel.isCancelled;
        }
        return fixture.data[hash]!;
      },
    );
    addTearDown(service.dispose);
    final runtime = await service.retain('A', {'wenkai': 'A'});
    await started.future;
    await service.retain('B', {'wenkai': 'B'});
    await service.retain('C', {'wenkai': 'AB'});
    finish.complete();
    await runtime.demandQueue!.settle();
    expect(cancelled, isFalse);
    expect(fontRequests, 2);
    expect(runtime.demandQueue!.snapshot.loadedCount, 2);
  });

  for (final failed in ['catalog', 'policy', 'manifest']) {
    test('冷启动$failed暂时失败后原正文自动恢复，无刷新或重开', () async {
      final fixture = FontTestFixture();
      final requests = <String>[], loaded = <String>[];
      final done = Completer<void>();
      var failOnce = true;
      final service = TextFontService(
        WenyouApi(basePathOverride: 'https://api.example'),
        cache: MemoryFontCache(directory),
        observePlatform: false,
        retries: TextFontRetryLedger(random: () => 0),
        register: (family, _) async {
          loaded.add(family);
          if (loaded.length == 2) done.complete();
        },
        fetch: (uri, limit, mime, cancel) async {
          final kind = uri.path.endsWith('runtime-policy')
              ? 'policy'
              : uri.path.endsWith('/text-fonts')
              ? 'catalog'
              : uri.path.endsWith('.json')
              ? 'manifest'
              : 'asset';
          requests.add(kind);
          if (kind == 'catalog' || kind == 'policy') expect(limit, 65536);
          if (kind == failed && failOnce) {
            failOnce = false;
            throw const TextFontTransferFailure(
              TextFontTransferFailureKind.temporary,
            );
          }
          return switch (kind) {
            'catalog' => fixture.envelope(fixture.catalog()),
            'policy' => fixture.envelope(fixture.policy()),
            'manifest' => fixture.manifestBytes,
            _ => fixture.data[uri.pathSegments.last.split('.').first]!,
          };
        },
      );
      addTearDown(service.dispose);
      final runtime = await service.retain('body', {'wenkai': 'AB'});
      await done.future.timeout(const Duration(seconds: 5));
      await runtime.demandQueue!.settle();
      expect(requests.where((r) => r == failed).length, 2);
      expect(loaded, ['WYF1-abc-a', 'WYF1-abc-b']);
      expect(runtime.demandQueue!.snapshot.attemptedCount, 2);
      expect(identical(await service.load(), runtime), isTrue);
    });
  }

  test('已知离线冷启动由前台唤醒；事件不缩短Retry-After', () async {
    final fixture = FontTestFixture();
    var now = Duration.zero, requests = 0;
    final service = TextFontService(
      WenyouApi(basePathOverride: 'https://api.example'),
      cache: MemoryFontCache(directory),
      observePlatform: false,
      elapsed: () => now,
      retries: TextFontRetryLedger(random: () => 0.5),
      register: (_, _) async {},
      fetch: (uri, limit, mime, cancel) async {
        requests++;
        if (requests == 1) {
          throw const TextFontTransferFailure(
            TextFontTransferFailureKind.temporary,
            retryAfter: Duration(seconds: 120),
          );
        }
        if (uri.path.endsWith('/text-fonts')) {
          return fixture.envelope(fixture.catalog());
        }
        if (uri.path.endsWith('runtime-policy')) {
          return fixture.envelope(fixture.policy());
        }
        return fixture.data[uri.pathSegments.last.split('.').first]!;
      },
    );
    addTearDown(service.dispose);
    service.setOnline(false);
    final runtime = await service.retain('body', {'wenkai': 'A'});
    expect(requests, 0);
    expect(runtime.manifest, isNull);
    service.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await service.load();
    expect(requests, 1);
    for (var i = 0; i < 10; i++) {
      service.setOnline(true);
      await service.load();
    }
    expect(requests, 1);
    now = const Duration(seconds: 120);
    service.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await service.load();
    await runtime.demandQueue!.settle();
    expect(runtime.loadedFamilies('wenkai'), ['WYF1-abc-a']);
  });

  test('目录/策略同窗64KiB预占；窗口不足停留排队，到期重新准入', () async {
    final fixture = FontTestFixture();
    var now = Duration.zero, requests = 0;
    final service = TextFontService(
      WenyouApi(basePathOverride: 'https://api.example'),
      cache: MemoryFontCache(directory),
      observePlatform: false,
      elapsed: () => now,
      register: (_, _) async {},
      fetch: (uri, limit, mime, cancel) async {
        requests++;
        if (uri.path.endsWith('/text-fonts')) {
          return fixture.envelope(fixture.catalog());
        }
        if (uri.path.endsWith('runtime-policy')) {
          return fixture.envelope(fixture.policy());
        }
        return fixture.data[uri.pathSegments.last.split('.').first]!;
      },
    );
    addTearDown(service.dispose);
    expect(service.window.reserve(24 * 1024 * 1024 - 65535, now), isTrue);
    final runtime = await service.retain('body', {'wenkai': 'A'});
    expect(requests, 0);
    now = const Duration(seconds: 60);
    await service.load();
    await runtime.demandQueue!.settle();
    expect(requests, 5); // catalog、manifest、policy、notice、font
    expect(
      service.window.reserve(
        24 * 1024 * 1024 - 2 * 65536 - fixture.manifestBytes.length - 4,
        now,
      ),
      isTrue,
    );
    expect(service.window.reserve(1, now), isFalse);
  });

  test('缓存与目录指针不可写仍注册；同进程撤回立即回退，迟到结果不复活', () async {
    final fixture = FontTestFixture();
    final cache = MemoryFontCache(directory)..broken = true;
    var withdrawn = false, fonts = 0;
    await Directory('${directory.path}/catalog.json').create(); // 文件位置被目录占用
    final service = TextFontService(
      WenyouApi(basePathOverride: 'https://api.example'),
      cache: cache,
      observePlatform: false,
      register: (_, _) async {},
      fetch: (uri, limit, mime, cancel) async {
        if (uri.path.endsWith('/text-fonts')) {
          return fixture.envelope(fixture.catalog(withdrawn: withdrawn));
        }
        if (uri.path.endsWith('runtime-policy')) {
          return fixture.envelope(fixture.policy());
        }
        if (uri.path.endsWith('.ttf')) fonts++;
        return fixture.data[uri.pathSegments.last.split('.').first]!;
      },
    );
    addTearDown(service.dispose);
    final runtime = await service.retain('body', {'wenkai': 'A'});
    await runtime.demandQueue!.settle();
    expect(runtime.loadedFamilies('wenkai'), ['WYF1-abc-a']);
    expect(fonts, 1);
    await service.load();
    await runtime.demandQueue!.settle();
    expect(fonts, 1);
    withdrawn = true;
    await service.retry();
    expect(runtime.loadedFamilies('wenkai'), isEmpty);
    expect(runtime.manifest, isNull);
    await service.load();
    expect(fonts, 1);
  });

  test('超大元数据保持回退，不把失败当无限额度', () async {
    final fixture = FontTestFixture();
    var requests = 0;
    final service = TextFontService(
      WenyouApi(basePathOverride: 'https://api.example'),
      cache: MemoryFontCache(directory),
      observePlatform: false,
      fetch: (uri, limit, mime, cancel) async {
        requests++;
        return Uint8List(65537);
      },
    );
    addTearDown(service.dispose);
    final runtime = await service.retain('body', {'wenkai': 'A'});
    expect(runtime.manifest, isNull);
    expect(requests, 1);
    service.setOnline(true);
    await service.load();
    expect(requests, 1);
    expect(fixture.manifest.fonts.length, 1);
  });
}
