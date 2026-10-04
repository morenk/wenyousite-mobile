//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/thread_identity_state_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_identities_clear200_response.g.dart';

/// ThreadIdentitiesClear200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadIdentitiesClear200Response implements ApiSuccessEnvelope, Built<ThreadIdentitiesClear200Response, ThreadIdentitiesClear200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ThreadIdentityStateDto get data;

  ThreadIdentitiesClear200Response._();

  factory ThreadIdentitiesClear200Response([void updates(ThreadIdentitiesClear200ResponseBuilder b)]) = _$ThreadIdentitiesClear200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadIdentitiesClear200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadIdentitiesClear200Response> get serializer => _$ThreadIdentitiesClear200ResponseSerializer();
}

class _$ThreadIdentitiesClear200ResponseSerializer implements PrimitiveSerializer<ThreadIdentitiesClear200Response> {
  @override
  final Iterable<Type> types = const [ThreadIdentitiesClear200Response, _$ThreadIdentitiesClear200Response];

  @override
  final String wireName = r'ThreadIdentitiesClear200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadIdentitiesClear200Response object, {
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
    ThreadIdentitiesClear200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadIdentitiesClear200ResponseBuilder result,
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
  ThreadIdentitiesClear200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadIdentitiesClear200ResponseBuilder();
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

class ThreadIdentitiesClear200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadIdentitiesClear200ResponseCodeEnum number0 = _$threadIdentitiesClear200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadIdentitiesClear200ResponseCodeEnum unknownDefaultOpenApi = _$threadIdentitiesClear200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadIdentitiesClear200ResponseCodeEnum> get serializer => _$threadIdentitiesClear200ResponseCodeEnumSerializer;

  const ThreadIdentitiesClear200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadIdentitiesClear200ResponseCodeEnum> get values => _$threadIdentitiesClear200ResponseCodeEnumValues;
  static ThreadIdentitiesClear200ResponseCodeEnum valueOf(String name) => _$threadIdentitiesClear200ResponseCodeEnumValueOf(name);
}
