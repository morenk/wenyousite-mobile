//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/dynamic_font_runtime_policy_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'text_fonts_v2_get_runtime_policy200_response.g.dart';

/// TextFontsV2GetRuntimePolicy200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class TextFontsV2GetRuntimePolicy200Response implements ApiSuccessEnvelope, Built<TextFontsV2GetRuntimePolicy200Response, TextFontsV2GetRuntimePolicy200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DynamicFontRuntimePolicyDto get data;

  TextFontsV2GetRuntimePolicy200Response._();

  factory TextFontsV2GetRuntimePolicy200Response([void updates(TextFontsV2GetRuntimePolicy200ResponseBuilder b)]) = _$TextFontsV2GetRuntimePolicy200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TextFontsV2GetRuntimePolicy200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TextFontsV2GetRuntimePolicy200Response> get serializer => _$TextFontsV2GetRuntimePolicy200ResponseSerializer();
}

class _$TextFontsV2GetRuntimePolicy200ResponseSerializer implements PrimitiveSerializer<TextFontsV2GetRuntimePolicy200Response> {
  @override
  final Iterable<Type> types = const [TextFontsV2GetRuntimePolicy200Response, _$TextFontsV2GetRuntimePolicy200Response];

  @override
  final String wireName = r'TextFontsV2GetRuntimePolicy200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TextFontsV2GetRuntimePolicy200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DynamicFontRuntimePolicyDto),
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
    TextFontsV2GetRuntimePolicy200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TextFontsV2GetRuntimePolicy200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DynamicFontRuntimePolicyDto),
          ) as DynamicFontRuntimePolicyDto;
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
  TextFontsV2GetRuntimePolicy200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TextFontsV2GetRuntimePolicy200ResponseBuilder();
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

class TextFontsV2GetRuntimePolicy200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const TextFontsV2GetRuntimePolicy200ResponseCodeEnum number0 = _$textFontsV2GetRuntimePolicy200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const TextFontsV2GetRuntimePolicy200ResponseCodeEnum unknownDefaultOpenApi = _$textFontsV2GetRuntimePolicy200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<TextFontsV2GetRuntimePolicy200ResponseCodeEnum> get serializer => _$textFontsV2GetRuntimePolicy200ResponseCodeEnumSerializer;

  const TextFontsV2GetRuntimePolicy200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<TextFontsV2GetRuntimePolicy200ResponseCodeEnum> get values => _$textFontsV2GetRuntimePolicy200ResponseCodeEnumValues;
  static TextFontsV2GetRuntimePolicy200ResponseCodeEnum valueOf(String name) => _$textFontsV2GetRuntimePolicy200ResponseCodeEnumValueOf(name);
}
