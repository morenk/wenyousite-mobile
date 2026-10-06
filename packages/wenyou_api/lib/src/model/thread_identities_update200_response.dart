//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/thread_identity_state_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'thread_identities_update200_response.g.dart';

/// ThreadIdentitiesUpdate200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class ThreadIdentitiesUpdate200Response implements ApiSuccessEnvelope, Built<ThreadIdentitiesUpdate200Response, ThreadIdentitiesUpdate200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ThreadIdentityStateDto get data;

  ThreadIdentitiesUpdate200Response._();

  factory ThreadIdentitiesUpdate200Response([void updates(ThreadIdentitiesUpdate200ResponseBuilder b)]) = _$ThreadIdentitiesUpdate200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ThreadIdentitiesUpdate200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ThreadIdentitiesUpdate200Response> get serializer => _$ThreadIdentitiesUpdate200ResponseSerializer();
}

class _$ThreadIdentitiesUpdate200ResponseSerializer implements PrimitiveSerializer<ThreadIdentitiesUpdate200Response> {
  @override
  final Iterable<Type> types = const [ThreadIdentitiesUpdate200Response, _$ThreadIdentitiesUpdate200Response];

  @override
  final String wireName = r'ThreadIdentitiesUpdate200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ThreadIdentitiesUpdate200Response object, {
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
    ThreadIdentitiesUpdate200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ThreadIdentitiesUpdate200ResponseBuilder result,
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
  ThreadIdentitiesUpdate200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ThreadIdentitiesUpdate200ResponseBuilder();
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

class ThreadIdentitiesUpdate200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const ThreadIdentitiesUpdate200ResponseCodeEnum number0 = _$threadIdentitiesUpdate200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const ThreadIdentitiesUpdate200ResponseCodeEnum unknownDefaultOpenApi = _$threadIdentitiesUpdate200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<ThreadIdentitiesUpdate200ResponseCodeEnum> get serializer => _$threadIdentitiesUpdate200ResponseCodeEnumSerializer;

  const ThreadIdentitiesUpdate200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<ThreadIdentitiesUpdate200ResponseCodeEnum> get values => _$threadIdentitiesUpdate200ResponseCodeEnumValues;
  static ThreadIdentitiesUpdate200ResponseCodeEnum valueOf(String name) => _$threadIdentitiesUpdate200ResponseCodeEnumValueOf(name);
}
