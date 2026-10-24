import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_demand_queue.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_download_window.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_native_snapshot.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_progress.dart';

import 'font_test_fixture.dart';

void main() {
  test('必需声明文件校验失败立即通知进度终态，不等下一次正文操作', () {
    fakeAsync((time) {
      final f = FontTestFixture(), release = Completer<void>();
      final queue = TextFontDemandQueue(
        cache: MemoryFontCache(),
        download: (asset) async {
          await release.future;
          throw const FormatException('声明文件损坏');
        },
        register: (_, _) async {},
        snapshot: TextFontNativeSnapshot(
          manifest: f.manifest,
          assetCount: 2,
          totalBytes: 6,
        ),
        window: TextFontDownloadWindow(
          period: const Duration(minutes: 1),
          maximumBytes: 24,
          maximumRequests: 64,
        ),
      )..updateSource(f.manifest, downloadable: true);
      final states = <TextFontProgressPhase>[];
      queue.progress.addListener(
        () => states.add(queue.progressFor('wenkai', 'A', {}).phase),
      );
      queue.setDemand('author', {'wenkai': 'A'});
      time.flushMicrotasks();
      release.complete();
      time.flushMicrotasks();
      expect(states.last, TextFontProgressPhase.failed);
      queue.dispose();
    });
  });
  test('分块独立节流、未知总量无百分比、重试重新计数、销毁取消通知', () {
    fakeAsync((time) {
      final f = FontTestFixture(), ledger = TextFontProgressLedger();
      var notifications = 0;
      ledger.addListener(() => notifications++);
      expect(ledger.summarize([f.a], applicable: false).fraction, isNull);
      ledger.start(f.a);
      final initial = notifications;
      ledger.received(f.a, 1);
      ledger.received(f.a, 2);
      expect(notifications, initial);
      time.elapse(const Duration(milliseconds: 100));
      expect(notifications, initial + 1);
      expect(ledger.summarize([f.a], applicable: false).fraction, 2 / 3);
      ledger.received(f.a, 1);
      ledger.received(f.a, 4);
      expect(ledger.summarize([f.a], applicable: false).receivedBytes, 2);
      ledger.waiting(f.a);
      ledger.start(f.a);
      expect(ledger.summarize([f.a], applicable: false).receivedBytes, 0);
      ledger.received(f.a, 1);
      final beforeDispose = notifications;
      ledger.dispose();
      time.elapse(const Duration(seconds: 1));
      expect(notifications, beforeDispose);
    });
  });

  for (final cachedSecond in [false, true]) {
    test('首片下载即有全量分母并扣除缓存 cached=$cachedSecond', () {
      fakeAsync((time) {
        final f = FontTestFixture(), cache = MemoryFontCache();
        if (cachedSecond) cache.values[f.b.hash] = f.data[f.b.hash]!;
        final transfer = Completer<void>(), registration = Completer<void>();
        final queue = TextFontDemandQueue(
          cache: cache,
          download: (asset) async {
            if (asset.hash == f.a.hash) await transfer.future;
            return f.data[asset.hash]!;
          },
          register: (family, _) async {
            if (family.endsWith('-a')) await registration.future;
          },
          snapshot: TextFontNativeSnapshot(
            manifest: f.manifest,
            assetCount: 2,
            totalBytes: 6,
          ),
          window: TextFontDownloadWindow(
            period: const Duration(minutes: 1),
            maximumBytes: 24,
            maximumRequests: 64,
          ),
        )..updateSource(f.manifest, downloadable: true);
        var readyNotifications = 0;
        queue.addListener(() => readyNotifications++);
        queue.setDemand('editor', {'wenkai': 'AB'});
        time.flushMicrotasks();
        final tracked = <String>{};
        final beforeChunks = readyNotifications;
        queue.reportReceived('/${f.a.path}', 1);
        time.elapse(const Duration(milliseconds: 100));
        var status = queue.progressFor('wenkai', 'AB', tracked);
        expect(status.totalBytes, cachedSecond ? 3 : 6);
        expect(status.receivedBytes, 1);
        expect(status.fraction, cachedSecond ? 1 / 3 : 1 / 6);
        expect(readyNotifications, beforeChunks, reason: '字节进度不能广播字体可用性');
        transfer.complete();
        time.flushMicrotasks();
        status = queue.progressFor('wenkai', 'AB', tracked);
        expect(
          status.phase,
          cachedSecond
              ? TextFontProgressPhase.applying
              : TextFontProgressPhase.waiting,
        );
        expect(status.fraction, isNull, reason: '原生注册未完成不能显示100%或失败');
        registration.complete();
        time.flushMicrotasks();
        expect(
          queue.progressFor('wenkai', 'AB', tracked).phase,
          TextFontProgressPhase.complete,
        );
        expect(
          queue.progressFor('wenkai', 'AB', tracked).receivedBytes,
          cachedSecond ? 3 : 6,
        );
        queue.dispose();
      });
    });
  }

  test('纯缓存没有下载标记；原生失败不会永久准备', () async {
    final f = FontTestFixture(),
        cache = MemoryFontCache()..values.addAll(FontTestFixture().data);
    final queue = TextFontDemandQueue(
      cache: cache,
      download: (_) async => throw StateError('缓存不应下载'),
      register: (_, _) async => throw StateError('模拟原生失败'),
      snapshot: TextFontNativeSnapshot(
        manifest: f.manifest,
        assetCount: 2,
        totalBytes: 6,
      ),
      window: TextFontDownloadWindow(
        period: const Duration(minutes: 1),
        maximumBytes: 24,
        maximumRequests: 64,
      ),
    )..updateSource(f.manifest, downloadable: true);
    addTearDown(queue.dispose);
    queue.setDemand('editor', {'wenkai': 'A'});
    await queue.settle();
    expect(queue.requests, 0);
    expect(
      queue.progressFor('wenkai', 'A', {}).phase,
      TextFontProgressPhase.failed,
    );
    expect(queue.progressFor('wenkai', 'A', {}).usedNetwork, isFalse);
  });

  test('独立需求、取消后的迟到字节不能重新显示', () {
    fakeAsync((time) {
      final f = FontTestFixture(), delayed = Completer<void>();
      final queue = TextFontDemandQueue(
        cache: MemoryFontCache(),
        download: (asset) async {
          if (asset.hash == f.a.hash) await delayed.future;
          return f.data[asset.hash]!;
        },
        register: (_, _) async {},
        snapshot: TextFontNativeSnapshot(
          manifest: f.manifest,
          assetCount: 2,
          totalBytes: 6,
        ),
        window: TextFontDownloadWindow(
          period: const Duration(minutes: 1),
          maximumBytes: 24,
          maximumRequests: 64,
        ),
      )..updateSource(f.manifest, downloadable: true);
      queue.setDemand('reader', {'wenkai': 'A'});
      time.flushMicrotasks();
      queue.reportReceived(f.a.path, 2);
      expect(queue.progressFor('wenkai', 'B', {}).receivedBytes, 0);
      queue.release('reader');
      queue.reportReceived(f.a.path, 3);
      expect(queue.progressFor('wenkai', 'A', {}).usedNetwork, isFalse);
      delayed.complete();
      time.flushMicrotasks();
      expect(queue.snapshot.loadedCount, 0);
      queue.dispose();
    });
  });
  test('分片超过单窗口硬上限不会永久准备', () {
    final f = FontTestFixture();
    final queue = TextFontDemandQueue(
      cache: MemoryFontCache(),
      download: (_) async => throw StateError('不可下载'),
      register: (_, _) async {},
      snapshot: TextFontNativeSnapshot(
        manifest: f.manifest,
        assetCount: 2,
        totalBytes: 6,
      ),
      window: TextFontDownloadWindow(
        period: const Duration(minutes: 1),
        maximumBytes: 2,
        maximumRequests: 64,
      ),
    )..updateSource(f.manifest, downloadable: true);
    addTearDown(queue.dispose);
    queue.setDemand('editor', {'wenkai': 'A'});
    expect(
      queue.progressFor('wenkai', 'A', {}).phase,
      TextFontProgressPhase.failed,
    );
    expect(queue.pendingCount, 0);
  });
}
