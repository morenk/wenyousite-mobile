//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'threads_remove200_response.g.dart';

/// ThreadsRemove200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadsRemove200Response implements ApiSuccessEnvelope, Built<ThreadsRemove200Response, ThreadsRemove200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  ThreadsRemove200Response._();

  factory ThreadsRemove200Response([void updates(ThreadsRemove200ResponseBuilder b)]) = _$ThreadsRemove200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadsRemove200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadsRemove200Response> get serializer => _$ThreadsRemove200ResponseSerializer();
}

class _$ThreadsRemove200ResponseSerializer implements PrimitiveSerializer<ThreadsRemove200Response> {
  @override
  final Iterable<Type> types = const [ThreadsRemove200Response, _$ThreadsRemove200Response];

  @override
  final String wireName = r'ThreadsRemove200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadsRemove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MessageResponseDto),
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
    ThreadsRemove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadsRemove200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MessageResponseDto),
          ) as MessageResponseDto;
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
  ThreadsRemove200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadsRemove200ResponseBuilder();
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

class ThreadsRemove200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadsRemove200ResponseCodeEnum number0 = _$threadsRemove200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadsRemove200ResponseCodeEnum unknownDefaultOpenApi = _$threadsRemove200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadsRemove200ResponseCodeEnum> get serializer => _$threadsRemove200ResponseCodeEnumSerializer;

  const ThreadsRemove200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadsRemove200ResponseCodeEnum> get values => _$threadsRemove200ResponseCodeEnumValues;
  static ThreadsRemove200ResponseCodeEnum valueOf(String name) => _$threadsRemove200ResponseCodeEnumValueOf(name);
}
