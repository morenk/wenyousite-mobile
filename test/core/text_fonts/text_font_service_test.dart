import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_service.dart';

class _Api extends Mock implements WenyouApi {}

class _Meta extends Mock implements MetaApi {}

void main() {
  test('目录重试复用同一运行时与预算，离线启动仅读取已校验清单', () async {
    final directory = await Directory.systemTemp.createTemp(
      'wenyou-font-service-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final cache = TextFontCache(directory);
    final bytes = File(
      'contracts/thread-font-manifest-v1.json',
    ).readAsBytesSync();
    final hash = sha256.convert(bytes).toString();
    final descriptor = TextFontAsset(
      path: 'fonts/v1/$hash.json',
      hash: hash,
      bytes: bytes.length,
    );
    await cache.write(descriptor, bytes);
    final api = _Api(), meta = _Meta();
    when(api.getMetaApi).thenReturn(meta);
    when(() => meta.textFontsGetCatalog(extra: any(named: 'extra'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/api/v1/meta/text-fonts'),
        data: TextFontsGetCatalog200Response(
          (b) => b
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'OK'
            ..data.replace(
              TextFontCatalogDto(
                (b) => b
                  ..fontVersion = TextFontCatalogDtoFontVersionEnum.n1
                  ..catalogVersion = '1.0.0'
                  ..assetBaseUrl = 'https://assets.example/'
                  ..fonts.replace([])
                  ..manifest.replace(
                    TextFontManifestDto(
                      (b) => b
                        ..path = descriptor.path
                        ..sha256 = hash
                        ..bytes = bytes.length,
                    ),
                  ),
              ),
            ),
        ),
      ),
    );
    final service = TextFontService(api, cache: cache);
    final first = await service.load();
    expect(first.manifest!.fonts.length, 17);
    first.requests = 17;
    first.registeredBytes = 1000;
    expect(identical(await service.retry(), first), isTrue);
    expect(first.requests, 17);
    expect(first.registeredBytes, 1000);
    verify(
      () => meta.textFontsGetCatalog(extra: any(named: 'extra')),
    ).called(2);
    when(() => meta.textFontsGetCatalog(extra: any(named: 'extra'))).thenThrow(
      DioException(requestOptions: RequestOptions(path: '/meta/text-fonts')),
    );
    final offline = await TextFontService(api, cache: cache).load();
    expect(offline.assetsAvailable, isFalse);
    expect(offline.manifest!.fonts.length, 17);
    expect(offline.requests, 0);
  });
}
