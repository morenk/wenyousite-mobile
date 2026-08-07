//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:wenyou_api/src/model/invite_link_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'threads_create_invite_link200_response.g.dart';

/// ThreadsCreateInviteLink200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadsCreateInviteLink200Response implements ApiSuccessEnvelope, Built<ThreadsCreateInviteLink200Response, ThreadsCreateInviteLink200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  InviteLinkResponseDto get data;

  ThreadsCreateInviteLink200Response._();

  factory ThreadsCreateInviteLink200Response([void updates(ThreadsCreateInviteLink200ResponseBuilder b)]) = _$ThreadsCreateInviteLink200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadsCreateInviteLink200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadsCreateInviteLink200Response> get serializer => _$ThreadsCreateInviteLink200ResponseSerializer();
}

class _$ThreadsCreateInviteLink200ResponseSerializer implements PrimitiveSerializer<ThreadsCreateInviteLink200Response> {
  @override
  final Iterable<Type> types = const [ThreadsCreateInviteLink200Response, _$ThreadsCreateInviteLink200Response];

  @override
  final String wireName = r'ThreadsCreateInviteLink200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadsCreateInviteLink200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(InviteLinkResponseDto),
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
    ThreadsCreateInviteLink200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadsCreateInviteLink200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(InviteLinkResponseDto),
          ) as InviteLinkResponseDto;
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
  ThreadsCreateInviteLink200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadsCreateInviteLink200ResponseBuilder();
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

class ThreadsCreateInviteLink200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadsCreateInviteLink200ResponseCodeEnum number0 = _$threadsCreateInviteLink200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadsCreateInviteLink200ResponseCodeEnum unknownDefaultOpenApi = _$threadsCreateInviteLink200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadsCreateInviteLink200ResponseCodeEnum> get serializer => _$threadsCreateInviteLink200ResponseCodeEnumSerializer;

  const ThreadsCreateInviteLink200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadsCreateInviteLink200ResponseCodeEnum> get values => _$threadsCreateInviteLink200ResponseCodeEnumValues;
  static ThreadsCreateInviteLink200ResponseCodeEnum valueOf(String name) => _$threadsCreateInviteLink200ResponseCodeEnumValueOf(name);
}
