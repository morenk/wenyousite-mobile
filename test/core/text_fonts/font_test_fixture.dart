import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';

class FontTestFixture {
  FontTestFixture({bool alias = false, bool jsonNotice = false}) {
    notice = asset(
      jsonNotice ? utf8.encode('{"attribution":"fixture"}') : [9],
      jsonNotice ? 'json' : 'txt',
    );
    a = asset([1, 2, 3], 'ttf');
    b = alias ? a : asset([4, 5, 6], 'ttf');
    manifestBytes = Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'schemaVersion': 1,
          'fontVersion': 1,
          'fonts': [
            {
              'id': 'wenkai',
              'name': '测试字体',
              'designLanguage': 'zh',
              'deliveryMode': 'subset',
              'availability': 'ready',
              'notices': [notice.toJson()],
              'shards': [
                {
                  'id': 'a',
                  'family': 'WYF1-abc-a',
                  'mobile': a.toJson(),
                  'unicodeRanges': ['U+0041'],
                },
                {
                  'id': 'b',
                  'family': 'WYF1-abc-b',
                  'mobile': b.toJson(),
                  'unicodeRanges': ['U+0042'],
                },
              ],
            },
          ],
        }),
      ),
    );
    manifest = TextFontManifest(manifestBytes);
    descriptor = asset(manifestBytes, 'json');
  }
  final data = <String, Uint8List>{};
  late final TextFontAsset notice, a, b, descriptor;
  late final Uint8List manifestBytes;
  late final TextFontManifest manifest;
  TextFontAsset asset(List<int> bytes, String extension) {
    final value = Uint8List.fromList(bytes);
    final hash = sha256.convert(value).toString();
    data[hash] = value;
    return TextFontAsset(
      path: 'fonts/v1/$hash.$extension',
      hash: hash,
      bytes: value.length,
    );
  }

  Map<String, dynamic> policy() {
    final value =
        jsonDecode(
              File(
                'contracts/thread-font-runtime-policy-v2.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    value['manifestSha256'] = descriptor.hash;
    (value['mobile'] as Map)['registration']['snapshot'] = {
      'assetCount': a.hash == b.hash ? 1 : 2,
      'totalAssetBytes': a.hash == b.hash ? 3 : 6,
      'registrationCount': 2,
      'totalRegistrationAssetBytes': 6,
    };
    return value;
  }

  Uint8List envelope(Object body) => Uint8List.fromList(
    utf8.encode(jsonEncode({'code': 0, 'message': 'OK', 'data': body})),
  );
  Map<String, Object?> catalog({bool withdrawn = false}) => {
    'fontVersion': 1,
    'catalogVersion': '1.2.0',
    'fonts': [],
    'assetBaseUrl': withdrawn ? null : 'https://assets.example/',
    'manifest': descriptor.toJson(),
  };
}

class MemoryFontCache extends TextFontCache {
  MemoryFontCache([Directory? directory])
    : super(directory ?? Directory.systemTemp);
  final values = <String, Uint8List>{};
  bool broken = false;
  @override
  Future<Uint8List?> read(TextFontAsset asset) async {
    if (broken) throw const FileSystemException('模拟磁盘失败');
    return values[asset.hash];
  }

  @override
  Future<void> write(TextFontAsset asset, Uint8List bytes) async {
    if (broken) throw const FileSystemException('模拟磁盘失败');
    values[asset.hash] = bytes;
  }
}
