//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/thread_detail_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'threads_update200_response.g.dart';

/// ThreadsUpdate200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadsUpdate200Response implements ApiSuccessEnvelope, Built<ThreadsUpdate200Response, ThreadsUpdate200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ThreadDetailResponseDto get data;

  ThreadsUpdate200Response._();

  factory ThreadsUpdate200Response([void updates(ThreadsUpdate200ResponseBuilder b)]) = _$ThreadsUpdate200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadsUpdate200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadsUpdate200Response> get serializer => _$ThreadsUpdate200ResponseSerializer();
}

class _$ThreadsUpdate200ResponseSerializer implements PrimitiveSerializer<ThreadsUpdate200Response> {
  @override
  final Iterable<Type> types = const [ThreadsUpdate200Response, _$ThreadsUpdate200Response];

  @override
  final String wireName = r'ThreadsUpdate200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadsUpdate200Response object, {
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
    ThreadsUpdate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadsUpdate200ResponseBuilder result,
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
  ThreadsUpdate200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadsUpdate200ResponseBuilder();
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

class ThreadsUpdate200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadsUpdate200ResponseCodeEnum number0 = _$threadsUpdate200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadsUpdate200ResponseCodeEnum unknownDefaultOpenApi = _$threadsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadsUpdate200ResponseCodeEnum> get serializer => _$threadsUpdate200ResponseCodeEnumSerializer;

  const ThreadsUpdate200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadsUpdate200ResponseCodeEnum> get values => _$threadsUpdate200ResponseCodeEnumValues;
  static ThreadsUpdate200ResponseCodeEnum valueOf(String name) => _$threadsUpdate200ResponseCodeEnumValueOf(name);
}
