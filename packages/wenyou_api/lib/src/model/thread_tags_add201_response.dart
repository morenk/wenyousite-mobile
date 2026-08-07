//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/thread_tag_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_tags_add201_response.g.dart';

/// ThreadTagsAdd201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadTagsAdd201Response implements ApiSuccessEnvelope, Built<ThreadTagsAdd201Response, ThreadTagsAdd201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ThreadTagResponseDto get data;

  ThreadTagsAdd201Response._();

  factory ThreadTagsAdd201Response([void updates(ThreadTagsAdd201ResponseBuilder b)]) = _$ThreadTagsAdd201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadTagsAdd201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadTagsAdd201Response> get serializer => _$ThreadTagsAdd201ResponseSerializer();
}

class _$ThreadTagsAdd201ResponseSerializer implements PrimitiveSerializer<ThreadTagsAdd201Response> {
  @override
  final Iterable<Type> types = const [ThreadTagsAdd201Response, _$ThreadTagsAdd201Response];

  @override
  final String wireName = r'ThreadTagsAdd201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadTagsAdd201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ThreadTagResponseDto),
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
    ThreadTagsAdd201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadTagsAdd201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadTagResponseDto),
          ) as ThreadTagResponseDto;
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
  ThreadTagsAdd201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadTagsAdd201ResponseBuilder();
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

class ThreadTagsAdd201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadTagsAdd201ResponseCodeEnum number0 = _$threadTagsAdd201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadTagsAdd201ResponseCodeEnum unknownDefaultOpenApi = _$threadTagsAdd201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadTagsAdd201ResponseCodeEnum> get serializer => _$threadTagsAdd201ResponseCodeEnumSerializer;

  const ThreadTagsAdd201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadTagsAdd201ResponseCodeEnum> get values => _$threadTagsAdd201ResponseCodeEnumValues;
  static ThreadTagsAdd201ResponseCodeEnum valueOf(String name) => _$threadTagsAdd201ResponseCodeEnumValueOf(name);
}
