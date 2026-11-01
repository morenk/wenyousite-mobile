import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_retry_ledger.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transport.dart';
import 'dynamic_font_fixture.dart';
import 'font_test_fixture.dart';

void main() {
  late Directory directory;
  late TextFontService service;
  late FontTestFixture legacy;
  late DynamicFontFixture first, second;
  late Duration now;
  late int active, peak, catalogAttempts, registrations, legacyRequests;
  late bool damageCatalog, holdFont, holdDescriptor;
  late int secondDescriptorStatus, secondDescriptorAttempts;
  late bool withdrawSecond;
  late Completer<void> fontStarted, releaseFont;
  late Completer<void> descriptorStarted, releaseDescriptor, secondRegistered;
  late CancelToken? fontCancel;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'wenyou-font-service-v2-',
    );
    legacy = FontTestFixture(jsonNotice: true);
    first = DynamicFontFixture();
    second = DynamicFontFixture(identity: 2, fontBytes: [8, 9]);
    now = Duration.zero;
    active = 0;
    peak = 0;
    catalogAttempts = 0;
    registrations = 0;
    legacyRequests = 0;
    damageCatalog = false;
    holdFont = false;
    holdDescriptor = false;
    secondDescriptorStatus = 200;
    secondDescriptorAttempts = 0;
    withdrawSecond = false;
    fontStarted = Completer();
    releaseFont = Completer();
    descriptorStarted = Completer();
    releaseDescriptor = Completer();
    secondRegistered = Completer();
    fontCancel = null;
    Future<T> track<T>(Future<T> Function() action) async {
      active++;
      if (active > peak) peak = active;
      try {
        return await action();
      } finally {
        active--;
      }
    }

    service = TextFontService(
      WenyouApi(dio: Dio(BaseOptions(baseUrl: 'https://api.example'))),
      observePlatform: false,
      cache: MemoryFontCache(directory),
      elapsed: () => now,
      retries: TextFontRetryLedger(random: () => 1),
      register: (family, _) async {
        registrations++;
        if (family == second.family && !secondRegistered.isCompleted) {
          secondRegistered.complete();
        }
      },
      fetch: (uri, limit, mime, cancel) => track(() async {
        legacyRequests++;
        await Future<void>.delayed(const Duration(milliseconds: 1));
        if (uri.path == '/api/v1/meta/text-fonts') {
          return legacy.envelope(legacy.catalog());
        }
        if (uri.path.endsWith('/runtime-policy')) {
          return legacy.envelope(legacy.policy());
        }
        final hash = uri.pathSegments.last.split('.').first;
        return legacy.data[hash]!;
      }),
      dynamicRequest: (uri, limit, mime, cancel, {etag}) => track(() async {
        if (uri.path.endsWith('/runtime-policy')) {
          return TextFontResponse(200, first.envelope(first.policy));
        }
        if (uri.path == '/api/v1/meta/text-fonts/v2') {
          catalogAttempts++;
          if (damageCatalog) throw const FormatException('错误MIME或超限');
          return TextFontResponse(
            200,
            first.envelope(first.page(items: [first.entry, second.entry])),
            etag: '"v1"',
          );
        }
        for (final font in [first, second]) {
          if (uri.path.endsWith('/versions/${font.id}')) {
            if (font == second) {
              secondDescriptorAttempts++;
              if (secondDescriptorStatus != 200) {
                return TextFontResponse(secondDescriptorStatus, Uint8List(0));
              }
              if (withdrawSecond) {
                return TextFontResponse(
                  200,
                  font.envelope(font.descriptor(withdrawn: true)),
                );
              }
            }
            if (font == first && holdDescriptor) {
              if (!descriptorStarted.isCompleted) descriptorStarted.complete();
              await releaseDescriptor.future;
            }
            return TextFontResponse(200, font.envelope(font.descriptor()));
          }
          if (font.data[uri.path] case final bytes?) {
            if (uri.path.endsWith('.ttf') && holdFont) {
              fontCancel = cancel;
              if (!fontStarted.isCompleted) fontStarted.complete();
              await releaseFont.future;
            }
            await Future<void>.delayed(const Duration(milliseconds: 2));
            return TextFontResponse(200, bytes);
          }
        }
        return TextFontResponse(404, Uint8List(0));
      }),
    )..dynamicEnabled = true;
  });
  tearDown(() async {
    if (!releaseFont.isCompleted) releaseFont.complete();
    if (!releaseDescriptor.isCompleted) releaseDescriptor.complete();
    service.dispose();
    await directory.delete(recursive: true);
  });

  for (final sameOwner in [true, false]) {
    test('元数据在途新增字体需求自动尾随加载，不等五分钟 sameOwner=$sameOwner', () async {
      holdDescriptor = true;
      final owner = Object();
      final nextOwner = sameOwner ? owner : Object();
      final firstLoad = service.retain(owner, {first.id: 'A'});
      await descriptorStarted.future.timeout(const Duration(seconds: 2));
      final secondLoad = service.retain(nextOwner, {second.id: 'A'});
      releaseDescriptor.complete();
      final runtime = await firstLoad;
      await secondLoad;
      // 不调用 load/wake、不推进五分钟时钟，必须自动消费迟到的正文需求。
      await secondRegistered.future.timeout(const Duration(seconds: 2));
      await runtime.demandQueue!.settle();
      expect(runtime.loadedFamilies(second.id), [second.family]);
      expect(now, Duration.zero);
      expect(peak, 1);
      expect(catalogAttempts, 1, reason: '尾随刷新复用仍新鲜的目录');
      expect(runtime.ledger.attemptedCount, sameOwner ? 1 : 2);
      expect(
        service.window.availableAt(service.window.maximumBytes, now),
        const Duration(seconds: 60),
        reason: '尾随加载不重置已占用的下载窗口',
      );
      service.release(owner);
      service.release(nextOwner);
    });
  }

  test('迟到字体需求随页面销毁释放，不进行尾随下载', () async {
    holdDescriptor = true;
    final owner = Object();
    final firstLoad = service.retain(owner, {first.id: 'A'});
    await descriptorStarted.future.timeout(const Duration(seconds: 2));
    final secondLoad = service.retain(owner, {second.id: 'A'});
    service.release(owner);
    releaseDescriptor.complete();
    final runtime = await firstLoad;
    await secondLoad;
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await runtime.demandQueue!.settle();
    expect(registrations, 0);
    expect(secondRegistered.isCompleted, isFalse);
    expect(runtime.demandQueue!.pendingCount, 0);
  });

  test('同一字体只增长正文时复用元数据，不等待或打断正在下载的字库', () async {
    holdFont = true;
    final owner = Object();
    final runtime = await service.retain(owner, {first.id: 'A'});
    await fontStarted.future.timeout(const Duration(seconds: 2));
    await service
        .retain(owner, {first.id: 'AA'})
        .timeout(const Duration(milliseconds: 200));
    expect(fontCancel!.isCancelled, isFalse);
    expect(active, 1);
    expect(catalogAttempts, 1);
    releaseFont.complete();
    await runtime.demandQueue!.settle();
    expect(registrations, 1);
    service.release(owner);
  });

  test('性能回归：新片段复用已加载字体，不等待另一字体下载', () async {
    final owner = Object();
    final runtime = await service.retain(owner, {first.id: 'A'});
    await runtime.demandQueue!.settle();
    expect(runtime.loadedFamilies(first.id), [first.family]);
    holdFont = true;
    await service.retain(Object(), {second.id: 'A'});
    await fontStarted.future.timeout(const Duration(seconds: 2));
    final nextOwner = Object();
    final reused = await service
        .retain(nextOwner, {first.id: 'A'})
        .timeout(const Duration(milliseconds: 200));
    expect(reused.loadedFamilies(first.id), [first.family]);
    expect(fontCancel!.isCancelled, isFalse);
    releaseFont.complete();
    await runtime.demandQueue!.settle();
    expect(registrations, 2);
    expect(peak, 1);
  });

  test('迟到需求期间离线不循环请求，恢复在线后继续加载', () async {
    holdDescriptor = true;
    final owner = Object();
    final firstLoad = service.retain(owner, {first.id: 'A'});
    await descriptorStarted.future.timeout(const Duration(seconds: 2));
    final secondLoad = service.retain(owner, {second.id: 'A'});
    service.setOnline(false);
    releaseDescriptor.complete();
    final runtime = await firstLoad;
    await secondLoad;
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(secondDescriptorAttempts, 0);
    expect(registrations, 0);
    service.setOnline(true);
    await secondRegistered.future.timeout(const Duration(seconds: 2));
    await runtime.demandQueue!.settle();
    expect(runtime.loadedFamilies(second.id), [second.family]);
    expect(peak, 1);
    service.release(owner);
  });

  for (final withdrawn in [false, true]) {
    test('迟到版本不存在或已撤回不循环请求/不注册 withdrawn=$withdrawn', () async {
      holdDescriptor = true;
      withdrawSecond = withdrawn;
      secondDescriptorStatus = withdrawn ? 200 : 404;
      final owner = Object();
      final firstLoad = service.retain(owner, {first.id: 'A'});
      await descriptorStarted.future.timeout(const Duration(seconds: 2));
      final secondLoad = service.retain(owner, {second.id: 'A'});
      releaseDescriptor.complete();
      final runtime = await firstLoad;
      await secondLoad;
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(secondDescriptorAttempts, 1);
      expect(runtime.loadedFamilies(second.id), isEmpty);
      expect(
        runtime.fontUnavailable?.call(second.id),
        isTrue,
        reason: '不存在或撤回必须结束作者进度，不应永久准备',
      );
      expect(registrations, 0);
      service.release(owner);
    });
  }

  test('元数据损坏后退避，同一会话恢复；仍可按版本加载正文', () async {
    damageCatalog = true;
    final owner = Object();
    final runtime = await service.retain(owner, {first.id: 'A'});
    await runtime.demandQueue?.settle();
    expect(runtime.loadedFamilies(first.id), [first.family]);
    expect(catalogAttempts, 1);
    damageCatalog = false;
    await service.openPicker();
    expect(catalogAttempts, 1, reason: '退避尚未到期');
    now = const Duration(seconds: 2);
    await service.openPicker();
    expect(catalogAttempts, 2);
    expect(service.dynamicRuntime!.catalog.entries, hasLength(2));
    expect(peak, 1);
    service.closePicker();
    service.release(owner);
  });

  test('动态正文与选择器无需请求旧目录和全量manifest', () async {
    final runtime = await service.openPicker();
    expect(legacyRequests, 0);
    expect(registrations, 0);
    final owner = Object();
    await service.retain(owner, {first.id: 'A'});
    await runtime.demandQueue!.settle();
    expect(legacyRequests, 0);
    expect(runtime.loadedFamilies(first.id), [first.family]);
    service.release(owner);
    service.closePicker();
  });

  test('多个样张与正文共用并发1，样张等待持续下载且不取消正文', () async {
    holdFont = true;
    final owner = Object();
    final runtime = await service.retain(owner, {first.id: 'A'});
    await fontStarted.future.timeout(const Duration(seconds: 5));
    final a = standardSerializers.deserializeWith(
      FontCatalogEntryDto.serializer,
      first.entry,
    )!;
    final b = standardSerializers.deserializeWith(
      FontCatalogEntryDto.serializer,
      second.entry,
    )!;
    final pending = [service.specimen(a), service.specimen(b)];
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(fontCancel!.isCancelled, isFalse);
    expect(active, 1);
    expect(peak, 1);
    releaseFont.complete();
    final images = await Future.wait(
      pending,
    ).timeout(const Duration(seconds: 5));
    await runtime.demandQueue?.settle();
    expect(images.every((image) => image != null), isTrue);
    expect(registrations, 1);
    expect(runtime.loadedFamilies(first.id), [first.family]);
    expect(peak, 1);
    service.release(owner);
  });
}
