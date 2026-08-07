//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/health_check200_response_all_of_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'health_check200_response.g.dart';

/// HealthCheck200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class HealthCheck200Response implements ApiSuccessEnvelope, Built<HealthCheck200Response, HealthCheck200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  HealthCheck200ResponseAllOfData get data;

  HealthCheck200Response._();

  factory HealthCheck200Response([void updates(HealthCheck200ResponseBuilder b)]) = _$HealthCheck200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HealthCheck200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HealthCheck200Response> get serializer => _$HealthCheck200ResponseSerializer();
}

class _$HealthCheck200ResponseSerializer implements PrimitiveSerializer<HealthCheck200Response> {
  @override
  final Iterable<Type> types = const [HealthCheck200Response, _$HealthCheck200Response];

  @override
  final String wireName = r'HealthCheck200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HealthCheck200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(HealthCheck200ResponseAllOfData),
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
    HealthCheck200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required HealthCheck200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HealthCheck200ResponseAllOfData),
          ) as HealthCheck200ResponseAllOfData;
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
  HealthCheck200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HealthCheck200ResponseBuilder();
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

class HealthCheck200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const HealthCheck200ResponseCodeEnum number0 = _$healthCheck200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const HealthCheck200ResponseCodeEnum unknownDefaultOpenApi = _$healthCheck200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<HealthCheck200ResponseCodeEnum> get serializer => _$healthCheck200ResponseCodeEnumSerializer;

  const HealthCheck200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<HealthCheck200ResponseCodeEnum> get values => _$healthCheck200ResponseCodeEnumValues;
  static HealthCheck200ResponseCodeEnum valueOf(String name) => _$healthCheck200ResponseCodeEnumValueOf(name);
}
