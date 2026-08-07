//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/thread_like_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'threads_unlike200_response.g.dart';

/// ThreadsUnlike200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadsUnlike200Response implements ApiSuccessEnvelope, Built<ThreadsUnlike200Response, ThreadsUnlike200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ThreadLikeResponseDto get data;

  ThreadsUnlike200Response._();

  factory ThreadsUnlike200Response([void updates(ThreadsUnlike200ResponseBuilder b)]) = _$ThreadsUnlike200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadsUnlike200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadsUnlike200Response> get serializer => _$ThreadsUnlike200ResponseSerializer();
}

class _$ThreadsUnlike200ResponseSerializer implements PrimitiveSerializer<ThreadsUnlike200Response> {
  @override
  final Iterable<Type> types = const [ThreadsUnlike200Response, _$ThreadsUnlike200Response];

  @override
  final String wireName = r'ThreadsUnlike200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadsUnlike200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ThreadLikeResponseDto),
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
    ThreadsUnlike200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadsUnlike200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadLikeResponseDto),
          ) as ThreadLikeResponseDto;
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
  ThreadsUnlike200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadsUnlike200ResponseBuilder();
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

class ThreadsUnlike200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadsUnlike200ResponseCodeEnum number0 = _$threadsUnlike200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadsUnlike200ResponseCodeEnum unknownDefaultOpenApi = _$threadsUnlike200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadsUnlike200ResponseCodeEnum> get serializer => _$threadsUnlike200ResponseCodeEnumSerializer;

  const ThreadsUnlike200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadsUnlike200ResponseCodeEnum> get values => _$threadsUnlike200ResponseCodeEnumValues;
  static ThreadsUnlike200ResponseCodeEnum valueOf(String name) => _$threadsUnlike200ResponseCodeEnumValueOf(name);
}
