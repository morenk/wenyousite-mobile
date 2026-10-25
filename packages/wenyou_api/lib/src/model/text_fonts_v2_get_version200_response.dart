//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/font_version_descriptor_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'text_fonts_v2_get_version200_response.g.dart';

/// TextFontsV2GetVersion200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class TextFontsV2GetVersion200Response implements ApiSuccessEnvelope, Built<TextFontsV2GetVersion200Response, TextFontsV2GetVersion200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  FontVersionDescriptorDto get data;

  TextFontsV2GetVersion200Response._();

  factory TextFontsV2GetVersion200Response([void updates(TextFontsV2GetVersion200ResponseBuilder b)]) = _$TextFontsV2GetVersion200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TextFontsV2GetVersion200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TextFontsV2GetVersion200Response> get serializer => _$TextFontsV2GetVersion200ResponseSerializer();
}

class _$TextFontsV2GetVersion200ResponseSerializer implements PrimitiveSerializer<TextFontsV2GetVersion200Response> {
  @override
  final Iterable<Type> types = const [TextFontsV2GetVersion200Response, _$TextFontsV2GetVersion200Response];

  @override
  final String wireName = r'TextFontsV2GetVersion200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TextFontsV2GetVersion200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(FontVersionDescriptorDto),
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
    TextFontsV2GetVersion200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TextFontsV2GetVersion200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FontVersionDescriptorDto),
          ) as FontVersionDescriptorDto;
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
  TextFontsV2GetVersion200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TextFontsV2GetVersion200ResponseBuilder();
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

class TextFontsV2GetVersion200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const TextFontsV2GetVersion200ResponseCodeEnum number0 = _$textFontsV2GetVersion200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const TextFontsV2GetVersion200ResponseCodeEnum unknownDefaultOpenApi = _$textFontsV2GetVersion200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<TextFontsV2GetVersion200ResponseCodeEnum> get serializer => _$textFontsV2GetVersion200ResponseCodeEnumSerializer;

  const TextFontsV2GetVersion200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<TextFontsV2GetVersion200ResponseCodeEnum> get values => _$textFontsV2GetVersion200ResponseCodeEnumValues;
  static TextFontsV2GetVersion200ResponseCodeEnum valueOf(String name) => _$textFontsV2GetVersion200ResponseCodeEnumValueOf(name);
}
