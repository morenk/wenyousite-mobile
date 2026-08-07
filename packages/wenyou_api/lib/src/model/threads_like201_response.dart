//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/thread_like_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'threads_like201_response.g.dart';

/// ThreadsLike201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadsLike201Response implements ApiSuccessEnvelope, Built<ThreadsLike201Response, ThreadsLike201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ThreadLikeResponseDto get data;

  ThreadsLike201Response._();

  factory ThreadsLike201Response([void updates(ThreadsLike201ResponseBuilder b)]) = _$ThreadsLike201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadsLike201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadsLike201Response> get serializer => _$ThreadsLike201ResponseSerializer();
}

class _$ThreadsLike201ResponseSerializer implements PrimitiveSerializer<ThreadsLike201Response> {
  @override
  final Iterable<Type> types = const [ThreadsLike201Response, _$ThreadsLike201Response];

  @override
  final String wireName = r'ThreadsLike201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadsLike201Response object, {
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
    ThreadsLike201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadsLike201ResponseBuilder result,
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
  ThreadsLike201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadsLike201ResponseBuilder();
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

class ThreadsLike201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadsLike201ResponseCodeEnum number0 = _$threadsLike201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadsLike201ResponseCodeEnum unknownDefaultOpenApi = _$threadsLike201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadsLike201ResponseCodeEnum> get serializer => _$threadsLike201ResponseCodeEnumSerializer;

  const ThreadsLike201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadsLike201ResponseCodeEnum> get values => _$threadsLike201ResponseCodeEnumValues;
  static ThreadsLike201ResponseCodeEnum valueOf(String name) => _$threadsLike201ResponseCodeEnumValueOf(name);
}
