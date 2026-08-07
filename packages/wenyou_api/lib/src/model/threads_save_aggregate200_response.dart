//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/thread_detail_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'threads_save_aggregate200_response.g.dart';

/// ThreadsSaveAggregate200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadsSaveAggregate200Response implements ApiSuccessEnvelope, Built<ThreadsSaveAggregate200Response, ThreadsSaveAggregate200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ThreadDetailResponseDto get data;

  ThreadsSaveAggregate200Response._();

  factory ThreadsSaveAggregate200Response([void updates(ThreadsSaveAggregate200ResponseBuilder b)]) = _$ThreadsSaveAggregate200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadsSaveAggregate200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadsSaveAggregate200Response> get serializer => _$ThreadsSaveAggregate200ResponseSerializer();
}

class _$ThreadsSaveAggregate200ResponseSerializer implements PrimitiveSerializer<ThreadsSaveAggregate200Response> {
  @override
  final Iterable<Type> types = const [ThreadsSaveAggregate200Response, _$ThreadsSaveAggregate200Response];

  @override
  final String wireName = r'ThreadsSaveAggregate200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadsSaveAggregate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ThreadDetailResponseDto),
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
    ThreadsSaveAggregate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadsSaveAggregate200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadDetailResponseDto),
          ) as ThreadDetailResponseDto;
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
  ThreadsSaveAggregate200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadsSaveAggregate200ResponseBuilder();
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

class ThreadsSaveAggregate200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadsSaveAggregate200ResponseCodeEnum number0 = _$threadsSaveAggregate200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadsSaveAggregate200ResponseCodeEnum unknownDefaultOpenApi = _$threadsSaveAggregate200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadsSaveAggregate200ResponseCodeEnum> get serializer => _$threadsSaveAggregate200ResponseCodeEnumSerializer;

  const ThreadsSaveAggregate200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadsSaveAggregate200ResponseCodeEnum> get values => _$threadsSaveAggregate200ResponseCodeEnumValues;
  static ThreadsSaveAggregate200ResponseCodeEnum valueOf(String name) => _$threadsSaveAggregate200ResponseCodeEnumValueOf(name);
}
