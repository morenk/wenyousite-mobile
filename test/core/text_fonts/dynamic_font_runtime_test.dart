import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/text_fonts/dynamic_font_catalog.dart';
import 'package:wenyousite_mobile/core/text_fonts/dynamic_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/dynamic_font_policy.dart';
import 'package:wenyousite_mobile/core/text_fonts/dynamic_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_download_window.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_native_ledger.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transport.dart';

import 'dynamic_font_fixture.dart';
import 'font_test_fixture.dart';

void main() {
  test('正式协议构造输入通过策略与清单独立校验', () {
    final font = DynamicFontFixture();
    DynamicFontPolicy(font.policy);
    final manifest = DynamicFontManifest(font.manifestBytes, font.dto());
    expect(manifest.shards, hasLength(1));
  });
  late Directory directory;
  late MemoryFontCache cache;
  late TextFontRuntime runtime;
  late DynamicFontRuntime controller;
  late Map<String, DynamicFontFixture> versions;
  late List<String> registrations;
  late Set<String> withdrawn;
  late bool badCatalog, badPolicy, nativeFailure;
  late String? corruptManifest;
  late int retries, cancellations;
  late int catalogRevision;
  late List<Object?>? catalogItems;
  late List<String> downloads;
  late Future<Uint8List> Function(TextFontAsset)? slowDownload;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('wenyou-dynamic-font-');
    cache = MemoryFontCache(directory);
    registrations = [];
    withdrawn = {};
    versions = {};
    badCatalog = false;
    badPolicy = false;
    nativeFailure = false;
    corruptManifest = null;
    retries = 0;
    cancellations = 0;
    slowDownload = null;
    catalogRevision = 1;
    catalogItems = null;
    downloads = [];
    runtime = TextFontRuntime(
      cache: cache,
      download: (asset) async {
        downloads.add(asset.path);
        if (slowDownload case final read?) return read(asset);
        for (final fixture in versions.values) {
          if (fixture.data[asset.path] case final bytes?) return bytes;
        }
        throw StateError('Unexpected asset ${asset.path}');
      },
      register: (family, bytes) async {
        registrations.add(family);
        if (nativeFailure) throw StateError('模拟原生注册失败');
      },
    );
    runtime.assetsAvailable = true;
    controller = DynamicFontRuntime(
      runtime: runtime,
      window: TextFontDownloadWindow(
        period: const Duration(seconds: 60),
        maximumBytes: 24 * 1024 * 1024,
        maximumRequests: 64,
      ),
      elapsed: () => Duration.zero,
      cancel: (_) {
        cancellations++;
      },
      retryLater: () {
        retries++;
      },
      read: (path, bytes, mime, {etag}) async {
        final fixture = versions.values.first;
        if (path.endsWith('/runtime-policy')) {
          if (badPolicy) throw const FormatException('broken policy');
          return TextFontResponse(200, fixture.envelope(fixture.policy));
        }
        if (path.contains('?limit=')) {
          if (badCatalog) throw const FormatException('broken catalog');
          return TextFontResponse(
            200,
            fixture.envelope(
              fixture.page(
                revision: catalogRevision,
                items:
                    catalogItems ??
                    versions.values.map((f) => f.entry).toList(),
              ),
            ),
          );
        }
        for (final entry in versions.values) {
          if (path.endsWith('/versions/${entry.id}')) {
            return TextFontResponse(
              200,
              entry.envelope(
                entry.descriptor(withdrawn: withdrawn.contains(entry.id)),
              ),
            );
          }
          if (entry.data[path] case final data?) {
            return TextFontResponse(
              200,
              corruptManifest == path ? Uint8List.fromList([0]) : data,
            );
          }
        }
        return TextFontResponse(404, Uint8List(0));
      },
    );
  });
  tearDown(() async {
    runtime.demandQueue?.dispose();
    runtime.dispose();
    await directory.delete(recursive: true);
  });

  test('同版本目录重排保留缓存、已下载字节与原生注册预算', () async {
    final first = DynamicFontFixture(),
        second = DynamicFontFixture(identity: 2, fontBytes: [6, 7]);
    versions.addAll({first.id: first, second.id: second});
    await controller.refresh(versions.keys);
    await runtime.ensure(first.id, 'A');
    final queue = runtime.demandQueue!;
    final window = queue.window;
    final ledger = runtime.ledger;
    final cached = Map.of(cache.values);
    final priorDownloads = List.of(downloads);
    final priorRegistrations = List.of(registrations);
    final inputBytes = ledger.chargedInputBytes;
    final attempts = ledger.attemptedCount;
    final nextFullWindow = window.availableAt(
      window.maximumBytes,
      Duration.zero,
    );
    expect(nextFullWindow, const Duration(seconds: 60));
    expect(inputBytes, 3);
    expect(attempts, 1);

    catalogRevision = 2;
    catalogItems = [
      {...second.entry, 'sortOrder': 0},
      {...first.entry, 'sortOrder': 1},
    ];
    await controller.refresh(versions.keys, force: true);
    await runtime.ensure(first.id, 'A');
    expect(controller.catalog.revision, 2);
    expect(controller.catalog.entries.map((entry) => entry.versionId), [
      second.id,
      first.id,
    ]);
    expect(runtime.demandQueue, same(queue));
    expect(queue.window, same(window));
    expect(runtime.ledger, same(ledger));
    expect(runtime.cache, same(cache));
    expect(cache.values, cached);
    expect(downloads, priorDownloads);
    expect(registrations, priorRegistrations);
    expect(ledger.chargedInputBytes, inputBytes);
    expect(ledger.attemptedCount, attempts);
    expect(
      window.availableAt(window.maximumBytes, Duration.zero),
      nextFullWindow,
    );
    expect(runtime.loadedFamilies(first.id), [first.family]);
  });

  for (final failed in [false, true]) {
    test('旧 v1 注册后导入 v2 使用相同 SHA/family，不再注册计费（失败=$failed）', () async {
      nativeFailure = failed;
      final old = FontTestFixture(jsonNotice: true);
      final source =
          jsonDecode(utf8.decode(old.manifestBytes)) as Map<String, dynamic>;
      final shards = (source['fonts'] as List).first['shards'] as List;
      shards.first['family'] = 'WYF1-0123456789abcdef-core';
      final legacy = TextFontManifest(
        Uint8List.fromList(utf8.encode(jsonEncode(source))),
      );
      cache.values.addAll(old.data);
      runtime.updateManifest(legacy);
      await runtime.ensure('wenkai', 'A');
      expect(registrations, ['WYF1-0123456789abcdef-core']);
      expect(runtime.ledger.chargedInputBytes, 3);
      final imported = DynamicFontFixture(alias: 'WYF1-0123456789abcdef-core');
      versions[imported.id] = imported;
      await controller.refresh([imported.id]);
      await runtime.ensure(imported.id, 'A');
      expect(
        runtime.loadedFamilies(imported.id),
        failed ? isEmpty : ['WYF1-0123456789abcdef-core'],
      );
      expect(registrations, hasLength(1));
      expect(runtime.ledger.attemptedCount, 1);
      expect(runtime.ledger.chargedInputBytes, 3);
    });
  }

  test('目录损坏不阻断按 ID 查描述符和渲染', () async {
    final font = DynamicFontFixture();
    versions[font.id] = font;
    badCatalog = true;
    await controller.refresh([font.id]);
    await runtime.ensure(font.id, 'A');
    expect(registrations, [font.family]);
    expect(retries, 1);
  });

  test('已有可信策略时新策略和目录失败仍加载另一个版本', () async {
    final first = DynamicFontFixture(),
        second = DynamicFontFixture(identity: 2, fontBytes: [6, 7]);
    versions[first.id] = first;
    await controller.refresh([first.id]);
    versions[second.id] = second;
    badPolicy = true;
    badCatalog = true;
    await controller.refresh([second.id], force: true);
    await runtime.ensure(second.id, 'A');
    expect(registrations, [second.family]);
    expect(retries, 2);
  });

  test('一个坏清单不会阻断后续正常字体', () async {
    final first = DynamicFontFixture(),
        second = DynamicFontFixture(identity: 2, fontBytes: [6, 7]);
    versions.addAll({first.id: first, second.id: second});
    corruptManifest = '${first.base}${first.manifestAsset['sha256']}.json';
    await controller.refresh([first.id, second.id]);
    await runtime.ensure(second.id, 'A');
    expect(runtime.loadedFamilies(first.id), isEmpty);
    expect(registrations, [second.family]);
    expect(retries, 1);
  });

  test('撤回已加载版本立即停止呈现，物理账本不退额', () async {
    final font = DynamicFontFixture();
    versions[font.id] = font;
    await controller.refresh([font.id]);
    await runtime.ensure(font.id, 'A');
    expect(runtime.loadedFamilies(font.id), [font.family]);
    controller.catalog.markWithdrawn(font.id);
    for (var i = 2; i < DynamicFontCatalog.maximumDescriptors + 3; i++) {
      controller.catalog.acceptVersion(DynamicFontFixture(identity: i).dto());
    }
    expect(runtime.loadedFamilies(font.id), isEmpty);
    expect(runtime.ledger.loadedCount, 1);
    expect(runtime.ledger.chargedInputBytes, 3);
    controller.catalog.acceptVersion(font.dto(revision: 100));
    expect(controller.catalog.canRender(font.id), isFalse);
    expect(controller.catalog.canPaste(font.id), isFalse);
    expect(controller.catalog.canSelect(font.id), isFalse);
    expect(
      controller.allowsAsset(
        dynamicFontAsset(
          font.id,
          font.base,
          font.dto().manifest!,
          formats: {'json'},
          maximumBytes: 4 * 1024 * 1024,
        ),
      ),
      isFalse,
    );
    await runtime.ensure(font.id, 'A');
    expect(registrations, hasLength(1));
    expect(runtime.loadedFamilies(font.id), isEmpty);
  });

  test('在途分片撤回触发取消，迟到字节不再注册', () async {
    final font = DynamicFontFixture();
    versions[font.id] = font;
    await controller.refresh([font.id]);
    final pending = Completer<Uint8List>(), started = Completer<void>();
    slowDownload = (asset) async {
      if (asset.path.endsWith('.json')) return font.data[asset.path]!;
      started.complete();
      return pending.future;
    };
    final loading = runtime.ensure(font.id, 'A');
    await started.future;
    controller.catalog.markWithdrawn(font.id);
    expect(cancellations, greaterThan(0));
    pending.complete(Uint8List.fromList([1, 2, 3]));
    await loading;
    expect(registrations, isEmpty);
    expect(runtime.loadedFamilies(font.id), isEmpty);
  });

  test('历史超限引擎迁移保持可见并阻止新注册', () async {
    final font = DynamicFontFixture();
    versions[font.id] = font;
    runtime.ledger.importEngineAttempt(
      hash: font.font['sha256']! as String,
      family: font.family,
      inputBytes: 3,
      succeeded: true,
    );
    runtime.ledger.importEngineAttempt(
      hash: 'e' * 64,
      family: 'historic-large',
      inputBytes: 64 * 1024 * 1024,
      succeeded: false,
    );
    await controller.refresh([font.id]);
    await runtime.ensure(font.id, 'A');
    expect(runtime.loadedFamilies(font.id), [font.family]);
    final second = DynamicFontFixture(identity: 2, fontBytes: [6, 7]);
    versions[second.id] = second;
    await controller.refresh([second.id]);
    await runtime.ensure(second.id, 'A');
    expect(registrations, isEmpty);
    expect(runtime.ledger.chargedInputBytes, 64 * 1024 * 1024 + 3);
  });

  test('共享正式导入夹具维持一个注册键和原始输入收费', () {
    final fixture =
        jsonDecode(
              File(
                'contracts/thread-font-dynamic-v2-fixtures.json',
              ).readAsStringSync(),
            )
            as Map;
    for (final row in fixture['legacyImportRegistrationCases'] as List) {
      final ledger = TextFontNativeLedger();
      var attempts = 0;
      for (final event in row['events'] as List) {
        if (ledger.beginNativeAttempt(
          hash: event['sha256'] as String,
          family: event['family'] as String,
          inputBytes: event['bytes'] as int,
        )) {
          attempts++;
        }
      }
      expect(attempts, row['expectedNativeAttempts']);
      expect(ledger.chargedInputBytes, row['expectedChargedBytes']);
    }
  });
}
