//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:wenyou_api/src/model/message_response_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:wenyou_api/src/model/api_success_envelope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'users_follow_unblock200_response.g.dart';

/// UsersFollowUnblock200Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [data]
@BuiltValue()
abstract class UsersFollowUnblock200Response implements ApiSuccessEnvelope, Built<UsersFollowUnblock200Response, UsersFollowUnblock200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MessageResponseDto get data;

  UsersFollowUnblock200Response._();

  factory UsersFollowUnblock200Response([void updates(UsersFollowUnblock200ResponseBuilder b)]) = _$UsersFollowUnblock200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UsersFollowUnblock200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UsersFollowUnblock200Response> get serializer => _$UsersFollowUnblock200ResponseSerializer();
}

class _$UsersFollowUnblock200ResponseSerializer implements PrimitiveSerializer<UsersFollowUnblock200Response> {
  @override
  final Iterable<Type> types = const [UsersFollowUnblock200Response, _$UsersFollowUnblock200Response];

  @override
  final String wireName = r'UsersFollowUnblock200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UsersFollowUnblock200Response object, {
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
    UsersFollowUnblock200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UsersFollowUnblock200ResponseBuilder result,
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
  UsersFollowUnblock200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UsersFollowUnblock200ResponseBuilder();
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

class UsersFollowUnblock200ResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 0)
  static const UsersFollowUnblock200ResponseCodeEnum number0 = _$usersFollowUnblock200ResponseCodeEnum_number0;
  @BuiltValueEnumConst(wireNumber: 11184809, fallback: true)
  static const UsersFollowUnblock200ResponseCodeEnum unknownDefaultOpenApi = _$usersFollowUnblock200ResponseCodeEnum_unknownDefaultOpenApi;

  static Serializer<UsersFollowUnblock200ResponseCodeEnum> get serializer => _$usersFollowUnblock200ResponseCodeEnumSerializer;

  const UsersFollowUnblock200ResponseCodeEnum._(String name): super(name);

  static BuiltSet<UsersFollowUnblock200ResponseCodeEnum> get values => _$usersFollowUnblock200ResponseCodeEnumValues;
  static UsersFollowUnblock200ResponseCodeEnum valueOf(String name) => _$usersFollowUnblock200ResponseCodeEnumValueOf(name);
}
