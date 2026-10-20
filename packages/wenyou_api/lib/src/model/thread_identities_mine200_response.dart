//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/thread_identity_state_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_identities_mine200_response.g.dart';

/// ThreadIdentitiesMine200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadIdentitiesMine200Response implements ApiSuccessEnvelope, Built<ThreadIdentitiesMine200Response, ThreadIdentitiesMine200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ThreadIdentityStateDto get data;

  ThreadIdentitiesMine200Response._();

  factory ThreadIdentitiesMine200Response([void updates(ThreadIdentitiesMine200ResponseBuilder b)]) = _$ThreadIdentitiesMine200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadIdentitiesMine200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadIdentitiesMine200Response> get serializer => _$ThreadIdentitiesMine200ResponseSerializer();
}

class _$ThreadIdentitiesMine200ResponseSerializer implements PrimitiveSerializer<ThreadIdentitiesMine200Response> {
  @override
  final Iterable<Type> types = const [ThreadIdentitiesMine200Response, _$ThreadIdentitiesMine200Response];

  @override
  final String wireName = r'ThreadIdentitiesMine200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadIdentitiesMine200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ThreadIdentityStateDto),
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
    ThreadIdentitiesMine200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadIdentitiesMine200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ThreadIdentityStateDto),
          ) as ThreadIdentityStateDto;
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
  ThreadIdentitiesMine200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadIdentitiesMine200ResponseBuilder();
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

class ThreadIdentitiesMine200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadIdentitiesMine200ResponseCodeEnum number0 = _$threadIdentitiesMine200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadIdentitiesMine200ResponseCodeEnum unknownDefaultOpenApi = _$threadIdentitiesMine200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadIdentitiesMine200ResponseCodeEnum> get serializer => _$threadIdentitiesMine200ResponseCodeEnumSerializer;

  const ThreadIdentitiesMine200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadIdentitiesMine200ResponseCodeEnum> get values => _$threadIdentitiesMine200ResponseCodeEnumValues;
  static ThreadIdentitiesMine200ResponseCodeEnum valueOf(String name) => _$threadIdentitiesMine200ResponseCodeEnumValueOf(name);
}
