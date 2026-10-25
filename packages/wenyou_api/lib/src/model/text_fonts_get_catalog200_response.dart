//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/text_font_catalog_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'text_fonts_get_catalog200_response.g.dart';

/// TextFontsGetCatalog200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class TextFontsGetCatalog200Response implements ApiSuccessEnvelope, Built<TextFontsGetCatalog200Response, TextFontsGetCatalog200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  TextFontCatalogDto get data;

  TextFontsGetCatalog200Response._();

  factory TextFontsGetCatalog200Response([void updates(TextFontsGetCatalog200ResponseBuilder b)]) = _$TextFontsGetCatalog200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TextFontsGetCatalog200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TextFontsGetCatalog200Response> get serializer => _$TextFontsGetCatalog200ResponseSerializer();
}

class _$TextFontsGetCatalog200ResponseSerializer implements PrimitiveSerializer<TextFontsGetCatalog200Response> {
  @override
  final Iterable<Type> types = const [TextFontsGetCatalog200Response, _$TextFontsGetCatalog200Response];

  @override
  final String wireName = r'TextFontsGetCatalog200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TextFontsGetCatalog200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(TextFontCatalogDto),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TextFontsGetCatalog200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TextFontsGetCatalog200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TextFontCatalogDto),
          ) as TextFontCatalogDto;
          result.data.replace(valueDes);
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiSuccessEnvelopeCodeEnum),
          ) as ApiSuccessEnvelopeCodeEnum;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TextFontsGetCatalog200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TextFontsGetCatalog200ResponseBuilder();
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

class TextFontsGetCatalog200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const TextFontsGetCatalog200ResponseCodeEnum number0 = _$textFontsGetCatalog200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const TextFontsGetCatalog200ResponseCodeEnum unknownDefaultOpenApi = _$textFontsGetCatalog200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<TextFontsGetCatalog200ResponseCodeEnum> get serializer => _$textFontsGetCatalog200ResponseCodeEnumSerializer;

  const TextFontsGetCatalog200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<TextFontsGetCatalog200ResponseCodeEnum> get values => _$textFontsGetCatalog200ResponseCodeEnumValues;
  static TextFontsGetCatalog200ResponseCodeEnum valueOf(String name) => _$textFontsGetCatalog200ResponseCodeEnumValueOf(name);
}
