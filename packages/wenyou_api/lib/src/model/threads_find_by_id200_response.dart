//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/thread_detail_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'threads_find_by_id200_response.g.dart';

/// ThreadsFindById200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadsFindById200Response implements ApiSuccessEnvelope, Built<ThreadsFindById200Response, ThreadsFindById200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ThreadDetailResponseDto get data;

  ThreadsFindById200Response._();

  factory ThreadsFindById200Response([void updates(ThreadsFindById200ResponseBuilder b)]) = _$ThreadsFindById200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadsFindById200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadsFindById200Response> get serializer => _$ThreadsFindById200ResponseSerializer();
}

class _$ThreadsFindById200ResponseSerializer implements PrimitiveSerializer<ThreadsFindById200Response> {
  @override
  final Iterable<Type> types = const [ThreadsFindById200Response, _$ThreadsFindById200Response];

  @override
  final String wireName = r'ThreadsFindById200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadsFindById200Response object, {
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
    ThreadsFindById200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadsFindById200ResponseBuilder result,
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
  ThreadsFindById200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadsFindById200ResponseBuilder();
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

class ThreadsFindById200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadsFindById200ResponseCodeEnum number0 = _$threadsFindById200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadsFindById200ResponseCodeEnum unknownDefaultOpenApi = _$threadsFindById200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadsFindById200ResponseCodeEnum> get serializer => _$threadsFindById200ResponseCodeEnumSerializer;

  const ThreadsFindById200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadsFindById200ResponseCodeEnum> get values => _$threadsFindById200ResponseCodeEnumValues;
  static ThreadsFindById200ResponseCodeEnum valueOf(String name) => _$threadsFindById200ResponseCodeEnumValueOf(name);
}
