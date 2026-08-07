//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/thread_member_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_members_join201_response.g.dart';

/// ThreadMembersJoin201Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadMembersJoin201Response implements ApiSuccessEnvelope, Built<ThreadMembersJoin201Response, ThreadMembersJoin201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ThreadMemberResponseDto get data;

  ThreadMembersJoin201Response._();

  factory ThreadMembersJoin201Response([void updates(ThreadMembersJoin201ResponseBuilder b)]) = _$ThreadMembersJoin201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadMembersJoin201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadMembersJoin201Response> get serializer => _$ThreadMembersJoin201ResponseSerializer();
}

class _$ThreadMembersJoin201ResponseSerializer implements PrimitiveSerializer<ThreadMembersJoin201Response> {
  @override
  final Iterable<Type> types = const [ThreadMembersJoin201Response, _$ThreadMembersJoin201Response];

  @override
  final String wireName = r'ThreadMembersJoin201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadMembersJoin201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ThreadMemberResponseDto),
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
    ThreadMembersJoin201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadMembersJoin201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadMemberResponseDto),
          ) as ThreadMemberResponseDto;
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
  ThreadMembersJoin201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadMembersJoin201ResponseBuilder();
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

class ThreadMembersJoin201ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadMembersJoin201ResponseCodeEnum number0 = _$threadMembersJoin201ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadMembersJoin201ResponseCodeEnum unknownDefaultOpenApi = _$threadMembersJoin201ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadMembersJoin201ResponseCodeEnum> get serializer => _$threadMembersJoin201ResponseCodeEnumSerializer;

  const ThreadMembersJoin201ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadMembersJoin201ResponseCodeEnum> get values => _$threadMembersJoin201ResponseCodeEnumValues;
  static ThreadMembersJoin201ResponseCodeEnum valueOf(String name) => _$threadMembersJoin201ResponseCodeEnumValueOf(name);
}
