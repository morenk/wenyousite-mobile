import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_text_font.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_runtime.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('wenyou-font-test-');
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });
  final data = Uint8List.fromList([1, 2, 3]);
  final ids = MarkdownTextFont.ids.toList();
  final hash = sha256.convert(data).toString();
  TextFontAsset asset() =>
      TextFontAsset(path: 'fonts/v1/$hash.ttf', hash: hash, bytes: data.length);
  TextFontManifest manifest({int count = 10, int shards = 1}) =>
      TextFontManifest(
        Uint8List.fromList(
          utf8.encode(
            jsonEncode({
              'schemaVersion': 1,
              'fontVersion': 1,
              'fonts': [
                for (var i = 0; i < count; i++)
                  {
                    'id': ids[i],
                    'name': '字体$i',
                    'designLanguage': 'zh',
                    'deliveryMode': 'subset',
                    'availability': 'ready',
                    'notices': [asset().toJson()],
                    'shards': [
                      for (var j = 0; j < shards; j++)
                        {
                          'id': 'core',
                          'family': 'WYF1-$i-core-$j',
                          'mobile': asset().toJson(),
                          'unicodeRanges': ['U+4E00-9FFF'],
                        },
                    ],
                  },
              ],
            }),
          ),
        ),
      );
  TextFontRuntime runtime({
    TextFontRegister? register,
    TextFontDownload? download,
  }) => TextFontRuntime(
    cache: TextFontCache(directory),
    download: download ?? (_) async => data,
    register: register ?? (_, _) async {},
  )..assetsAvailable = true;

  test('正式清单可解析；三 BOOTH 与篆书覆盖不冒充完整中文和英文', () {
    final actual = TextFontManifest(
      File('contracts/thread-font-manifest-v1.json').readAsBytesSync(),
    );
    expect(actual.fonts.length, 28);
    expect(actual.fonts.values.where((f) => f.ready).length, 28);
    expect(actual.fonts['xiaocheng-lafeng'], isNull);
    expect(actual.fonts['kaitou-yokoku-gothic']!.ready, isTrue);
    for (final (language, count) in [
      (TextFontLanguage.zh, 12),
      (TextFontLanguage.ja, 10),
      (TextFontLanguage.en, 6),
    ]) {
      expect(
        actual.fonts.values.where((f) => f.language == language).length,
        count,
      );
    }
    expect(
      actual.fonts['jf-zsk-seal']!.shards.any((s) => s.contains(65)),
      isFalse,
    );
    for (final id in ['shinsyoku-mincho', 'bouken-gothic', 'hakkou-mincho']) {
      expect(actual.fonts[id]!.language, TextFontLanguage.ja);
      expect(
        actual.fonts[id]!.shards.any((s) => s.contains('汉'.runes.single)),
        isFalse,
      );
    }
  });
  test('路径必须是匹配哈希的本地相对对象；禁止跨站和路径穿越', () {
    for (final path in [
      '../$hash.ttf',
      'https://example.com/$hash.ttf',
      '/fonts/v1/$hash.ttf',
      'fonts/v1/$hash.ttf?token=secret',
    ]) {
      expect(
        () => TextFontAsset(path: path, hash: hash, bytes: 3),
        throwsFormatException,
      );
    }
    expect(
      TextFontService.trustedBase('https://assets.example/fonts/'),
      isNotNull,
    );
    for (final url in [
      'http://assets.example/',
      'https://a.example/?q=1',
      'https://u:p@a.example/',
      'https://a.example/fonts',
    ]) {
      expect(TextFontService.trustedBase(url), isNull);
    }
  });
  test('缓存命中验证哈希，损坏缓存删除后只重新请求一次', () async {
    final r = runtime();
    await directory.create(recursive: true);
    await File('${directory.path}/$hash').writeAsBytes([9, 9, 9]);
    expect(await r.asset(asset()), data);
    expect(r.requests, 1);
    expect(await r.asset(asset()), data);
    expect(r.requests, 1);
  });
  test('坏下载不会注册，后续滚动不自动重试', () async {
    var calls = 0;
    final r = runtime(
      download: (_) async {
        calls++;
        return Uint8List(3);
      },
    )..manifest = manifest();
    await r.ensure(ids.first, '中文');
    await r.ensure(ids.first, '更多字');
    expect(calls, 1);
    expect(r.registeredFaces, 0);
  });
  test('家族和分片预算跨 ensure 累计，重复请求不会重复注册', () async {
    final r = runtime()..manifest = manifest();
    await Future.wait([for (var i = 0; i < 10; i++) r.ensure(ids[i], '中文')]);
    expect(r.families.length, 8);
    expect(r.registeredFaces, 8);
    await r.ensure(ids.first, '中文');
    expect(r.registeredFaces, 8);
    final many = runtime()..manifest = manifest(count: 1, shards: 40);
    await many.ensure(ids.first, '中文');
    expect(many.registeredFaces, 32);
  });
  test('失败的原生注册保留预算但不提供家族名', () async {
    final r = runtime(
      register: (_, _) async {
        throw StateError('native');
      },
    )..manifest = manifest();
    await r.ensure(ids.first, '中文');
    expect(r.registeredFaces, 1);
    expect(r.registeredBytes, 3);
    expect(r.loadedFamilies(ids.first), isEmpty);
  });
  test('缓存有上限，正在使用的字体不被 LRU 淘汰', () async {
    final cache = TextFontCache(directory, maximumBytes: 3);
    await cache.write(asset(), data);
    cache.pinned.add(hash);
    final other = Uint8List.fromList([4, 5, 6]);
    final otherHash = sha256.convert(other).toString();
    final descriptor = TextFontAsset(
      path: 'fonts/v1/$otherHash.ttf',
      hash: otherHash,
      bytes: 3,
    );
    await cache.write(descriptor, other);
    expect(await cache.read(asset()), data);
    expect(await cache.read(descriptor), isNull);
  });
  test('离线只用缓存，空基址不发请求', () async {
    final r = runtime()..assetsAvailable = false;
    await expectLater(r.asset(asset()), throwsA(isA<TextFontUnavailable>()));
    expect(r.requests, 0);
    await r.cache.write(asset(), data);
    expect(await r.asset(asset()), data);
    expect(r.requests, 0);
  });
  test('请求和字节硬上限在下一次下载或注册前阻止工作', () async {
    final requests = runtime()..requests = 64;
    await expectLater(
      requests.asset(asset()),
      throwsA(isA<TextFontUnavailable>()),
    );
    final bytes = runtime()..downloadedBytes = 24 * 1024 * 1024;
    await expectLater(
      bytes.asset(asset()),
      throwsA(isA<TextFontUnavailable>()),
    );
    final registered = runtime()
      ..manifest = manifest()
      ..registeredBytes = 24 * 1024 * 1024;
    await registered.ensure(ids.first, '中文');
    expect(registered.registeredFaces, 0);
  });
}
