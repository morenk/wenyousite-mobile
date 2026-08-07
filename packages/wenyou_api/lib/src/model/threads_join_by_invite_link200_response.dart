//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/joined_thread_member_response_dto.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'threads_join_by_invite_link200_response.g.dart';

/// ThreadsJoinByInviteLink200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadsJoinByInviteLink200Response implements ApiSuccessEnvelope, Built<ThreadsJoinByInviteLink200Response, ThreadsJoinByInviteLink200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  JoinedThreadMemberResponseDto get data;

  ThreadsJoinByInviteLink200Response._();

  factory ThreadsJoinByInviteLink200Response([void updates(ThreadsJoinByInviteLink200ResponseBuilder b)]) = _$ThreadsJoinByInviteLink200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadsJoinByInviteLink200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadsJoinByInviteLink200Response> get serializer => _$ThreadsJoinByInviteLink200ResponseSerializer();
}

class _$ThreadsJoinByInviteLink200ResponseSerializer implements PrimitiveSerializer<ThreadsJoinByInviteLink200Response> {
  @override
  final Iterable<Type> types = const [ThreadsJoinByInviteLink200Response, _$ThreadsJoinByInviteLink200Response];

  @override
  final String wireName = r'ThreadsJoinByInviteLink200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadsJoinByInviteLink200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(JoinedThreadMemberResponseDto),
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
    ThreadsJoinByInviteLink200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadsJoinByInviteLink200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JoinedThreadMemberResponseDto),
          ) as JoinedThreadMemberResponseDto;
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
  ThreadsJoinByInviteLink200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadsJoinByInviteLink200ResponseBuilder();
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

class ThreadsJoinByInviteLink200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadsJoinByInviteLink200ResponseCodeEnum number0 = _$threadsJoinByInviteLink200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadsJoinByInviteLink200ResponseCodeEnum unknownDefaultOpenApi = _$threadsJoinByInviteLink200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadsJoinByInviteLink200ResponseCodeEnum> get serializer => _$threadsJoinByInviteLink200ResponseCodeEnumSerializer;

  const ThreadsJoinByInviteLink200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadsJoinByInviteLink200ResponseCodeEnum> get values => _$threadsJoinByInviteLink200ResponseCodeEnumValues;
  static ThreadsJoinByInviteLink200ResponseCodeEnum valueOf(String name) => _$threadsJoinByInviteLink200ResponseCodeEnumValueOf(name);
}
