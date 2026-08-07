//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_members_exit_member200_response.g.dart';

/// ThreadMembersExitMember200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadMembersExitMember200Response implements ApiSuccessEnvelope, Built<ThreadMembersExitMember200Response, ThreadMembersExitMember200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  ThreadMembersExitMember200Response._();

  factory ThreadMembersExitMember200Response([void updates(ThreadMembersExitMember200ResponseBuilder b)]) = _$ThreadMembersExitMember200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadMembersExitMember200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadMembersExitMember200Response> get serializer => _$ThreadMembersExitMember200ResponseSerializer();
}

class _$ThreadMembersExitMember200ResponseSerializer implements PrimitiveSerializer<ThreadMembersExitMember200Response> {
  @override
  final Iterable<Type> types = const [ThreadMembersExitMember200Response, _$ThreadMembersExitMember200Response];

  @override
  final String wireName = r'ThreadMembersExitMember200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadMembersExitMember200Response object, {
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
    ThreadMembersExitMember200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadMembersExitMember200ResponseBuilder result,
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
  ThreadMembersExitMember200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadMembersExitMember200ResponseBuilder();
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

class ThreadMembersExitMember200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadMembersExitMember200ResponseCodeEnum number0 = _$threadMembersExitMember200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadMembersExitMember200ResponseCodeEnum unknownDefaultOpenApi = _$threadMembersExitMember200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadMembersExitMember200ResponseCodeEnum> get serializer => _$threadMembersExitMember200ResponseCodeEnumSerializer;

  const ThreadMembersExitMember200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadMembersExitMember200ResponseCodeEnum> get values => _$threadMembersExitMember200ResponseCodeEnumValues;
  static ThreadMembersExitMember200ResponseCodeEnum valueOf(String name) => _$threadMembersExitMember200ResponseCodeEnumValueOf(name);
}
