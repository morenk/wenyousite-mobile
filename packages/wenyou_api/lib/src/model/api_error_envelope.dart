//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/business_error_code.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'api_error_envelope.g.dart';

/// ApiErrorEnvelope
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ApiErrorEnvelope implements Built<ApiErrorEnvelope, ApiErrorEnvelopeBuilder> {
  @BuiltValueField(wireName: r'code')
  BusinessErrorCode get code;
  // enum codeEnum {  0,  40000,  40001,  40002,  40003,  40004,  40005,  40006,  40007,  40008,  40100,  40101,  40102,  40103,  40104,  40105,  40106,  40107,  40108,  40109,  40110,  40111,  40112,  40113,  40114,  40115,  40116,  40300,  40301,  40302,  40303,  40304,  40305,  40306,  40307,  40308,  40309,  40400,  40401,  40402,  40403,  40404,  40405,  40406,  40407,  40408,  40409,  40410,  40411,  40412,  40413,  40414,  40415,  40900,  40901,  40902,  40903,  40904,  40905,  40906,  40907,  40908,  40909,  40910,  40911,  40912,  40913,  40914,  40915,  40916,  40917,  40918,  40919,  42900,  50000,  };

  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'data')
  JsonObject? get data;

  ApiErrorEnvelope._();

  factory ApiErrorEnvelope([void updates(ApiErrorEnvelopeBuilder b)]) = _$ApiErrorEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ApiErrorEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApiErrorEnvelope> get serializer => _$ApiErrorEnvelopeSerializer();
}

class _$ApiErrorEnvelopeSerializer implements PrimitiveSerializer<ApiErrorEnvelope> {
  @override
  final Iterable<Type> types = const [ApiErrorEnvelope, _$ApiErrorEnvelope];

  @override
  final String wireName = r'ApiErrorEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApiErrorEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(BusinessErrorCode),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'data';
    yield object.data == null ? null : serializers.serialize(
      object.data,
      specifiedType: const FullType.nullable(JsonObject),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ApiErrorEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ApiErrorEnvelopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BusinessErrorCode),
          ) as BusinessErrorCode;
          result.code = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.data = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ApiErrorEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ApiErrorEnvelopeBuilder();
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
