import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:wenyou_api/wenyou_api.dart';

class DynamicFontFixture {
  DynamicFontFixture({
    int identity = 1,
    String? versionId,
    String? alias,
    List<int> fontBytes = const [1, 2, 3],
  }) {
    id = versionId ?? 'tfv_${identity.toRadixString(16).padLeft(32, '0')}';
    family = alias ?? 'WYF2-${id.substring(4)}-core';
    base = '/api/v1/meta/text-fonts/v2/versions/$id/assets/';
    font = asset(fontBytes, 'ttf');
    specimen = asset([137, 80, 78, 71], 'png');
    final manifest = {
      'manifestVersion': 2,
      'buildKey': 'a' * 64,
      'sourceSha256': 'b' * 64,
      'baseWeight': 400,
      'baseStyle': 'normal',
      'coverage': {
        'unicodeRanges': ['U+0041'],
        'codepointCount': 1,
      },
      'shards': [
        {
          'id': 'core',
          'family': family,
          'unicodeRanges': ['U+0041'],
          'codepointCount': 1,
          'web': asset([4, 5], 'woff2'),
          'mobile': font,
        },
      ],
      'notices': [asset(utf8.encode('{}'), 'json')],
      'specimen': specimen,
    };
    manifestBytes = Uint8List.fromList(utf8.encode(jsonEncode(manifest)));
    manifestAsset = asset(manifestBytes, 'json');
  }
  late final String id, family, base;
  late final Map<String, Object> font, specimen, manifestAsset;
  late final Uint8List manifestBytes;
  final data = <String, Uint8List>{};
  Map<String, Object> asset(List<int> value, String format) {
    final bytes = Uint8List.fromList(value),
        hash = sha256.convert(value).toString();
    data['$base$hash.$format'] = bytes;
    return {'sha256': hash, 'bytes': bytes.length, 'format': format};
  }

  Map<String, Object?> descriptor({
    int revision = 1,
    bool current = true,
    bool enabled = true,
    bool withdrawn = false,
  }) => {
    'fontVersion': 2,
    'versionId': id,
    'familyId': 'tff_${id.substring(4)}',
    'versionNumber': 1,
    'name': '动态字体',
    'designLanguage': 'zh',
    'revision': revision,
    'status': withdrawn
        ? 'withdrawn'
        : enabled
        ? 'published'
        : 'disabled',
    'selectable': current && enabled && !withdrawn,
    'pasteAllowed': enabled && !withdrawn,
    'renderAllowed': !withdrawn,
    'assetBasePath': withdrawn ? null : base,
    'manifest': withdrawn ? null : manifestAsset,
    'specimen': withdrawn ? null : specimen,
  };
  FontVersionDescriptorDto dto({
    int revision = 1,
    bool current = true,
    bool enabled = true,
    bool withdrawn = false,
  }) => standardSerializers.deserializeWith(
    FontVersionDescriptorDto.serializer,
    descriptor(
      revision: revision,
      current: current,
      enabled: enabled,
      withdrawn: withdrawn,
    ),
  )!;
  Map<String, Object?> get entry => {
    'versionId': id,
    'familyId': 'tff_${id.substring(4)}',
    'name': '动态字体',
    'designLanguage': 'zh',
    'sortOrder': 0,
    'selectable': true,
    'pasteAllowed': true,
    'renderAllowed': true,
    'assetBasePath': base,
    'specimen': specimen,
  };
  Map<String, Object?> page({
    int revision = 1,
    List<Object?>? items,
    String? cursor,
  }) => {
    'fontVersion': 2,
    'releaseId': 'tfc_${revision.toRadixString(16).padLeft(32, '0')}',
    'revision': revision,
    'items': items ?? [entry],
    'nextCursor': cursor,
  };
  Uint8List envelope(Object? value) => Uint8List.fromList(
    utf8.encode(jsonEncode({'code': 0, 'data': value, 'message': 'OK'})),
  );
  Map<String, dynamic> get policy =>
      jsonDecode(
            File(
              'contracts/thread-font-runtime-policy-v3.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
}
