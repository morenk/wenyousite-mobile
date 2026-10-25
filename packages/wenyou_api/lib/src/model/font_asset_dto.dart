//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'font_asset_dto.g.dart';

/// FontAssetDto
///
/// Properties:
/// * [sha256]
/// * [bytes]
/// * [format]
@BuiltValue()
abstract class FontAssetDto implements Built<FontAssetDto, FontAssetDtoBuilder> {
  @BuiltValueField(wireName: r'sha256')
  String get sha256;

  @BuiltValueField(wireName: r'bytes')
  int get bytes;

  @BuiltValueField(wireName: r'format')
  FontAssetDtoFormatEnum get format;
  // enum formatEnum {  woff2,  ttf,  otf,  json,  png,  };

  FontAssetDto._();

  factory FontAssetDto([void updates(FontAssetDtoBuilder b)]) = _$FontAssetDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FontAssetDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FontAssetDto> get serializer => _$FontAssetDtoSerializer();
}

class _$FontAssetDtoSerializer implements PrimitiveSerializer<FontAssetDto> {
  @override
  final Iterable<Type> types = const [FontAssetDto, _$FontAssetDto];

  @override
  final String wireName = r'FontAssetDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FontAssetDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sha256';
    yield serializers.serialize(
      object.sha256,
      specifiedType: const FullType(String),
    );
    yield r'bytes';
    yield serializers.serialize(
      object.bytes,
      specifiedType: const FullType(int),
    );
    yield r'format';
    yield serializers.serialize(
      object.format,
      specifiedType: const FullType(FontAssetDtoFormatEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FontAssetDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FontAssetDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sha256':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sha256 = valueDes;
          break;
        case r'bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.bytes = valueDes;
          break;
        case r'format':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontAssetDtoFormatEnum),
          ) as FontAssetDtoFormatEnum;
          result.format = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FontAssetDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FontAssetDtoBuilder();
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

class FontAssetDtoFormatEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'woff2')
  static const FontAssetDtoFormatEnum woff2 = _$fontAssetDtoFormatEnum_woff2;
  @BuiltValueEnumConst(wireName: r'ttf')
  static const FontAssetDtoFormatEnum ttf = _$fontAssetDtoFormatEnum_ttf;
  @BuiltValueEnumConst(wireName: r'otf')
  static const FontAssetDtoFormatEnum otf = _$fontAssetDtoFormatEnum_otf;
  @BuiltValueEnumConst(wireName: r'json')
  static const FontAssetDtoFormatEnum json = _$fontAssetDtoFormatEnum_json;
  @BuiltValueEnumConst(wireName: r'png')
  static const FontAssetDtoFormatEnum png = _$fontAssetDtoFormatEnum_png;
  @BuiltValueEnumConst(wireName: r'unknown_default_open_api', fallback: true)
  static const FontAssetDtoFormatEnum unknownDefaultOpenApi = _$fontAssetDtoFormatEnum_unknownDefaultOpenApi;

  static Serializer<FontAssetDtoFormatEnum> get serializer => _$fontAssetDtoFormatEnumSerializer;

  const FontAssetDtoFormatEnum._(String name): super(name);

  static BuiltSet<FontAssetDtoFormatEnum> get values => _$fontAssetDtoFormatEnumValues;
  static FontAssetDtoFormatEnum valueOf(String name) => _$fontAssetDtoFormatEnumValueOf(name);
}
