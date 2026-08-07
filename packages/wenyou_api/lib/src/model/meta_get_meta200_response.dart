//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_meta_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'meta_get_meta200_response.g.dart';

/// MetaGetMeta200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class MetaGetMeta200Response implements ApiSuccessEnvelope, Built<MetaGetMeta200Response, MetaGetMeta200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ApiMetaResponseDto get data;

  MetaGetMeta200Response._();

  factory MetaGetMeta200Response([void updates(MetaGetMeta200ResponseBuilder b)]) = _$MetaGetMeta200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MetaGetMeta200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MetaGetMeta200Response> get serializer => _$MetaGetMeta200ResponseSerializer();
}

class _$MetaGetMeta200ResponseSerializer implements PrimitiveSerializer<MetaGetMeta200Response> {
  @override
  final Iterable<Type> types = const [MetaGetMeta200Response, _$MetaGetMeta200Response];

  @override
  final String wireName = r'MetaGetMeta200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MetaGetMeta200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ApiMetaResponseDto),
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
    MetaGetMeta200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MetaGetMeta200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ApiMetaResponseDto),
          ) as ApiMetaResponseDto;
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
  MetaGetMeta200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MetaGetMeta200ResponseBuilder();
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

class MetaGetMeta200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const MetaGetMeta200ResponseCodeEnum number0 = _$metaGetMeta200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const MetaGetMeta200ResponseCodeEnum unknownDefaultOpenApi = _$metaGetMeta200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<MetaGetMeta200ResponseCodeEnum> get serializer => _$metaGetMeta200ResponseCodeEnumSerializer;

  const MetaGetMeta200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<MetaGetMeta200ResponseCodeEnum> get values => _$metaGetMeta200ResponseCodeEnumValues;
  static MetaGetMeta200ResponseCodeEnum valueOf(String name) => _$metaGetMeta200ResponseCodeEnumValueOf(name);
}
