//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/text_font_runtime_policy_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'text_fonts_get_runtime_policy200_response.g.dart';

/// TextFontsGetRuntimePolicy200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class TextFontsGetRuntimePolicy200Response implements ApiSuccessEnvelope, Built<TextFontsGetRuntimePolicy200Response, TextFontsGetRuntimePolicy200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  TextFontRuntimePolicyDto get data;

  TextFontsGetRuntimePolicy200Response._();

  factory TextFontsGetRuntimePolicy200Response([void updates(TextFontsGetRuntimePolicy200ResponseBuilder b)]) = _$TextFontsGetRuntimePolicy200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TextFontsGetRuntimePolicy200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TextFontsGetRuntimePolicy200Response> get serializer => _$TextFontsGetRuntimePolicy200ResponseSerializer();
}

class _$TextFontsGetRuntimePolicy200ResponseSerializer implements PrimitiveSerializer<TextFontsGetRuntimePolicy200Response> {
  @override
  final Iterable<Type> types = const [TextFontsGetRuntimePolicy200Response, _$TextFontsGetRuntimePolicy200Response];

  @override
  final String wireName = r'TextFontsGetRuntimePolicy200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TextFontsGetRuntimePolicy200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(TextFontRuntimePolicyDto),
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
    TextFontsGetRuntimePolicy200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TextFontsGetRuntimePolicy200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TextFontRuntimePolicyDto),
          ) as TextFontRuntimePolicyDto;
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
  TextFontsGetRuntimePolicy200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TextFontsGetRuntimePolicy200ResponseBuilder();
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

class TextFontsGetRuntimePolicy200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const TextFontsGetRuntimePolicy200ResponseCodeEnum number0 = _$textFontsGetRuntimePolicy200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const TextFontsGetRuntimePolicy200ResponseCodeEnum unknownDefaultOpenApi = _$textFontsGetRuntimePolicy200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<TextFontsGetRuntimePolicy200ResponseCodeEnum> get serializer => _$textFontsGetRuntimePolicy200ResponseCodeEnumSerializer;

  const TextFontsGetRuntimePolicy200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<TextFontsGetRuntimePolicy200ResponseCodeEnum> get values => _$textFontsGetRuntimePolicy200ResponseCodeEnumValues;
  static TextFontsGetRuntimePolicy200ResponseCodeEnum valueOf(String name) => _$textFontsGetRuntimePolicy200ResponseCodeEnumValueOf(name);
}
