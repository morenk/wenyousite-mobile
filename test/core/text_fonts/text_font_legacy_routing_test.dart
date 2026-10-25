import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_legacy_mapping.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_transport.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_dynamic_font_paste.dart';

import 'dynamic_font_fixture.dart';
import 'font_test_fixture.dart';

void main() {
  final fixture =
      jsonDecode(
            File(
              'contracts/thread-font-dynamic-v2-fixtures.json',
            ).readAsStringSync(),
          )
          as Map;
  test('固定映射逐项等于正式契约，动态 ID 不受映射目录限制', () {
    final mapping =
        jsonDecode(
              File(
                'contracts/thread-font-v1-import-map.json',
              ).readAsStringSync(),
            )
            as Map;
    expect(legacyTextFontVersions, {
      for (final row in mapping['fonts'] as List)
        row['legacyId']: row['versionId'],
    });
    for (final id in mapping['retired'] as List) {
      expect(dynamicTextFontVersion(id as String), isNull);
    }
    const future = 'tfv_ffffffffffffffffffffffffffffffff';
    expect(dynamicTextFontVersion(future), future);
  });

  for (final row in fixture['legacyRoutingCases'] as List) {
    test('正式历史路由：${row['id']}', () async {
      final h = await _Harness.create(row['versionId'] as String);
      addTearDown(h.dispose);
      h.service.dynamicEnabled = true;
      final id = row['legacyId'] as String;
      const text = 'A';
      final source = '<span data-wenyou-font-v1="$id">$text</span>';
      final delta = MarkdownDeltaCodec.decode(source).delta;
      final owner = Object();
      final trusted = row['lastTrustedStatus'] as String?;
      if (trusted != null) {
        h.status = trusted;
        final runtime = await h.service.retain(owner, {id: text});
        await runtime.demandQueue?.settle();
      }
      h.requests.clear();
      h.status = row['response'] as String;
      final runtime = await h.service.retain(owner, {id: text});
      await h.service.openPicker(); // 强制重查可信状态，包括负缓存/离线。
      await runtime.demandQueue?.settle();
      expect(
        runtime.loadedFamilies(id).isNotEmpty,
        row['expectedRenderAllowed'],
      );
      expect(h.service.canPasteFont(id), row['expectedPasteAllowed']);
      expect(h.legacyRequests, row['expectedLegacyManifestRequests']);
      final assets = h.requests.where((path) => path.contains('/assets/'));
      expect(assets.isNotEmpty, row['expectedAssetRequest'] == 'v2');
      expect(MarkdownDeltaCodec.encode(delta), source);
      final pasted = await prepareDynamicFontPaste(delta, h.service);
      expect(
        pasted.operations.any((op) => op.attributes?['font'] == id),
        row['expectedPasteAllowed'],
      );
      expect(
        pasted.operations
            .where((op) => op.data is String)
            .map((op) => op.data)
            .join(),
        'A\n',
      );
      h.service.closePicker();
      h.service.release(owner);
    });
  }

  for (final row in fixture['legacyCapabilityCases'] as List) {
    test('正式能力防降级：${row['id']}', () async {
      final h = await _Harness.create(legacyTextFontVersions['great-vibes']!);
      addTearDown(h.dispose);
      if (row['knownWithdrawn'] == true) {
        h.service.dynamicEnabled = true;
        h.status = 'withdrawn';
        await h.service.retain(Object(), {'great-vibes': 'A'});
        await h.service.dynamicRuntime!.catalog.persist();
        // 通过磁盘恢复墓碑，覆盖新进程尚未观察到 v2 能力的夹具。
        h.service.dispose();
        h.service = h.newService();
        h.status = 'stale-published';
      }
      h.service.dynamicEnabled = row['previouslyActivated'] == true;
      h.service.dynamicEnabled = row['capability'] == true;
      h.requests.clear();
      final runtime = await h.service.retain(Object(), {'great-vibes': 'A'});
      await runtime.demandQueue?.settle();
      final expected = row['expectedRoute'];
      if (expected == 'legacy-v1') {
        expect(h.service.dynamicEnabled, isFalse);
        expect(h.legacyRequests, greaterThan(0));
      } else {
        expect(h.service.dynamicEnabled, isTrue);
        expect(h.legacyRequests, 0);
        expect(
          runtime.loadedFamilies('great-vibes').isNotEmpty,
          expected == 'mapped-v2',
        );
      }
    });
  }

  test('已注册 v1 切换后能力缺失且 v2 失败，立即默认且不走旧资源', () async {
    final h = await _Harness.create(legacyTextFontVersions['wenkai']!);
    addTearDown(h.dispose);
    final runtime = await h.service.retain(Object(), {'wenkai': 'A'});
    await runtime.demandQueue!.settle();
    expect(runtime.loadedFamilies('wenkai'), isNotEmpty);
    final charged = h.service.ledger.chargedInputBytes;
    h.legacyRequests = 0;
    h.service.dynamicEnabled = true;
    expect(runtime.loadedFamilies('wenkai'), isEmpty);
    h.service.dynamicEnabled = false;
    h.status = 'network-error';
    await h.service.openPicker();
    expect(runtime.loadedFamilies('wenkai'), isEmpty);
    expect(h.legacyRequests, 0);
    expect(h.service.ledger.chargedInputBytes, charged);
  });

  test('映射 v1 与 v2 撤回同时停止，原生账本不退额，退役无映射不加载', () async {
    final h = await _Harness.create(legacyTextFontVersions['great-vibes']!);
    addTearDown(h.dispose);
    h.service.dynamicEnabled = true;
    final runtime = await h.service.retain(Object(), {
      'great-vibes': 'A',
      h.font.id: 'A',
      'xiaocheng-lafeng': 'A',
    });
    await runtime.demandQueue!.settle();
    expect(h.registrations, 1);
    expect(
      runtime.loadedFamilies('great-vibes'),
      runtime.loadedFamilies(h.font.id),
    );
    expect(runtime.loadedFamilies('xiaocheng-lafeng'), isEmpty);
    expect(h.service.canPasteFont('xiaocheng-lafeng'), isFalse);
    final charged = h.service.ledger.chargedInputBytes;
    h.status = 'withdrawn';
    await h.service.openPicker();
    expect(runtime.loadedFamilies('great-vibes'), isEmpty);
    expect(runtime.loadedFamilies(h.font.id), isEmpty);
    expect(h.service.ledger.chargedInputBytes, charged);
    expect(h.legacyRequests, 0);
  });
}

