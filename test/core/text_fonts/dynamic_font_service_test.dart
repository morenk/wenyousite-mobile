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
  late bool damageCatalog, holdFont;
  late Completer<void> fontStarted, releaseFont;
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
    fontStarted = Completer();
    releaseFont = Completer();
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
      register: (_, _) async {
        registrations++;
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
    service.dispose();
    await directory.delete(recursive: true);
  });

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
