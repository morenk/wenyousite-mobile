import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';

void main() {
  test('动态目录的数字 fontVersion=2 不落入未知枚举并保持数值往返', () {
    final value = <String, Object?>{
      'fontVersion': 2,
      'releaseId': 'tfc_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      'revision': 1,
      'items': [],
      'nextCursor': null,
    };
    final dto = standardSerializers.deserializeWith(
      FontCatalogPageDto.serializer,
      value,
    )!;
    expect(dto.fontVersion, FontCatalogPageDtoFontVersionEnum.n2);
    final encoded =
        standardSerializers.serializeWith(FontCatalogPageDto.serializer, dto)
            as Map;
    expect(encoded['fontVersion'], 2);
  });
  test('撤回描述符的数字版本保持数值往返', () {
    final value = <String, Object?>{
      'fontVersion': 2,
      'versionId': 'tfv_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      'familyId': 'tff_bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      'versionNumber': 1,
      'name': '测试字体',
      'designLanguage': 'zh',
      'revision': 2,
      'status': 'withdrawn',
      'selectable': false,
      'pasteAllowed': false,
      'renderAllowed': false,
      'manifest': null,
      'specimen': null,
      'assetBasePath': null,
    };
    final dto = standardSerializers.deserializeWith(
      FontVersionDescriptorDto.serializer,
      value,
    )!;
    expect(dto.fontVersion, FontVersionDescriptorDtoFontVersionEnum.n2);
    final encoded =
        standardSerializers.serializeWith(
              FontVersionDescriptorDto.serializer,
              dto,
            )
            as Map;
    expect(encoded['fontVersion'], 2);
  });
}
