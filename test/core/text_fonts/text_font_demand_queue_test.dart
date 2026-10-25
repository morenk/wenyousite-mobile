import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_demand_queue.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_download_window.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_native_snapshot.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_retry_ledger.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transfer_failure.dart';

import 'font_test_fixture.dart';

void main() {
  test('同SHA两个family一次下载两次登记，单键原生失败不隔离另一键', () async {
    final f = FontTestFixture(alias: true), cache = MemoryFontCache();
    final fetched = <String>[], registered = <String>[];
    final queue = TextFontDemandQueue(
      cache: cache,
      download: (a) async {
        fetched.add(a.hash);
        return f.data[a.hash]!;
      },
      register: (family, _) async {
        registered.add(family);
        if (family.endsWith('-a')) throw StateError('解码失败');
      },
      snapshot: TextFontNativeSnapshot(
        manifest: f.manifest,
        assetCount: 1,
        totalBytes: 3,
        registrationCount: 2,
        totalRegistrationBytes: 6,
      ),
      window: TextFontDownloadWindow(
        period: const Duration(seconds: 60),
        maximumBytes: 24,
        maximumRequests: 64,
      ),
    )..updateSource(f.manifest, downloadable: true);
    addTearDown(queue.dispose);
    queue.setDemand('body', {'wenkai': 'AB'});
    await queue.settle();
    expect(fetched.where((h) => h == f.a.hash).length, 1);
    expect(registered, ['WYF1-abc-a', 'WYF1-abc-b']);
    expect(queue.snapshot.attemptedCount, 2);
    expect(queue.snapshot.assetCount, 1);
    expect(queue.snapshot.registrationCount, 2);
    expect(queue.snapshot.loadedCount, 1);
    queue.setDemand('body', {'wenkai': 'AB'});
    queue.wake();
    await queue.settle();
    expect(registered.length, 2);
  });

  test('单片429保持Retry-After，其他片继续；窗口与退避自动恢复', () {
    fakeAsync((time) {
      final f = FontTestFixture();
      final attempts = <String, int>{};
      final loaded = <String>[];
      final queue = TextFontDemandQueue(
        cache: MemoryFontCache(),
        elapsed: () => time.elapsed,
        retries: TextFontRetryLedger(random: () => 0.5),
        download: (a) async {
          attempts[a.hash] = (attempts[a.hash] ?? 0) + 1;
          if (a.hash == f.a.hash && attempts[a.hash] == 1) {
            throw const TextFontTransferFailure(
              TextFontTransferFailureKind.temporary,
              retryAfter: Duration(seconds: 120),
            );
          }
          return f.data[a.hash]!;
        },
        register: (family, _) async => loaded.add(family),
        snapshot: TextFontNativeSnapshot(
          manifest: f.manifest,
          assetCount: 2,
          totalBytes: 6,
        ),
        window: TextFontDownloadWindow(
          period: const Duration(seconds: 60),
          maximumBytes: 7,
          maximumRequests: 3,
        ),
      )..updateSource(f.manifest, downloadable: true);
      queue.setDemand('body', {'wenkai': 'AB'});
      time.flushMicrotasks();
      expect(loaded, ['WYF1-abc-b']);
      for (var i = 0; i < 10; i++) {
        queue.setOnline(true);
        queue.setForeground(true);
      }
      time.elapse(const Duration(seconds: 119));
      expect(attempts[f.a.hash], 1);
      time.elapse(const Duration(seconds: 1));
      expect(attempts[f.a.hash], 2);
      expect(loaded, ['WYF1-abc-b', 'WYF1-abc-a']);
      expect(queue.hasTimer, isFalse);
      queue.dispose();
    });
  });

  test('额度耗尽排队，离屏撤销；回到正文自动续额且不重复注册', () {
    fakeAsync((time) {
      final f = FontTestFixture(), fetched = <String>[];
      final queue = TextFontDemandQueue(
        cache: MemoryFontCache(),
        elapsed: () => time.elapsed,
        download: (a) async {
          fetched.add(a.hash);
          return f.data[a.hash]!;
        },
        register: (_, _) async {},
        snapshot: TextFontNativeSnapshot(
          manifest: f.manifest,
          assetCount: 2,
          totalBytes: 6,
        ),
        window: TextFontDownloadWindow(
          period: const Duration(seconds: 60),
          maximumBytes: 4,
          maximumRequests: 2,
        ),
      )..updateSource(f.manifest, downloadable: true);
      queue.setDemand('body', {'wenkai': 'AB'});
      time.flushMicrotasks();
      expect(queue.snapshot.loadedCount, 1);
      queue.release('body');
      time.elapse(const Duration(seconds: 60));
      expect(fetched.length, 2);
      expect(queue.hasTimer, isFalse);
      queue.setDemand('body', {'wenkai': 'AB'});
      time.flushMicrotasks();
      expect(queue.snapshot.loadedCount, 2);
      expect(fetched.length, 3);
      queue.dispose();
    });
  });

  test('缓存读写失败仍消费已验证输入，撤回拒绝迟到成功', () async {
    final f = FontTestFixture(), cache = MemoryFontCache()..broken = true;
    final delayed = Completer<void>();
    final loaded = <String>[];
    final queue = TextFontDemandQueue(
      cache: cache,
      download: (a) async {
        if (a.hash == f.b.hash) await delayed.future;
        return f.data[a.hash]!;
      },
      register: (family, _) async => loaded.add(family),
      snapshot: TextFontNativeSnapshot(
        manifest: f.manifest,
        assetCount: 2,
        totalBytes: 6,
      ),
      window: TextFontDownloadWindow(
        period: const Duration(seconds: 60),
        maximumBytes: 24,
        maximumRequests: 64,
      ),
    )..updateSource(f.manifest, downloadable: true);
    addTearDown(queue.dispose);
    queue.setDemand('body', {'wenkai': 'A'});
    await queue.settle();
    expect(loaded, ['WYF1-abc-a']);
    queue.setDemand('body', {'wenkai': 'AB'});
    await Future<void>.delayed(Duration.zero);
    queue.updateSource(null, downloadable: false);
    delayed.complete();
    await queue.settle();
    expect(loaded, ['WYF1-abc-a']);
    expect(queue.pendingCount, 0);
  });

  test('坏SHA只隔离该资产，另一片照常加载，网络与前台事件不能清除隔离', () {
    fakeAsync((time) {
      final f = FontTestFixture(), loaded = <String>[];
      var badAttempts = 0;
      final queue = TextFontDemandQueue(
        cache: MemoryFontCache(),
        elapsed: () => time.elapsed,
        download: (a) async {
          if (a.hash == f.a.hash) {
            badAttempts++;
            return f.data[f.b.hash]!;
          }
          return f.data[a.hash]!;
        },
        register: (family, _) async => loaded.add(family),
        snapshot: TextFontNativeSnapshot(
          manifest: f.manifest,
          assetCount: 2,
          totalBytes: 6,
        ),
        window: TextFontDownloadWindow(
          period: const Duration(seconds: 60),
          maximumBytes: 24,
          maximumRequests: 64,
        ),
      )..updateSource(f.manifest, downloadable: true);
      queue.setDemand('body', {'wenkai': 'AB'});
      time.flushMicrotasks();
      time.elapse(const Duration(minutes: 2));
      queue.setOnline(true);
      queue.setForeground(true);
      time.flushMicrotasks();
      expect(loaded, ['WYF1-abc-b']);
      expect(badAttempts, 1);
      expect(queue.snapshot.attemptedCount, 1);
      queue.dispose();
    });
  });
}
