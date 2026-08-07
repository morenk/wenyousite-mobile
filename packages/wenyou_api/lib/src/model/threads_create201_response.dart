//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/thread_detail_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'threads_create201_response.g.dart';

/// ThreadsCreate201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadsCreate201Response implements ApiSuccessEnvelope, Built<ThreadsCreate201Response, ThreadsCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ThreadDetailResponseDto get data;

  ThreadsCreate201Response._();

  factory ThreadsCreate201Response([void updates(ThreadsCreate201ResponseBuilder b)]) = _$ThreadsCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadsCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadsCreate201Response> get serializer => _$ThreadsCreate201ResponseSerializer();
}

class _$ThreadsCreate201ResponseSerializer implements PrimitiveSerializer<ThreadsCreate201Response> {
  @override
  final Iterable<Type> types = const [ThreadsCreate201Response, _$ThreadsCreate201Response];

  @override
  final String wireName = r'ThreadsCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadsCreate201Response object, {
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
    ThreadsCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadsCreate201ResponseBuilder result,
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
  ThreadsCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadsCreate201ResponseBuilder();
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

class ThreadsCreate201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadsCreate201ResponseCodeEnum number0 = _$threadsCreate201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadsCreate201ResponseCodeEnum unknownDefaultOpenApi = _$threadsCreate201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadsCreate201ResponseCodeEnum> get serializer => _$threadsCreate201ResponseCodeEnumSerializer;

  const ThreadsCreate201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadsCreate201ResponseCodeEnum> get values => _$threadsCreate201ResponseCodeEnumValues;
  static ThreadsCreate201ResponseCodeEnum valueOf(String name) => _$threadsCreate201ResponseCodeEnumValueOf(name);
}
