//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/text_font_manifest_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/text_font_family_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'text_font_catalog_dto.g.dart';

/// TextFontCatalogDto
///
/// Properties:
/// * [fontVersion]
/// * [catalogVersion]
/// * [assetBaseUrl] - 运营配置的自有静态分发前缀，末尾为 /；未发布时 null，不直接访问第三方上游。
/// * [manifest]
/// * [fonts]
@BuiltValue()
abstract class TextFontCatalogDto implements Built<TextFontCatalogDto, TextFontCatalogDtoBuilder> {
  @BuiltValueField(wireName: r'fontVersion')
  TextFontCatalogDtoFontVersionEnum get fontVersion;
  // enum fontVersionEnum {  1,  };

  @BuiltValueField(wireName: r'catalogVersion')
  String get catalogVersion;

  /// 运营配置的自有静态分发前缀，末尾为 /；未发布时 null，不直接访问第三方上游。
  @BuiltValueField(wireName: r'assetBaseUrl')
  String? get assetBaseUrl;

  @BuiltValueField(wireName: r'manifest')
  TextFontManifestDto? get manifest;

  @BuiltValueField(wireName: r'fonts')
  BuiltList<TextFontFamilyDto> get fonts;

  TextFontCatalogDto._();

  factory TextFontCatalogDto([void updates(TextFontCatalogDtoBuilder b)]) = _$TextFontCatalogDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TextFontCatalogDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TextFontCatalogDto> get serializer => _$TextFontCatalogDtoSerializer();
}

class _$TextFontCatalogDtoSerializer implements PrimitiveSerializer<TextFontCatalogDto> {
  @override
  final Iterable<Type> types = const [TextFontCatalogDto, _$TextFontCatalogDto];

  @override
  final String wireName = r'TextFontCatalogDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TextFontCatalogDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fontVersion';
    yield serializers.serialize(
      object.fontVersion,
      specifiedType: const FullType(TextFontCatalogDtoFontVersionEnum),
    );
    yield r'catalogVersion';
    yield serializers.serialize(
      object.catalogVersion,
      specifiedType: const FullType(String),
    );
    yield r'assetBaseUrl';
    yield object.assetBaseUrl == null ? null : serializers.serialize(
      object.assetBaseUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'manifest';
    yield object.manifest == null ? null : serializers.serialize(
      object.manifest,
      specifiedType: const FullType.nullable(TextFontManifestDto),
    );
    yield r'fonts';
    yield serializers.serialize(
      object.fonts,
      specifiedType: const FullType(BuiltList, [FullType(TextFontFamilyDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TextFontCatalogDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TextFontCatalogDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fontVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TextFontCatalogDtoFontVersionEnum),
          ) as TextFontCatalogDtoFontVersionEnum;
          result.fontVersion = valueDes;
          break;
        case r'catalogVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.catalogVersion = valueDes;
          break;
        case r'assetBaseUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.assetBaseUrl = valueDes;
          break;
        case r'manifest':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(TextFontManifestDto),
          ) as TextFontManifestDto?;
          if (valueDes == null) continue;
          result.manifest.replace(valueDes);
          break;
        case r'fonts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TextFontFamilyDto)]),
          ) as BuiltList<TextFontFamilyDto>;
          result.fonts.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TextFontCatalogDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TextFontCatalogDtoBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class TextFontCatalogDtoFontVersionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'1')
  static const TextFontCatalogDtoFontVersionEnum n1 = _$textFontCatalogDtoFontVersionEnum_n1;
  @BuiltValueEnumConst(wireName: r'11184809', fallback: true)
  static const TextFontCatalogDtoFontVersionEnum unknownDefaultOpenApi = _$textFontCatalogDtoFontVersionEnum_unknownDefaultOpenApi;

  static Serializer<TextFontCatalogDtoFontVersionEnum> get serializer => _$textFontCatalogDtoFontVersionEnumSerializer;

  const TextFontCatalogDtoFontVersionEnum._(String name): super(name);

  static BuiltSet<TextFontCatalogDtoFontVersionEnum> get values => _$textFontCatalogDtoFontVersionEnumValues;
  static TextFontCatalogDtoFontVersionEnum valueOf(String name) => _$textFontCatalogDtoFontVersionEnumValueOf(name);
}
