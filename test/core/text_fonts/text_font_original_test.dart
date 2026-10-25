import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';

// 隔离预算状态机：模拟已经通过 SHA 校验的缓存边界。
// 原件真实字节与 FontLoader 的验证由离线正式资产预览执行。
class _VerifiedCache extends TextFontCache {
  _VerifiedCache({required this.hasOriginal}) : super(Directory.systemTemp);
  final bool hasOriginal;
  @override
  Future<Uint8List?> read(TextFontAsset asset) async =>
      asset.isOriginal && !hasOriginal ? null : Uint8List(asset.bytes);
}

void main() {
  Map<String, dynamic> original() {
    final json =
        jsonDecode(
              File(
                'contracts/archive/thread-font-xiaocheng-lafeng-v1.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    return json['font'] as Map<String, dynamic>;
  }

  TextFontManifest manifest() => TextFontManifest(
    Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'schemaVersion': 1,
          'fontVersion': 1,
          'fonts': [original()],
        }),
      ),
    ),
  );

  TextFontRuntime runtime({
    bool cached = true,
    TextFontDownload? download,
    TextFontRegister? register,
  }) =>
      TextFontRuntime(
          cache: _VerifiedCache(hasOriginal: cached),
          download: download ?? (_) async => throw StateError('不得下载'),
          register: register ?? (_, _) async {},
        )
        ..assetsAvailable = true
        ..manifest = manifest();

  test('仅正式原件身份可突破普通 6 MiB，Web/Mobile 必须指向同一对象', () {
    final family = TextFontFamily(original());
    final asset = family.shards.single.asset;
    expect(asset.isOriginal, isTrue);
    expect(asset.bytes, TextFontOriginal.bytes);
    expect(() => TextFontAsset.fromJson(asset.toJson()), throwsFormatException);
    for (final field in ['path', 'sha256', 'bytes', 'format', 'contentType']) {
      for (final platform in ['web', 'mobile']) {
        final json = original();
        final descriptor =
            ((json['shards'] as List).single as Map)[platform] as Map;
        descriptor[field] = field == 'bytes' ? 1 : 'invalid';
        expect(
          () => TextFontFamily(json),
          throwsFormatException,
          reason: '$platform/$field',
        );
      }
    }
    final duplicate = original();
    (duplicate['shards'] as List).add((duplicate['shards'] as List).single);
    expect(() => TextFontFamily(duplicate), throwsFormatException);
  });

  test('未知语言/加载方式/预算身份安全回退，不按中文名称猜测', () {
    for (final field in [
      'designLanguage',
      'deliveryMode',
      'id',
      'budgetException',
    ]) {
      for (final value in [null, 'future']) {
        final json = original()..[field] = value;
        if (field == 'id' && value == null) continue;
        final font = TextFontFamily(json);
        expect(font.ready, isFalse, reason: '$field/$value');
        expect(font.shards, isEmpty);
        if (field == 'designLanguage') expect(font.language, isNull);
      }
    }
    for (final field in [
      'kind',
      'assetSha256',
      'assetBytes',
      'additionalSessionBytes',
    ]) {
      final json = original();
      (json['budgetException'] as Map)[field] = field.endsWith('Bytes')
          ? 1
          : 'future';
      expect(TextFontFamily(json).ready, isFalse, reason: field);
    }
    final subset = original()..['deliveryMode'] = 'subset';
    expect(TextFontFamily(subset).ready, isFalse);
    final renamed = original();
    ((renamed['shards'] as List).single as Map)['family'] =
        'WYF1-cf4a4215e562d6de-core';
    expect(() => TextFontFamily(renamed), throwsFormatException);
  });

  test('缓存首次注册预留原件额度，普通 24 MiB 不被挪用，重复 ensure 复用家族', () async {
    var registrations = 0;
    final r =
        runtime(
            register: (family, bytes) async {
              registrations++;
              expect(family, TextFontOriginal.family);
              expect(bytes.length, TextFontOriginal.bytes);
            },
          )
          ..downloadedBytes = 24 * 1024 * 1024
          ..registeredBytes = 24 * 1024 * 1024;
    await r.ensure(TextFontOriginal.id, '中文');
    r.updateManifest(manifest());
    await r.ensure(TextFontOriginal.id, '更多字');
    expect(registrations, 1);
    expect(r.originalReservedBytes, TextFontOriginal.bytes);
    expect(r.originalRegisteredBytes, TextFontOriginal.bytes);
    expect(r.originalDownloadedBytes, 0);
    expect(r.requests, 0);
    expect(r.downloadedBytes, 24 * 1024 * 1024);
    expect(r.registeredBytes, 24 * 1024 * 1024);
    expect(r.loadedFamilies(TextFontOriginal.id), [TextFontOriginal.family]);
    await expectLater(
      r.asset(r.manifest!.fonts[TextFontOriginal.id]!.shards.single.asset),
      throwsA(isA<TextFontUnavailable>()),
    );
  });

  for (final failure in ['timeout', 'corrupt', 'native']) {
    test('原件 $failure 后不退额度、不自动重试，刷新清单也不能重置', () async {
      var downloads = 0;
      var registrations = 0;
      final r = runtime(
        cached: failure == 'native',
        download: (asset) async {
          downloads++;
          if (failure == 'timeout') throw TimeoutException('下载超时');
          return Uint8List(asset.bytes);
        },
        register: (_, _) async {
          registrations++;
          throw StateError('native');
        },
      );
      await r.ensure(TextFontOriginal.id, '中文');
      r.updateManifest(manifest());
      await r.ensure(TextFontOriginal.id, '更多');
      expect(r.originalReservedBytes, TextFontOriginal.bytes);
      expect(
        r.originalDownloadedBytes,
        failure == 'native' ? 0 : TextFontOriginal.bytes,
      );
      expect(
        r.originalRegisteredBytes,
        failure == 'native' ? TextFontOriginal.bytes : 0,
      );
      expect(downloads, failure == 'native' ? 0 : 1);
      expect(registrations, failure == 'native' ? 1 : 0);
      expect(r.loadedFamilies(TextFontOriginal.id), isEmpty);
      expect(r.registeredBytes, 0);
      expect(r.downloadedBytes, 0);
    });
  }

  test('原件继续受共享家族和请求限制；普通声明不能使用原件额度', () async {
    final families = runtime()
      ..families.addAll([for (var i = 0; i < 8; i++) '$i']);
    await families.ensure(TextFontOriginal.id, '中文');
    expect(families.originalReservedBytes, 0);
    final requests = runtime(cached: false)..requests = 64;
    await requests.ensure(TextFontOriginal.id, '中文');
    expect(requests.originalReservedBytes, TextFontOriginal.bytes);
    expect(requests.originalDownloadedBytes, 0);
    expect(requests.requests, 64);
    final json = original();
    (json['notices'] as List)[0] =
        ((json['shards'] as List).single as Map)['mobile'];
    expect(() => TextFontFamily(json), throwsFormatException);
  });

  test('原件不能突破共享 32 faces，已用原件额度也不能补贴普通注册', () async {
    TextFontManifest ordinary(int count) => TextFontManifest(
      Uint8List.fromList(
        utf8.encode(
          jsonEncode({
            'schemaVersion': 1,
            'fontVersion': 1,
            'fonts': [
              {
                'id': 'wenkai',
                'name': '名字不决定语言',
                'designLanguage': 'en',
                'deliveryMode': 'subset',
                'availability': 'ready',
                'notices': [
                  {
                    'path': 'fonts/v1/${TextFontOriginal.hash}.txt',
                    'sha256': TextFontOriginal.hash,
                    'bytes': 1,
                  },
                ],
                'shards': [
                  for (var i = 0; i < count; i++)
                    {
                      'id': 'core',
                      'family': 'WYF1-abcd-core-$i',
                      'unicodeRanges': ['U+4E00-9FFF'],
                      'mobile': {
                        'path': 'fonts/v1/${TextFontOriginal.hash}.ttf',
                        'sha256': TextFontOriginal.hash,
                        'bytes': 1,
                      },
                    },
                ],
              },
            ],
          }),
        ),
      ),
    );
    final full = runtime()..manifest = ordinary(32);
    await full.ensure('wenkai', '中文');
    expect(full.registeredFaces, 32);
    full.updateManifest(manifest());
    await full.ensure(TextFontOriginal.id, '中文');
    expect(full.originalReservedBytes, 0);
    expect(full.registeredFaces, 32);

    final separate = runtime();
    await separate.ensure(TextFontOriginal.id, '中文');
    separate.updateManifest(ordinary(1));
    separate.registeredBytes = 24 * 1024 * 1024;
    await separate.ensure('wenkai', '中文');
    expect(separate.originalRegisteredBytes, TextFontOriginal.bytes);
    expect(separate.registeredFaces, 1);
    expect(separate.loadedFamilies('wenkai'), isEmpty);
    expect(separate.manifest!.fonts['wenkai']!.language, TextFontLanguage.en);
  });
}
