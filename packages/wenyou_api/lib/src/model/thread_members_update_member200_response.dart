//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/thread_member_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_members_update_member200_response.g.dart';

/// ThreadMembersUpdateMember200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadMembersUpdateMember200Response implements ApiSuccessEnvelope, Built<ThreadMembersUpdateMember200Response, ThreadMembersUpdateMember200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ThreadMemberResponseDto get data;

  ThreadMembersUpdateMember200Response._();

  factory ThreadMembersUpdateMember200Response([void updates(ThreadMembersUpdateMember200ResponseBuilder b)]) = _$ThreadMembersUpdateMember200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadMembersUpdateMember200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadMembersUpdateMember200Response> get serializer => _$ThreadMembersUpdateMember200ResponseSerializer();
}

class _$ThreadMembersUpdateMember200ResponseSerializer implements PrimitiveSerializer<ThreadMembersUpdateMember200Response> {
  @override
  final Iterable<Type> types = const [ThreadMembersUpdateMember200Response, _$ThreadMembersUpdateMember200Response];

  @override
  final String wireName = r'ThreadMembersUpdateMember200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadMembersUpdateMember200Response object, {
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
    ThreadMembersUpdateMember200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadMembersUpdateMember200ResponseBuilder result,
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
  ThreadMembersUpdateMember200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadMembersUpdateMember200ResponseBuilder();
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

class ThreadMembersUpdateMember200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadMembersUpdateMember200ResponseCodeEnum number0 = _$threadMembersUpdateMember200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadMembersUpdateMember200ResponseCodeEnum unknownDefaultOpenApi = _$threadMembersUpdateMember200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadMembersUpdateMember200ResponseCodeEnum> get serializer => _$threadMembersUpdateMember200ResponseCodeEnumSerializer;

  const ThreadMembersUpdateMember200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadMembersUpdateMember200ResponseCodeEnum> get values => _$threadMembersUpdateMember200ResponseCodeEnumValues;
  static ThreadMembersUpdateMember200ResponseCodeEnum valueOf(String name) => _$threadMembersUpdateMember200ResponseCodeEnumValueOf(name);
}
