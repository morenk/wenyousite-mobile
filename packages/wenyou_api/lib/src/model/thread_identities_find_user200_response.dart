//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/thread_identity_state_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_identities_find_user200_response.g.dart';

/// ThreadIdentitiesFindUser200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadIdentitiesFindUser200Response implements ApiSuccessEnvelope, Built<ThreadIdentitiesFindUser200Response, ThreadIdentitiesFindUser200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ThreadIdentityStateDto get data;

  ThreadIdentitiesFindUser200Response._();

  factory ThreadIdentitiesFindUser200Response([void updates(ThreadIdentitiesFindUser200ResponseBuilder b)]) = _$ThreadIdentitiesFindUser200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadIdentitiesFindUser200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadIdentitiesFindUser200Response> get serializer => _$ThreadIdentitiesFindUser200ResponseSerializer();
}

class _$ThreadIdentitiesFindUser200ResponseSerializer implements PrimitiveSerializer<ThreadIdentitiesFindUser200Response> {
  @override
  final Iterable<Type> types = const [ThreadIdentitiesFindUser200Response, _$ThreadIdentitiesFindUser200Response];

  @override
  final String wireName = r'ThreadIdentitiesFindUser200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadIdentitiesFindUser200Response object, {
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
    ThreadIdentitiesFindUser200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadIdentitiesFindUser200ResponseBuilder result,
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
  ThreadIdentitiesFindUser200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadIdentitiesFindUser200ResponseBuilder();
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

class ThreadIdentitiesFindUser200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadIdentitiesFindUser200ResponseCodeEnum number0 = _$threadIdentitiesFindUser200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadIdentitiesFindUser200ResponseCodeEnum unknownDefaultOpenApi = _$threadIdentitiesFindUser200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadIdentitiesFindUser200ResponseCodeEnum> get serializer => _$threadIdentitiesFindUser200ResponseCodeEnumSerializer;

  const ThreadIdentitiesFindUser200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadIdentitiesFindUser200ResponseCodeEnum> get values => _$threadIdentitiesFindUser200ResponseCodeEnumValues;
  static ThreadIdentitiesFindUser200ResponseCodeEnum valueOf(String name) => _$threadIdentitiesFindUser200ResponseCodeEnumValueOf(name);
}