class _Harness {
  _Harness(this.directory, this.font);
  final Directory directory;
  final DynamicFontFixture font;
  final legacy = FontTestFixture(jsonNotice: true);
  late TextFontService service;
  String status = 'published';
  int legacyRequests = 0, registrations = 0;
  final requests = <String>[];

  static Future<_Harness> create(String version) async {
    final value = _Harness(
      await Directory.systemTemp.createTemp('font-v1-route-'),
      DynamicFontFixture(versionId: version),
    );
    value.service = value.newService();
    return value;
  }

  TextFontService newService() => TextFontService(
    WenyouApi(dio: Dio(BaseOptions(baseUrl: 'https://api.example'))),
    observePlatform: false,
    cache: TextFontCache(directory),
    elapsed: () => Duration.zero,
    register: (_, _) async {
      registrations++;
    },
    fetch: (uri, limit, mime, cancel) async {
      legacyRequests++;
      if (uri.path == '/api/v1/meta/text-fonts') {
        return legacy.envelope(legacy.catalog());
      }
      if (uri.path.endsWith('/runtime-policy')) {
        return legacy.envelope(legacy.policy());
      }
      return legacy.data[uri.pathSegments.last.split('.').first]!;
    },
    dynamicRequest: (uri, limit, mime, cancel, {etag}) async {
      final path = uri.path;
      requests.add(path);
      if (path.endsWith('/runtime-policy')) {
        return TextFontResponse(200, font.envelope(font.policy));
      }
      if (path == '/api/v1/meta/text-fonts/v2') {
        return TextFontResponse(200, font.envelope(font.page(items: [])));
      }
      if (path.endsWith('/versions/${font.id}')) {
        if (status == 'network-error') throw const SocketException('offline');
        if (status == '404' || status == 'unknown') {
          return TextFontResponse(404, Uint8List(0));
        }
        return TextFontResponse(
          200,
          font.envelope(
            font.descriptor(
              revision: status == 'stale-published' ? 0 : 1,
              enabled: status != 'disabled',
              withdrawn: status == 'withdrawn',
            ),
          ),
        );
      }
      if (font.data[path] case final bytes?) {
        return TextFontResponse(200, bytes);
      }
      return TextFontResponse(404, Uint8List(0));
    },
  );

  Future<void> dispose() async {
    service.dispose();
    await directory.delete(recursive: true);
  }
}
